<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Article extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'category',
        'content',
        'image_url',
        'author',
        'is_published',
        'view_count',
        'tags',
    ];

    protected $casts = [
        'tags' => 'array',
        'is_published' => 'boolean',
        'view_count' => 'integer',
    ];

    // Increment view count
    public function incrementViews()
    {
        $this->increment('view_count');
    }

    // Scope for published articles
    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    // Scope for category
    public function scopeCategory($query, $category)
    {
        return $query->where('category', $category);
    }
}
