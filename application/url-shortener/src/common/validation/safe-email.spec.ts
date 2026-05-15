import { assertSafeEmail, isSafeEmail, normalizeSafeEmail } from './safe-email';

describe('safe-email', () => {
  it('accepts valid emails and normalizes casing', () => {
    expect(isSafeEmail('  User@Example.COM  ')).toBe(true);
    expect(normalizeSafeEmail('  User@Example.COM  ')).toBe('user@example.com');
  });

  it('rejects malformed addresses', () => {
    expect(isSafeEmail('not-an-email')).toBe(false);
    expect(isSafeEmail('user@@example.com')).toBe(false);
    expect(isSafeEmail('.user@example.com')).toBe(false);
    expect(isSafeEmail('user@example..com')).toBe(false);
  });

  it('rejects control characters and embedded whitespace', () => {
    expect(isSafeEmail('user name@example.com')).toBe(false);
    expect(() => assertSafeEmail('user@example.com\n')).toThrow();
  });
});
