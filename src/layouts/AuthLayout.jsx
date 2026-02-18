// Authentication page layout with two-column split: form area (left) and branded panel (right)
import React from 'react';
import { Outlet } from 'react-router-dom';
import Logo from '../assets/Logo.png';

export function AuthLayout() {
    return (
        // Main container: full-height grid with 5 columns on large screens
        <div className="min-h-screen grid lg:grid-cols-5">

            {/* Left column: form area (3/5 width on large screens) */}
            <div className="flex items-center justify-center p-8 bg-cool-gray-10 lg:col-span-3">
                <div className="w-full max-w-sm space-y-6">
                    {/* Logo displayed above form on mobile/tablet */}
                    <div className="flex justify-center mb-8">
                        <img src={Logo} alt="CookHub Logo" className="h-16 w-auto" />
                    </div>
                    {/* Renders child route (Login or Signup form) */}
                    <Outlet />
                </div>
            </div>

            {/* Right column: branding panel (2/5 width, hidden on mobile) */}
            <div className="hidden lg:flex lg:col-span-2 flex-col bg-cool-gray-90 text-white p-12 relative overflow-hidden">
                {/* Centered logo and title */}
                <div className="z-10 flex-1 flex flex-col items-center justify-center gap-6">
                    <img src={Logo} alt="CookHub Logo" className="h-32 w-auto" />
                    <h1 className="text-5xl font-bold">CookHub</h1>
                </div>

                {/* Decorative blurred circles for visual interest */}
                <div className="absolute top-0 right-0 -mr-20 -mt-20 w-[500px] h-[500px] bg-white/5 rounded-full blur-3xl" />
                <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-[400px] h-[400px] bg-white/5 rounded-full blur-3xl" />
            </div>

        </div>
    );
}
