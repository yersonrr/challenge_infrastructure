import {
  registerDecorator,
  type ValidationArguments,
  type ValidationOptions,
} from 'class-validator';
import { isSafeHttpUrl } from './safe-http-url';

export function IsSafeHttpUrl(validationOptions?: ValidationOptions) {
  return function registerIsSafeHttpUrl(object: object, propertyName: string) {
    registerDecorator({
      name: 'isSafeHttpUrl',
      target: object.constructor,
      propertyName,
      options: validationOptions,
      validator: {
        validate(value: unknown): boolean {
          return typeof value === 'string' && isSafeHttpUrl(value);
        },
        defaultMessage(args: ValidationArguments) {
          return `${args.property} must be a valid public http(s) URL`;
        },
      },
    });
  };
}
