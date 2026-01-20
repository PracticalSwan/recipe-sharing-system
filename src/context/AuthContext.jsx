import React, { createContext, useContext, useState, useEffect } from 'react';
import { storage } from '../lib/storage';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Initialize storage handling (seeding if empty)
        storage.initialize();

        // Check for active session
        try {
            const currentUser = storage.getCurrentUser();
            if (currentUser) {
                setUser(currentUser);
            }
        } catch (error) {
            console.error("Failed to load user session", error);
        } finally {
            setLoading(false);
        }
    }, []);

    const login = (email, password) => {
        try {
            const loggedUser = storage.login(email, password);
            setUser(loggedUser);
            return { success: true };
        } catch (error) {
            return { success: false, error: error.message };
        }
    };

    const logout = () => {
        storage.logout();
        setUser(null);
    };

    const signup = (userData) => {
        // Basic signup logic - in a real app check email dupe
        const newUser = {
            id: `user-${Date.now()}`,
            role: 'user',
            status: 'active',
            joinedDate: new Date().toISOString(),
            favorites: [],
            viewedRecipes: [],
            ...userData
        };
        storage.saveUser(newUser);
        // Record new user for daily stats tracking
        storage.recordNewUser(newUser.id, newUser.role);
        // Auto login
        storage.login(userData.email, userData.password);
        setUser(newUser);
    };

    const updateProfile = (updates) => {
        if (!user) return;
        const updatedUser = { ...user, ...updates };
        storage.saveUser(updatedUser);
        localStorage.setItem('cookhub_current_user', JSON.stringify(updatedUser));
        setUser(updatedUser);
    };

    const value = {
        user,
        loading,
        isAdmin: user?.role === 'admin',
        login,
        logout,
        signup,
        updateProfile
    };

    return (
        <AuthContext.Provider value={value}>
            {!loading && children}
        </AuthContext.Provider>
    );
}

export function useAuth() {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
}
