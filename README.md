# Recipe Sharing System

A collaborative web application that enables users to share, discover, and interact with recipes. The system features role-based access for Admins, Contributors, and regular Users, with a robust recipe approval workflow and comprehensive recipe management capabilities.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [User Roles & Functions](#user-roles-functions)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Technologies](#technologies)
- [Data & Database](#data-database)
- [Available Scripts](#available-scripts)
- [Documentation](#documentation)
- [Test Data](#test-data)
- [License](#license)
- [Contributing](#contributing)

<a id="overview"></a>
## Overview

The Recipe Sharing System is a full-stack application with complete database integration (all 6 phases implemented):

- **Frontend:** React 19.2 + Vite 7.3 + Tailwind CSS 4.1
- **Backend:** Plain PHP REST API (PDO + prepared statements + session-based auth)
- **Database:** MySQL/MariaDB (cookhub) with 13 tables, views, stored procedures, and triggers
- **Testing:** Playwright E2E test suite (35/35 tests passing)

### Recent Fixes (2026-02-14)

- Fixed recipe card navigation so opening a recipe consistently stays on the detail route (`/#/recipes/:id`) instead of bouncing back to home.
- Fixed recipe edit loading (`/#/recipes/edit/:id`) by aligning frontend payload parsing with the PHP API response shape.
- Updated detail access logic so recipe owners can view their own non-published recipes.
- Updated search keyword behavior to match recipe titles explicitly and re-verified filter behavior (difficulty/search combinations).
- Re-verified navigation, likes, and search/filter flows with Playwright targeted runs.

### Approval Workflow

The system features a comprehensive approval workflow where:

1. New users register → Account created with "Pending" status
2. Admin reviews and activates user accounts
3. Contributors submit recipes → Admin approves before publication
4. Activity tracking and analytics provide insights into platform engagement

<a id="key-features"></a>
## Key Features

- User authentication with role-based access control (Admin, Contributor, User)
- Recipe submission with admin approval workflow
- Comprehensive recipe management (Create, Read, Update, Delete)
- Advanced recipe discovery (search, filtering, sorting)
- User profile management
- Recipe ratings and reviews (one review per user per recipe)
- Favorites/saved recipes functionality
- Interactive ingredient checklist to mark off ingredients while cooking
- Admin dashboard with site analytics and metrics
- User and recipe management tools for admins
- Activity tracking system with real-time updates
- Last active timestamp tracking (updated on logout/browser close)
- Daily Active Users (DAU) tracking with session heartbeat
- Admin activity logging for audit trail

<a id="system-architecture"></a>
## System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│               Recipe Sharing System                      │
├──────────────────────────────────────────────────────────────┤
│  Authentication & Authorization                         │
│  ├── Registration → Initial Status: Pending            │
│  └── Role-based Access Control                     │
├──────────────────────────────────────────────────────────────┤
│  Admin Module  Contributor Module   Guest Module (Pending)  │
│  ├── Dashboard   ├── Full Platform     ├── Browse Recipes    │
│  ├── User Mgmt    ├── Create Recipe     ├── Search & Filter   │
│  ├── Recipe Approv ├── My Recipes        ├── View Details      │
│  ├── Analytics     ├── Profile Mgmt     ├── View Reviews      │
│  └── Activity      ├── Favorites         └── Awaits Admin     │
│                    ├── Reviews & Ratings         Approval          │
│                    └── Likes & Engagement        Full Access        │
├──────────────────────────────────────────────────────────────┤
│  Data Layer: MySQL/MariaDB (cookhub) via PHP API       │
│  ├── User Accounts (credentials, profiles, roles)          │
│  ├── Recipes (content, status, metadata)                    │
│  ├── Reviews & Ratings (one per user per recipe)            │
│  ├── Daily Stats (views, active users, new users)           │
│  └── Activity Logs (admin actions, user management)       │
├──────────────────────────────────────────────────────────────┤
│  Testing: Playwright E2E (35 tests, 7 categories)      │
└──────────────────────────────────────────────────────────────┘
```

<a id="user-roles-functions"></a>
## User Roles & Functions

### Guest (Pending Users)
New registrations start with pending status; can browse and search recipes while awaiting admin approval. Guests cannot create recipes, write reviews, or save favorites until accounts are activated by admin.

### Contributor (Active Users)
Approved users with full platform access including:
- Create and manage recipes
- Search and browse content
- Review and rate recipes
- Save favorites
- Like recipes
- Edit profile

### Admin Dashboard
Access with admin credentials (`admin@cookhub.com` / `admin`)

**Features:**
- View real-time metrics and site-wide analytics
- Track daily activity and user engagement
- Recent Activity Feed showing latest admin actions
- Manage user accounts (activate, deactivate, delete)
- Recipe approval workflow (approve, reject, delete pending recipes)

**Metrics Displayed:**

| Metric | Description |
|----------|-------------|
| Total Users | Total number of registered users |
| New Users | Number of new users registered today |
| Total Contributors | Total number of users with contributor role |
| New Contributors | Number of new contributors registered today |
| Total Published Recipes | Count of approved and visible recipes |
| Total Pending Recipes | Count of recipes awaiting approval |
| Daily Views | Site-wide page views per day |
| Daily Active Users (DAU) | Number of unique active users per day (with hourly heartbeat tracking) |

<a id="installation"></a>
## Installation

### Prerequisites

- **Node.js** v18 or higher
- **npm** v9+
- **XAMPP** 8.x+ (Apache + MySQL + PHP)

### Quick Start

```bash
# Clone repository
git clone <repository-url>
cd recipe-sharing-system

# Install dependencies
npm install

# Link project to XAMPP (run as Administrator)
cmd /c mklink /J "C:\xampp\htdocs\recipe-sharing-system" "C:\path\to\recipe-sharing-system"

# Set up database (run SQL scripts in order via phpMyAdmin or CLI)
# See docs/DEPLOYMENT_GUIDE.md for full instructions

# Start development server
npm run dev
```

The application will open at `http://localhost:5173/recipe-sharing-system-deploy/`

> See [docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) for full setup instructions.

### Build for Production

```bash
# Build optimized bundle
npm run build

# Preview production build
npm run preview
```

<a id="usage"></a>
## Usage

### Test Credentials

**Admin Accounts:**

| Email | Password | Name |
|-------|----------|------|
| `admin@cookhub.com` | `admin` | Admin User |
| `olivia@cookhub.com` | `admin` | Olivia Admin |
| `marcus@cookhub.com` | `admin` | Marcus Admin |

**Sample User Accounts:**

| Email | Password | Name | Status |
|-------|----------|------|--------|
| `user@cookhub.com` | `user` | John Doe | Active |
| `maria@cookhub.com` | `maria123` | Maria Garcia | Active |
| `tom@cookhub.com` | `tom123` | Tom Baker | Suspended |
| `amy@cookhub.com` | `amy123` | Amy Wilson | Pending |
| `kevin@cookhub.com` | `kevin123` | Kevin Tran | Pending |
| `sarah@cookhub.com` | `sarah123` | Sarah Kim | Active |
| `daniel@cookhub.com` | `daniel123` | Daniel Rivera | Active |
| `lina@cookhub.com` | `lina123` | Lina Patel | Inactive |
| `omar@cookhub.com` | `omar123` | Omar Hassan | Pending |

> **Note:** These credentials are seeded by `database/05_seed_users.sql` when the database scripts are executed.

### Reset Seed Data (Database)

To reset the system to the initial seeded state:

1. Drop and recreate the `cookhub` database.
2. Re-run SQL scripts in order (`01_create_database.sql` through `14_backup_restore.sql`) as documented in `guides/SETUP_GUIDE_PHPMYADMIN.md`.
3. Log in again from the frontend after the database is re-seeded.

Seed execution note:
`database/05_seed_users.sql` and `database/08_seed_stats.sql` now preserve the current `@DISABLE_TRIGGERS` state, so they work correctly both standalone and inside wrapper rebuild sequences.

<a id="project-structure"></a>
## Project Structure

```
recipe-sharing-system/
├── database/                  # SQL database scripts (14 files)
│   ├── 01_create_database.sql      # Database creation
│   ├── 02_create_tables.sql       # 13 tables (user, recipe, review, etc.)
│   ├── 03_create_indexes.sql       # Performance indexes
│   ├── 04_create_views.sql         # 2 views (statistics, dashboard)
│   ├── 05_seed_users.sql          # User accounts (12 users)
│   ├── 06_seed_recipes.sql         # Recipe data + ingredients + instructions
│   ├── 07_seed_reviews.sql         # Reviews + likes + favorites
│   ├── 08_seed_stats.sql           # Daily stats + activity logs
│   ├── 09_common_queries.sql       # Common SELECT queries
│   ├── 10_admin_queries.sql        # Admin management queries
│   ├── 11_analytics_queries.sql     # Analytics & trends
│   ├── 12_stored_procedures.sql   # 4 procedures + 1 function
│   ├── 13_triggers.sql            # 6 triggers for automation
│   └── 14_backup_restore.sql      # Backup & restore commands
├── guides/                    # Documentation guides
│   ├── database_implementation_logic_explanation.md
│   ├── SETUP_GUIDE_PHPMYADMIN.md
│   └── SQL_SCRIPTS.md
├── plan/                      # Development planning documents
│   └── upgrade-database-integration-1.md  # MySQL + PHP backend migration plan
├── src/
│   ├── components/           # Reusable UI components
│   │   ├── layout/          # Navigation & layout components
│   │   ├── recipe/          # Recipe-specific components
│   │   └── ui/              # Generic UI components
│   ├── context/             # React context (AuthContext)
│   ├── layouts/             # Layout templates
│   ├── lib/                 # Utilities & helpers
│   ├── pages/               # Page components
│   │   ├── Auth/            # Authentication pages
│   │   ├── Admin/           # Admin dashboard pages
│   │   └── Recipe/          # Recipe & user pages
│   ├── App.jsx              # Main application component
│   ├── main.jsx             # Application entry point
│   └── index.css            # Global styles
├── backend/                   # PHP REST API
│   ├── api/                 # API endpoint modules (7 files)
│   ├── config/              # Database configuration
│   └── helpers/             # Auth, CORS, response helpers
├── docs/                      # Generated documentation
│   ├── API_DOCUMENTATION.md   # Full API reference
│   ├── DATABASE_SCHEMA.md     # Database schema docs
│   ├── DEPLOYMENT_GUIDE.md    # Setup & deployment guide
│   └── TESTING_GUIDE.md       # Testing documentation
├── tests/                     # Playwright E2E tests
│   └── e2e.spec.js            # 35 test scenarios
├── public/                    # Static assets
├── playwright.config.js       # Playwright configuration
├── CHANGELOG.md               # Version changelog
├── package.json               # Dependencies & scripts
└── README.md                  # This file
```

<a id="technologies"></a>
## Technologies

### Frontend

- **React** (v19.2.0) - Modern UI library
- **React Router DOM** (v7.13.0) - Client-side routing
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
- **date-fns** (v4.1.0) - Date formatting and manipulation

<a id="data-database"></a>
## Data & Database

### Current Storage: MySQL/MariaDB via PHP API

The application now persists data in **MySQL/MariaDB** through the PHP API layer (`backend/api/*`). The legacy localStorage service has been removed from runtime usage (`src/lib/storage.js`).

### Database Integration Status

Database and API integration for Phases 1-5 is implemented as part of the CSX3006 Database Systems project plan.

**Database Features:**
- 13 normalized tables (3NF design) with proper constraints
- 2 views for complex queries (recipe statistics, user dashboard)
- 4 stored procedures + 1 function for complex operations
- Stored procedure parameters follow `p_` snake_case naming
- 6 triggers for automatic logging and statistics updates
- Complete seed data matching current localStorage structure
- SQL scripts in `database/` are import-ready for phpMyAdmin with minimal (SQL-only) formatting
- Full RESTful API in plain PHP with PDO
- Session-based authentication with HttpOnly cookies

**Database Tables:**

| Table | Description |
|--------|-------------|
| `user` | User accounts with roles and status |
| `recipe` | Recipe metadata with status |
| `ingredient` | Recipe ingredients with quantity/unit |
| `instruction` | Step-by-step cooking instructions |
| `recipe_image` | Multiple images per recipe |
| `review` | Star ratings + comments |
| `favorite` | Saved/bookmarked recipes |
| `like_record` | Recipe likes |
| `recipe_view` | View tracking (authenticated users) |
| `search_history` | Search query history |
| `daily_stat` | Daily aggregation (views, active users, new users) |
| `activity_log` | Admin action audit trail |
| `session` | Server-side session tokens |

> **Progress:** View detailed implementation plan at [plan/upgrade-database-integration-1.md](plan/upgrade-database-integration-1.md) (100% complete — all 6 phases implemented)

<a id="available-scripts"></a>
## Available Scripts

| Script | Purpose |
|--------|---------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Build optimized production bundle |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint to check code quality |
| `npx playwright test` | Run E2E test suite (35 tests) |
| `npx playwright test --headed` | Run tests with visible browser |
| `npx playwright show-report` | View HTML test report |

<a id="documentation"></a>
## Documentation

### API & Backend

- [API Documentation](docs/API_DOCUMENTATION.md) — Complete REST API reference (40+ endpoints)
- [Database Schema](docs/DATABASE_SCHEMA.md) — Full schema with ER diagram and table definitions
- [Database README](database/README.md) — Database setup and SQL script reference

### Setup & Deployment

- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) — XAMPP setup, database, and production deployment
- [Database Setup Guide](guides/SETUP_GUIDE_PHPMYADMIN.md) — Step-by-step phpMyAdmin configuration

### Testing

- [Testing Guide](docs/TESTING_GUIDE.md) — Playwright E2E test suite with 35 test scenarios

### Planning & Design

- [Implementation Plan](plan/upgrade-database-integration-1.md) — MySQL + PHP backend migration plan (100% complete)
- [Database Logic Explanation](guides/database_implementation_logic_explanation.md) — Detailed SQL scripts documentation
- [SQL Scripts Reference](guides/SQL_SCRIPTS.md) — Complete SQL scripts catalog
- [Changelog](CHANGELOG.md) — Version history

<a id="test-data"></a>
## Test Data

The application comes with comprehensive seed data for immediate exploration including:

- 3 Admin accounts with different activity levels
- 9 User accounts spanning all statuses (Active, Inactive, Pending, Suspended)
- 14 diverse recipes across multiple categories (Breakfast, Lunch, Dinner, Dessert)
- Recipe metadata: views, likes, favorites, varying approval statuses (Published, Pending, Rejected)
- Pre-filled reviews and ratings from multiple users
- Sample favorites/bookmarks for user accounts
- Historical daily stats for analytics dashboard

This rich seed data allows you to immediately explore all features without creating accounts or recipes from scratch.

<a id="license"></a>
## License

See [LICENSE](LICENSE) file for details.

<a id="contributing"></a>
## Contributing

For issues, questions, or contributions, please contact the development team or submit an issue through the project repository.
