const PASSWORD_MIN_LENGTH = 8;
const PASSWORD_MAX_LENGTH = 128;

const LOWERCASE_PATTERN = /[a-z]/;
const UPPERCASE_PATTERN = /[A-Z]/;
const DIGIT_PATTERN = /[0-9]/;

export interface SafePasswordOptions {
  requireComplexity?: boolean;
}

export class UnsafePasswordError extends Error {
  constructor(message = 'Password is not allowed') {
    super(message);
    this.name = 'UnsafePasswordError';
  }
}

export function assertSafePassword(
  input: string,
  options: SafePasswordOptions = {},
): void {
  if (typeof input !== 'string') {
    throw new UnsafePasswordError('Password must be a string');
  }

  if (input !== input.trim()) {
    throw new UnsafePasswordError(
      'Password must not have leading or trailing whitespace',
    );
  }

  if (/[\u0000-\u001F\u007F]/.test(input)) {
    throw new UnsafePasswordError('Password contains invalid characters');
  }

  if (input.length < PASSWORD_MIN_LENGTH) {
    throw new UnsafePasswordError(
      `Password must be at least ${PASSWORD_MIN_LENGTH} characters`,
    );
  }

  if (input.length > PASSWORD_MAX_LENGTH) {
    throw new UnsafePasswordError(
      `Password must not exceed ${PASSWORD_MAX_LENGTH} characters`,
    );
  }

  if (options.requireComplexity) {
    if (!LOWERCASE_PATTERN.test(input)) {
      throw new UnsafePasswordError('Password must include a lowercase letter');
    }

    if (!UPPERCASE_PATTERN.test(input)) {
      throw new UnsafePasswordError(
        'Password must include an uppercase letter',
      );
    }

    if (!DIGIT_PATTERN.test(input)) {
      throw new UnsafePasswordError('Password must include a number');
    }
  }
}

export function isSafePassword(
  input: string,
  options: SafePasswordOptions = {},
): boolean {
  try {
    assertSafePassword(input, options);
    return true;
  } catch {
    return false;
  }
}
