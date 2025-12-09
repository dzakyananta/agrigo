<?php

namespace App\Http\Controllers;

use App\Models\Article;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ArticleController extends Controller
{
    public function index()
    {
        $articles = Article::orderBy('created_at', 'desc')->paginate(10);
        return view('articles.index', compact('articles'));
    }

    public function create()
    {
        $categories = ['Tips Pertanian', 'Berita', 'Tutorial', 'Panduan', 'Teknologi'];
        return view('articles.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string',
            'content' => 'required|string',
            'image_url' => 'nullable|url',
            'author' => 'required|string|max:255',
            'tags' => 'nullable|string',
            'is_published' => 'boolean',
        ]);

        // Process tags
        if (!empty($validated['tags'])) {
            $validated['tags'] = array_map('trim', explode(',', $validated['tags']));
        }

        $validated['is_published'] = $request->has('is_published');

        Article::create($validated);

        return redirect()->route('articles.index')
            ->with('success', 'Artikel berhasil ditambahkan!');
    }

    public function show(Article $article)
    {
        return view('articles.show', compact('article'));
    }

    public function edit(Article $article)
    {
        $categories = ['Tips Pertanian', 'Berita', 'Tutorial', 'Panduan', 'Teknologi'];
        return view('articles.edit', compact('article', 'categories'));
    }

    public function update(Request $request, Article $article)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string',
            'content' => 'required|string',
            'image_url' => 'nullable|url',
            'author' => 'required|string|max:255',
            'tags' => 'nullable|string',
            'is_published' => 'boolean',
        ]);

        // Process tags
        if (!empty($validated['tags'])) {
            $validated['tags'] = array_map('trim', explode(',', $validated['tags']));
        }

        $validated['is_published'] = $request->has('is_published');

        $article->update($validated);

        return redirect()->route('articles.index')
            ->with('success', 'Artikel berhasil diperbarui!');
    }

    public function destroy(Article $article)
    {
        $article->delete();

        return redirect()->route('articles.index')
            ->with('success', 'Artikel berhasil dihapus!');
    }

    public function togglePublish(Article $article)
    {
        $article->update(['is_published' => !$article->is_published]);

        $status = $article->is_published ? 'dipublikasikan' : 'disembunyikan';
        return back()->with('success', "Artikel berhasil {$status}!");
    }
}
