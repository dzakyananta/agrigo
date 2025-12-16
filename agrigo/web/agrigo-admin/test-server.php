<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

$email = $_POST['email'] ?? '';
$otp = $_POST['otp'] ?? '';

if (empty($email) || empty($otp)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email dan OTP harus diisi']);
    exit();
}

// Log untuk debugging
$log = date('[Y-m-d H:i:s]') . " TEST: OTP $otp untuk $email\n";
file_put_contents(__DIR__ . '/test_logs.txt', $log, FILE_APPEND);

// Return success tanpa mengirim email (untuk testing)
http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'TEST MODE: OTP diterima di server',
    'email' => $email,
    'otp' => $otp
]);
