import { TransactionCanceledException } from '@aws-sdk/client-dynamodb';
import {
  isConditionalCheckFailed,
  isTransactionCanceledDueToConditionalCheck,
} from './dynamodb-errors';

describe('dynamodb-errors', () => {
  it('detects conditional check failures on put', () => {
    expect(isConditionalCheckFailed({ name: 'ConditionalCheckFailedException' })).toBe(true);
    expect(isConditionalCheckFailed(new Error('other'))).toBe(false);
  });

  it('detects conditional check failures in transactions', () => {
    const error = new TransactionCanceledException({
      message: 'Transaction cancelled',
      CancellationReasons: [{ Code: 'ConditionalCheckFailed' }],
      $metadata: {},
    });

    expect(isTransactionCanceledDueToConditionalCheck(error)).toBe(true);
  });
});
