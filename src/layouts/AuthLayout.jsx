import React from 'react';
import { Outlet } from 'react-router-dom';

export function AuthLayout() {
    return (
        <div className="min-h-screen grid lg:grid-cols-2">
            {/* Left: Branding/Image */}
            <div className="hidden lg:flex flex-col bg-cool-gray-90 text-white p-12 justify-between relative overflow-hidden">
                <div className="z-10">
                    <h1 className="text-3xl font-bold">CookHub</h1>
                </div>
                <div className="z-10">
                    <blockquote className="space-y-2">
                        <p className="text-lg">
                            "Cooking is like love. It should be entered into with abandon or not at all."
                        </p>
                        <footer className="text-sm opacity-80">Harriet Van Horne</footer>
                    </blockquote>
                </div>
                {/* Abstract Background Decoration */}
                <div className="absolute top-0 right-0 -mr-20 -mt-20 w-[500px] h-[500px] bg-white/5 rounded-full blur-3xl" />
                <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-[400px] h-[400px] bg-white/5 rounded-full blur-3xl" />
            </div>

            {/* Right: Form */}
            <div className="flex items-center justify-center p-8 bg-cool-gray-10">
                <div className="w-full max-w-sm space-y-6">
                    <Outlet />
                </div>
            </div>
        </div>
    );
}
