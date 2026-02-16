/**
 * Signup (registration) page.
 * File: src/pages/Auth/Signup.jsx
 *
 * Collects first name, last name, birthday, email, and password.
 * Auto-generates a DiceBear avatar URL from the first name.
 * Client-side validation before calling AuthContext.signup().
 */
import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';

export function Signup() {
    const [formData, setFormData] = useState({
        firstName: '',
        lastName: '',
        email: '',
        birthday: '',
        password: '',
        confirmPassword: ''
    });
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const { signup } = useAuth();
    const navigate = useNavigate();

    const handleChange = (e) => {
        setFormData(prev => ({ ...prev, [e.target.id]: e.target.value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');

        if (!formData.firstName.trim() || !formData.lastName.trim()) {
            setError('First name and last name are required');
            return;
        }

        if (!formData.birthday) {
            setError('Birthday is required');
            return;
        }

        if (formData.password.length < 6) {
            setError('Password must be at least 6 characters');
            return;
        }

        if (formData.password !== formData.confirmPassword) {
            setError('Passwords do not match');
            return;
        }

        setIsLoading(true);

        try {
            const username = `${formData.firstName} ${formData.lastName}`;
            await signup({
                username,
                firstName: formData.firstName,
                lastName: formData.lastName,
                email: formData.email,
                birthday: formData.birthday,
                password: formData.password,
                avatarUrl: `https://api.dicebear.com/7.x/avataaars/svg?seed=${formData.firstName}`
            });

            navigate('/');
        } catch {
            setError('Failed to create account');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            <div className="space-y-2 text-center">
                <h2 className="text-3xl font-bold tracking-tight text-cool-gray-90">Get Started</h2>
                <p className="text-cool-gray-60">Create a new account to join the community</p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                    <Input
                        id="firstName"
                        name="firstName"
                        label="First Name"
                        placeholder="John"
                        autoComplete="given-name"
                        value={formData.firstName}
                        onChange={handleChange}
                        required
                    />
                    <Input
                        id="lastName"
                        name="lastName"
                        label="Last Name"
                        placeholder="Doe"
                        autoComplete="family-name"
                        value={formData.lastName}
                        onChange={handleChange}
                        required
                    />
                </div>
                <Input
                    id="birthday"
                    name="birthday"
                    label="Birthday"
                    type="date"
                    autoComplete="bday"
                    value={formData.birthday}
                    onChange={handleChange}
                    required
                />
                <Input
                    id="email"
                    name="email"
                    label="Email"
                    type="email"
                    placeholder="john@example.com"
                    autoComplete="email"
                    value={formData.email}
                    onChange={handleChange}
                    required
                />
                <Input
                    id="password"
                    name="password"
                    label="Password"
                    type="password"
                    autoComplete="new-password"
                    value={formData.password}
                    onChange={handleChange}
                    required
                />
                <Input
                    id="confirmPassword"
                    name="confirmPassword"
                    label="Confirm Password"
                    type="password"
                    autoComplete="new-password"
                    value={formData.confirmPassword}
                    onChange={handleChange}
                    required
                />

                {error && (
                    <div className="p-3 text-sm text-red-500 bg-red-50 rounded-md">
                        {error}
                    </div>
                )}

                <Button type="submit" className="w-full" isLoading={isLoading} size="lg">
                    Create Account
                </Button>
            </form>

            <div className="text-center text-sm text-cool-gray-60">
                Already have an account?{' '}
                <Link to="/login" className="font-semibold text-cool-gray-90 hover:underline">
                    Log in
                </Link>
            </div>
        </div>
    );
}
