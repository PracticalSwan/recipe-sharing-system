/**
 * Controlled / uncontrolled tab primitives using React context.
 * Components: Tabs (root), TabsList, TabsTrigger, TabsContent.
 * Supports both `value + onValueChange` (controlled) and
 * `defaultValue` (uncontrolled) patterns.
 */
import { createContext, useContext, useState, useId } from 'react';
import { cn } from '../../lib/utils';

const TabsContext = createContext(null);

export function Tabs({ defaultValue, value, onValueChange, children, className }) {
    const [localValue, setLocalValue] = useState(defaultValue);
    const currentValue = value ?? localValue;
    const onChange = onValueChange ?? setLocalValue;
    const baseId = useId();

    return (
        <TabsContext.Provider value={{ value: currentValue, onChange, baseId }}>
            <div className={cn("w-full", className)}>
                {children}
            </div>
        </TabsContext.Provider>
    );
}

export function TabsList({ className, children }) {
    const context = useContext(TabsContext);

    const handleKeyDown = (e) => {
        if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;

        const triggers = Array.from(e.currentTarget.querySelectorAll('[role="tab"]'));
        const activeIndex = triggers.findIndex(t => t.getAttribute('aria-selected') === 'true');

        if (activeIndex === -1) return;

        let nextIndex;
        if (e.key === 'ArrowRight') {
            nextIndex = (activeIndex + 1) % triggers.length;
        } else if (e.key === 'ArrowLeft') {
            nextIndex = (activeIndex - 1 + triggers.length) % triggers.length;
        }

        e.preventDefault();
        const nextTrigger = triggers[nextIndex];
        const nextValue = nextTrigger.getAttribute('data-value');

        context.onChange(nextValue);
        // Delay focus slightly to ensure React has updated the tabIndex
        setTimeout(() => nextTrigger.focus(), 0);
    };

    return (
        <div
            role="tablist"
            aria-orientation="horizontal"
            onKeyDown={handleKeyDown}
            className={cn("inline-flex h-10 items-center justify-center rounded-md bg-cool-gray-10 p-1 text-cool-gray-60", className)}
        >
            {children}
        </div>
    );
}

export function TabsTrigger({ value, children, className }) {
    const { value: activeValue, onChange, baseId } = useContext(TabsContext);
    const isActive = activeValue === value;
    const tabId = `${baseId}-tab-${value}`;
    const panelId = `${baseId}-panel-${value}`;

    return (
        <button
            type="button"
            role="tab"
            id={tabId}
            data-value={value}
            aria-selected={isActive}
            aria-controls={panelId}
            tabIndex={isActive ? 0 : -1}
            className={cn(
                "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 text-sm font-medium ring-offset-white transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-cool-gray-90 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 cursor-pointer",
                isActive && "bg-white text-cool-gray-90 shadow-sm",
                className
            )}
            onClick={() => onChange(value)}
        >
            {children}
        </button>
    );
}

export function TabsContent({ value, children, className }) {
    const { value: activeValue, baseId } = useContext(TabsContext);

    if (activeValue !== value) return null;

    const tabId = `${baseId}-tab-${value}`;
    const panelId = `${baseId}-panel-${value}`;

    return (
        <div
            role="tabpanel"
            id={panelId}
            aria-labelledby={tabId}
            tabIndex={0}
            className={cn("mt-2 ring-offset-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-cool-gray-90 focus-visible:ring-offset-2", className)}
        >
            {children}
        </div>
    );
}
