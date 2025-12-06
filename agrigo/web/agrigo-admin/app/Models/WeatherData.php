<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WeatherData extends Model
{
    use HasFactory;

    protected $fillable = [
        'location',
        'latitude',
        'longitude',
        'temperature',
        'humidity',
        'rainfall',
        'wind_speed',
        'wind_direction',
        'weather_condition',
        'visibility',
        'pressure',
        'recorded_at'
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'temperature' => 'decimal:2',
        'humidity' => 'decimal:2',
        'rainfall' => 'decimal:2',
        'wind_speed' => 'decimal:2',
        'visibility' => 'decimal:2',
        'pressure' => 'decimal:2',
        'recorded_at' => 'datetime'
    ];
}