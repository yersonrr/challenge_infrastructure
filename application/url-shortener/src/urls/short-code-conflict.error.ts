export class ShortCodeConflictError extends Error {
  constructor() {
    super('Short code already exists');
    this.name = 'ShortCodeConflictError';
  }
}
