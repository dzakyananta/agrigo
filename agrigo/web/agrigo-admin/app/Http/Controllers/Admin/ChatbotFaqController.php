<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ChatbotFaq;
use Illuminate\Http\Request;

class ChatbotFaqController extends Controller
{
    /**
     * Display a listing of chatbot FAQs
     */
    public function index(Request $request)
    {
        $query = ChatbotFaq::query();

        // Filter by category
        if ($request->filled('category')) {
            $query->byCategory($request->category);
        }

        // Filter by status
        if ($request->filled('status')) {
            $query->where('is_active', $request->status === 'active');
        }

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('question', 'like', "%{$search}%")
                  ->orWhere('answer', 'like', "%{$search}%")
                  ->orWhere('category', 'like', "%{$search}%");
            });
        }

        $faqs = $query->orderBy('category')
                     ->orderBy('created_at', 'desc')
                     ->paginate(20);

        $categories = ChatbotFaq::distinct()->pluck('category');
        $stats = [
            'total' => ChatbotFaq::count(),
            'active' => ChatbotFaq::where('is_active', true)->count(),
            'inactive' => ChatbotFaq::where('is_active', false)->count(),
            'total_usage' => ChatbotFaq::sum('usage_count')
        ];

        return view('admin.chatbot-faqs.index', compact('faqs', 'categories', 'stats'));
    }

    /**
     * Show the form for creating a new FAQ
     */
    public function create()
    {
        $categories = ChatbotFaq::distinct()->pluck('category');
        return view('admin.chatbot-faqs.create', compact('categories'));
    }

    /**
     * Store a newly created FAQ in storage
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'category' => 'required|string|max:255',
            'keywords' => 'required|string',
            'question' => 'required|string',
            'answer' => 'required|string',
            'is_active' => 'boolean'
        ]);

        // Convert keywords string to array
        $keywords = array_map('trim', explode(',', $validated['keywords']));
        $validated['keywords'] = $keywords;
        $validated['is_active'] = $request->has('is_active');

        ChatbotFaq::create($validated);

        return redirect()->route('admin.chatbot-faqs.index')
            ->with('success', 'Chatbot FAQ berhasil ditambahkan!');
    }

    /**
     * Display the specified FAQ
     */
    public function show(ChatbotFaq $chatbotFaq)
    {
        return view('admin.chatbot-faqs.show', compact('chatbotFaq'));
    }

    /**
     * Show the form for editing the specified FAQ
     */
    public function edit(ChatbotFaq $chatbotFaq)
    {
        $categories = ChatbotFaq::distinct()->pluck('category');
        return view('admin.chatbot-faqs.edit', compact('chatbotFaq', 'categories'));
    }

    /**
     * Update the specified FAQ in storage
     */
    public function update(Request $request, ChatbotFaq $chatbotFaq)
    {
        $validated = $request->validate([
            'category' => 'required|string|max:255',
            'keywords' => 'required|string',
            'question' => 'required|string',
            'answer' => 'required|string',
            'is_active' => 'boolean'
        ]);

        // Convert keywords string to array
        $keywords = array_map('trim', explode(',', $validated['keywords']));
        $validated['keywords'] = $keywords;
        $validated['is_active'] = $request->has('is_active');

        $chatbotFaq->update($validated);

        return redirect()->route('admin.chatbot-faqs.index')
            ->with('success', 'Chatbot FAQ berhasil diperbarui!');
    }

    /**
     * Remove the specified FAQ from storage
     */
    public function destroy(ChatbotFaq $chatbotFaq)
    {
        $chatbotFaq->delete();

        return redirect()->route('admin.chatbot-faqs.index')
            ->with('success', 'Chatbot FAQ berhasil dihapus!');
    }

    /**
     * Toggle FAQ status
     */
    public function toggleStatus(ChatbotFaq $chatbotFaq)
    {
        $chatbotFaq->update([
            'is_active' => !$chatbotFaq->is_active
        ]);

        return back()->with('success', 'Status FAQ berhasil diubah!');
    }

    /**
     * Reset usage count
     */
    public function resetUsage(ChatbotFaq $chatbotFaq)
    {
        $chatbotFaq->update(['usage_count' => 0]);

        return back()->with('success', 'Usage count berhasil direset!');
    }
}
