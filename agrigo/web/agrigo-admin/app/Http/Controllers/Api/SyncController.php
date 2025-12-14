<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Schedule;
use App\Models\Transaction;
use Illuminate\Http\Request;

class SyncController extends Controller
{
    public function syncUser(Request $request)
    {
        User::updateOrCreate(
            ['firebase_uid' => $request->firebase_uid],
            [
                'name' => $request->name,
                'email' => $request->email,
                'role' => $request->role ?? 'farmer',
                'password' => bcrypt(str_random(32)), // Random password
            ]
        );

        return response()->json(['success' => true]);
    }

    public function syncSchedule(Request $request)
    {
        $user = User::where('firebase_uid', $request->firebase_uid)->first();
        
        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        Schedule::updateOrCreate(
            ['firebase_schedule_id' => $request->firebase_schedule_id],
            [
                'user_id' => $user->id,
                'commodity_name' => $request->commodity_name,
                'start_date' => $request->start_date,
                'end_date' => $request->end_date,
                'notes' => $request->notes,
                'status' => $request->status,
            ]
        );

        return response()->json(['success' => true]);
    }

    public function syncTransaction(Request $request)
    {
        $user = User::where('firebase_uid', $request->firebase_uid)->first();
        
        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        Transaction::updateOrCreate(
            ['firebase_transaction_id' => $request->firebase_transaction_id],
            [
                'user_id' => $user->id,
                'type' => $request->type,
                'amount' => $request->amount,
                'description' => $request->description,
                'date' => $request->date,
            ]
        );

        return response()->json(['success' => true]);
    }
}
