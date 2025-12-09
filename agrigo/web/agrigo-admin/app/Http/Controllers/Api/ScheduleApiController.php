<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Schedule;
use App\Models\Commodity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ScheduleApiController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user_id;
        
        $schedules = Schedule::with('commodity')
            ->where('user_id', $userId)
            ->orderBy('start_date', 'desc')
            ->get()
            ->map(function($schedule) {
                return [
                    'id' => $schedule->id,
                    'komoditas' => $schedule->commodity->name,
                    'commodity_id' => $schedule->commodity_id,
                    'startDate' => $schedule->start_date->timestamp * 1000,
                    'endDate' => $schedule->end_date->timestamp * 1000,
                    'createdAt' => $schedule->created_at->timestamp * 1000,
                    'status' => $schedule->status,
                    'notes' => $schedule->notes,
                ];
            });

        return response()->json([
            'success' => true,
            'schedules' => $schedules
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'komoditas' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Find or create commodity
        $commodity = Commodity::where('name', $request->komoditas)->first();
        
        if (!$commodity) {
            $commodity = Commodity::create([
                'name' => $request->komoditas,
                'type' => 'Umum',
                'is_active' => true,
            ]);
        }

        $schedule = Schedule::create([
            'user_id' => $request->user_id,
            'commodity_id' => $commodity->id,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'status' => 'active',
            'notes' => $request->notes,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Schedule created successfully',
            'schedule' => [
                'id' => $schedule->id,
                'komoditas' => $commodity->name,
                'startDate' => strtotime($schedule->start_date) * 1000,
                'endDate' => strtotime($schedule->end_date) * 1000,
                'createdAt' => $schedule->created_at->timestamp * 1000,
            ]
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $schedule = Schedule::find($id);

        if (!$schedule) {
            return response()->json(['success' => false, 'message' => 'Schedule not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'komoditas' => 'nullable|string',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'notes' => 'nullable|string',
            'status' => 'nullable|in:active,completed,cancelled',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($request->has('komoditas')) {
            $commodity = Commodity::where('name', $request->komoditas)->first();
            if (!$commodity) {
                $commodity = Commodity::create([
                    'name' => $request->komoditas,
                    'type' => 'Umum',
                    'is_active' => true,
                ]);
            }
            $schedule->commodity_id = $commodity->id;
        }

        $schedule->update([
            'start_date' => $request->start_date ?? $schedule->start_date,
            'end_date' => $request->end_date ?? $schedule->end_date,
            'notes' => $request->notes ?? $schedule->notes,
            'status' => $request->status ?? $schedule->status,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Schedule updated successfully',
            'schedule' => $schedule->load('commodity')
        ]);
    }

    public function destroy($id)
    {
        $schedule = Schedule::find($id);

        if (!$schedule) {
            return response()->json(['success' => false, 'message' => 'Schedule not found'], 404);
        }

        $schedule->delete();

        return response()->json([
            'success' => true,
            'message' => 'Schedule deleted successfully'
        ]);
    }
}
