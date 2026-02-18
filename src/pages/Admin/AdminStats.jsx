// Admin dashboard - displays system stats, KPIs, and activity feed
import React, { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/Card';
import api, { getErrorMessage } from '../../lib/api';
import { LoadingSpinner } from '../../components/ui/LoadingSpinner';
import { ErrorMessage } from '../../components/ui/ErrorMessage';
import { Users, FileText, Activity, UserPlus, ChefHat, Eye } from 'lucide-react';

// Reusable KPI card component
const StatCard = ({ title, value, icon, subtext }) => {
    const Icon = icon;
    return (
        <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-cool-gray-60">
                    {title}
                </CardTitle>
                <Icon className="h-4 w-4 text-cool-gray-60" />
            </CardHeader>
            <CardContent>
                <div className="text-2xl font-bold">{value}</div>
                {subtext && <p className="text-xs text-cool-gray-60 mt-1">{subtext}</p>}
            </CardContent>
        </Card>
    );
};

export function AdminStats() {
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        const loadStats = async () => {
            try {
                setError('');
                const data = await api.stats.dashboard();
                setStats({
                    totalUsers: data.totals?.users || 0,
                    newUsersToday: data.today?.newUsers || 0,
                    contributors: data.contributors || 0,
                    newContributorsToday: data.today?.newContributors || 0,
                    publishedRecipes: data.recipesByStatus?.published || 0,
                    pendingRecipes: data.recipesByStatus?.pending || 0,
                    dailyViews: data.today?.dailyViews || 0,
                    dailyActiveUsers: data.today?.dailyActiveUsers || 0,
                    recentActivity: (data.recentActivity || []).map(a => ({
                        type: a.actionType,
                        text: a.description,
                        time: a.createdAt,
                        adminUsername: a.adminUsername || 'Unknown admin',
                    })),
                });
            } catch (err) {
                setStats(null);
                setError(getErrorMessage(err, 'Failed to load admin dashboard stats.'));
            } finally {
                setLoading(false);
            }
        };

        loadStats();
        const interval = setInterval(loadStats, 30000);
        return () => clearInterval(interval);
    }, []);

    if (loading) return <LoadingSpinner className="py-20" />;
    if (!stats) {
        return (
            <div className="rounded-lg border border-cool-gray-20 bg-white">
                <ErrorMessage message={error || 'Failed to load stats.'} />
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-cool-gray-90">Dashboard</h1>
                <p className="text-cool-gray-60">Overview of system performance and activity.</p>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <StatCard title="Total Users" value={stats.totalUsers} icon={Users} subtext="All registered users" />
                <StatCard title="New Users Today" value={stats.newUsersToday} icon={UserPlus} subtext="Joined today" />
                <StatCard title="Total Contributors" value={stats.contributors} icon={ChefHat} subtext="Recipe creators" />
                <StatCard title="New Contributors Today" value={stats.newContributorsToday} icon={UserPlus} subtext="New recipe creators" />
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <StatCard title="Published Recipes" value={stats.publishedRecipes} icon={FileText} subtext="Approved recipes" />
                <StatCard title="Pending Recipes" value={stats.pendingRecipes} icon={FileText} subtext="Awaiting approval" />
                <StatCard title="Daily Views" value={stats.dailyViews} icon={Eye} subtext="Total recipe views" />
                <StatCard title="Daily Active Users" value={stats.dailyActiveUsers} icon={Activity} subtext="Active today (DAU)" />
            </div>

            <div className="grid gap-4 md:grid-cols-2">
                {/* Quick placeholder for charts/trends */}
                <Card className="col-span-1">
                    <CardHeader>
                        <CardTitle>Recent Activity</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-2 text-sm text-cool-gray-60">
                            {stats.recentActivity.length ? (
                                stats.recentActivity.map((activity, index) => (
                                    <div key={`${activity.type}-${activity.time}-${index}`} className="flex items-start justify-between gap-4">
                                        <span>
                                            {activity.text}
                                            <span className="ml-1 text-cool-gray-50">by {activity.adminUsername}</span>
                                        </span>
                                        <span className="whitespace-nowrap text-xs text-cool-gray-50">
                                            {new Date(activity.time).toLocaleString()}
                                        </span>
                                    </div>
                                ))
                            ) : (
                                <p>No recent activity yet.</p>
                            )}
                        </div>
                    </CardContent>
                </Card>
                <Card className="col-span-1">
                    <CardHeader>
                        <CardTitle>System Health</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="flex items-center gap-2">
                            <div className="h-2 w-2 rounded-full bg-green-500"></div>
                            <span className="text-sm font-medium">All systems operational</span>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
