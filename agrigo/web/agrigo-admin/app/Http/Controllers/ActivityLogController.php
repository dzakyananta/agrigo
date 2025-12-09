<?php

namespace App\Http\Controllers;

use App\Models\ActivityLog;
use App\Models\User;
use Illuminate\Http\Request;

class ActivityLogController extends Controller
{
    public function index(Request $request)
    {
        $query = ActivityLog::with('user')->orderBy('created_at', 'desc');

        // Filter by module
        if ($request->has('module') && $request->module != '') {
            $query->where('module', $request->module);
        }

        // Filter by user
        if ($request->has('user_id') && $request->user_id != '') {
            $query->where('user_id', $request->user_id);
        }

        // Filter by date range
        if ($request->has('date_from') && $request->date_from) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        if ($request->has('date_to') && $request->date_to) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        $logs = $query->paginate(20);
        $users = User::all();
        $modules = ActivityLog::distinct('module')->pluck('module');

        return view('activity-logs.index', compact('logs', 'users', 'modules'));
    }

    public function show(ActivityLog $activityLog)
    {
        $activityLog->load('user');
        return view('activity-logs.show', compact('activityLog'));
    }

    public function destroy(ActivityLog $activityLog)
    {
        $activityLog->delete();

        return redirect()->route('activity-logs.index')
            ->with('success', 'Log aktivitas berhasil dihapus!');
    }

    public function clearOld(Request $request)
    {
        $days = $request->input('days', 30);
        $date = now()->subDays($days);

        $count = ActivityLog::where('created_at', '<', $date)->delete();

        return back()->with('success', "Berhasil menghapus {$count} log yang lebih lama dari {$days} hari!");
    }
}
