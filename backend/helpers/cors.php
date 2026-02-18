<?php
// CORS and security headers for React frontend (localhost:5173)
function setCorsHeaders(): void {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $allowedOrigins = ['http://localhost:5173', 'http://127.0.0.1:5173'];

    if (in_array($origin, $allowedOrigins, true)) {
        header("Access-Control-Allow-Origin: $origin");
    }

    header('Access-Control-Allow-Credentials: true');                    // Allow cookies
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Content-Type: application/json; charset=UTF-8');

    // Security headers
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('X-XSS-Protection: 1; mode=block');
    header('Referrer-Policy: strict-origin-when-cross-origin');

    // Handle preflight request
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}
