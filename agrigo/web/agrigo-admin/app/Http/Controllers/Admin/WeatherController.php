<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\WeatherData;
use Illuminate\Http\Request;

class WeatherController extends Controller
{
    public function index()
    {
        $weatherData = WeatherData::orderBy('date', 'desc')->paginate(20);
        return view('admin.weather.index', compact('weatherData'));
    }

    public function create()
    {
        return view('admin.weather.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'location' => 'required|string|max:255',
            'date' => 'required|date',
            'temperature' => 'required|numeric',
            'humidity' => 'required|numeric|min:0|max:100',
            'rainfall' => 'nullable|numeric|min:0',
            'condition' => 'required|string|max:100',
            'wind_speed' => 'nullable|numeric|min:0',
            'description' => 'nullable|string',
        ]);

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
