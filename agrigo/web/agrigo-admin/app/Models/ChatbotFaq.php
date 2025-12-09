<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChatbotFaq extends Model
{
    use HasFactory;

    protected $fillable = [
        'category',
        'keywords',
        'question',
        'answer',
        'is_active',
        'usage_count',
    ];

    protected $casts = [
        'keywords' => 'array',
        'is_active' => 'boolean',
        'usage_count' => 'integer',
    ];

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeSearchKeyword($query, $keyword)
    {
        return $query->where(function($q) use ($keyword) {
            $q->where('question', 'like', "%{$keyword}%")
              ->orWhere('answer', 'like', "%{$keyword}%")
              ->orWhere('category', 'like', "%{$keyword}%");
        });
    }

    // Increment usage count
    public function incrementUsage()
    {
        $this->increment('usage_count');
    }
}
