<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class ResetAdminPasswordSeeder extends Seeder
{
    public function run()
    {
        $admin = User::where('email', 'admin@agrigo.com')->first();
        
        if ($admin) {
            $admin->password = Hash::make('admin123');
            $admin->save();
            
            $this->command->info('Admin password has been reset!');
            $this->command->info('Email: admin@agrigo.com');
            $this->command->info('Password: admin123');
        } else {
            $this->command->error('Admin user not found!');
        }
    }
}
