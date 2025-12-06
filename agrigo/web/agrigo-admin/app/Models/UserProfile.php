<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'phone',
        'address',
        'date_of_birth',
        'gender',
        'farm_size',
        'farm_location',
        'crops_grown',
        'experience_years',
        'profile_picture'
    ];

    protected $casts = [
        'date_of_birth' => 'date',
        'farm_size' => 'decimal:2',
        'experience_years' => 'integer'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
