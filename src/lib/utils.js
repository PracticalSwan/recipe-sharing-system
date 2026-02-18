// Shared utility functions and constants
import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

// Merge class names with Tailwind conflict resolution (cn = classNames)
export function cn(...inputs) {
    return twMerge(clsx(inputs))
}

// Available recipe categories for filters and the create/edit form
export const RECIPE_CATEGORIES = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Italian',
    'Asian',
    'Health'
]

// Supported difficulty levels (maps to DB 'difficulty' column)
export const RECIPE_DIFFICULTIES = [
    'Easy',
    'Medium',
    'Hard'
]

// Normalize a category value to an array (handles string, array, or empty)
export const normalizeCategories = (value) => {
    if (Array.isArray(value)) return value.filter(Boolean)
    if (typeof value === 'string' && value.trim()) return [value]
    return []
}
