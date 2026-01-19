<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\WeatherData;
use App\Models\User;
use Illuminate\Http\Request;

class WeatherController extends Controller
{
    public function index()
    {
        $users = User::orderBy('name')->get();
        $queryUserId = request()->query('user_id');

        $weatherData = WeatherData::when($queryUserId, function ($q) use ($queryUserId) {
            return $q->where('user_id', $queryUserId);
        })->orderBy('date', 'desc')->paginate(20)->withQueryString();

        return view('admin.weather.index', compact('weatherData', 'users', 'queryUserId'));
    }

    public function create()
    {
        $users = User::orderBy('name')->get();
        return view('admin.weather.create', compact('users'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'location' => 'required|string|max:255',
            'date' => 'required|date',
            'temperature' => 'required|numeric',
            'humidity' => 'required|numeric|min:0|max:100',
            'rainfall' => 'nullable|numeric|min:0',
            'condition' => 'required|string|max:100',
            'wind_speed' => 'nullable|numeric|min:0',
            'description' => 'nullable|string',
        ]);

        // map 'condition' to underlying column 'weather_condition' if needed
        if (isset($validated['condition'])) {
            $validated['weather_condition'] = $validated['condition'];
            unset($validated['condition']);
        }

        WeatherData::create($validated);

        return redirect()->route('admin.weather.index')
            ->with('success', 'Data cuaca berhasil ditambahkan!');
    }

    public function destroy($id)
    {
        $weather = WeatherData::findOrFail($id);
        $weather->delete();

        return redirect()->route('admin.weather.index')
            ->with('success', 'Data cuaca berhasil dihapus!');
    }
}
