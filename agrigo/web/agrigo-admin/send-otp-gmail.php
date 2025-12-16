<?php
/**
 * Send OTP via Gmail menggunakan PHPMailer
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

require_once 'E:/basedproject/agrigo/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;

function loadEnv($path) {
    if (!file_exists($path)) return false;
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            list($key, $value) = explode('=', $line, 2);
            putenv(trim($key) . '=' . trim($value, '"\''));
        }
    }
    return true;
}

loadEnv(__DIR__ . '/.env');

$email = $_POST['email'] ?? '';
$otp = $_POST['otp'] ?? '';

if (empty($email) || empty($otp)) {
    echo json_encode(['success' => false, 'message' => 'Email dan OTP harus diisi']);
    exit();
}

try {
    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = getenv('MAIL_USERNAME');
    $mail->Password = getenv('MAIL_PASSWORD');
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->Port = 465;
    $mail->Timeout = 10;
    $mail->SMTPDebug = 0; // 0 = off, 2 = verbose
    
    $mail->setFrom(getenv('MAIL_FROM_ADDRESS'), 'Agrigo');
    $mail->addAddress($email);
    $mail->isHTML(true);
    $mail->CharSet = 'UTF-8';
    $mail->Subject = 'Kode OTP Reset Password - Agrigo';
    $mail->Body = "<h2>Kode OTP Anda</h2><h1 style='color:#4CAF50;font-size:36px;letter-spacing:8px;'>{$otp}</h1><p>Berlaku 5 menit</p>";
    
    $mail->send();
    file_put_contents(__DIR__ . '/otp_logs.txt', date('[Y-m-d H:i:s]') . " OTP {$otp} → {$email}\n", FILE_APPEND);
    echo json_encode(['success' => true, 'message' => 'OTP terkirim', 'email' => $email]);
    
} catch (Exception $e) {
    file_put_contents(__DIR__ . '/otp_logs.txt', date('[Y-m-d H:i:s]') . " ERROR: {$mail->ErrorInfo}\n", FILE_APPEND);
    echo json_encode(['success' => false, 'message' => 'Gagal kirim: ' . $mail->ErrorInfo]);
}
