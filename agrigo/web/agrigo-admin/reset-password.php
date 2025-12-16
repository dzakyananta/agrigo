<?php
/**
 * Reset Password via Firebase Admin SDK
 * Endpoint untuk mengubah password user setelah OTP terverifikasi
 */

// Untuk debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set header JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Hanya terima POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed. Use POST.'
    ]);
    exit();
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Get email and new password
$email = $input['email'] ?? '';
$newPassword = $input['password'] ?? '';

// Validate input
if (empty($email) || empty($newPassword)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Email dan password harus diisi.'
    ]);
    exit();
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Format email tidak valid.'
    ]);
    exit();
}

// Validate password length
if (strlen($newPassword) < 6) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Password minimal 6 karakter.'
    ]);
    exit();
}

// Load Composer autoloader
require_once __DIR__ . '/vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\Exception\FirebaseException;

try {
    // Initialize Firebase Admin SDK
    $serviceAccountPath = __DIR__ . '/storage/firebase-credentials.json';
    
    if (!file_exists($serviceAccountPath)) {
        throw new Exception('Firebase credentials file not found');
    }
    
    $factory = (new Factory)->withServiceAccount($serviceAccountPath);
    $auth = $factory->createAuth();
    
    // Get user by email
    $user = $auth->getUserByEmail($email);
    
    // Update password
    $auth->updateUser($user->uid, [
        'password' => $newPassword
    ]);
    
    // Log success
    $logMessage = date('[Y-m-d H:i:s]') . " Password reset successful for {$email}\n";
    file_put_contents(__DIR__ . '/password_reset_logs.txt', $logMessage, FILE_APPEND);
    
    // Success response
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Password berhasil diubah. Silakan login dengan password baru.'
    ]);
    
} catch (FirebaseException $e) {
    // Log error
    $errorLog = date('[Y-m-d H:i:s]') . " Firebase Error: " . $e->getMessage() . " (Email: {$email})\n";
    file_put_contents(__DIR__ . '/password_reset_logs.txt', $errorLog, FILE_APPEND);
    
    // Error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Gagal mengubah password: ' . $e->getMessage()
    ]);
    
} catch (Exception $e) {
    // Log error
    $errorLog = date('[Y-m-d H:i:s]') . " Error: " . $e->getMessage() . " (Email: {$email})\n";
    file_put_contents(__DIR__ . '/password_reset_logs.txt', $errorLog, FILE_APPEND);
    
    // Error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Terjadi kesalahan: ' . $e->getMessage()
    ]);
}
