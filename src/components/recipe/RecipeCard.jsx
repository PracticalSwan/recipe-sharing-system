import React from 'react';
import { Link } from 'react-router-dom';
import { Clock, User, Heart, Eye, Bookmark } from 'lucide-react';
import { Card, CardContent, CardFooter } from '../ui/Card';
import { Badge } from '../ui/Badge';
import { storage } from '../../lib/storage';
import { useAuth } from '../../context/AuthContext';
import { cn } from '../../lib/utils';

export function RecipeCard({ recipe, compact = false, onFavoriteToggle }) {
    const { user } = useAuth();
    const isLiked = user ? storage.hasUserLiked(user.id, recipe.id) : false;
    const isFavorited = user ? storage.hasUserFavorited(user.id, recipe.id) : false;
    // We still track viewCount/likeCount from props generally, but let's rely on recipe prop for count
    const count = recipe.likedBy?.length || 0;
    const viewCount = recipe.viewedBy?.length || 0;

    // Fetch author name from storage
    const author = storage.getUsers().find(u => u.id === recipe.authorId);
    const authorName = author ? author.username : `User ${recipe.authorId}`;

    const handleLikeClick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (!user) return;
        storage.toggleLike(user.id, recipe.id);
        if (onFavoriteToggle) onFavoriteToggle(); // Re-using this prop to trigger refresh if needed
        window.dispatchEvent(new CustomEvent('recipeUpdated')); // Generic update event
    };

    const handleSaveClick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (!user) return;
        storage.toggleFavorite(user.id, recipe.id);
        if (onFavoriteToggle) onFavoriteToggle();
        window.dispatchEvent(new CustomEvent('favoriteToggled'));
    };

    return (
        <Link to={`/recipes/${recipe.id}`} className="group block">
            <Card className="h-full overflow-hidden transition-all hover:shadow-lg border-cool-gray-20 hover-lift cursor-pointer">
                <div className="relative aspect-[4/3] w-full overflow-hidden bg-cool-gray-10">
                    <img
                        src={recipe.images?.[0] || "https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&q=80&w=400"}
                        alt={recipe.title}
                        className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                    />
                    <div className="absolute top-1.5 right-1.5">
                        <Badge variant="default" className="bg-white/90 backdrop-blur-sm text-cool-gray-90 shadow-sm text-[10px] px-1.5 py-0.5">
                            {recipe.difficulty}
                        </Badge>
                    </div>
                    {/* Like Heart Overlay */}
                    <button
                        onClick={handleLikeClick}
                        className="absolute top-1.5 left-1.5 p-1.5 rounded-full bg-white/80 backdrop-blur-sm shadow-sm hover:bg-white transition-colors"
                        title={isLiked ? 'Unlike' : 'Like'}
                    >
                        <Heart
                            className={`h-3.5 w-3.5 transition-colors ${isLiked ? 'fill-red-500 text-red-500' : 'text-cool-gray-60 hover:text-red-400'}`}
                        />
                    </button>
                </div>

                <CardContent className="p-2.5">
                    <div className="mb-1.5 flex items-center justify-between">
                        <Badge variant="outline" className="text-[8px] uppercase tracking-wider px-1.5 py-0.5">{recipe.category}</Badge>
                        <div className="flex items-center gap-0.5 text-[10px] text-cool-gray-60">
                            <Clock className="h-2.5 w-2.5" />
                            <span>{recipe.prepTime + recipe.cookTime}m</span>
                        </div>
                    </div>

                    <div className="mb-0.5 flex items-center justify-between gap-2">
                        <h3 className="text-sm font-bold text-cool-gray-90 line-clamp-1 group-hover:text-black flex-1">
                            {recipe.title}
                        </h3>
                        <button
                            onClick={handleSaveClick}
                            className="p-1 rounded-md hover:bg-cool-gray-10 transition-colors shrink-0"
                            title={isFavorited ? 'Unsave' : 'Save'}
                        >
                            <Bookmark className={cn("h-4 w-4", isFavorited ? "fill-cool-gray-90 text-cool-gray-90" : "text-cool-gray-30")} />
                        </button>
                    </div>
                    <p className="text-[11px] text-cool-gray-60 line-clamp-2 mb-1.5">
                        {recipe.description}
                    </p>

                    <div className="flex items-center gap-1.5 text-[10px] text-cool-gray-60">
                        <User className="h-2.5 w-2.5" />
                        <Link
                            to={`/users/${recipe.authorId}`}
                            className="truncate hover:text-cool-gray-90 hover:underline"
                            onClick={(e) => e.stopPropagation()}
                        >
                            {authorName}
                        </Link>
                    </div>
                </CardContent>

                <CardFooter className="px-2.5 pb-2.5 pt-0 flex justify-between text-[10px] text-cool-gray-60">
                    <div className="flex items-center gap-0.5">
                        <Eye className="h-2.5 w-2.5" />
                        <span>{viewCount}</span>
                    </div>
                    <div className="flex items-center gap-0.5">
                        <Heart className="h-2.5 w-2.5" />
                        <span>{count}</span>
                    </div>
                </CardFooter>
            </Card>
        </Link>
    );
}
