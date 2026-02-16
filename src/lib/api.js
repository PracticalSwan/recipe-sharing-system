/**
 * Centralized API client for all backend endpoints.
 * File: src/lib/api.js
 *
 * Exports domain-specific modules (auth, recipes, reviews, users, search,
 * stats, activity) that wrap apiFetch() — a thin fetch wrapper handling
 * JSON serialization, credentials (HttpOnly cookies), and error mapping.
 *
 * Usage:  import { recipes } from '@/lib/api'
 *         const data = await recipes.list({ page: 1 })
 */

// Base URL from env, with trailing slashes stripped
export const API_BASE = (import.meta.env.VITE_API_BASE_URL || '/api').replace(/\/+$/, '');

/** Pre-built avatar URLs from DiceBear API for user registration */
export const DEFAULT_AVATARS = [
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Oliver',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Luna',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Leo',
];

/** Custom error class carrying HTTP status and response data */
class ApiError extends Error {
    constructor(message, status, data = null) {
        super(message);
        this.name = 'ApiError';
        this.status = status;
        this.data = data;
    }
}

/**
 * Core fetch wrapper. Sends JSON requests with credentials (HttpOnly session
 * cookie) and maps non-2xx responses to ApiError.
 */
async function apiFetch(endpoint, options = {}) {
    const url = `${API_BASE}${endpoint}`;
    const config = {
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json',
            ...options.headers,
        },
        ...options,
    };

    if (config.body && typeof config.body === 'object' && !(config.body instanceof FormData)) {
        config.body = JSON.stringify(config.body);
    }

    const response = await fetch(url, config);
    const data = await response.json().catch(() => null);

    if (!response.ok) {
        throw new ApiError(
            data?.error || `Request failed with status ${response.status}`,
            response.status,
            data
        );
    }

    return data;
}

/** Build a query string from an object, omitting empty/null values */
function buildQuery(params) {
    const query = new URLSearchParams();
    for (const [key, value] of Object.entries(params)) {
        if (value !== undefined && value !== null && value !== '') {
            query.append(key, value);
        }
    }
    const str = query.toString();
    return str ? `?${str}` : '';
}

// ─── Auth ──────────────────────────────────────────────────────────────────────

export const auth = {
    async login(email, password) {
        const res = await apiFetch('/auth/login', {
            method: 'POST',
            body: { email, password },
        });
        return res.data.user;
    },

    async register(userData) {
        const res = await apiFetch('/auth/register', {
            method: 'POST',
            body: userData,
        });
        return res.data.user;
    },

    async logout() {
        await apiFetch('/auth/logout', { method: 'POST' });
    },

    async me() {
        const res = await apiFetch('/auth/me');
        return res.data;
    },

    async heartbeat() {
        await apiFetch('/auth/heartbeat', { method: 'POST' });
    },
};

// ─── Recipes ───────────────────────────────────────────────────────────────────

export const recipes = {
    async list(params = {}) {
        const res = await apiFetch(`/recipes${buildQuery(params)}`);
        return res.data;
    },

    async get(id) {
        const res = await apiFetch(`/recipes/${id}`);
        return res.data;
    },

    async create(data) {
        const res = await apiFetch('/recipes', {
            method: 'POST',
            body: data,
        });
        return res.data;
    },

    async update(id, data) {
        const res = await apiFetch(`/recipes/${id}`, {
            method: 'PUT',
            body: data,
        });
        return res.data;
    },

    async delete(id) {
        await apiFetch(`/recipes/${id}`, { method: 'DELETE' });
    },

    async updateStatus(id, status) {
        const res = await apiFetch(`/recipes/${id}/status`, {
            method: 'PUT',
            body: { status },
        });
        return res.data;
    },

    async toggleLike(id) {
        const res = await apiFetch(`/recipes/${id}/like`, { method: 'POST' });
        return res.data;
    },

    async toggleFavorite(id) {
        const res = await apiFetch(`/recipes/${id}/favorite`, { method: 'POST' });
        return res.data;
    },

    async recordView(id) {
        const res = await apiFetch(`/recipes/${id}/view`, { method: 'POST' });
        return res.data;
    },
};

// ─── Reviews ───────────────────────────────────────────────────────────────────

export const reviews = {
    async list(recipeId) {
        const res = await apiFetch(`/reviews?recipeId=${recipeId}`);
        return res.data;
    },

    async create(data) {
        const res = await apiFetch('/reviews', {
            method: 'POST',
            body: data,
        });
        return res.data;
    },

    async update(id, data) {
        const res = await apiFetch(`/reviews/${id}`, {
            method: 'PUT',
            body: data,
        });
        return res.data;
    },

    async delete(id) {
        await apiFetch(`/reviews/${id}`, { method: 'DELETE' });
    },
};

// ─── Users ─────────────────────────────────────────────────────────────────────

export const users = {
    async list(params = {}) {
        const res = await apiFetch(`/users${buildQuery(params)}`);
        return res.data;
    },

    async get(id) {
        const res = await apiFetch(`/users/${id}`);
        return res.data;
    },

    async update(id, data) {
        const res = await apiFetch(`/users/${id}`, {
            method: 'PUT',
            body: data,
        });
        return res.data;
    },

    async delete(id) {
        await apiFetch(`/users/${id}`, { method: 'DELETE' });
    },

    async updateStatus(id, status) {
        const res = await apiFetch(`/users/${id}/status`, {
            method: 'PUT',
            body: { status },
        });
        return res.data;
    },
};

// ─── Search ────────────────────────────────────────────────────────────────────

export const search = {
    async recipes(params = {}) {
        const res = await apiFetch(`/search${buildQuery(params)}`);
        return res.data;
    },

    async getHistory() {
        const res = await apiFetch('/search/history');
        return res.data;
    },

    async saveHistory(data) {
        const res = await apiFetch('/search/history', {
            method: 'POST',
            body: data,
        });
        return res.data;
    },

    async clearHistory() {
        await apiFetch('/search/history', { method: 'DELETE' });
    },

    async deleteHistoryItem(id) {
        await apiFetch(`/search/history/${id}`, { method: 'DELETE' });
    },
};

// ─── Stats ─────────────────────────────────────────────────────────────────────

export const stats = {
    async dashboard() {
        const res = await apiFetch('/stats/dashboard');
        return res.data;
    },

    async daily(days = 30) {
        const res = await apiFetch(`/stats/daily?days=${days}`);
        return res.data;
    },
};

// ─── Activity ──────────────────────────────────────────────────────────────────

export const activity = {
    async list(params = {}) {
        const res = await apiFetch(`/activity${buildQuery(params)}`);
        return res.data;
    },
};

// ─── Convenience bundle ────────────────────────────────────────────────────────

const api = { auth, recipes, reviews, users, search, stats, activity };
export default api;
