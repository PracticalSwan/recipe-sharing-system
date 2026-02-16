<?php
// ============================================================================
// JSON Response Helpers
// File: backend/helpers/response.php
//
// Utility functions for sending standardized JSON responses from all API
// endpoints. Every response exits immediately after sending to prevent
// accidental additional output.
// ============================================================================

/**
 * Sends a generic JSON response wrapping data under a "data" key.
 * Used for returning fetched records (e.g., recipe lists, user details).
 */
function jsonResponse(mixed $data, int $status = 200): void {
    http_response_code($status);
    echo json_encode(['data' => $data]);
    exit;
}

/**
 * Sends an error JSON response with an "error" message string.
 * Used for validation failures, not-found, and other client errors.
 */
function errorResponse(string $message, int $status = 400): void {
    http_response_code($status);
    echo json_encode(['error' => $message]);
    exit;
}

/**
 * Sends a success JSON response with an optional data payload and message.
 * Used after create/update/delete operations to confirm the action.
 */
function successResponse(mixed $data = null, string $message = 'Success', int $status = 200): void {
    http_response_code($status);
    $response = ['message' => $message];
    if ($data !== null) {
        $response['data'] = $data;
    }
    echo json_encode($response);
    exit;
}
