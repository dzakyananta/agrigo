<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Commodity;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function index()
    {
        $transactions = Transaction::with(['user', 'commodity'])
            ->orderBy('date', 'desc')
            ->paginate(15);
        
        // Calculate statistics per user
        $userStats = Transaction::with('user')
            ->get()
            ->groupBy('user_id')
            ->map(function ($userTransactions) {
                $income = $userTransactions->where('type', 'income')->sum('amount');
                $expense = $userTransactions->where('type', 'expense')->sum('amount');
                return [
                    'user' => $userTransactions->first()->user,
                    'income' => $income,
                    'expense' => $expense,
                    'balance' => $income - $expense,
                    'transaction_count' => $userTransactions->count()
                ];
            });
            
        return view('admin.transactions.index', compact('transactions', 'userStats'));
    }

    public function create()
    {
        $users = User::where('role', 'farmer')->where('is_active', true)->get();
        $commodities = Commodity::where('is_active', true)->get();
        return view('admin.transactions.create', compact('users', 'commodities'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'commodity_id' => 'nullable|exists:commodities,id',
            'type' => 'required|in:income,expense',
            'source' => 'nullable|string|max:255',
            'amount' => 'required|numeric|min:0',
            'description' => 'required|string',
            'date' => 'required|date'
        ]);

        Transaction::create($request->all());

        return redirect()->route('admin.transactions.index')
            ->with('success', 'Transaction created successfully.');
    }

    public function edit($id)
    {
        $transaction = Transaction::findOrFail($id);
        $users = User::where('role', 'farmer')->where('is_active', true)->get();
        $commodities = Commodity::where('is_active', true)->get();
        return view('admin.transactions.edit', compact('transaction', 'users', 'commodities'));
    }

    public function update(Request $request, $id)
    {
        $transaction = Transaction::findOrFail($id);
        
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'commodity_id' => 'nullable|exists:commodities,id',
            'type' => 'required|in:income,expense',
            'amount' => 'required|numeric|min:0',
            'description' => 'required|string',
            'date' => 'required|date'
        ]);

        $transaction->update($request->all());

        return redirect()->route('admin.transactions.index')
            ->with('success', 'Transaction updated successfully.');
    }

    public function destroy($id)
    {
        $transaction = Transaction::findOrFail($id);
        $transaction->delete();

        return redirect()->route('admin.transactions.index')
            ->with('success', 'Transaction deleted successfully.');
    }
}
