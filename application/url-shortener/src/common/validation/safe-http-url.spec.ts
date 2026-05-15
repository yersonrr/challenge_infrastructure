import {
  assertSafeHttpUrl,
  isSafeHttpUrl,
  normalizeSafeHttpUrl,
} from './safe-http-url';

describe('safe-http-url', () => {
  it('accepts valid public https URLs', () => {
    expect(isSafeHttpUrl('https://example.com/path?q=1')).toBe(true);
    expect(normalizeSafeHttpUrl('https://example.com/path')).toBe(
      'https://example.com/path',
    );
  });

  it('rejects non-http(s) protocols', () => {
    expect(isSafeHttpUrl('javascript:alert(1)')).toBe(false);
    expect(isSafeHttpUrl('data:text/html,hello')).toBe(false);
    expect(isSafeHttpUrl('file:///etc/passwd')).toBe(false);
  });

  it('rejects localhost and private networks', () => {
    expect(isSafeHttpUrl('http://localhost/admin')).toBe(false);
    expect(isSafeHttpUrl('http://127.0.0.1/')).toBe(false);
    expect(isSafeHttpUrl('http://192.168.1.1/')).toBe(false);
    expect(isSafeHttpUrl('http://10.0.0.5/')).toBe(false);
    expect(isSafeHttpUrl('http://169.254.169.254/')).toBe(false);
  });

  it('rejects URLs with credentials', () => {
    expect(isSafeHttpUrl('https://user:pass@example.com')).toBe(false);
  });

  it('rejects control characters and backslashes', () => {
    expect(isSafeHttpUrl('https://example.com/\x00evil')).toBe(false);
    expect(isSafeHttpUrl('https://example.com\\@evil.com')).toBe(false);
  });

  it('rejects URLs that exceed max length', () => {
    const longPath = 'a'.repeat(2048);
    expect(() =>
      assertSafeHttpUrl(`https://example.com/${longPath}`),
    ).toThrow();
  });
});
