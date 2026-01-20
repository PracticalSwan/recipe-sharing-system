import React, { useEffect, useState } from 'react';
import { storage } from '../../lib/storage';
import { RecipeCard } from '../../components/recipe/RecipeCard';
import { Input } from '../../components/ui/Input';
import { Button } from '../../components/ui/Button';
import { Search } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export function Home() {
    const [recipes, setRecipes] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [, forceUpdate] = useState(0);
    const navigate = useNavigate();

    useEffect(() => {
        loadRecipes();

        // Listen for favorite toggles to refresh
        const handleFavoriteToggle = () => forceUpdate(n => n + 1);
        window.addEventListener('favoriteToggled', handleFavoriteToggle);
        return () => window.removeEventListener('favoriteToggled', handleFavoriteToggle);
    }, []);

    const loadRecipes = () => {
        const allRecipes = storage.getRecipes();
        setRecipes(allRecipes.filter(r => r.status === 'published'));
    };

    const handleSearch = (e) => {
        e.preventDefault();
        if (searchTerm.trim()) {
            navigate(`/search?q=${encodeURIComponent(searchTerm)}`);
        }
    };

    return (
        <div className="space-y-8 animate-page-in">
            {/* Hero Section */}
            <section className="relative -mt-8 py-16 px-4 text-center bg-cool-gray-90 text-white rounded-b-3xl mb-10 overflow-hidden">
                <div className="absolute inset-0 opacity-20 bg-[url('https://images.unsplash.com/photo-1495521841625-f46248f59218?auto=format&fit=crop&q=80')] bg-cover bg-center" />
                <div className="relative z-10 max-w-2xl mx-auto space-y-5">
                    <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">Share Your Culinary <span className="text-orange-400">Masterpiece</span></h1>
                    <p className="text-base text-cool-gray-30">Join our community of home cooks and professional chefs.</p>

                    <form onSubmit={handleSearch} className="relative max-w-lg mx-auto">
                        <Search className="absolute left-3 top-3 h-5 w-5 text-cool-gray-60" />
                        <Input
                            placeholder="Search for recipes, ingredients, or chefs..."
                            className="pl-10 h-11 text-cool-gray-90"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </form>
                </div>
            </section>

            {/* Featured/Feed Section */}
            <section className="space-y-4">
                <div className="flex items-center justify-between">
                    <h2 className="text-xl font-bold text-cool-gray-90">Fresh from the Kitchen</h2>
                    <Button variant="ghost" className="text-sm" onClick={() => navigate('/search')}>View All</Button>
                </div>

                <div className="grid gap-4 grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
                    {recipes.length > 0 ? (
                        recipes.map(recipe => (
                            <RecipeCard key={recipe.id} recipe={recipe} onFavoriteToggle={loadRecipes} />
                        ))
                    ) : (
                        <p className="col-span-full text-center text-cool-gray-60 py-10">No recipes published yet. Be the first!</p>
                    )}
                </div>
            </section>
        </div>
    );
}
