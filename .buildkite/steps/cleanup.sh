#!/bin/bash
# shellcheck disable=SC2016
set -euxo pipefail

stack_name=$(buildkite-agent meta-data get stack_name)
cutoff_date=$(date --date='-2 days' +%Y-%m-%d)

echo "--- Deleting stack $stack_name"
aws cloudformation delete-stack --stack-name "$stack_name"

echo "--- Deleting test managed secrets buckets created"
aws s3api list-buckets \
  --output text \
  --query "$(printf '[?CreationDate<`%s`].Name' "$cutoff_date" )" |
  grep -E 'buildkite-aws-stack-test(-\d+)?-managed'

echo "--- Deleting old cloudformation stacks"
aws cloudformation describe-stacks \
  --output text \
  --query "$(printf 'Stacks[?CreationTime<`%s`].StackName' "$cutoff_date" )" |
  grep -E 'buildkite-aws-stack-test-(\d+)'