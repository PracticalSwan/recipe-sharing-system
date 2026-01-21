import React from 'react';
import { Outlet, Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Navbar } from '../components/layout/Navbar';
import { Loader2 } from 'lucide-react';

export function RootLayout() {
    const { user, loading, isAdmin } = useAuth();

    if (loading) {
        return <div className="min-h-screen flex items-center justify-center"><Loader2 className="h-8 w-8 animate-spin text-cool-gray-90" /></div>;
    }

    if (!user) {
        return <Navigate to="/login" replace />;
    }

    if (isAdmin) {
        return <Navigate to="/admin" replace />;
    }

    return (
        <div className="min-h-screen bg-cool-gray-10 pb-20">
            <Navbar />
            <main className="container mx-auto px-4 py-8 sm:px-6 lg:px-8">
                <Outlet />
            </main>
        </div>
    );
}
