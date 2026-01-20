import React, { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { storage } from '../../lib/storage';
import { RecipeCard } from '../../components/recipe/RecipeCard';
import { Input } from '../../components/ui/Input';
import { Button } from '../../components/ui/Button';
import { Search as SearchIcon, X } from 'lucide-react';

export function Search() {
    const [searchParams, setSearchParams] = useSearchParams();
    const query = searchParams.get('q') || '';

    const [recipes, setRecipes] = useState([]);
    const [filteredRecipes, setFilteredRecipes] = useState([]);

    const [filters, setFilters] = useState({
        keyword: query,
        category: 'All',
        difficulty: 'All',
        sort: 'newest'
    });

    useEffect(() => {
        // Sync filters with URL query initially
        if (query) setFilters(prev => ({ ...prev, keyword: query }));
    }, [query]);

    useEffect(() => {
        const all = storage.getRecipes().filter(r => r.status === 'published');
        setRecipes(all);
    }, []);

    useEffect(() => {
        let result = [...recipes];

        // Keyword
        if (filters.keyword) {
            const lower = filters.keyword.toLowerCase();
            result = result.filter(r =>
                r.title.toLowerCase().includes(lower) ||
                r.description.toLowerCase().includes(lower) ||
                r.ingredients.some(i => i.name.toLowerCase().includes(lower))
            );
        }

        // Category
        if (filters.category !== 'All') {
            result = result.filter(r => r.category === filters.category);
        }

        // Difficulty
        if (filters.difficulty !== 'All') {
            result = result.filter(r => r.difficulty === filters.difficulty);
        }

        // Sort
        result.sort((a, b) => {
            if (filters.sort === 'newest') return new Date(b.createdAt) - new Date(a.createdAt);
            if (filters.sort === 'rating') return (b.likes || 0) - (a.likes || 0); // Simplified rating sort via likes for now
            if (filters.sort === 'difficulty-asc') return ['Easy', 'Medium', 'Hard'].indexOf(a.difficulty) - ['Easy', 'Medium', 'Hard'].indexOf(b.difficulty);
            return 0;
        });

        setFilteredRecipes(result);
    }, [recipes, filters]);

    const handleFilterChange = (key, value) => {
        setFilters(prev => ({ ...prev, [key]: value }));
    };

    const clearFilters = () => {
        setFilters({ keyword: '', category: 'All', difficulty: 'All', sort: 'newest' });
        setSearchParams({});
    };

    return (
        <div className="space-y-6 animate-page-in">
            <div className="flex flex-col gap-4 bg-white p-6 rounded-xl border border-cool-gray-20 shadow-sm">
                <div className="relative">
                    <SearchIcon className="absolute left-3 top-3.5 h-5 w-5 text-cool-gray-60" />
                    <Input
                        placeholder="Search recipes..."
                        className="pl-10 text-lg py-6"
                        value={filters.keyword}
                        onChange={(e) => handleFilterChange('keyword', e.target.value)}
                    />
                </div>

                <div className="flex flex-wrap items-center gap-4">
                    <select
                        className="h-10 rounded-md border border-cool-gray-30 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cool-gray-90"
                        value={filters.category}
                        onChange={(e) => handleFilterChange('category', e.target.value)}
                    >
                        <option value="All">All Categories</option>
                        <option value="Italian">Italian</option>
                        <option value="Breakfast">Breakfast</option>
                        <option value="Asian">Asian</option>
                        <option value="Dessert">Dessert</option>
                    </select>

                    <select
                        className="h-10 rounded-md border border-cool-gray-30 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cool-gray-90"
                        value={filters.difficulty}
                        onChange={(e) => handleFilterChange('difficulty', e.target.value)}
                    >
                        <option value="All">All Difficulties</option>
                        <option value="Easy">Easy</option>
                        <option value="Medium">Medium</option>
                        <option value="Hard">Hard</option>
                    </select>

                    <select
                        className="h-10 rounded-md border border-cool-gray-30 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cool-gray-90"
                        value={filters.sort}
                        onChange={(e) => handleFilterChange('sort', e.target.value)}
                    >
                        <option value="newest">Newest First</option>
                        <option value="rating">Most Popular</option>
                        <option value="difficulty-asc">Difficulty (Low to High)</option>
                    </select>

                    <Button variant="ghost" onClick={clearFilters} className="ml-auto text-cool-gray-60">
                        <X className="mr-2 h-4 w-4" /> Clear
                    </Button>
                </div>
            </div>

            <div className="space-y-4">
                <h2 className="text-xl font-bold text-cool-gray-90">Results ({filteredRecipes.length})</h2>
                <div className="grid gap-4 grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
                    {filteredRecipes.length > 0 ? (
                        filteredRecipes.map(r => <RecipeCard key={r.id} recipe={r} />)
                    ) : (
                        <div className="col-span-full py-12 text-center text-cool-gray-60">
                            No recipes found. Try adjusting your filters.
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
