import React, { useEffect } from 'react';
import { createPortal } from 'react-dom';
import { X } from 'lucide-react';
import { cn } from '../../lib/utils';
import { Button } from './Button';

export function Modal({
    isOpen,
    onClose,
    title,
    children,
    className,
    closeOnOverlayClick = true,
    closeOnEscape = true,
}) {
    useEffect(() => {
        const handleEscape = (e) => {
            if (closeOnEscape && e.key === 'Escape') onClose();
        };

        if (isOpen) {
            document.body.style.overflow = 'hidden';
            window.addEventListener('keydown', handleEscape);
        }

        return () => {
            document.body.style.overflow = 'unset';
            window.removeEventListener('keydown', handleEscape);
        };
    }, [isOpen, onClose, closeOnEscape]);

    if (!isOpen) return null;

    return createPortal(
        <div 
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm transition-opacity"
            onClick={closeOnOverlayClick ? onClose : undefined}
        >
            <div 
                className={cn("relative w-full max-w-lg transform overflow-hidden rounded-xl bg-white p-6 shadow-2xl transition-all", className)}
                role="dialog"
                aria-modal="true"
                onClick={(e) => e.stopPropagation()}
            >
                <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-semibold leading-6 text-cool-gray-90">
                        {title}
                    </h3>
                    <Button variant="ghost" size="icon" onClick={onClose} className="h-8 w-8 rounded-full" aria-label="Close modal">
                        <X className="h-4 w-4" />
                    </Button>
                </div>
                <div>
                    {children}
                </div>
            </div>
        </div>,
        document.body
    );
}
