<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function index()
    {
        $transactions = Transaction::with(['user', 'commodity'])
            ->orderBy('created_at', 'desc')
            ->paginate(15);
            
        return view('admin.transactions.index', compact('transactions'));
    }

    public function show($id)
    {
        $transaction = Transaction::with(['user', 'commodity'])->findOrFail($id);
        return view('admin.transactions.show', compact('transaction'));
    }

    public function updateStatus(Request $request, $id)
    {
        $transaction = Transaction::findOrFail($id);
        
        $request->validate([
            'status' => 'required|in:pending,confirmed,completed,cancelled'
        ]);

        $transaction->update([
            'status' => $request->status
        ]);

        return redirect()->back()
            ->with('success', 'Transaction status updated successfully.');
    }

    public function destroy($id)
    {
        $transaction = Transaction::findOrFail($id);
        $transaction->delete();

        return redirect()->route('admin.transactions.index')
            ->with('success', 'Transaction deleted successfully.');
    }
}
