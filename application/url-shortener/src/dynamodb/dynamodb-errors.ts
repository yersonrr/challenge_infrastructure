import { TransactionCanceledException } from '@aws-sdk/client-dynamodb';

export function isConditionalCheckFailed(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'name' in error &&
    error.name === 'ConditionalCheckFailedException'
  );
}

export function isTransactionCanceledDueToConditionalCheck(error: unknown): boolean {
  if (!(error instanceof TransactionCanceledException)) {
    return false;
  }

  return (
    error.CancellationReasons?.some((reason) => reason.Code === 'ConditionalCheckFailed') ??
    false
  );
}
