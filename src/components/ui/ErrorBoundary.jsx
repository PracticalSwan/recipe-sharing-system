/**
 * React class-based error boundary.
 * Catches unhandled render errors and shows a "Reload page" fallback
 * instead of a white screen.
 */
import React from 'react';

export class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false };
    }

    static getDerivedStateFromError() {
        return { hasError: true };
    }

    componentDidCatch(error, errorInfo) {
        // Keep diagnostics in dev tools while showing a user-friendly fallback.
        console.error('Unhandled UI error:', error, errorInfo);
    }

    handleReload = () => {
        window.location.reload();
    };

    render() {
        if (this.state.hasError) {
            return (
                <div className="min-h-screen flex items-center justify-center bg-cool-gray-10 p-4">
                    <div className="w-full max-w-md rounded-xl border border-cool-gray-20 bg-white p-6 shadow-sm text-center">
                        <h1 className="text-xl font-bold text-cool-gray-90 mb-2">Something went wrong</h1>
                        <p className="text-cool-gray-60 mb-5">
                            An unexpected error occurred while rendering this page.
                        </p>
                        <button
                            type="button"
                            onClick={this.handleReload}
                            className="inline-flex items-center justify-center rounded-md bg-cool-gray-90 px-4 py-2 text-sm font-medium text-white hover:bg-black transition-colors"
                        >
                            Reload page
                        </button>
                    </div>
                </div>
            );
        }

        return this.props.children;
    }
}

