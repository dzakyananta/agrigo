<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class OtpController extends Controller
{
    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp'   => 'required'
        ]);

        $mail = new PHPMailer(true);

        try {
            // SMTP CONFIG
            $mail->isSMTP();
            $mail->Host       = 'smtp.gmail.com';
            $mail->SMTPAuth   = true;

            // EMAIL YANG PUNYA APP PASSWORD
            $mail->Username   = 'serverdocker22@gmail.com';
            $mail->Password   = 'stnbtftirxjrctqw';

            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
            $mail->Port       = 465;

            // EMAIL CONTENT
            $mail->setFrom('serverdocker22@gmail.com', 'Agrigo');
            $mail->addAddress($request->email);

            $mail->isHTML(true);
            $mail->Subject = 'Kode OTP Reset Password';
            $mail->Body    = "
                <h2>Kode OTP Anda</h2>
                <h1>{$request->otp}</h1>
            ";

            $mail->send();

            return response()->json([
                'success' => true,
                'message' => 'OTP berhasil dikirim'
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'error'   => $mail->ErrorInfo
            ], 500);
        }
    }
}
