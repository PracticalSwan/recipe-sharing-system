# Recipe Sharing System

A collaborative web application that enables users to share, discover, and interact with recipes. The system features role-based access for Admins, Contributors, and regular Users, with a robust recipe approval workflow and comprehensive recipe management capabilities.

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [System Architecture](#️-system-architecture)
- [User Roles & Functions](#-user-roles--functions)
  - [Admin Dashboard](#admin-dashboard)
  - [Contributor Module](#contributor-module)
  - [User Module](#user-module)
- [Installation & Setup](#-installation--setup)
- [Available Scripts](#-available-scripts)
- [Project Structure](#-project-structure)
- [Technologies Used](#️-technologies-used)
- [Data Storage](#-data-storage)
- [Security Considerations](#-security-considerations)
- [Support](#-support)

## 🎯 Overview

The Recipe Sharing System is built to facilitate a community-driven platform where:
- **Users** discover and interact with recipes through browsing, searching, and rating
- **Contributors** create and manage recipes, which undergo admin approval before publication
- **Admins** oversee the platform with analytics, user management, and content moderation

The system uses a **client-side storage approach** with localStorage, making it lightweight and suitable for demonstration and development purposes.

## ✨ Key Features

### Core Functionality
- ✅ User authentication with role-based access control (Admin, Contributor, User)
- ✅ Recipe submission with admin approval workflow
- ✅ Comprehensive recipe management (Create, Read, Update, Delete)
- ✅ Advanced recipe discovery (search, filtering, sorting)
- ✅ User profile management
- ✅ Recipe ratings and reviews (one review per user per recipe)
- ✅ Favorites/saved recipes functionality
- ✅ Admin dashboard with site analytics and metrics
- ✅ User and recipe management tools for admins
- ✅ Activity tracking system with real-time updates
- ✅ Last active timestamp tracking (updated on logout/browser close)
- ✅ Daily Active Users (DAU) tracking with session heartbeat
- ✅ Admin activity logging (user/recipe management actions)
- ✅ Data integrity enforcement (cascade cleanup on deletes)

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Recipe Sharing System                     │
├─────────────────────────────────────────────────────────────┤
│  Authentication & Authorization                             │
│  ├── Login / Registration (Shared)                           │
│  └── Role-based Access Control (Admin, Contributor, User)   │
├─────────────────────────────────────────────────────────────┤
│  Admin Module          Contributor Module    User Module     │
│  ├── Dashboard         ├── Profile Mgmt      ├── Home/Browse │
│  ├── User Mgmt         ├── Create Recipe     ├── Search      │
│  ├── Recipe Mgmt       ├── My Recipes        ├── Recipe View │
│  └── Analytics         └── Edit/Delete       ├── Favorites   │
│                                               └── Reviews     │
├─────────────────────────────────────────────────────────────┤
│  Local Storage (User Accounts, Recipes, Reviews & Ratings)  │
└─────────────────────────────────────────────────────────────┘
```

## 👥 User Roles & Functions

### Admin Dashboard

**Access:** Login with admin credentials (`admin@example.com` / `password`)

#### 1. **Dashboard & Analytics**
- View real-time metrics and site-wide analytics
- Track daily activity and user engagement
- **Recent Activity Feed:** Dynamic log showing latest admin actions (user status changes, recipe approvals/rejections, account deletions)

**Metrics Displayed:**
| Metric | Description |
|--------|-------------|
| Total Users | Total number of registered users |
| New Users | Number of new users registered today |
| Total Contributors | Total number of users with contributor role |
| New Contributors | Number of new contributors registered today |
| Total Published Recipes | Count of approved and visible recipes |
| Total Pending Recipes | Count of recipes awaiting approval |
| Daily Views | Site-wide page views per day |
| Daily Active Users (DAU) | Number of unique active users per day (with hourly heartbeat tracking) |

#### 2. **User Management**
- View a comprehensive list of all registered users in table format
- Display user details including:
  - Username
  - Email address
  - Account status (Active, Inactive, Pending, Suspended)
  - User role (Admin, Contributor, User)
  - Account creation date
  - Last activity timestamp (auto-updates on logout/browser close)
- Activate or deactivate user accounts (logs admin action)
- Delete user accounts from the system (logs admin action)

#### 3. **Recipe Management**
- **Recipe Approval Workflow:**
  - View all recipes (Pending, Approved, Rejected)
  - Approve pending recipes to make them visible to users (logs admin action)
  - Reject recipes with optional feedback (logs admin action)
  - Delete any recipe from the system with modal confirmation (auto-removes from all user favorites)
  - Preview complete recipe details (ingredients, instructions, contributor info)

**Recipe Management Table Displays:**
- Recipe ID
- Recipe title
- Recipe image thumbnail
- Contributor name
- Current status (Pending, Approved, Rejected)
- Created date
- Action buttons (View, Approve, Reject, Delete)

---

### Contributor Module

**Access:** Registration + Login as a Contributor

#### 1. **Authentication**
- **Registration:** Create account with:
  - First name & last name
  - Email address
  - Birthday
  - Password (with confirmation)
- **Login:** Email and password authentication
- **Logout:** Secure session termination

#### 2. **Profile Management**
Edit and manage your contributor profile with:
- Full name
- Bio/About section
- Avatar image
- Location
- Email address
- Cooking skill level (Beginner, Intermediate, Advanced)

#### 3. **Create Recipe**
Submit new recipes with comprehensive details:
- **Recipe Image:** Upload or link recipe photo
- **Title:** Recipe name
- **Description:** Detailed overview of the dish
- **Category:** Recipe type/tag (e.g., Breakfast, Dinner, Dessert)
- **Duration:** Prep time and cook time
- **Servings:** Number of people the recipe serves
- **Difficulty:** Easy, Medium, or Hard
- **Instructions:** Step-by-step cooking instructions
- **Ingredients:** List with name, quantity, and measurement unit

**Important:** Recipes remain **hidden** until approved by an admin

#### 4. **My Recipes**
- View all your submitted recipes with their current approval status
- **Edit recipes:** Modify any of your submitted recipes
- **Delete recipes:** Remove recipes from the system
- Track approval status of each recipe (Pending, Approved, Rejected)

---

### User Module

**Access:** Registration + Login as a User

#### 1. **Authentication**
- **Registration:** Create account with:
  - First name & last name
  - Email address
  - Birthday
  - Password (with confirmation)
- **Login:** Email and password authentication
- **Logout:** Secure session termination

#### 2. **Profile Management**
Edit and manage your user profile with:
- Full name
- Bio/About section
- Avatar image
- Location
- Email address
- Cooking skill level

#### 3. **Discover & Browse Recipes**
- View all approved recipes from the community
- See recipe details including images, descriptions, ingredients, and instructions
- Explore recipes from various contributors

#### 4. **Search & Filter**
**Search Functionality:**
- Keyword search across recipe titles and descriptions
- Real-time search results

**Filtering Options:**
- Filter by recipe category/tags
- Filter by difficulty level
- Filter by cooking time

**Sorting Options:**
- Sort by newest recipes
- Sort by highest ratings
- Sort by difficulty level

#### 5. **Saved Recipes (Favorites)**
- Save recipes to your personal collection
- View all saved recipes in one place
- Remove recipes from your saved list
- Quick access to favorite recipes for future reference

#### 6. **Reviews & Ratings**
- **Rate recipes** on a 1-5 star scale
- **Write reviews:** Submit detailed text reviews with your thoughts (one review per recipe)
- **Update reviews:** Edit your existing review on a recipe
- **View community ratings:** See average ratings and other user reviews
- **Delete your reviews:** Remove your own reviews anytime
- Contribute to recipe ratings that help the community discover great recipes

---

##  Installation & Setup

### Prerequisites
- **Node.js** v16 or higher
- **npm** (comes with Node.js)

### Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd recipe-sharing-system
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Start Development Server**
   ```bash
   npm run dev
   ```
   The application will open at `http://localhost:5173`

4. **Build for Production**
   ```bash
   npm run build
   ```

5. **Preview Production Build**
   ```bash
   npm run preview
   ```

## 📦 Available Scripts

| Script | Purpose |
|--------|---------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Build optimized production bundle |
| `npm run preview` | Preview the production build locally |
| `npm run lint` | Run ESLint to check code quality |

## 📁 Project Structure

```
recipe-sharing-system/
├── src/
│   ├── components/           # Reusable UI components
│   │   ├── layout/          # Navigation & layout components
│   │   │   ├── Navbar.jsx
│   │   │   └── Sidebar.jsx
│   │   ├── recipe/          # Recipe-specific components
│   │   │   └── RecipeCard.jsx
│   │   └── ui/              # Generic UI components
│   │       ├── Badge.jsx
│   │       ├── Button.jsx
│   │       ├── Card.jsx
│   │       ├── Input.jsx
│   │       ├── Modal.jsx
│   │       ├── Table.jsx
│   │       └── Tabs.jsx
│   ├── context/             # React context for state management
│   │   └── AuthContext.jsx  # Authentication, user state & session tracking
│   ├── layouts/             # Layout templates for different routes
│   │   ├── AdminLayout.jsx
│   │   ├── AuthLayout.jsx
│   │   └── RootLayout.jsx
│   ├── lib/                 # Utilities & helpers
│   │   ├── storage.js       # LocalStorage management, seed data & activity logging
│   │   └── utils.js         # Helper functions
│   ├── pages/               # Page components
│   │   ├── Auth/            # Authentication pages
│   │   │   ├── Login.jsx
│   │   │   └── Signup.jsx
│   │   ├── Admin/           # Admin pages
│   │   │   ├── AdminRecipes.jsx
│   │   │   ├── AdminStats.jsx
│   │   │   └── UserList.jsx
│   │   └── Recipe/          # Recipe & user pages
│   │       ├── CreateRecipe.jsx
│   │       ├── Home.jsx
│   │       ├── Profile.jsx
│   │       ├── RecipeDetail.jsx
│   │       └── Search.jsx
│   ├── App.jsx              # Main application component
│   ├── main.jsx             # Application entry point
│   └── index.css            # Global styles
├── public/                  # Static assets
├── package.json             # Project dependencies & scripts
├── vite.config.js          # Vite configuration
├── eslint.config.js        # ESLint configuration
└── README.md               # This file
```

## 🛠️ Technologies Used

### Frontend Framework
- **React** (v19.2.0) - Modern UI library
- **React Router DOM** (v7.12.0) - Client-side routing
- **React DOM** (v19.2.0) - React rendering engine

### Styling & UI
- **Tailwind CSS** (v4.1.18) - Utility-first CSS framework
- **Tailwind CSS Vite Plugin** (v4.1.18) - Build tool integration
- **Tailwind Merge** (v3.4.0) - Intelligent class merging
- **Lucide React** (v0.562.0) - Icon library

### Build & Development
- **Vite** (v7.2.4) - Fast build tool
- **Vite React Plugin** (v5.1.1) - React optimization for Vite
- **ESLint** (v9.39.1) - Code quality tool

### Utilities
- **Clsx** (v2.1.1) - Conditional className utility

## 💾 Data Storage

The application uses **browser localStorage** for data persistence:

### Stored Data
1. **User Accounts** - All registered user profiles and credentials
2. **Recipes** - All submitted recipes with their metadata
3. **Reviews & Ratings** - User feedback on recipes (enforces one per user per recipe)
4. **Session Data** - Current logged-in user information
5. **Daily Stats** - Page views, active users per day
6. **Activity Logs** - Admin action history (user management, recipe approvals)

### Initial Data
The application comes with **comprehensive seed data** including:
- Multiple admin accounts for testing admin workflows
- Sample user accounts with various roles and statuses (active, inactive, pending)
- Diverse sample recipes across different categories and difficulty levels
- Pre-filled reviews and ratings for demonstration
- Activity logs for admin dashboard

This allows you to immediately explore all features without creating accounts or recipes from scratch.

### Test Credentials

**Admin Accounts:**
| Email | Password | Name |
|-------|----------|------|
| `admin@cookhub.com` | `admin` | Admin (Primary) |
| `sarah.admin@cookhub.com` | `sarah123` | Sarah Chen |
| `mike.admin@cookhub.com` | `mike123` | Mike Johnson |

**Sample User Accounts:**
| Email | Password | Name | Role | Status |
|-------|----------|------|------|--------|
| `user@cookhub.com` | `user` | John Doe | User | Active |
| `maria@cookhub.com` | `maria123` | Maria Garcia | User | Active |
| `tom@cookhub.com` | `tom123` | Tom Baker | User | Active |
| `amy@cookhub.com` | `amy123` | Amy Wilson | User | Pending |
| `bob@cookhub.com` | `bob123` | Bob Smith | User | Inactive |
| `lisa@cookhub.com` | `lisa123` | Lisa Chen | Contributor | Active |
| `david@cookhub.com` | `david123` | David Kim | Contributor | Active |

### Resetting Data

To reset all data to the initial seed state, open the browser console and run:
```javascript
localStorage.clear();
location.reload();
```
Or use the storage utility:
```javascript
import { storage } from './src/lib/storage';
storage.resetData();
```

---

## 🔒 Security Considerations

- Passwords are stored in localStorage (for development only - use proper authentication in production)
- Consider implementing a backend API with secure token-based authentication for production
- Implement HTTPS for all communications
- Add proper input validation and sanitization
- Use secure cookie handling for session management

---

## 📧 Support

For issues, questions, or contributions, please contact the development team or submit an issue through the project repository.
