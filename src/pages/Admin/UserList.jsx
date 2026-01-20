import React, { useEffect, useState } from 'react';
import { storage } from '../../lib/storage';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../../components/ui/Table';
import { Button } from '../../components/ui/Button';
import { Badge } from '../../components/ui/Badge';
import { Input } from '../../components/ui/Input';
import { Search, Trash2, Shield, Ban, CheckCircle } from 'lucide-react';

export function UserList() {
    const [users, setUsers] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [roleFilter, setRoleFilter] = useState('all');

    useEffect(() => {
        loadUsers();
    }, []);

    const loadUsers = () => {
        setUsers(storage.getUsers());
    };

    const handleStatusChange = (userId, newStatus) => {
        const user = users.find(u => u.id === userId);
        if (user) {
            storage.saveUser({ ...user, status: newStatus });
            loadUsers();
        }
    };

    const handleDelete = (userId) => {
        // In real app, confirm first. For prototype, just delete from array logic (not fully implemented in storage.js, assume soft delete usually)
        // But let's implement status 'deleted' or actually filter them out.
        // For now, toggle status to 'banned' is safer than delete.
        handleStatusChange(userId, 'banned');
    };

    const filteredUsers = users.filter(user => {
        const matchesSearch = user.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
            user.email.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesRole = roleFilter === 'all' || user.role === roleFilter;
        return matchesSearch && matchesRole;
    });

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-cool-gray-90">User Management</h1>
                    <p className="text-cool-gray-60">Manage user accounts and permissions.</p>
                </div>
                <Button>Add User (Demo)</Button>
            </div>

            <div className="flex items-center gap-4">
                <div className="relative w-64">
                    <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-cool-gray-60" />
                    <Input
                        className="pl-9"
                        placeholder="Search users..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
                <select
                    className="h-10 rounded-md border border-cool-gray-30 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cool-gray-90"
                    value={roleFilter}
                    onChange={(e) => setRoleFilter(e.target.value)}
                >
                    <option value="all">All Roles</option>
                    <option value="user">User</option>
                    <option value="admin">Admin</option>
                </select>
            </div>

            <div className="rounded-md border border-cool-gray-20 bg-white">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>User</TableHead>
                            <TableHead>Role</TableHead>
                            <TableHead>Status</TableHead>
                            <TableHead>Joined</TableHead>
                            <TableHead>Last Active</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {filteredUsers.map((user) => (
                            <TableRow key={user.id}>
                                <TableCell>
                                    <div className="flex items-center gap-3">
                                        <img src={user.avatar} className="h-8 w-8 rounded-full" alt="" />
                                        <div>
                                            <div className="font-medium">{user.username}</div>
                                            <div className="text-xs text-cool-gray-60">{user.email}</div>
                                        </div>
                                    </div>
                                </TableCell>
                                <TableCell>
                                    <Badge variant={user.role === 'admin' ? 'default' : 'outline'}>
                                        {user.role}
                                    </Badge>
                                </TableCell>
                                <TableCell>
                                    <Badge variant={user.status === 'active' ? 'success' : user.status === 'banned' ? 'error' : 'warning'}>
                                        {user.status}
                                    </Badge>
                                </TableCell>
                                <TableCell>{new Date(user.joinedDate).toLocaleDateString()}</TableCell>
                                <TableCell>{user.lastActive ? new Date(user.lastActive).toLocaleDateString() : 'Never'}</TableCell>
                                <TableCell className="text-right">
                                    <div className="flex justify-end gap-2">
                                        {user.status === 'active' ? (
                                            <Button size="icon" variant="ghost" title="Deactivate" onClick={() => handleStatusChange(user.id, 'deactivated')}>
                                                <Ban className="h-4 w-4 text-orange-500" />
                                            </Button>
                                        ) : (
                                            <Button size="icon" variant="ghost" title="Activate" onClick={() => handleStatusChange(user.id, 'active')}>
                                                <CheckCircle className="h-4 w-4 text-green-500" />
                                            </Button>
                                        )}
                                        <Button size="icon" variant="ghost" title="Delete/Ban" onClick={() => handleDelete(user.id)}>
                                            <Trash2 className="h-4 w-4 text-red-500" />
                                        </Button>
                                    </div>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
