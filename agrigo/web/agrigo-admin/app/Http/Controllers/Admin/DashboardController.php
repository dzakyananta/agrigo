<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        // Get dashboard statistics
        $stats = [
            'total_users' => User::count(),
            'total_farmers' => User::where('role', 'farmer')->count(),
            'total_transactions' => Transaction::count(),
            'monthly_transactions' => Transaction::whereMonth('created_at', date('m'))
                ->whereYear('created_at', date('Y'))
                ->count(),
            'recent_users' => User::latest()->take(5)->get(),
            'recent_transactions' => Transaction::with(['user', 'commodity'])
                ->latest()
                ->take(10)
                ->get(),
            'monthly_revenue' => Transaction::whereMonth('created_at', date('m'))
                ->whereYear('created_at', date('Y'))
                ->sum('amount') ?: 0
        ];

        // Get monthly transaction data for chart (MySQL compatible)
        $monthlyData = Transaction::select(
            DB::raw("MONTH(created_at) as month"),
            DB::raw('COUNT(*) as count'),
            DB::raw('SUM(amount) as total')
        )
        ->whereYear('created_at', date('Y'))
        ->groupBy('month')
        ->get();

        return view('admin.dashboard', compact('stats', 'monthlyData'));
    }
}
