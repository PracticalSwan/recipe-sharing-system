<?php
// ============================================================================
// Database Configuration - PDO Singleton Connection
// Project: CookHub Recipe Sharing System
// File: backend/config/database.php
//
// Provides a single shared database connection using the Singleton pattern.
// All API endpoints call Database::getConnection() to obtain the PDO instance.
// ============================================================================

class Database {
    // Holds the single PDO instance (null until first call)
    private static ?PDO $instance = null;

    // ----- Connection credentials (XAMPP defaults) -----
    private static string $host = 'localhost';
    private static string $dbname = 'cookhub';
    private static string $username = 'root';
    private static string $password = '';
    private static string $charset = 'utf8mb4'; // Supports emojis & special characters

    /**
     * Returns the shared PDO connection, creating it on first call.
     * PDO options:
     *  - ERRMODE_EXCEPTION  → Throws exceptions on SQL errors
     *  - FETCH_ASSOC        → Returns rows as associative arrays
     *  - EMULATE_PREPARES=false → Uses real prepared statements for security
     */
    public static function getConnection(): PDO {
        if (self::$instance === null) {
            $dsn = "mysql:host=" . self::$host . ";dbname=" . self::$dbname . ";charset=" . self::$charset;
            self::$instance = new PDO($dsn, self::$username, self::$password, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]);
        }
        return self::$instance;
    }

    // Prevent instantiation, cloning, and unserialization (Singleton enforcement)
    private function __construct() {}
    private function __clone() {}
}
