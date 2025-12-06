<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\User::create([
            'name' => 'Admin Agrigo',
            'email' => 'admin@agrigo.com',
            'password' => bcrypt('password'),
            'role' => 'admin',
            'status' => 'active',
            'email_verified_at' => now()
        ]);

        // Create some sample farmer users
        \App\Models\User::create([
            'name' => 'Petani Budi',
            'email' => 'budi@farmer.com',
            'password' => bcrypt('password'),
            'role' => 'farmer',
            'status' => 'active',
            'email_verified_at' => now()
        ]);

        \App\Models\User::create([
            'name' => 'Petani Sari',
            'email' => 'sari@farmer.com',
            'password' => bcrypt('password'),
            'role' => 'farmer',
            'status' => 'active',
            'email_verified_at' => now()
        ]);
    }
}
