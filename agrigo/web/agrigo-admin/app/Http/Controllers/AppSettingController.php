<?php

namespace App\Http\Controllers;

use App\Models\AppSetting;
use Illuminate\Http\Request;

class AppSettingController extends Controller
{
    public function index()
    {
        $settings = AppSetting::orderBy('category')->orderBy('key')->get();
        
        // Group by category
        $groupedSettings = $settings->groupBy('category');
        
        return view('settings.index', compact('groupedSettings'));
    }

    public function create()
    {
        $categories = ['general', 'api', 'features', 'notifications', 'weather'];
        $types = ['string', 'boolean', 'number', 'json'];
        
        return view('settings.create', compact('categories', 'types'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'key' => 'required|string|unique:app_settings,key',
            'value' => 'required',
            'type' => 'required|in:string,boolean,number,json',
            'category' => 'required|string',
            'description' => 'nullable|string',
        ]);

        AppSetting::create($validated);

        return redirect()->route('settings.index')
            ->with('success', 'Pengaturan berhasil ditambahkan!');
    }

    public function edit(AppSetting $setting)
    {
        $categories = ['general', 'api', 'features', 'notifications', 'weather'];
        $types = ['string', 'boolean', 'number', 'json'];
        
        return view('settings.edit', compact('setting', 'categories', 'types'));
    }

    public function update(Request $request, AppSetting $setting)
    {
        $validated = $request->validate([
            'key' => 'required|string|unique:app_settings,key,' . $setting->id,
            'value' => 'required',
            'type' => 'required|in:string,boolean,number,json',
            'category' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $setting->update($validated);

        return redirect()->route('settings.index')
            ->with('success', 'Pengaturan berhasil diperbarui!');
    }

    public function destroy(AppSetting $setting)
    {
        $setting->delete();

        return redirect()->route('settings.index')
            ->with('success', 'Pengaturan berhasil dihapus!');
    }

    public function bulkUpdate(Request $request)
    {
        foreach ($request->settings as $id => $value) {
            $setting = AppSetting::find($id);
            if ($setting) {
                $setting->update(['value' => $value]);
            }
        }

        return back()->with('success', 'Pengaturan berhasil diperbarui!');
    }
}
