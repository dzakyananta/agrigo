<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Commodity;
use Illuminate\Http\Request;

class CommodityController extends Controller
{
    public function index()
    {
        $commodities = Commodity::orderBy('created_at', 'desc')->paginate(20);
        return view('admin.commodities.index', compact('commodities'));
    }

    public function create()
    {
        return view('admin.commodities.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|string|max:100',
            'description' => 'nullable|string',
            'is_active' => 'boolean'
        ]);

        $validated['is_active'] = $request->has('is_active');

        Commodity::create($validated);

        return redirect()->route('admin.commodities.index')
            ->with('success', 'Komoditas berhasil ditambahkan!');
    }

    public function show($id)
    {
        $commodity = Commodity::with(['transactions', 'schedules'])->findOrFail($id);
        return view('admin.commodities.show', compact('commodity'));
    }

    public function edit($id)
    {
        $commodity = Commodity::findOrFail($id);
        return view('admin.commodities.edit', compact('commodity'));
    }

    public function update(Request $request, $id)
    {
        $commodity = Commodity::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|string|max:100',
            'is_active' => 'boolean'
        ]);

        $validated['is_active'] = $request->has('is_active');

        $commodity->update($validated);

        return redirect()->route('admin.commodities.index')
            ->with('success', 'Komoditas berhasil diperbarui!');
    }

    public function destroy($id)
    {
        $commodity = Commodity::findOrFail($id);
        $commodity->delete();

        return redirect()->route('admin.commodities.index')
            ->with('success', 'Komoditas berhasil dihapus!');
    }

    public function toggleStatus($id)
    {
        $commodity = Commodity::findOrFail($id);
        $commodity->is_active = !$commodity->is_active;
        $commodity->save();

        return back()->with('success', 'Status komoditas berhasil diubah!');
    }
}
