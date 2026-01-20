import React, { useEffect, useState } from 'react';
import { storage } from '../../lib/storage';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../../components/ui/Table';
import { Button } from '../../components/ui/Button';
import { Badge } from '../../components/ui/Badge';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '../../components/ui/Tabs';
import { Modal } from '../../components/ui/Modal';
import { Eye, Check, X, Trash2 } from 'lucide-react';

export function AdminRecipes() {
    const [recipes, setRecipes] = useState([]);
    const [users, setUsers] = useState([]);
    const [selectedRecipe, setSelectedRecipe] = useState(null);
    const [isPreviewOpen, setIsPreviewOpen] = useState(false);

    useEffect(() => {
        loadRecipes();
        setUsers(storage.getUsers());
    }, []);

    const loadRecipes = () => {
        setRecipes(storage.getRecipes());
    };

    // Helper to get author username from ID
    const getAuthorName = (authorId) => {
        const author = users.find(u => u.id === authorId);
        return author?.username || authorId;
    };

    const updateStatus = (id, status) => {
        const recipe = recipes.find(r => r.id === id);
        if (recipe) {
            storage.saveRecipe({ ...recipe, status });
            loadRecipes();
            setIsPreviewOpen(false);
        }
    };

    const handleDelete = (id) => {
        if (window.confirm('Are you sure you want to delete this recipe? This action cannot be undone.')) {
            storage.deleteRecipe(id);
            loadRecipes();
        }
    };

    const handlePreview = (recipe) => {
        setSelectedRecipe(recipe);
        setIsPreviewOpen(true);
    };

    const RecipeTable = ({ statusFilter }) => {
        const filtered = recipes.filter(r => r.status === statusFilter);

        return (
            <div className="rounded-md border border-cool-gray-20 bg-white mt-4">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead className="w-20">ID</TableHead>
                            <TableHead className="w-16">Image</TableHead>
                            <TableHead>Title</TableHead>
                            <TableHead>Author</TableHead>
                            <TableHead>Category</TableHead>
                            <TableHead>Date</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {filtered.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={7} className="text-center h-24 text-cool-gray-60">No recipes found.</TableCell>
                            </TableRow>
                        ) : filtered.map((recipe) => (
                            <TableRow key={recipe.id}>
                                <TableCell className="font-mono text-xs text-cool-gray-60">{recipe.id}</TableCell>
                                <TableCell>
                                    <img 
                                        src={recipe.images?.[0] || 'https://via.placeholder.com/40'} 
                                        alt={recipe.title} 
                                        className="w-10 h-10 rounded object-cover cursor-pointer hover:opacity-80"
                                        onClick={() => handlePreview(recipe)}
                                    />
                                </TableCell>
                                <TableCell className="font-medium">{recipe.title}</TableCell>
                                <TableCell>{getAuthorName(recipe.authorId)}</TableCell>
                                <TableCell>{recipe.category}</TableCell>
                                <TableCell>{new Date(recipe.createdAt).toLocaleDateString()}</TableCell>
                                <TableCell className="text-right">
                                    <div className="flex justify-end gap-2">
                                        <Button size="icon" variant="ghost" onClick={() => handlePreview(recipe)}>
                                            <Eye className="h-4 w-4" />
                                        </Button>
                                        {statusFilter === 'pending' && (
                                            <>
                                                <Button size="icon" variant="ghost" title="Approve" onClick={() => updateStatus(recipe.id, 'published')}>
                                                    <Check className="h-4 w-4 text-green-500" />
                                                </Button>
                                                <Button size="icon" variant="ghost" title="Reject" onClick={() => updateStatus(recipe.id, 'rejected')}>
                                                    <X className="h-4 w-4 text-red-500" />
                                                </Button>
                                            </>
                                        )}
                                        <Button size="icon" variant="ghost" title="Delete" onClick={() => handleDelete(recipe.id)}>
                                            <Trash2 className="h-4 w-4 text-red-500" />
                                        </Button>
                                    </div>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </div>
        );
    };

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-cool-gray-90">Recipe Management</h1>
                <p className="text-cool-gray-60">Approve, reject, and manage user submissions.</p>
            </div>

            <Tabs defaultValue="pending">
                <TabsList>
                    <TabsTrigger value="pending">Pending</TabsTrigger>
                    <TabsTrigger value="published">Published</TabsTrigger>
                    <TabsTrigger value="rejected">Rejected</TabsTrigger>
                </TabsList>
                <TabsContent value="pending"><RecipeTable statusFilter="pending" /></TabsContent>
                <TabsContent value="published"><RecipeTable statusFilter="published" /></TabsContent>
                <TabsContent value="rejected"><RecipeTable statusFilter="rejected" /></TabsContent>
            </Tabs>

            <Modal
                isOpen={isPreviewOpen}
                onClose={() => setIsPreviewOpen(false)}
                title={selectedRecipe?.title || 'Recipe Preview'}
                className="max-w-3xl"
            >
                {selectedRecipe && (
                    <div className="space-y-4 max-h-[70vh] overflow-auto">
                        <img src={selectedRecipe.images?.[0]} alt="" className="w-full h-48 object-cover rounded-lg" />
                        <p className="text-cool-gray-60">{selectedRecipe.description}</p>

                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <h4 className="font-semibold mb-2">Ingredients</h4>
                                <ul className="list-disc list-inside text-sm">
                                    {selectedRecipe.ingredients?.map((ing, i) => (
                                        <li key={i}>{ing.quantity} {ing.unit} {ing.name}</li>
                                    ))}
                                </ul>
                            </div>
                            <div>
                                <h4 className="font-semibold mb-2">Instructions</h4>
                                <ol className="list-decimal list-inside text-sm">
                                    {selectedRecipe.instructions?.map((step, i) => (
                                        <li key={i}>{step}</li>
                                    ))}
                                </ol>
                            </div>
                        </div>

                        {selectedRecipe.status === 'pending' && (
                            <div className="flex justify-end gap-3 mt-6 pt-4 border-t border-cool-gray-20 items-center">
                                <Button variant="outline" onClick={() => updateStatus(selectedRecipe.id, 'rejected')}>Reject</Button>
                                <Button onClick={() => updateStatus(selectedRecipe.id, 'published')}>Approve</Button>
                            </div>
                        )}
                    </div>
                )}
            </Modal>
        </div>
    );
}
