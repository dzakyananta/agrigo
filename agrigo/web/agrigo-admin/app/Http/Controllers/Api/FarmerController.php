<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Schedule;
use App\Models\Transaction;
use App\Models\Commodity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Api\NotificationController;

class FarmerController extends Controller
{
    protected $notificationController;

    public function __construct()
    {
        $this->notificationController = new NotificationController();
    }

    public function schedules(Request $request)
    {
        $schedules = Schedule::where('user_id', $request->user()->id)
            ->with('commodity')
            ->orderBy('start_date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $schedules,
        ]);
    }

    public function createSchedule(Request $request)
    {
        $request->validate([
            'commodity_id' => 'required|exists:commodities,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'notes' => 'nullable|string',
        ]);

        $schedule = Schedule::create([
            'user_id' => $request->user()->id,
            'commodity_id' => $request->commodity_id,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'notes' => $request->notes,
            'status' => 'active',
        ]);

        $schedule->load('commodity');

        // Send notification
        $this->notificationController->sendToUser(
            $request->user()->id,
            '📅 Jadwal Tanam Baru',
            "Jadwal tanam {$schedule->commodity->name} berhasil ditambahkan! Mulai: {$schedule->start_date}",
            ['type' => 'schedule_created', 'schedule_id' => $schedule->id]
        );

        return response()->json([
            'success' => true,
            'message' => 'Schedule created successfully',
            'data' => $schedule,
        ], 201);
    }

    public function updateSchedule(Request $request, $id)
    {
        $schedule = Schedule::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'commodity_id' => 'sometimes|exists:commodities,id',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after:start_date',
            'status' => 'sometimes|in:active,completed,cancelled',
            'notes' => 'nullable|string',
        ]);

        $schedule->update($request->all());
        $schedule->load('commodity');

        return response()->json([
            'success' => true,
            'message' => 'Schedule updated successfully',
            'data' => $schedule,
        ]);
    }

    public function deleteSchedule(Request $request, $id)
    {
        $schedule = Schedule::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $schedule->delete();

        return response()->json([
            'success' => true,
            'message' => 'Schedule deleted successfully',
        ]);
    }

    public function transactions(Request $request)
    {
        $transactions = Transaction::where('user_id', $request->user()->id)
            ->with('commodity')
            ->orderBy('date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $transactions,
        ]);
    }

    public function createTransaction(Request $request)
    {
        $request->validate([
            'type' => 'required|in:income,expense',
            'amount' => 'required|numeric|min:0',
            'commodity_id' => 'nullable|exists:commodities,id',
            'description' => 'nullable|string',
            'date' => 'required|date',
        ]);

        $transaction = Transaction::create([
            'user_id' => $request->user()->id,
            'type' => $request->type,
            'amount' => $request->amount,
            'commodity_id' => $request->commodity_id,
            'description' => $request->description,
            'date' => $request->date,
        ]);

        $transaction->load('commodity');

        // Send notification
        $typeText = $request->type === 'income' ? '💰 Pemasukan' : '💸 Pengeluaran';
        $this->notificationController->sendToUser(
            $request->user()->id,
            $typeText . ' Tercatat',
            'Rp ' . number_format($request->amount, 0, ',', '.') . ' - ' . ($request->description ?? ''),
            ['type' => 'transaction_created', 'transaction_id' => $transaction->id]
        );

        return response()->json([
            'success' => true,
            'message' => 'Transaction created successfully',
            'data' => $transaction,
        ], 201);
    }

    public function transactionSummary(Request $request)
    {
        $summary = Transaction::where('user_id', $request->user()->id)
            ->select('type', DB::raw('SUM(amount) as total'))
            ->groupBy('type')
            ->get()
            ->keyBy('type');

        $income = $summary->get('income')->total ?? 0;
        $expense = $summary->get('expense')->total ?? 0;
        $balance = $income - $expense;

        return response()->json([
            'success' => true,
            'data' => [
                'income' => $income,
                'expense' => $expense,
                'balance' => $balance,
            ],
        ]);
    }

    public function commodities()
    {
        $commodities = Commodity::where('is_active', true)
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $commodities,
        ]);
    }

    public function weather(Request $request)
    {
        // Placeholder - integrate with weather API
        return response()->json([
            'success' => true,
            'data' => [
                'location' => 'Subang, Jawa Barat',
                'temperature' => 28.5,
                'humidity' => 75,
                'condition' => 'Partly Cloudy',
                'description' => 'Cuaca cerah dengan sedikit berawan',
            ],
        ]);
    }
}
