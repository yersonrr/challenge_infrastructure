import {
  registerDecorator,
  type ValidationArguments,
  type ValidationOptions,
} from 'class-validator';
import { type SafePasswordOptions, isSafePassword } from './safe-password';

export function IsSafePassword(
  passwordOptions: SafePasswordOptions = {},
  validationOptions?: ValidationOptions,
) {
  return function registerIsSafePassword(object: object, propertyName: string) {
    registerDecorator({
      name: 'isSafePassword',
      target: object.constructor,
      propertyName,
      constraints: [passwordOptions],
      options: validationOptions,
      validator: {
        validate(value: unknown, args: ValidationArguments): boolean {
          const [options] = args.constraints as [SafePasswordOptions];
          return typeof value === 'string' && isSafePassword(value, options);
        },
        defaultMessage(args: ValidationArguments) {
          const [options] = args.constraints as [SafePasswordOptions];
          if (options.requireComplexity) {
            return `${args.property} must be 8-128 characters and include uppercase, lowercase, and a number`;
          }

          return `${args.property} must be 8-128 characters`;
        },
      },
    });
  };
}
