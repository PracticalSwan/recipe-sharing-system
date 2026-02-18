<?php
// Standardized JSON response helpers for API endpoints

// Send data response (e.g., lists, details)
function jsonResponse(mixed $data, int $status = 200): void {
    http_response_code($status);
    echo json_encode(['data' => $data]);
    exit;
}

// Send error response
function errorResponse(string $message, int $status = 400): void {
    http_response_code($status);
    echo json_encode(['error' => $message]);
    exit;
}

// Send success response with optional data
function successResponse(mixed $data = null, string $message = 'Success', int $status = 200): void {
    http_response_code($status);
    $response = ['message' => $message];
    if ($data !== null) {
        $response['data'] = $data;
    }
    echo json_encode($response);
    exit;
}
