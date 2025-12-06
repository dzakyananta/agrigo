<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class CreateAdminSeeder extends Seeder
{
    public function run()
    {
        // Check if admin already exists
        $adminExists = User::where('email', 'admin@agrigo.com')->first();
        
        if (!$adminExists) {
            User::create([
                'name' => 'Admin Agrigo',
                'email' => 'admin@agrigo.com',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'status' => 'active',
            ]);
            
            $this->command->info('Admin user created successfully!');
            $this->command->info('Email: admin@agrigo.com');
            $this->command->info('Password: admin123');
        } else {
            $this->command->info('Admin user already exists!');
        }
    }
}
