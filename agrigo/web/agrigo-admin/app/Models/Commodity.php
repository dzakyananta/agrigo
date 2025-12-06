<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Commodity extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'category',
        'description',
        'unit',
        'current_price',
        'min_price',
        'max_price',
        'harvest_season',
        'storage_requirements',
        'quality_standards',
        'is_active'
    ];

    protected $casts = [
        'current_price' => 'decimal:2',
        'min_price' => 'decimal:2',
        'max_price' => 'decimal:2',
        'is_active' => 'boolean'
    ];

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }
}