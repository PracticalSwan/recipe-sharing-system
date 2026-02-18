// Login page: email + password form with demo credentials
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import { getErrorMessage } from '../../lib/api';

export function Login() {
    // Form state
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setIsLoading(true);

        try {
            const result = await login(email, password);
            if (result.success) {
                navigate('/');
            } else {
                setError(result.error);
            }
        } catch (err) {
            setError(getErrorMessage(err, 'An unexpected error occurred.'));
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            {/* Page header */}
            <div className="space-y-2 text-center">
                <h2 className="text-3xl font-bold tracking-tight text-cool-gray-90">Welcome Back!</h2>
                <p className="text-cool-gray-60">Enter your credentials to access your account</p>
            </div>

            {/* Login form */}
            <form onSubmit={handleSubmit} className="space-y-4">
                <Input
                    id="email"
                    name="email"
                    label="Email"
                    type="email"
                    placeholder="admin@cookhub.com"
                    autoComplete="email"
                    value={email}
                    onChange={(e) => { setEmail(e.target.value); setError(''); }}
                    required
                />
                <div className="space-y-1">
                    <Input
                        id="password"
                        name="password"
                        label="Password"
                        type="password"
                        placeholder="••••••"
                        autoComplete="current-password"
                        value={password}
                        onChange={(e) => { setPassword(e.target.value); setError(''); }}
                        required
                    />
                </div>

                {/* Error message display */}
                {error && (
                    <div className="p-3 text-sm text-red-500 bg-red-50 rounded-md">
                        {error}
                    </div>
                )}

                <Button type="submit" className="w-full" isLoading={isLoading} size="lg">
                    Login
                </Button>
            </form>

            {/* Signup link */}
            <div className="text-center text-sm text-cool-gray-60">
                Don't have an account?{' '}
                <Link to="/signup" className="font-semibold text-cool-gray-90 hover:underline">
                    Sign up
                </Link>
            </div>

            {/* Demo credentials for testing */}
            <div className="text-center text-xs text-cool-gray-30 mt-4">
                <p className="font-semibold">Demo Credentials:</p>
                <p>User: user@cookhub.com / user</p>
                <p>Admin: admin@cookhub.com / admin</p>
                <p>Pending: amy@cookhub.com / amy123</p>
                <p>Suspended: tom@cookhub.com / tom123</p>
            </div>
        </div>
    );
}
