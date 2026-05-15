import {
  registerDecorator,
  type ValidationArguments,
  type ValidationOptions,
} from 'class-validator';
import { isSafeEmail } from './safe-email';

export function IsSafeEmail(validationOptions?: ValidationOptions) {
  return function registerIsSafeEmail(object: object, propertyName: string) {
    registerDecorator({
      name: 'isSafeEmail',
      target: object.constructor,
      propertyName,
      options: validationOptions,
      validator: {
        validate(value: unknown): boolean {
          return typeof value === 'string' && isSafeEmail(value);
        },
        defaultMessage(args: ValidationArguments) {
          return `${args.property} must be a valid email address`;
        },
      },
    });
  };
}
