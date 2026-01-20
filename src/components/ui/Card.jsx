import { twMerge } from 'tailwind-merge';
import { clsx } from 'clsx';

export function Card({ className, children, ...props }) {
    return (
        <div
            className={twMerge(clsx("rounded-xl border border-cool-gray-20 bg-white text-cool-gray-90 shadow-sm", className))}
            {...props}
        >
            {children}
        </div>
    );
}

export function CardHeader({ className, children, ...props }) {
    return (
        <div className={twMerge(clsx("flex flex-col space-y-1.5 p-6", className))} {...props}>
            {children}
        </div>
    );
}

export function CardTitle({ className, children, ...props }) {
    return (
        <div className={twMerge(clsx("font-semibold leading-none tracking-tight", className))} {...props}>
            {children}
        </div>
    );
}

export function CardContent({ className, children, ...props }) {
    return (
        <div className={twMerge(clsx("p-6 pt-0", className))} {...props}>
            {children}
        </div>
    );
}

export function CardFooter({ className, children, ...props }) {
    return (
        <div className={twMerge(clsx("flex items-center p-6 pt-0", className))} {...props}>
            {children}
        </div>
    );
}
