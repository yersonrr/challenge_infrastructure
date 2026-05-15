#!/usr/bin/env bash
set -euo pipefail

service_arn="${1:?App Runner service ARN is required}"
operation_id="${2:?Operation ID is required}"
max_attempts="${3:-60}"
sleep_seconds="${4:-10}"

for attempt in $(seq 1 "${max_attempts}"); do
  status="$(aws apprunner list-operations \
    --service-arn "${service_arn}" \
    --query "OperationSummaryList[?Id=='${operation_id}'].Status | [0]" \
    --output text)"

  echo "Deployment status: ${status} (attempt ${attempt}/${max_attempts})"

  case "${status}" in
    SUCCEEDED)
      aws apprunner describe-service \
        --service-arn "${service_arn}" \
        --query 'Service.{Status:Status,Url:ServiceUrl}' \
        --output table
      exit 0
      ;;
    FAILED | ROLLBACK_SUCCEEDED | ROLLBACK_FAILED)
      aws apprunner list-operations \
        --service-arn "${service_arn}" \
        --max-results 5 \
        --output table
      exit 1
      ;;
  esac

  sleep "${sleep_seconds}"
done

echo "Timed out waiting for App Runner deployment"
exit 1
