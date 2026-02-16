/**
 * Styled text input with label and validation error display.
 * Supports aria-invalid / aria-describedby for accessible error states.
 */
import { cn } from '../../lib/utils';

export function Input({
    label,
    error,
    className,
    id,
    type = "text",
    required,
    ...props
}) {
    const errorId = id ? `${id}-error` : undefined;

    return (
        <div className="w-full">
            {label && (
                <label htmlFor={id} className="block text-sm font-medium text-cool-gray-60 mb-1">
                    {label}
                    {required && <span className="text-red-500 ml-1" aria-hidden="true">*</span>}
                </label>
            )}
            <input
                id={id}
                type={type}
                required={required}
                aria-invalid={error ? "true" : undefined}
                aria-describedby={error ? errorId : undefined}
                className={cn(
                    "flex h-10 w-full rounded-md border border-cool-gray-30 bg-white px-3 py-2 text-sm placeholder:text-cool-gray-30 focus:outline-none focus:ring-2 focus:ring-cool-gray-90 focus:border-transparent disabled:cursor-not-allowed disabled:opacity-50 transition-all",
                    error && "border-red-500 focus:ring-red-500",
                    className
                )}
                {...props}
            />
            {error && (
                <p id={errorId} className="mt-1 text-xs text-red-500" role="alert">
                    {error}
                </p>
            )}
        </div>
    );
}
