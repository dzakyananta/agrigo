<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Schedule;
use App\Models\User;
use App\Models\Commodity;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    public function index()
    {
        $schedules = Schedule::with(['user', 'commodity'])
            ->orderBy('start_date', 'desc')
            ->paginate(20);
        
        return view('admin.schedules.index', compact('schedules'));
    }

    public function create()
    {
        $users = User::where('role', 'farmer')->get();
        $commodities = Commodity::where('is_active', true)->get();
        
        return view('admin.schedules.create', compact('users', 'commodities'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'commodity_id' => 'nullable|exists:commodities,id',
            'komoditas' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'status' => 'required|in:active,completed,cancelled',
            'notes' => 'nullable|string',
        ]);

        Schedule::create($validated);

        return redirect()->route('admin.schedules.index')
            ->with('success', 'Jadwal tanam berhasil ditambahkan!');
    }

    public function show($id)
    {
        $schedule = Schedule::with(['user', 'commodity'])->findOrFail($id);
        return view('admin.schedules.show', compact('schedule'));
    }

    public function edit($id)
    {
        $schedule = Schedule::findOrFail($id);
        $users = User::where('role', 'farmer')->get();
        $commodities = Commodity::where('is_active', true)->get();
        
        return view('admin.schedules.edit', compact('schedule', 'users', 'commodities'));
    }

    public function update(Request $request, $id)
    {
        $schedule = Schedule::findOrFail($id);

        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'commodity_id' => 'nullable|exists:commodities,id',
            'komoditas' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'status' => 'required|in:active,completed,cancelled',
            'notes' => 'nullable|string',
        ]);

        $schedule->update($validated);

        return redirect()->route('admin.schedules.index')
            ->with('success', 'Jadwal tanam berhasil diperbarui!');
    }

    public function destroy($id)
    {
        $schedule = Schedule::findOrFail($id);
        $schedule->delete();

        return redirect()->route('admin.schedules.index')
            ->with('success', 'Jadwal tanam berhasil dihapus!');
    }

    public function updateStatus(Request $request, $id)
    {
        $schedule = Schedule::findOrFail($id);
        
        $validated = $request->validate([
            'status' => 'required|in:active,completed,cancelled'
        ]);

        $schedule->update($validated);

        return back()->with('success', 'Status jadwal berhasil diubah!');
    }
}
