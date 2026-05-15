const MAX_URL_LENGTH = 2048;
const ALLOWED_PROTOCOLS = new Set(['http:', 'https:']);

const BLOCKED_HOSTNAMES = new Set([
  'localhost',
  '0.0.0.0',
  'metadata.google.internal',
  'metadata.google',
]);

const PRIVATE_IPV4_PREFIXES = [
  /^127\./,
  /^10\./,
  /^192\.168\./,
  /^172\.(1[6-9]|2\d|3[01])\./,
  /^169\.254\./,
  /^0\./,
  /^100\.(6[4-9]|[7-9]\d|1[01]\d|12[0-7])\./,
  /^198\.(1[89])\./,
];

export class UnsafeHttpUrlError extends Error {
  constructor(message = 'URL is not allowed') {
    super(message);
    this.name = 'UnsafeHttpUrlError';
  }
}

export function assertSafeHttpUrl(input: string): void {
  if (typeof input !== 'string') {
    throw new UnsafeHttpUrlError('URL must be a string');
  }

  const trimmed = input.trim();
  if (!trimmed) {
    throw new UnsafeHttpUrlError('URL must not be empty');
  }

  if (trimmed.length > MAX_URL_LENGTH) {
    throw new UnsafeHttpUrlError(
      `URL must not exceed ${MAX_URL_LENGTH} characters`,
    );
  }

  if (/[\u0000-\u001F\u007F]/.test(trimmed) || trimmed.includes('\\')) {
    throw new UnsafeHttpUrlError('URL contains invalid characters');
  }

  let parsed: URL;
  try {
    parsed = new URL(trimmed);
  } catch {
    throw new UnsafeHttpUrlError('URL is malformed');
  }

  if (!ALLOWED_PROTOCOLS.has(parsed.protocol)) {
    throw new UnsafeHttpUrlError('Only http and https URLs are allowed');
  }

  if (parsed.username || parsed.password) {
    throw new UnsafeHttpUrlError(
      'URLs with embedded credentials are not allowed',
    );
  }

  const hostname = parsed.hostname.toLowerCase();
  if (!hostname) {
    throw new UnsafeHttpUrlError('URL must include a hostname');
  }

  if (BLOCKED_HOSTNAMES.has(hostname) || hostname.endsWith('.localhost')) {
    throw new UnsafeHttpUrlError('URL hostname is not allowed');
  }

  if (isPrivateOrLocalAddress(hostname)) {
    throw new UnsafeHttpUrlError(
      'Private and local network URLs are not allowed',
    );
  }
}

export function normalizeSafeHttpUrl(input: string): string {
  assertSafeHttpUrl(input);
  return new URL(input.trim()).href;
}

export function isSafeHttpUrl(input: string): boolean {
  try {
    assertSafeHttpUrl(input);
    return true;
  } catch {
    return false;
  }
}

function isPrivateOrLocalAddress(hostname: string): boolean {
  const lower = hostname.toLowerCase();

  if (
    lower === '::1' ||
    lower.startsWith('fe80:') ||
    lower.startsWith('fc') ||
    lower.startsWith('fd')
  ) {
    return true;
  }

  if (lower.endsWith('.internal')) {
    return true;
  }

  if (/^\d{1,3}(\.\d{1,3}){3}$/.test(lower)) {
    return PRIVATE_IPV4_PREFIXES.some((pattern) => pattern.test(lower));
  }

  return false;
}
