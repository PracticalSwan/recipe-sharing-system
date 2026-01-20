// Simple ID Generator
const generateId = () => Math.random().toString(36).substr(2, 9);

const STORAGE_KEYS = {
    USERS: 'cookhub_users',
    RECIPES: 'cookhub_recipes',
    CURRENT_USER: 'cookhub_current_user',
    REVIEWS: 'cookhub_reviews',
    STATS: 'cookhub_stats',
    DAILY_STATS: 'cookhub_daily_stats'
};

// Helper to get today's date string (YYYY-MM-DD)
const getTodayKey = () => new Date().toISOString().split('T')[0];

// Default avatar options
const DEFAULT_AVATARS = [
    'https://api.dicebear.com/7.x/avataaars/svg?seed=chef1',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=chef2',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=baker',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=cook',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=foodie',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=gourmet'
];

const SEED_DATA = {
    users: [
        {
            id: 'admin-1',
            username: 'Admin User',
            firstName: 'Admin',
            lastName: 'User',
            email: 'admin@cookhub.com',
            password: 'admin',
            birthday: '1990-01-01',
            role: 'admin',
            status: 'active',
            joinedDate: new Date().toISOString(),
            avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',
            bio: 'System Administrator',
            location: 'Server Room',
            cookingLevel: 'Professional',
            favorites: [],
            viewedRecipes: []
        },
        {
            id: 'user-1',
            username: 'John Doe',
            firstName: 'John',
            lastName: 'Doe',
            email: 'user@cookhub.com',
            password: 'user',
            birthday: '1995-06-15',
            role: 'user',
            status: 'active',
            joinedDate: new Date('2025-06-15').toISOString(),
            avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
            bio: 'Love cooking italian food!',
            location: 'New York',
            cookingLevel: 'Intermediate',
            favorites: ['recipe-3'],
            viewedRecipes: ['recipe-1', 'recipe-3']
        },
        {
            id: 'user-2',
            username: 'Maria Garcia',
            firstName: 'Maria',
            lastName: 'Garcia',
            email: 'maria@cookhub.com',
            password: 'maria123',
            birthday: '1988-03-20',
            role: 'user',
            status: 'active',
            joinedDate: new Date('2025-03-20').toISOString(),
            avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=maria',
            bio: 'Professional chef specializing in Mediterranean cuisine.',
            location: 'Los Angeles',
            cookingLevel: 'Professional',
            favorites: ['recipe-1'],
            viewedRecipes: ['recipe-1', 'recipe-4']
        },
        {
            id: 'user-3',
            username: 'Tom Baker',
            firstName: 'Tom',
            lastName: 'Baker',
            email: 'tom@cookhub.com',
            password: 'tom123',
            birthday: '1992-08-01',
            role: 'user',
            status: 'active',
            joinedDate: new Date('2025-08-01').toISOString(),
            avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=tom',
            bio: 'Passionate about baking and desserts!',
            location: 'Chicago',
            cookingLevel: 'Intermediate',
            favorites: ['recipe-1', 'recipe-5'],
            viewedRecipes: ['recipe-1', 'recipe-5', 'recipe-6']
        },
        {
            id: 'user-4',
            username: 'Amy Wilson',
            firstName: 'Amy',
            lastName: 'Wilson',
            email: 'amy@cookhub.com',
            password: 'amy123',
            birthday: '1998-11-10',
            role: 'user',
            status: 'active',
            joinedDate: new Date('2025-11-10').toISOString(),
            avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=amy',
            bio: 'Home cook exploring healthy recipes.',
            location: 'Seattle',
            cookingLevel: 'Beginner',
            favorites: ['recipe-4', 'recipe-6'],
            viewedRecipes: ['recipe-3', 'recipe-4', 'recipe-6']
        }
    ],
    recipes: [
        {
            id: 'recipe-1',
            title: 'Classic Spaghetti Carbonara',
            description: 'A traditional Italian pasta dish from Rome with creamy egg sauce and crispy pancetta.',
            category: 'Italian',
            prepTime: 15,
            cookTime: 20,
            servings: 4,
            difficulty: 'Medium',
            ingredients: [
                { name: 'Spaghetti', quantity: '400', unit: 'g' },
                { name: 'Eggs', quantity: '4', unit: '' },
                { name: 'Pancetta', quantity: '200', unit: 'g' },
                { name: 'Parmesan', quantity: '100', unit: 'g' }
            ],
            instructions: ['Boil water and cook pasta al dente', 'Fry pancetta until crispy', 'Mix eggs with grated parmesan', 'Combine hot pasta with egg mixture off heat', 'Add pancetta and serve immediately'],
            images: ['https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&q=80&w=800'],
            authorId: 'user-1',
            status: 'published',
            createdAt: new Date('2025-12-01').toISOString(),
            likedBy: ['user-2', 'user-3'],
            viewedBy: ['user-1', 'user-2', 'user-3', 'user-4'],
            tags: ['pasta', 'dinner', 'italian']
        },
        {
            id: 'recipe-2',
            title: 'Fluffy Pancakes',
            description: 'Light and fluffy pancakes perfect for a weekend breakfast.',
            category: 'Breakfast',
            prepTime: 10,
            cookTime: 15,
            servings: 2,
            difficulty: 'Easy',
            ingredients: [
                { name: 'Flour', quantity: '200', unit: 'g' },
                { name: 'Milk', quantity: '250', unit: 'ml' },
                { name: 'Eggs', quantity: '2', unit: '' },
                { name: 'Sugar', quantity: '2', unit: 'tbsp' }
            ],
            instructions: ['Mix dry ingredients', 'Add wet ingredients and whisk', 'Cook on medium heat until bubbles form', 'Flip and cook other side'],
            images: ['https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&q=80&w=800'],
            authorId: 'user-1',
            status: 'pending',
            createdAt: new Date('2026-01-15').toISOString(),
            likedBy: [],
            viewedBy: [],
            tags: ['breakfast']
        },
        {
            id: 'recipe-3',
            title: 'Thai Green Curry',
            description: 'Aromatic and spicy Thai green curry with vegetables and coconut milk.',
            category: 'Asian',
            prepTime: 20,
            cookTime: 25,
            servings: 4,
            difficulty: 'Medium',
            ingredients: [
                { name: 'Green curry paste', quantity: '3', unit: 'tbsp' },
                { name: 'Coconut milk', quantity: '400', unit: 'ml' },
                { name: 'Chicken breast', quantity: '500', unit: 'g' },
                { name: 'Thai basil', quantity: '1', unit: 'bunch' }
            ],
            instructions: ['Fry curry paste in oil', 'Add coconut milk and bring to simmer', 'Add chicken and vegetables', 'Cook until chicken is done', 'Garnish with Thai basil'],
            images: ['https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?auto=format&fit=crop&q=80&w=800'],
            authorId: 'user-2',
            status: 'published',
            createdAt: new Date('2025-11-20').toISOString(),
            likedBy: ['user-1'],
            viewedBy: ['user-1', 'user-4'],
            tags: ['asian', 'dinner', 'spicy']
        },
        {
            id: 'recipe-4',
            title: 'Avocado Toast',
            description: 'Simple yet delicious avocado toast with poached eggs and chili flakes.',
            category: 'Breakfast',
            prepTime: 5,
            cookTime: 10,
            servings: 2,
            difficulty: 'Easy',
            ingredients: [
                { name: 'Avocado', quantity: '2', unit: '' },
                { name: 'Sourdough bread', quantity: '4', unit: 'slices' },
                { name: 'Eggs', quantity: '4', unit: '' },
                { name: 'Chili flakes', quantity: '1', unit: 'tsp' }
            ],
            instructions: ['Toast the bread until golden', 'Mash avocado and season', 'Poach eggs in simmering water', 'Spread avocado on toast', 'Top with poached eggs and chili'],
            images: ['https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?auto=format&fit=crop&q=80&w=800'],
            authorId: 'user-2',
            status: 'published',
            createdAt: new Date('2025-10-15').toISOString(),
            likedBy: ['user-4'],
            viewedBy: ['user-2', 'user-4'],
            tags: ['breakfast', 'healthy']
        },
        {
            id: 'recipe-5',
            title: 'Chocolate Lava Cake',
            description: 'Decadent chocolate cake with a molten center. Perfect for dessert lovers.',
            category: 'Dessert',
            prepTime: 15,
            cookTime: 12,
            servings: 4,
            difficulty: 'Hard',
            ingredients: [
                { name: 'Dark chocolate', quantity: '200', unit: 'g' },
                { name: 'Butter', quantity: '100', unit: 'g' },
                { name: 'Eggs', quantity: '4', unit: '' },
                { name: 'Sugar', quantity: '100', unit: 'g' }
            ],
            instructions: ['Melt chocolate and butter together', 'Whisk eggs and sugar until fluffy', 'Fold chocolate into egg mixture', 'Pour into ramekins', 'Bake at 200°C for 12 minutes'],
            images: ['https://images.unsplash.com/photo-1624353365286-3f8d62daad51?auto=format&fit=crop&q=80&w=800'],
            authorId: 'user-3',
            status: 'published',
            createdAt: new Date('2025-09-05').toISOString(),
            likedBy: ['user-3'],
            viewedBy: ['user-3'],
            tags: ['dessert', 'chocolate']
        },
        {
            id: 'recipe-6',
            title: 'Quinoa Buddha Bowl',
            description: 'Nutritious and colorful bowl packed with quinoa, roasted veggies, and tahini dressing.',
            category: 'Health',
            prepTime: 15,
            cookTime: 30,
            servings: 2,
            difficulty: 'Easy',
            ingredients: [
                { name: 'Quinoa', quantity: '150', unit: 'g' },
                { name: 'Sweet potato', quantity: '1', unit: 'large' },
                { name: 'Chickpeas', quantity: '200', unit: 'g' },
                { name: 'Tahini', quantity: '3', unit: 'tbsp' }
            ],
            instructions: ['Cook quinoa according to package', 'Roast diced sweet potato and chickpeas', 'Prepare tahini dressing', 'Assemble bowl with all ingredients', 'Drizzle with dressing'],
            images: ['https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=800'],
            authorId: 'user-4',
            status: 'published',
            createdAt: new Date('2025-12-20').toISOString(),
            likedBy: ['user-4'],
            viewedBy: ['user-3', 'user-4'],
            tags: ['healthy', 'lunch', 'vegan']
        },
        {
            id: 'recipe-7',
            title: 'Classic Beef Burger',
            description: 'Juicy homemade beef burger with all the fixings.',
            category: 'Dinner',
            prepTime: 20,
            cookTime: 15,
            servings: 4,
            difficulty: 'Medium',
            ingredients: [
                { name: 'Ground beef', quantity: '500', unit: 'g' },
                { name: 'Burger buns', quantity: '4', unit: '' },
                { name: 'Cheese slices', quantity: '4', unit: '' },
                { name: 'Lettuce', quantity: '4', unit: 'leaves' }
            ],
            instructions: ['Form beef into patties', 'Season with salt and pepper', 'Grill or pan-fry for 4-5 min per side', 'Toast buns', 'Assemble with toppings'],
            images: ['https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=800'],
            authorId: 'user-3',
            status: 'published',
            createdAt: new Date('2025-08-10').toISOString(),
            likedBy: ['user-1', 'user-2', 'user-3'],
            viewedBy: ['user-1', 'user-2', 'user-3', 'user-4'],
            tags: ['dinner', 'american']
        },
        {
            id: 'recipe-8',
            title: 'Mango Sticky Rice',
            description: 'Traditional Thai dessert with sweet coconut sticky rice and fresh mango.',
            category: 'Dessert',
            prepTime: 30,
            cookTime: 25,
            servings: 4,
            difficulty: 'Medium',
            ingredients: [
                { name: 'Sticky rice', quantity: '300', unit: 'g' },
                { name: 'Coconut milk', quantity: '400', unit: 'ml' },
                { name: 'Ripe mango', quantity: '2', unit: '' },
                { name: 'Palm sugar', quantity: '100', unit: 'g' }
            ],
            instructions: ['Soak sticky rice overnight', 'Steam rice until tender', 'Heat coconut milk with sugar', 'Pour half over rice', 'Serve with sliced mango and remaining sauce'],
            images: ['https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&q=80&w=800'],
            authorId: 'user-2',
            status: 'published',
            createdAt: new Date('2025-07-25').toISOString(),
            likedBy: ['user-2', 'user-4'],
            viewedBy: ['user-2', 'user-4'],
            tags: ['dessert', 'asian', 'thai']
        }
    ]
};

