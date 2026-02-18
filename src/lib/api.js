// Centralized API client for all backend endpoints
// Usage: import { recipes } from '@/lib/api'; const data = await recipes.list({ page: 1 })

// Base URL from env, with trailing slashes stripped
export const API_BASE = (import.meta.env.VITE_API_BASE_URL || '/api').replace(/\/+$/, '');
const DEFAULT_TIMEOUT_MS = 15000;
const DEFAULT_NETWORK_ERROR_MESSAGE = 'Unable to reach the server. Please check your connection and try again.';

// Pre-built avatar URLs from DiceBear API for user registration
export const DEFAULT_AVATARS = [
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Oliver',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Luna',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Leo',
];

// Custom error class carrying HTTP status and response data
export class ApiError extends Error {
    constructor(message, status = 0, data = null, code = null, cause = null) {
        super(message);
        this.name = 'ApiError';
        this.status = status;
        this.data = data;
        this.code = code;
        if (cause) {
            this.cause = cause;
        }
    }
}

function extractErrorMessage(payload) {
    if (!payload || typeof payload !== 'object') return null;

    if (typeof payload.error === 'string' && payload.error.trim() !== '') {
        return payload.error;
    }

    if (payload.error && typeof payload.error === 'object' && typeof payload.error.message === 'string') {
        return payload.error.message;
    }

    if (typeof payload.message === 'string' && payload.message.trim() !== '') {
        return payload.message;
    }

    return null;
}

function extractErrorCode(payload) {
    if (!payload || typeof payload !== 'object') return null;

    if (typeof payload.code === 'string' && payload.code.trim() !== '') {
        return payload.code;
    }

    if (payload.error && typeof payload.error === 'object' && typeof payload.error.code === 'string') {
        return payload.error.code;
    }

    return null;
}

async function parseResponsePayload(response) {
    const rawBody = await response.text();
    if (!rawBody) {
        return null;
    }

    const contentType = (response.headers.get('content-type') || '').toLowerCase();
    const likelyJson = contentType.includes('application/json') || /^[[{]/.test(rawBody.trim());
    if (!likelyJson) {
        return null;
    }

    try {
        return JSON.parse(rawBody);
    } catch {
        return null;
    }
}

export function getErrorMessage(error, fallback = 'Something went wrong. Please try again.') {
    if (error instanceof ApiError && typeof error.message === 'string' && error.message.trim() !== '') {
        return error.message;
    }
    if (error instanceof Error && typeof error.message === 'string' && error.message.trim() !== '') {
        return error.message;
    }
    return fallback;
}

// Core fetch wrapper: sends JSON requests with credentials and maps errors to ApiError
async function apiFetch(endpoint, options = {}) {
    const url = `${API_BASE}${endpoint}`;
    const { timeoutMs = DEFAULT_TIMEOUT_MS, ...requestOptions } = options;
    const controller = requestOptions.signal ? null : new AbortController();

    const config = {
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json',
            ...requestOptions.headers,
        },
        ...requestOptions,
    };

    if (config.body && typeof config.body === 'object' && !(config.body instanceof FormData)) {
        config.body = JSON.stringify(config.body);
    }

    if (controller) {
        config.signal = controller.signal;
    }

    const timeoutId = controller
        ? setTimeout(() => controller.abort(), Math.max(1, Number(timeoutMs) || DEFAULT_TIMEOUT_MS))
        : null;

    let response;
    try {
        response = await fetch(url, config);
    } catch (error) {
        if (error instanceof DOMException && error.name === 'AbortError') {
            throw new ApiError(
                'The request timed out. Please try again.',
                0,
                null,
                'request_timeout',
                error
            );
        }
        throw new ApiError(
            DEFAULT_NETWORK_ERROR_MESSAGE,
            0,
            null,
            'network_error',
            error instanceof Error ? error : null
        );
    } finally {
        if (timeoutId) {
            clearTimeout(timeoutId);
        }
    }

    const data = await parseResponsePayload(response);

    if (!response.ok) {
        throw new ApiError(
            extractErrorMessage(data) || `Request failed with status ${response.status}`,
            response.status,
            data,
            extractErrorCode(data) || `http_${response.status}`
        );
    }

    return data ?? {};
}

// Build a query string from an object, omitting empty/null values
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

// Auth endpoints
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

// Recipe endpoints
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

// Review endpoints
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

// User endpoints
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

// Search endpoints
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

// Stats endpoints
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

// Activity endpoints
export const activity = {
    async list(params = {}) {
        const res = await apiFetch(`/activity${buildQuery(params)}`);
        return res.data;
    },
};

// Convenience bundle
const api = { auth, recipes, reviews, users, search, stats, activity };
export default api;
