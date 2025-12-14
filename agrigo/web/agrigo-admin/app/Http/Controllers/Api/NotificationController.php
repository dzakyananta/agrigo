<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class NotificationController extends Controller
{
    // Firebase Server Key dari Firebase Console
    private $firebaseServerKey = 'YOUR_FIREBASE_SERVER_KEY_HERE';

    // Save FCM token
    public function saveFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $user = $request->user();
        $user->fcm_token = $request->fcm_token;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'FCM token saved',
        ]);
    }

    // Send notification to user
    public function sendToUser($userId, $title, $body, $data = [])
    {
        $user = \App\Models\User::find($userId);

        if (!$user || !$user->fcm_token) {
            return false;
        }

        $notification = [
            'title' => $title,
            'body' => $body,
            'sound' => 'default',
        ];

        $fcmData = [
            'to' => $user->fcm_token,
            'notification' => $notification,
            'data' => $data,
        ];

        try {
            $response = Http::withHeaders([
                'Authorization' => 'key=' . $this->firebaseServerKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', $fcmData);

            return $response->successful();
        } catch (\Exception $e) {
            \Log::error('FCM Error: ' . $e->getMessage());
            return false;
        }
    }

    // Send harvest reminder (called by scheduler)
    public function sendHarvestReminder($scheduleId)
    {
        $schedule = \App\Models\Schedule::with('user', 'commodity')->find($scheduleId);

        if (!$schedule) {
            return;
        }

        $this->sendToUser(
            $schedule->user_id,
            'Pengingat Panen',
            "Waktu panen {$schedule->commodity->name} sudah dekat! Persiapkan alat panen Anda.",
            [
                'type' => 'harvest_reminder',
                'schedule_id' => $scheduleId,
            ]
        );
    }

    // Send transaction alert
    public function sendTransactionAlert($userId, $amount, $type)
    {
        $typeText = $type === 'income' ? 'Pemasukan' : 'Pengeluaran';
        
        $this->sendToUser(
            $userId,
            'Transaksi Baru',
            "$typeText sebesar Rp " . number_format($amount, 0, ',', '.') . " telah dicatat.",
            [
                'type' => 'transaction_alert',
                'amount' => $amount,
                'transaction_type' => $type,
            ]
        );
    }
}
