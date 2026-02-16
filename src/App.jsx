/**
 * Root application component with route definitions.
 * File: src/App.jsx
 *
 * Uses HashRouter (for static hosting compatibility) and organizes routes
 * into three layout groups:
 *   1. AuthLayout   — login/signup (public, no navbar)
 *   2. RootLayout   — authenticated user pages (navbar + sidebar)
 *   3. AdminLayout  — admin-only pages (requires role='admin')
 *
 * The AuthProvider wraps the entire tree so any component can access
 * the current user via useAuth().
 */
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { AuthLayout } from './layouts/AuthLayout';
import { RootLayout } from './layouts/RootLayout';
import { AdminLayout } from './layouts/AdminLayout';

import { Login } from './pages/Auth/Login';
import { Signup } from './pages/Auth/Signup';
import { Home } from './pages/Recipe/Home';
import { Search } from './pages/Recipe/Search';
import { RecipeDetail } from './pages/Recipe/RecipeDetail';
import { CreateRecipe } from './pages/Recipe/CreateRecipe';
import { Profile } from './pages/Recipe/Profile';

import { AdminStats } from './pages/Admin/AdminStats';
import { UserList } from './pages/Admin/UserList';
import { AdminRecipes } from './pages/Admin/AdminRecipes';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          {/* Auth Routes — public pages (no navbar) */}
          <Route element={<AuthLayout />}>
            <Route path="/login" element={<Login />} />
            <Route path="/signup" element={<Signup />} />
          </Route>

          {/* User Routes — require authentication */}
          <Route element={<RootLayout />}>
            <Route path="/" element={<Home />} />
            <Route path="/search" element={<Search />} />
            <Route path="/recipes/create" element={<CreateRecipe />} />
            <Route path="/recipes/edit/:id" element={<CreateRecipe />} />   {/* Reuses CreateRecipe in edit mode */}
            <Route path="/recipes/:id" element={<RecipeDetail />} />
            <Route path="/profile" element={<Profile />} />                 {/* Own profile */}
            <Route path="/users/:userId" element={<Profile />} />           {/* Other user's profile */}
            <Route path="/recipes/my-recipes" element={<Profile activeTab="recipes" />} />
          </Route>

          {/* Admin Routes — require role='admin' */}
          <Route path="/admin" element={<AdminLayout />}>
            <Route index element={<AdminStats />} />
            <Route path="users" element={<UserList />} />
            <Route path="recipes" element={<AdminRecipes />} />
          </Route>

          {/* Catch-all: redirect unknown paths to home */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
