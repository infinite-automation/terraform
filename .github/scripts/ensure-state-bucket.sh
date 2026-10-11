#!/usr/bin/env bash
set -euo pipefail

region="us-east-1"
account_id=$(aws sts get-caller-identity --query Account --output text)
parameter="/github/${GITHUB_REPOSITORY}/java-demo-eks/state-bucket"
bucket="${TF_STATE_BUCKET:-}"
save_parameter=false
error_file=$(mktemp)
trap 'rm -f "$error_file"' EXIT

if [[ -z "$bucket" ]]; then
  if bucket=$(aws ssm get-parameter --region "$region" --name "$parameter" \
    --query Parameter.Value --output text 2>"$error_file"); then
    echo "Reusing state bucket: $bucket"
  elif [[ $(cat "$error_file") == *"(ParameterNotFound)"* ]]; then
    # The first commit names the bucket; later commits reuse the saved name.
    bucket="tfstate-${account_id}-${GITHUB_SHA}"
    save_parameter=true
  else
    cat "$error_file" >&2
    exit 1
  fi
fi

if ! aws s3api head-bucket --bucket "$bucket" --expected-bucket-owner "$account_id" 2>"$error_file"; then
  if [[ $(cat "$error_file") == *"(404)"* ]]; then
    aws s3api create-bucket --bucket "$bucket" --region "$region"
    aws s3api wait bucket-exists --bucket "$bucket" --expected-bucket-owner "$account_id"
  else
    cat "$error_file" >&2
    exit 1
  fi
fi

aws s3api put-public-access-block --bucket "$bucket" --expected-bucket-owner "$account_id" \
  --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'
aws s3api put-bucket-versioning --bucket "$bucket" --expected-bucket-owner "$account_id" \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "$bucket" --expected-bucket-owner "$account_id" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

if [[ "$save_parameter" == true ]]; then
  # Do not overwrite an existing pointer to another state bucket.
  aws ssm put-parameter --region "$region" --name "$parameter" --type String --value "$bucket"
fi

echo "bucket=$bucket" >> "$GITHUB_OUTPUT"
echo "Terraform state bucket: $bucket"
