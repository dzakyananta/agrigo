<?php
/**
 * Send OTP - DEMO MODE
 * Untuk testing tanpa kirim email asli
 * Di produksi, ganti dengan PHPMailer yang benar
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

$email = $_POST['email'] ?? '';
$otp = $_POST['otp'] ?? '';

if (empty($email) || empty($otp)) {
    echo json_encode(['success' => false, 'message' => 'Email dan OTP harus diisi']);
    exit();
}

// Log OTP ke file (untuk testing - di produksi kirim email asli)
$log = date('[Y-m-d H:i:s]') . " OTP: {$otp} untuk {$email}\n";
file_put_contents(__DIR__ . '/otp_logs.txt', $log, FILE_APPEND);

// Return success
echo json_encode([
    'success' => true,
    'message' => 'OTP berhasil di-generate. Cek file otp_logs.txt',
    'email' => $email,
    'otp' => $otp,
    'note' => 'DEMO MODE: Email tidak dikirim. Setup Gmail App Password untuk produksi.'
]);
