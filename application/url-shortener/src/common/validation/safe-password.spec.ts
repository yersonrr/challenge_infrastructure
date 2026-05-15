import { isSafePassword } from './safe-password';

describe('safe-password', () => {
  it('accepts passwords within length bounds for login', () => {
    expect(isSafePassword('password123')).toBe(true);
    expect(isSafePassword('Password1')).toBe(true);
  });

  it('requires complexity for signup-style validation', () => {
    expect(isSafePassword('password123', { requireComplexity: true })).toBe(
      false,
    );
    expect(isSafePassword('Password1', { requireComplexity: true })).toBe(true);
  });

  it('rejects invalid characters and whitespace padding', () => {
    expect(isSafePassword(' shortpass ')).toBe(false);
    expect(isSafePassword('pass\x00word')).toBe(false);
    expect(isSafePassword('short')).toBe(false);
  });
});
