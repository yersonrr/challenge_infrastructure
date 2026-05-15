const EMAIL_MAX_LENGTH = 320;

const EMAIL_PATTERN =
  /^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$/;

export class UnsafeEmailError extends Error {
  constructor(message = 'Email is not allowed') {
    super(message);
    this.name = 'UnsafeEmailError';
  }
}

export function assertSafeEmail(input: string): void {
  if (typeof input !== 'string') {
    throw new UnsafeEmailError('Email must be a string');
  }

  const normalized = normalizeSafeEmail(input);

  if (normalized.length > EMAIL_MAX_LENGTH) {
    throw new UnsafeEmailError(
      `Email must not exceed ${EMAIL_MAX_LENGTH} characters`,
    );
  }

  if (/[\u0000-\u001F\u007F]/.test(input)) {
    throw new UnsafeEmailError('Email contains invalid characters');
  }

  if (/\s/.test(normalized)) {
    throw new UnsafeEmailError('Email must not contain whitespace');
  }

  if (!EMAIL_PATTERN.test(normalized)) {
    throw new UnsafeEmailError('Email format is invalid');
  }

  const [localPart, domain] = normalized.split('@');
  if (!localPart || !domain || normalized.split('@').length > 2) {
    throw new UnsafeEmailError('Email format is invalid');
  }

  if (
    localPart.startsWith('.') ||
    localPart.endsWith('.') ||
    localPart.includes('..')
  ) {
    throw new UnsafeEmailError('Email local part is invalid');
  }

  if (domain.startsWith('.') || domain.endsWith('.') || domain.includes('..')) {
    throw new UnsafeEmailError('Email domain is invalid');
  }
}

export function normalizeSafeEmail(input: string): string {
  if (typeof input !== 'string') {
    throw new UnsafeEmailError('Email must be a string');
  }

  return input.trim().toLowerCase();
}

export function isSafeEmail(input: string): boolean {
  try {
    assertSafeEmail(input);
    return true;
  } catch {
    return false;
  }
}
