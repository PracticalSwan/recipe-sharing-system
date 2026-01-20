import React from 'react';
import { Outlet, Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Sidebar } from '../components/layout/Sidebar';
import { Loader2 } from 'lucide-react';

export function AdminLayout() {
    const { user, loading, isAdmin } = useAuth();

    if (loading) {
        return <div className="min-h-screen flex items-center justify-center"><Loader2 className="h-8 w-8 animate-spin text-cool-gray-90" /></div>;
    }

    if (!user || !isAdmin) {
        // Redirect non-admins to home or login
        return <Navigate to={user ? "/" : "/login"} replace />;
    }

    return (
        <div className="min-h-screen bg-cool-gray-10 flex">
            <Sidebar />
            <main className="flex-1 ml-64 p-8 overflow-auto">
                <div className="max-w-7xl mx-auto">
                    <Outlet />
                </div>
            </main>
        </div>
    );
}
