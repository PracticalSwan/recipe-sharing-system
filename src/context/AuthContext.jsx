/**
 * Authentication context and provider.
 * File: src/context/AuthContext.jsx
 *
 * Manages the global auth state for the entire app. On mount, checks for
 * an existing session via GET /auth/me. While logged in, sends a heartbeat
 * every 60 seconds to keep the session alive. Listens for 'favoriteToggled'
 * events to re-sync the user's favorite list.
 *
 * Exports:
 *   <AuthProvider>  — wrap the app tree to enable auth
 *   useAuth()       — hook returning { user, login, logout, signup, ... }
 */
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import api from '../lib/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    // Check for existing session on initial mount
    useEffect(() => {
        let cancelled = false;
        api.auth.me()
            .then((data) => {
                if (!cancelled) setUser(data.user);
            })
            .catch(() => {
                // No active session — user stays logged out
            })
            .finally(() => {
                if (!cancelled) setLoading(false);
            });
        return () => { cancelled = true; };
    }, []);

    // Send heartbeat every 60s while logged in (extends sliding-window session)
    useEffect(() => {
        if (!user?.id) return;

        const heartbeat = setInterval(() => {
            api.auth.heartbeat().catch(() => {});
        }, 60 * 1000);

        return () => clearInterval(heartbeat);
    }, [user?.id]);

    // Re-fetch user data to sync favorites after a like/favorite toggle
    const refreshUser = useCallback(async () => {
        try {
            const data = await api.auth.me();
            setUser(data.user);
        } catch { /* ignore */ }
    }, []);

    // Listen for custom 'favoriteToggled' events dispatched by recipe components
    useEffect(() => {
        window.addEventListener('favoriteToggled', refreshUser);
        return () => window.removeEventListener('favoriteToggled', refreshUser);
    }, [refreshUser]);

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

    // Derived auth states for convenient access in components
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

/** Hook to access auth context. Must be used inside <AuthProvider>. */
// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
}
