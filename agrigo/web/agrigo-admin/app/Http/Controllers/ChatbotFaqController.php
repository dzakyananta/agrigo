<?php

namespace App\Http\Controllers;

use App\Models\ChatbotFaq;
use Illuminate\Http\Request;

class ChatbotFaqController extends Controller
{
    public function index()
    {
        $faqs = ChatbotFaq::orderBy('category')->orderBy('created_at', 'desc')->paginate(15);
        return view('chatbot.index', compact('faqs'));
    }

    public function create()
    {
        $categories = ['Jadwal Tanam', 'Keuangan', 'Cuaca', 'Komoditas', 'Umum'];
        return view('chatbot.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'category' => 'required|string',
            'keywords' => 'required|string',
            'question' => 'required|string',
            'answer' => 'required|string',
            'is_active' => 'boolean',
        ]);

        // Process keywords
        $validated['keywords'] = array_map('trim', explode(',', $validated['keywords']));
        $validated['is_active'] = $request->has('is_active');

        ChatbotFaq::create($validated);

        return redirect()->route('chatbot.index')
            ->with('success', 'FAQ berhasil ditambahkan!');
    }

    public function edit(ChatbotFaq $chatbot)
    {
        $categories = ['Jadwal Tanam', 'Keuangan', 'Cuaca', 'Komoditas', 'Umum'];
        return view('chatbot.edit', compact('chatbot', 'categories'));
    }

    public function update(Request $request, ChatbotFaq $chatbot)
    {
        $validated = $request->validate([
            'category' => 'required|string',
            'keywords' => 'required|string',
            'question' => 'required|string',
            'answer' => 'required|string',
            'is_active' => 'boolean',
        ]);

        // Process keywords
        $validated['keywords'] = array_map('trim', explode(',', $validated['keywords']));
        $validated['is_active'] = $request->has('is_active');

        $chatbot->update($validated);

        return redirect()->route('chatbot.index')
            ->with('success', 'FAQ berhasil diperbarui!');
    }

    public function destroy(ChatbotFaq $chatbot)
    {
        $chatbot->delete();

        return redirect()->route('chatbot.index')
            ->with('success', 'FAQ berhasil dihapus!');
    }

    public function toggleActive(ChatbotFaq $chatbot)
    {
        $chatbot->update(['is_active' => !$chatbot->is_active]);

        $status = $chatbot->is_active ? 'diaktifkan' : 'dinonaktifkan';
        return back()->with('success', "FAQ berhasil {$status}!");
    }
}
