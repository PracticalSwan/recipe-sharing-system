<?php
// Singleton database connection for CookHub Recipe Sharing System
class Database {
    private static ?PDO $instance = null;

    // XAMPP MySQL connection settings
    private static string $host = 'localhost';
    private static string $dbname = 'cookhub';
    private static string $username = 'root';
    private static string $password = '';
    private static string $charset = 'utf8mb4'; // Supports emojis

    // Get or create the shared PDO connection
    public static function getConnection(): PDO {
        if (self::$instance === null) {
            $dsn = "mysql:host=" . self::$host . ";dbname=" . self::$dbname . ";charset=" . self::$charset;
            self::$instance = new PDO($dsn, self::$username, self::$password, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,   // Throw on SQL errors
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,          // Return arrays
                PDO::ATTR_EMULATE_PREPARES   => false,                     // Use real prepares
            ]);
        }
        return self::$instance;
    }

    // Singleton: prevent direct instantiation
    private function __construct() {}
    private function __clone() {}
}
