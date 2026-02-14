import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import api from '../lib/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    // Check session on mount
    useEffect(() => {
        let cancelled = false;
        api.auth.me()
            .then((data) => {
                if (!cancelled) setUser(data.user);
            })
            .catch(() => {
                // No active session – stay logged out
            })
            .finally(() => {
                if (!cancelled) setLoading(false);
            });
        return () => { cancelled = true; };
    }, []);

    // Heartbeat interval while logged in
    useEffect(() => {
        if (!user?.id) return;

        const heartbeat = setInterval(() => {
            api.auth.heartbeat().catch(() => {});
        }, 60 * 1000);

        return () => clearInterval(heartbeat);
    }, [user?.id]);

    // Re-fetch user to sync favorites after toggle
    const refreshUser = useCallback(async () => {
        try {
            const data = await api.auth.me();
            setUser(data.user);
        } catch { /* ignore */ }
    }, []);

    useEffect(() => {
        if (!user?.id) return;

        const syncCurrentUser = () => refreshUser();
        window.addEventListener('favoriteToggled', syncCurrentUser);
        return () => window.removeEventListener('favoriteToggled', syncCurrentUser);
    }, [user?.id, refreshUser]);

    const login = async (email, password) => {
        try {
            const loggedUser = await api.auth.login(email, password);
            setUser(loggedUser);
            return { success: true };
        } catch (error) {
            return { success: false, error: error.message };
        }
    };

    const logout = async () => {
        try {
            await api.auth.logout();
        } catch { /* ignore */ }
        setUser(null);
    };

    const signup = async (userData) => {
        const registeredUser = await api.auth.register(userData);
        setUser(registeredUser);
    };

    const updateProfile = async (updates) => {
        if (!user) return;
        const updatedUser = await api.users.update(user.id, updates);
        setUser(updatedUser);
    };

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

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
}
