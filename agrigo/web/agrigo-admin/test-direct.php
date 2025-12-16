<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "🧪 Testing PHPMailer dengan Gmail...\n\n";

require 'E:/basedproject/agrigo/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Load .env
$envFile = __DIR__ . '/.env';
if (!file_exists($envFile)) {
    die("❌ .env tidak ditemukan!\n");
}

$env = [];
$lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
foreach ($lines as $line) {
    if (strpos($line, '#') === 0 || strpos($line, '=') === false) continue;
    list($key, $value) = explode('=', $line, 2);
    $env[trim($key)] = trim($value);
}

echo "📧 Username: " . $env['MAIL_USERNAME'] . "\n";
echo "🔑 Password: " . substr($env['MAIL_PASSWORD'], 0, 4) . "..." . substr($env['MAIL_PASSWORD'], -4) . "\n";
echo "🔌 Port: " . $env['MAIL_PORT'] . "\n";
echo "🔒 Encryption: " . $env['MAIL_ENCRYPTION'] . "\n\n";

$mail = new PHPMailer(true);

try {
    // Server settings
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = $env['MAIL_USERNAME'];
    $mail->Password = $env['MAIL_PASSWORD'];
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->Port = 465;
    $mail->SMTPDebug = 0;

    // Recipients
    $mail->setFrom($env['MAIL_USERNAME'], 'AgriGo OTP');
    $mail->addAddress('antacursor@gmail.com', 'Test User');

    // Content
    $mail->isHTML(true);
    $mail->Subject = 'Test OTP Email';
    $mail->Body = '<div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Test Email dari AgriGo</h2>
        <p>Kode OTP Anda adalah:</p>
        <h1 style="color: #4CAF50; font-size: 48px; letter-spacing: 10px;">12345</h1>
        <p>Kode ini berlaku selama 5 menit.</p>
    </div>';

    echo "📤 Mengirim email...\n";
    $mail->send();
    echo "✅ Email berhasil dikirim!\n";
    echo "📬 Silakan cek inbox antacursor@gmail.com\n";
    
} catch (Exception $e) {
    echo "❌ Email gagal dikirim!\n";
    echo "Error: {$mail->ErrorInfo}\n";
}