export { DEFAULT_AVATARS };

export const storage = {
    initialize: () => {
        if (!localStorage.getItem(STORAGE_KEYS.USERS)) {
            localStorage.setItem(STORAGE_KEYS.USERS, JSON.stringify(SEED_DATA.users));
        }
        if (!localStorage.getItem(STORAGE_KEYS.RECIPES)) {
            localStorage.setItem(STORAGE_KEYS.RECIPES, JSON.stringify(SEED_DATA.recipes));
        }
    },

    getUsers: () => JSON.parse(localStorage.getItem(STORAGE_KEYS.USERS) || '[]'),

    getRecipes: () => JSON.parse(localStorage.getItem(STORAGE_KEYS.RECIPES) || '[]'),

    saveUser: (user) => {
        const users = storage.getUsers();
        const existing = users.findIndex(u => u.id === user.id);
        if (existing >= 0) {
            users[existing] = user;
        } else {
            users.push(user);
        }
        localStorage.setItem(STORAGE_KEYS.USERS, JSON.stringify(users));
    },

    saveRecipe: (recipe) => {
        const recipes = storage.getRecipes();
        const existing = recipes.findIndex(r => r.id === recipe.id);
        if (existing >= 0) {
            recipes[existing] = recipe;
        } else {
            recipes.push(recipe);
        }
        localStorage.setItem(STORAGE_KEYS.RECIPES, JSON.stringify(recipes));
    },

    login: (email, password) => {
        const users = storage.getUsers();
        const user = users.find(u => u.email === email && u.password === password);
        if (user) {
            if (user.status !== 'active') throw new Error('Account is not active.');
            user.lastActive = new Date().toISOString();
            storage.saveUser(user);
            localStorage.setItem(STORAGE_KEYS.CURRENT_USER, JSON.stringify(user));
            return user;
        }
        throw new Error('Invalid credentials');
    },

    getCurrentUser: () => JSON.parse(localStorage.getItem(STORAGE_KEYS.CURRENT_USER)),

    logout: () => localStorage.removeItem(STORAGE_KEYS.CURRENT_USER),

    getReviews: (recipeId) => {
        const reviews = JSON.parse(localStorage.getItem(STORAGE_KEYS.REVIEWS) || '[]');
        if (recipeId) return reviews.filter(r => r.recipeId === recipeId);
        return reviews;
    },

    addReview: (review) => {
        const reviews = storage.getReviews();
        reviews.push({ ...review, id: `review-${Date.now()}`, createdAt: new Date().toISOString() });
        localStorage.setItem(STORAGE_KEYS.REVIEWS, JSON.stringify(reviews));
    },

    // Toggle favorite: add/remove recipe from user's favorites
    toggleFavorite: (userId, recipeId) => {
        const users = storage.getUsers();
        const user = users.find(u => u.id === userId);
        if (!user) return false;

        if (!user.favorites) user.favorites = [];
        const index = user.favorites.indexOf(recipeId);
        if (index >= 0) {
            user.favorites.splice(index, 1);
        } else {
            user.favorites.push(recipeId);
        }
        storage.saveUser(user);
        // Also update current user session
        const currentUser = storage.getCurrentUser();
        if (currentUser?.id === userId) {
            localStorage.setItem(STORAGE_KEYS.CURRENT_USER, JSON.stringify(user));
        }
        return user.favorites.includes(recipeId);
    },

    // Toggle like: add/remove user from recipe's likedBy
    toggleLike: (userId, recipeId) => {
        const recipes = storage.getRecipes();
        const recipe = recipes.find(r => r.id === recipeId);
        if (!recipe) return { liked: false, count: 0 };

        if (!recipe.likedBy) recipe.likedBy = [];
        const index = recipe.likedBy.indexOf(userId);
        if (index >= 0) {
            recipe.likedBy.splice(index, 1);
        } else {
            recipe.likedBy.push(userId);
        }
        storage.saveRecipe(recipe);
        return { liked: recipe.likedBy.includes(userId), count: recipe.likedBy.length };
    },

    // Record view: add user to recipe's viewedBy if not already present
    recordView: (userId, recipeId) => {
        const recipes = storage.getRecipes();
        const recipe = recipes.find(r => r.id === recipeId);
        if (!recipe) return 0;

        if (!recipe.viewedBy) recipe.viewedBy = [];
        if (!recipe.viewedBy.includes(userId)) {
            recipe.viewedBy.push(userId);
            storage.saveRecipe(recipe);
        }
        return recipe.viewedBy.length;
    },

    // Get like count for a recipe
    getLikeCount: (recipeId) => {
        const recipes = storage.getRecipes();
        const recipe = recipes.find(r => r.id === recipeId);
        return recipe?.likedBy?.length || 0;
    },

    // Check if user has liked a recipe
    hasUserLiked: (userId, recipeId) => {
        const recipes = storage.getRecipes();
        const recipe = recipes.find(r => r.id === recipeId);
        return recipe?.likedBy?.includes(userId) || false;
    },

    // Check if user has favorited a recipe
    hasUserFavorited: (userId, recipeId) => {
        const users = storage.getUsers();
        const user = users.find(u => u.id === userId);
        return user?.favorites?.includes(recipeId) || false;
    },

    // Get view count for a recipe
    getViewCount: (recipeId) => {
        const recipes = storage.getRecipes();
        const recipe = recipes.find(r => r.id === recipeId);
        return recipe?.viewedBy?.length || 0;
    },

    // Delete a recipe by ID
    deleteRecipe: (recipeId) => {
        const recipes = storage.getRecipes().filter(r => r.id !== recipeId);
        localStorage.setItem(STORAGE_KEYS.RECIPES, JSON.stringify(recipes));
        // Also clean up any reviews for this recipe
        const reviews = storage.getReviews().filter(r => r.recipeId !== recipeId);
        localStorage.setItem(STORAGE_KEYS.REVIEWS, JSON.stringify(reviews));
    },

    // Delete a review by ID
    deleteReview: (reviewId) => {
        const reviews = storage.getReviews().filter(r => r.id !== reviewId);
        localStorage.setItem(STORAGE_KEYS.REVIEWS, JSON.stringify(reviews));
    },

    // Get a single recipe by ID
    getRecipeById: (recipeId) => {
        const recipes = storage.getRecipes();
        return recipes.find(r => r.id === recipeId) || null;
    },

    // Clear all data and re-seed (for testing)
    resetData: () => {
        localStorage.removeItem(STORAGE_KEYS.USERS);
        localStorage.removeItem(STORAGE_KEYS.RECIPES);
        localStorage.removeItem(STORAGE_KEYS.REVIEWS);
        localStorage.removeItem(STORAGE_KEYS.CURRENT_USER);
        localStorage.removeItem(STORAGE_KEYS.DAILY_STATS);
        storage.initialize();
    },

    // Get daily stats object (keyed by date)
    getDailyStats: () => {
        return JSON.parse(localStorage.getItem(STORAGE_KEYS.DAILY_STATS) || '{}');
    },

    // Get today's stats
    getTodayStats: () => {
        const allStats = storage.getDailyStats();
        const today = getTodayKey();
        return allStats[today] || { newUsers: [], newContributors: [], activeUsers: [] };
    },

    // Record a new user registration
    recordNewUser: (userId, role = 'user') => {
        const allStats = storage.getDailyStats();
        const today = getTodayKey();
        
        if (!allStats[today]) {
            allStats[today] = { newUsers: [], newContributors: [], activeUsers: [] };
        }
        
        if (!allStats[today].newUsers.includes(userId)) {
            allStats[today].newUsers.push(userId);
        }
        
        // If user is a contributor (non-admin role that can create recipes)
        if (role === 'user' && !allStats[today].newContributors.includes(userId)) {
            allStats[today].newContributors.push(userId);
        }
        
        localStorage.setItem(STORAGE_KEYS.DAILY_STATS, JSON.stringify(allStats));
    },

    // Record an active user (DAU tracking)
    recordActiveUser: (userId) => {
        const allStats = storage.getDailyStats();
        const today = getTodayKey();
        
        if (!allStats[today]) {
            allStats[today] = { newUsers: [], newContributors: [], activeUsers: [] };
        }
        
        if (!allStats[today].activeUsers.includes(userId)) {
            allStats[today].activeUsers.push(userId);
        }
        
        localStorage.setItem(STORAGE_KEYS.DAILY_STATS, JSON.stringify(allStats));
    },

    // Get new users count for today (using date comparison against joinedDate)
    getNewUsersToday: () => {
        const users = storage.getUsers();
        const today = getTodayKey();
        return users.filter(u => u.joinedDate && u.joinedDate.startsWith(today));
    },

    // Get new contributors today (non-admin users joined today)
    getNewContributorsToday: () => {
        const users = storage.getUsers();
        const today = getTodayKey();
        return users.filter(u => u.role === 'user' && u.joinedDate && u.joinedDate.startsWith(today));
    },

    // Get daily active users (users who logged in today)
    getDailyActiveUsers: () => {
        const users = storage.getUsers();
        const today = getTodayKey();
        return users.filter(u => u.lastActive && u.lastActive.startsWith(today));
    },

    // Get daily views (recipes viewed today - sum of all recipe viewedBy where view was today)
    getDailyViews: () => {
        const recipes = storage.getRecipes();
        // For simplicity, return total unique views across all recipes
        // In a real app, you'd track view timestamps
        return recipes.reduce((total, r) => total + (r.viewedBy?.length || 0), 0);
    }
};
