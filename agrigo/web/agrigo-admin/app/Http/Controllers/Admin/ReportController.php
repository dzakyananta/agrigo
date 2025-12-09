<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Commodity;
use App\Models\Schedule;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function index()
    {
        // Overall statistics
        $totalTransactions = Transaction::count();
        $totalIncome = Transaction::where('type', 'income')->sum('amount');
        $totalExpense = Transaction::where('type', 'expense')->sum('amount');
        $netProfit = $totalIncome - $totalExpense;

        // Commodity statistics
        $topCommodities = Transaction::select('commodity_id', DB::raw('COUNT(*) as transaction_count'), DB::raw('SUM(amount) as total_amount'))
            ->whereNotNull('commodity_id')
            ->groupBy('commodity_id')
            ->orderBy('transaction_count', 'desc')
            ->limit(5)
            ->with('commodity')
            ->get();

        // Monthly transactions
        $monthlyData = Transaction::select(
                DB::raw('MONTH(date) as month'),
                DB::raw('SUM(CASE WHEN type = "income" THEN amount ELSE 0 END) as income'),
                DB::raw('SUM(CASE WHEN type = "expense" THEN amount ELSE 0 END) as expense')
            )
            ->whereYear('date', date('Y'))
            ->groupBy('month')
            ->orderBy('month')
            ->get();

        // Active schedules
        $activeSchedules = Schedule::where('status', 'active')->count();
        $completedSchedules = Schedule::where('status', 'completed')->count();

        // User statistics
        $totalFarmers = User::where('role', 'farmer')->count();
        $activeUsers = User::where('is_active', true)->count();

        return view('admin.reports.index', compact(
            'totalTransactions',
            'totalIncome',
            'totalExpense',
            'netProfit',
            'topCommodities',
            'monthlyData',
            'activeSchedules',
            'completedSchedules',
            'totalFarmers',
            'activeUsers'
        ));
    }
}
