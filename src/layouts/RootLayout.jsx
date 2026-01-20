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

    // Optional: Redirect Admin to Admin Dashboard if they try to access root
    // The requirements say user is unaccessible to all Admin Consoles, and simpler separation.
    // If admin logs in, we might want to redirect them to /admin? 
    // But let's allow Admin to see "Home" (Discovery) if desired, OR strictly redirect.
    // The plan said "Admin routes strictly protected". 
    // Let's assume Admin CANNOT see the normal user view, per "User is unaccessible to all Admin Consoles" comment might imply strict separation?
    // "Ensure User is unaccessible to all Admin Consoles" -> means the *User Management Console* is inaccessible to Users.
    // But "Log in as Admin -> Access User Management" implies Admin mainly works there.
    // I will let Admin see Root for now to discover recipes too (unless strictly forbidden). 
    // Actually, standard practice: Admin sees Admin View. User sees User View.
    // Let's redirect Admin to /admin to be safe with "Admin Isolation".
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
