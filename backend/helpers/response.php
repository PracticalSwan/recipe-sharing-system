<?php
// ============================================================================
// JSON Response Helpers
// ============================================================================

function jsonResponse(mixed $data, int $status = 200): void {
    http_response_code($status);
    echo json_encode(['data' => $data]);
    exit;
}

function errorResponse(string $message, int $status = 400): void {
    http_response_code($status);
    if ($status === 500) {
        // Log the detailed error message for debugging, but hide it from the user
        error_log("Internal Server Error: " . $message);
        $message = 'An internal server error occurred';
    }
    echo json_encode(['error' => $message]);
    exit;
}

function successResponse(mixed $data = null, string $message = 'Success', int $status = 200): void {
    http_response_code($status);
    $response = ['message' => $message];
    if ($data !== null) {
        $response['data'] = $data;
    }
    echo json_encode($response);
    exit;
}
