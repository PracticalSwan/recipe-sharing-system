<?php
// Standardized JSON response and centralized API error handling.

/**
 * Enable strict PHP error handling and convert uncaught failures to JSON responses.
 */
function initializeErrorHandling(): void {
    static $initialized = false;
    if ($initialized) {
        return;
    }

    $initialized = true;

    ini_set('display_errors', '0');
    error_reporting(E_ALL);

    set_error_handler(static function (int $severity, string $message, string $file, int $line): bool {
        if (!(error_reporting() & $severity)) {
            return false;
        }
        throw new ErrorException($message, 0, $severity, $file, $line);
    });

    set_exception_handler(static function (Throwable $exception): void {
        logServerThrowable($exception);

        $message = 'An unexpected server error occurred';
        if (isDebugModeEnabled()) {
            $message = $exception->getMessage();
        }

        errorResponse($message, 500, 'internal_server_error');
    });

    register_shutdown_function(static function (): void {
        $lastError = error_get_last();
        if ($lastError === null) {
            return;
        }

        $fatalErrorTypes = [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR, E_USER_ERROR];
        if (!in_array($lastError['type'], $fatalErrorTypes, true)) {
            return;
        }

        $message = 'A fatal server error occurred';
        if (isDebugModeEnabled()) {
            $message = $lastError['message'];
        }

        if (!headers_sent()) {
            sendJsonPayload([
                'error' => $message,
                'code' => 'fatal_server_error',
            ], 500);
        }
    });
}

// Send data response (e.g., lists, details)
function jsonResponse(mixed $data, int $status = 200): void {
    sendJsonPayload(['data' => $data], $status);
}

// Send error response
function errorResponse(string $message, int $status = 400, ?string $code = null, ?array $details = null): void {
    $payload = [
        'error' => $message,
    ];

    if ($code !== null && $code !== '') {
        $payload['code'] = $code;
    }

    if ($details !== null && $details !== []) {
        $payload['details'] = $details;
    }

    sendJsonPayload($payload, $status);
}

// Send success response with optional data
function successResponse(mixed $data = null, string $message = 'Success', int $status = 200): void {
    $response = ['message' => $message];
    if ($data !== null) {
        $response['data'] = $data;
    }
    sendJsonPayload($response, $status);
}

function sendJsonPayload(array $payload, int $status): void {
    $statusCode = ($status >= 100 && $status <= 599) ? $status : 500;

    if (!headers_sent()) {
        header('Content-Type: application/json; charset=UTF-8');
    }
    http_response_code($statusCode);
    echo encodeJsonSafely($payload);
    exit;
}

function encodeJsonSafely(array $payload): string {
    try {
        return json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE | JSON_THROW_ON_ERROR);
    } catch (Throwable) {
        return '{"error":"Failed to encode response payload"}';
    }
}

function isDebugModeEnabled(): bool {
    $rawValue = $_ENV['APP_DEBUG'] ?? getenv('APP_DEBUG');
    if ($rawValue === false || $rawValue === null) {
        return false;
    }

    $normalized = strtolower(trim((string) $rawValue));
    return in_array($normalized, ['1', 'true', 'yes', 'on'], true);
}

function logServerThrowable(Throwable $exception): void {
    error_log(sprintf(
        '[API ERROR] %s in %s:%d',
        $exception->getMessage(),
        $exception->getFile(),
        $exception->getLine()
    ));
}
