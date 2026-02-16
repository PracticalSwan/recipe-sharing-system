<!-- prettier-ignore -->
<div align="center">

# Recipe Sharing System

[![Build Status](https://img.shields.io/badge/Build-Passing-green?style=flat-square)](package.json)
[![Tests](https://img.shields.io/badge/Tests-127%2F127%20Passing-brightgreen?style=flat-square)](tests/e2e.spec.js)
[![React](https://img.shields.io/badge/React-19.2.0-blue?style=flat-square&logo=react)](https://react.dev)
[![Node](https://img.shields.io/badge/Node.js-18%2B-green?style=flat-square&logo=node.js)](https://nodejs.org)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

A collaborative web application for sharing, discovering, and interacting with recipes with role-based access control and comprehensive recipe management.

</div>

---

## Overview

A full-stack application with complete database integration featuring:

- Frontend: React 19.2 + Vite 7.3 + Tailwind CSS 4.1
- Backend: Plain PHP REST API with PDO + session-based authentication
- Database: MySQL/MariaDB (cookhub) with 13 tables, views, stored procedures, and triggers
- Testing: Playwright E2E test suite (127/127 tests passing)

**Approval Workflow**: New users register with "Pending" status, admins review and activate accounts, contributors submit recipes for admin approval, and activity tracking provides insights into platform engagement.

## Table of Contents

- [Overview](#overview) • [Features](#features) • [Architecture](#architecture) • [User Roles](#user-roles) • [Getting Started](#getting-started) • [Usage](#usage) • [Tech Stack](#tech-stack) • [Database](#database) • [Test Data](#test-data) • [Documentation](#documentation) • [License](#license)

## Features

- User authentication with role-based access control (Admin, Contributor, User)
- Recipe submission with admin approval workflow
- Comprehensive recipe management (Create, Read, Update, Delete)
- Advanced recipe discovery (search, filtering, sorting)
- User profile management
- Recipe ratings and reviews with upsert capability
- Favorites/saved recipes functionality
- Per-user unique recipe view tracking
- Interactive ingredient checklist while cooking
- Admin dashboard with real-time site analytics
- User and recipe management for admins
- Activity tracking with real-time updates
- Daily Active Users (DAU) tracking with session heartbeat
- Admin activity logging for audit trail

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│               Recipe Sharing System                      │
├──────────────────────────────────────────────────────────────┤
│  Authentication & Authorization                         │
│  ├── Registration → Initial Status: Pending            │
│  └── Role-based Access Control                         │
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
│  Testing: Playwright E2E (127 tests, full regression)  │
└──────────────────────────────────────────────────────────────┘
```

## User Roles

### Guest (Pending Users)
New registrations start with pending status. Can browse and search recipes while awaiting admin approval. Cannot create recipes, write reviews, or save favorites until activated.

### Contributor (Active Users)
Approved users with full platform access:
- Create and manage recipes
- Search and browse content
- Review and rate recipes
- Save favorites and like recipes
- Edit profile

### Admin Dashboard
Access with admin credentials (`admin@cookhub.com` / `admin`)

**Features:**

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

## Getting Started

### Prerequisites

- Node.js v18 or higher
- npm v9+
- XAMPP 8.x+ (Apache + MySQL + PHP)

### Installation

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

> [!NOTE]
> See [docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) for complete setup instructions.

### Production Build

```bash
npm run build
npm run preview
```

<a id="usage"></a>
## Usage

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

> [!NOTE]
> These credentials are seeded by `database/05_seed_users.sql` when the database scripts are executed.

**Reset Seed Data:**
1. Drop and recreate the `cookhub` database.
2. Re-run SQL scripts in order (`01_create_database.sql` through `14_backup_restore.sql`) as documented in `guides/SETUP_GUIDE_PHPMYADMIN.md`.
3. Log in again from the frontend after the database is re-seeded.

## Tech Stack

### Frontend
- React 19.2.0, React Router DOM 7.13.0
- Tailwind CSS 4.1.18
- Vite 7.2.4, ESLint 9.39.1

### Backend
- Plain PHP REST API with PDO
- Session-based authentication with HttpOnly cookies

### Database
- MySQL/MariaDB with 13 normalized tables
- Stored procedures, triggers, and views

## Database

**Storage**: MySQL/MariaDB through PHP API layer (`backend/api/*`)

**Database Features:**
- 13 normalized tables (3NF design) with proper constraints
- 2 views for complex queries (recipe statistics, user dashboard)
- 4 stored procedures + 1 function for complex operations
- 6 triggers for automatic logging and statistics updates
- Complete seed data and RESTful API with PDO
- Session-based authentication with HttpOnly cookies

**Tables:** `user`, `recipe`, `ingredient`, `instruction`, `recipe_image`, `review`, `favorite`, `like_record`, `recipe_view`, `search_history`, `daily_stat`, `activity_log`, `session`

## Test Data

The application includes comprehensive seed data for immediate exploration:

- 3 Admin accounts with different activity levels
- 9 User accounts spanning all statuses (Active, Inactive, Pending, Suspended)
- 14 diverse recipes across multiple categories (Breakfast, Lunch, Dinner, Dessert)
- Recipe metadata: views, likes, favorites, varying approval statuses (Published, Pending, Rejected)
- Pre-filled reviews and ratings from multiple users
- Sample favorites/bookmarks for user accounts
- Historical daily stats for analytics dashboard

> [!TIP]
> You can immediately explore all features without creating accounts or recipes from scratch.

---

## Documentation

| Document | Description |
|----------|-------------|
| [API Documentation](docs/API_DOCUMENTATION.md) | Complete REST API reference (40+ endpoints) |
| [Database Schema](docs/DATABASE_SCHEMA.md) | Full schema with ER diagram and table definitions |
| [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) | XAMPP setup, database, and production deployment |
| [Testing Guide](docs/TESTING_GUIDE.md) | Playwright E2E strategy and execution guide |
| [Implementation Plan](plan/upgrade-database-integration-1.md) | MySQL + PHP backend migration plan (100% complete) |
| [Changelog](CHANGELOG.md) | Version history |

---

## License

See [LICENSE](LICENSE) file for details.
