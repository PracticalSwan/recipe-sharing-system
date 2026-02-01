# Recipe Sharing System

A collaborative web application that enables users to share, discover, and interact with recipes. The system features role-based access for Admins, Contributors, and regular Users, with a robust recipe approval workflow and comprehensive recipe management capabilities.

## 🎯 Overview

The Recipe Sharing System is built to facilitate a community-driven platform where:
- **Guests (Pending Users)** - New registrations start with pending status; can browse and search recipes while awaiting admin approval
- **Contributors (Active Users)** - Approved users with full platform access; create and manage recipes, interact with content through likes/favorites/reviews
- **Admins** - Oversee the platform with user activation, recipe approval workflows, analytics, and content moderation

The system uses a **client-side storage approach** with localStorage, making it lightweight and suitable for demonstration and development purposes.

## 🚀 Quick Start

Simply open `https://practicalswan.github.io/recipe-sharing-system-deploy/` in your web browser to start using the application. All data is stored locally in your browser's localStorage.

## 🔑 Test Credentials

**Admin Accounts:**
| Email | Password | Name |
|-------|----------|------|
| `admin@cookhub.com` | `admin` | Admin User |
| `olivia@cookhub.com` | `admin` | Olivia Admin |
| `marcus@cookhub.com` | `admin` | Marcus Admin |

**Sample User Accounts:**
| Email | Password | Name | Role | Status |
|-------|----------|------|------|--------|
| `user@cookhub.com` | `user` | John Doe | User | Active/Inactive |
| `maria@cookhub.com` | `maria123` | Maria Garcia | User | Active/Inactive |
| `tom@cookhub.com` | `tom123` | Tom Baker | User | Suspended |
| `amy@cookhub.com` | `amy123` | Amy Wilson | User | Pending |
| `kevin@cookhub.com` | `kevin123` | Kevin Tran | User | Pending |
| `sarah@cookhub.com` | `sarah123` | Sarah Kim | User | Active/Inactive |
| `daniel@cookhub.com` | `daniel123` | Daniel Rivera | User | Active/Inactive |
| `lina@cookhub.com` | `lina123` | Lina Patel | User | Active/Inactive |
| `omar@cookhub.com` | `omar123` | Omar Hassan | User | Pending |

## 📂 Source Code

For complete documentation, development setup, and source code, see the original repository: [PracticalSwan/recipe-sharing-system](https://github.com/PracticalSwan/recipe-sharing-system)

---

© 2026 Cookhub: Recipe Sharing System. All rights reserved.
