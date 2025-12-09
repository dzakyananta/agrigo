<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\User;
use App\Models\Schedule;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index()
    {
        $notifications = Notification::with(['user', 'schedule'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        
        return view('notifications.index', compact('notifications'));
    }

    public function create()
    {
        $users = User::where('is_active', true)->get();
        $schedules = Schedule::where('status', 'active')->get();
        
        return view('notifications.create', compact('users', 'schedules'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'icon_type' => 'required|in:info,warning,success,schedule,error',
            'color_type' => 'required|in:green,orange,blue,red,yellow',
            'schedule_id' => 'nullable|exists:schedules,id',
            'scheduled_at' => 'nullable|date',
            'send_now' => 'boolean',
        ]);

        // If no user_id, it's a broadcast notification
        if (!$validated['user_id']) {
            $validated['user_id'] = null;
        }

        $validated['is_sent'] = $request->has('send_now');
        unset($validated['send_now']);

        Notification::create($validated);

        return redirect()->route('notifications.index')
            ->with('success', 'Notifikasi berhasil dibuat!');
    }

    public function show(Notification $notification)
    {
        $notification->load(['user', 'schedule']);
        return view('notifications.show', compact('notification'));
    }

    public function destroy(Notification $notification)
    {
        $notification->delete();

        return redirect()->route('notifications.index')
            ->with('success', 'Notifikasi berhasil dihapus!');
    }

    public function sendBroadcast(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'icon_type' => 'required|in:info,warning,success,schedule,error',
            'color_type' => 'required|in:green,orange,blue,red,yellow',
        ]);

        $validated['is_sent'] = true;
        $validated['user_id'] = null; // Broadcast to all

        Notification::create($validated);

        return back()->with('success', 'Notifikasi broadcast berhasil dikirim ke semua pengguna!');
    }
}
