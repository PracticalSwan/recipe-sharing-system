// Authentication context: manages global auth state, session persistence, and user interactions
import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import api, { getErrorMessage } from '../lib/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    // Check for existing session on mount
    useEffect(() => {
        let cancelled = false;
        api.auth.me()
            .then((data) => {
                if (!cancelled) setUser(data.user);
            })
            .catch(() => {
                // No active session
            })
            .finally(() => {
                if (!cancelled) setLoading(false);
            });
        return () => { cancelled = true; };
    }, []);

    // Send heartbeat every 60s to keep session alive
    useEffect(() => {
        if (!user?.id) return;

        const heartbeat = setInterval(() => {
            api.auth.heartbeat().catch(() => {});
        }, 60 * 1000);

        return () => clearInterval(heartbeat);
    }, [user?.id]);

    // Re-fetch user data (used after favorite toggles)
    const refreshUser = useCallback(async () => {
        try {
            const data = await api.auth.me();
            setUser(data.user);
        } catch { /* ignore */ }
    }, []);

    // Listen for favorite toggle events from recipe components
    useEffect(() => {
        window.addEventListener('favoriteToggled', refreshUser);
        return () => window.removeEventListener('favoriteToggled', refreshUser);
    }, [refreshUser]);

    // Log in user with email and password
    const login = async (email, password) => {
        try {
            const loggedUser = await api.auth.login(email, password);
            setUser(loggedUser);
            return { success: true };
        } catch (error) {
            return { success: false, error: getErrorMessage(error, 'Login failed. Please try again.') };
        }
    };

    // Log out current user and clear state
    const logout = async () => {
        try {
            await api.auth.logout();
        } catch { /* ignore */ }
        setUser(null);
    };

    // Register new user account
    const signup = async (userData) => {
        const registeredUser = await api.auth.register(userData);
        setUser(registeredUser);
    };

    // Update current user's profile data
    const updateProfile = async (updates) => {
        if (!user) return;
        const updatedUser = await api.users.update(user.id, updates);
        setUser(updatedUser);
    };

    // Computed auth states for easy access in components
    const isAdmin = user?.role === 'admin';
    const isPending = user?.status === 'pending';
    const isSuspended = user?.status === 'suspended';
    const canInteract = Boolean(user && user.status === 'active' && !isAdmin);

    const value = {
        user,
        loading,
        isAdmin,
        isPending,
        isSuspended,
        canInteract,
        login,
        logout,
        signup,
        updateProfile,
        refreshUser,
    };

    return (
        <AuthContext.Provider value={value}>
            {!loading && children}
        </AuthContext.Provider>
    );
}

// Hook to access auth context (must be used inside AuthProvider)
// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
}
