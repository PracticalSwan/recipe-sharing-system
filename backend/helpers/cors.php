<?php
// ============================================================================
// CORS Headers Helper
// File: backend/helpers/cors.php
//
// Sets Cross-Origin Resource Sharing (CORS) headers so the React frontend
// (Vite dev server on localhost:5173) can communicate with the PHP backend.
// Also applies security headers to all API responses.
// ============================================================================

/**
 * Sets CORS, security, and content-type headers on every API response.
 * Handles OPTIONS preflight requests by returning 200 immediately.
 */
function setCorsHeaders(): void {
    // Only allow requests from known frontend origins
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $allowedOrigins = ['http://localhost:5173', 'http://127.0.0.1:5173'];

    if (in_array($origin, $allowedOrigins, true)) {
        header("Access-Control-Allow-Origin: $origin");
    }

    // Allow cookies to be sent cross-origin (needed for session cookie)
    header('Access-Control-Allow-Credentials: true');
    // Permitted HTTP methods for API requests
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    // Permitted request headers from the frontend
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    // All responses are JSON
    header('Content-Type: application/json; charset=UTF-8');

    // ----- Security headers -----
    header('X-Content-Type-Options: nosniff');                   // Prevent MIME-type sniffing
    header('X-Frame-Options: DENY');                             // Block clickjacking via iframes
    header('X-XSS-Protection: 1; mode=block');                   // Legacy XSS filter for older browsers
    header('Referrer-Policy: strict-origin-when-cross-origin');  // Limit referrer leakage

    // Handle preflight OPTIONS request — browser sends this before actual request
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}
