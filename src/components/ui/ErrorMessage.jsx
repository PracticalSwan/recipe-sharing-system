/**
 * Inline error message with optional retry button.
 * Used for data-fetching failures inside page sections.
 */
import React from 'react';
import { AlertCircle } from 'lucide-react';
import { Button } from './Button';

export function ErrorMessage({ message = 'Something went wrong', onRetry }) {
    return (
        <div className="flex flex-col items-center justify-center gap-3 p-6 text-center">
            <AlertCircle className="h-10 w-10 text-red-500" />
            <p className="text-sm text-cool-gray-60">{message}</p>
            {onRetry && (
                <Button variant="outline" size="sm" onClick={onRetry}>
                    Try Again
                </Button>
            )}
        </div>
    );
}
