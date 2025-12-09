<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Commodity;
use App\Models\User;
use Illuminate\Http\Request;

class TransactionApiController extends Controller
{
    /**
     * Get all transactions for authenticated user
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $transactions = Transaction::with(['commodity', 'user'])
            ->where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Transactions retrieved successfully',
            'data' => $transactions
        ]);
    }

    /**
     * Store a new transaction from mobile app
     */
    public function store(Request $request)
    {
        $user = $request->user();
        
        $validated = $request->validate([
            'type' => 'required|in:income,expense',
            'source' => 'nullable|string|max:255',
            'amount' => 'required|numeric|min:0',
            'description' => 'required|string',
            'date' => 'required|date',
            'commodity_id' => 'nullable|exists:commodities,id',
            'commodity_name' => 'nullable|string' // Jika commodity belum ada di database
        ]);

        // Auto-create commodity if provided by name
        if (isset($validated['commodity_name']) && !isset($validated['commodity_id'])) {
            $commodity = Commodity::firstOrCreate(
                ['name' => $validated['commodity_name']],
                [
                    'type' => 'Umum',
                    'description' => 'Auto-created from mobile app',
                    'is_active' => true
                ]
            );
            $validated['commodity_id'] = $commodity->id;
        }

        unset($validated['commodity_name']);
        $validated['user_id'] = $user->id;

        $transaction = Transaction::create($validated);
        $transaction->load(['commodity', 'user']);

        return response()->json([
            'success' => true,
            'message' => 'Transaction created successfully',
            'data' => $transaction
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, string $id)
    {
        $user = $request->user();
        $transaction = Transaction::with(['commodity', 'user'])
            ->where('user_id', $user->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Transaction retrieved successfully',
            'data' => $transaction
        ]);
    }

    /**
     * Update transaction
     */
    public function update(Request $request, string $id)
    {
        $user = $request->user();

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $user = $request->user();
        $transaction = Transaction::where('user_id', $user->id)->findOrFail($id);

        $validated = $request->validate([
            'type' => 'required|in:income,expense',
            'amount' => 'required|numeric|min:0',
            'description' => 'required|string',
            'date' => 'required|date',
            'commodity_id' => 'nullable|exists:commodities,id'
        ]);

        $transaction->update($validated);
        $transaction->load(['commodity', 'user']);

        return response()->json([
            'success' => true,
            'message' => 'Transaction updated successfully',
            'data' => $transaction
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        $user = $request->user();
        $transaction = Transaction::where('user_id', $user->id)->findOrFail($id);
        
        $transaction->delete();

        return response()->json([
            'success' => true,
            'message' => 'Transaction deleted successfully'
        ]);
    }

    /**
     * Get user financial summary
     */
    public function summary(Request $request)
    {
        $user = $request->user();
        
        $transactions = Transaction::where('user_id', $user->id)->get();
        
        $income = $transactions->where('type', 'income')->sum('amount');
        $expense = $transactions->where('type', 'expense')->sum('amount');
        $balance = $income - $expense;

        return response()->json([
            'success' => true,
            'message' => 'Financial summary retrieved successfully',
            'data' => [
                'total_transactions' => $transactions->count(),
                'income' => $income,
                'expense' => $expense,
                'balance' => $balance,
                'income_count' => $transactions->where('type', 'income')->count(),
                'expense_count' => $transactions->where('type', 'expense')->count()
            ]
        ]);
    }
}
