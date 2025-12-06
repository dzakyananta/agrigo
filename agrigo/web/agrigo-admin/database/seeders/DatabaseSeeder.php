<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\Commodity;
use App\Models\Transaction;
use App\Models\WeatherData;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create Admin User
        $admin = User::create([
            'name' => 'Admin Agrigo',
            'email' => 'admin@agrigo.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'status' => 'active',
        ]);

        // Create Sample Farmers
        $farmer1 = User::create([
            'name' => 'Budi Santoso',
            'email' => 'budi@farmer.com',
            'password' => Hash::make('password123'),
            'role' => 'farmer',
            'status' => 'active',
        ]);

        UserProfile::create([
            'user_id' => $farmer1->id,
            'phone' => '08123456789',
            'address' => 'Jl. Sawah Indah No. 123, Subang, Jawa Barat',
            'farm_size' => 2.5,
            'farm_location' => 'Subang, Jawa Barat',
            'crops_grown' => 'Padi, Jagung, Cabai',
            'experience_years' => 15,
        ]);

        $farmer2 = User::create([
            'name' => 'Siti Rahayu',
            'email' => 'siti@farmer.com',
            'password' => Hash::make('password123'),
            'role' => 'farmer',
            'status' => 'active',
        ]);

        UserProfile::create([
            'user_id' => $farmer2->id,
            'phone' => '08234567890',
            'address' => 'Jl. Tani Makmur No. 456, Karawang, Jawa Barat',
            'farm_size' => 1.8,
            'farm_location' => 'Karawang, Jawa Barat',
            'crops_grown' => 'Tomat, Kentang, Wortel',
            'experience_years' => 10,
        ]);

        // Create Buyers
        $buyer1 = User::create([
            'name' => 'PT. Agro Mandiri',
            'email' => 'buyer@agromandiri.com',
            'password' => Hash::make('password123'),
            'role' => 'buyer',
            'status' => 'active',
        ]);

        // Create Sample Commodities
        $commodities = [
            [
                'name' => 'Beras Premium',
                'category' => 'Biji-bijian',
                'description' => 'Beras premium kualitas terbaik hasil panen lokal',
                'unit' => 'kg',
                'current_price' => 15000,
                'min_price' => 12000,
                'max_price' => 18000,
                'harvest_season' => 'Maret-Juni, September-Desember',
                'storage_requirements' => 'Suhu ruang, kelembaban rendah',
                'quality_standards' => 'Beras putih, bersih, tidak berbau',
                'is_active' => true,
            ],
            [
                'name' => 'Jagung Pipilan',
                'category' => 'Biji-bijian',
                'description' => 'Jagung pipilan kering siap giling',
                'unit' => 'kg',
                'current_price' => 6500,
                'min_price' => 5500,
                'max_price' => 7500,
                'harvest_season' => 'Februari-Mei, Juli-Oktober',
                'storage_requirements' => 'Kering, ventilasi baik',
                'quality_standards' => 'Kadar air maksimal 14%, tidak berjamur',
                'is_active' => true,
            ],
            [
                'name' => 'Cabai Merah Keriting',
                'category' => 'Sayuran',
                'description' => 'Cabai merah keriting segar kualitas export',
                'unit' => 'kg',
                'current_price' => 35000,
                'min_price' => 25000,
                'max_price' => 50000,
                'harvest_season' => 'Sepanjang tahun',
                'storage_requirements' => 'Suhu dingin 10-15°C',
                'quality_standards' => 'Segar, tidak layu, warna merah cerah',
                'is_active' => true,
            ],
            [
                'name' => 'Tomat Sayur',
                'category' => 'Sayuran',
                'description' => 'Tomat sayur segar untuk kebutuhan rumah tangga dan industri',
                'unit' => 'kg',
                'current_price' => 8500,
                'min_price' => 6000,
                'max_price' => 12000,
                'harvest_season' => 'Sepanjang tahun',
                'storage_requirements' => 'Suhu sejuk, hindari sinar matahari langsung',
                'quality_standards' => 'Matang merata, tidak busuk, ukuran seragam',
                'is_active' => true,
            ]
        ];

        foreach ($commodities as $commodity) {
            Commodity::create($commodity);
        }

        // Create Sample Transactions
        $transactions = [
            [
                'user_id' => $farmer1->id,
                'commodity_id' => 1,
                'type' => 'sale',
                'category' => 'penjualan',
                'amount' => 750000,
                'quantity' => 50,
                'price_per_unit' => 15000,
                'status' => 'completed',
                'description' => 'Penjualan beras premium 50 kg',
                'transaction_date' => now()->subDays(5),
            ],
            [
                'user_id' => $farmer2->id,
                'commodity_id' => 3,
                'type' => 'sale',
                'category' => 'penjualan',
                'amount' => 1050000,
                'quantity' => 30,
                'price_per_unit' => 35000,
                'status' => 'completed',
                'description' => 'Penjualan cabai merah keriting 30 kg',
                'transaction_date' => now()->subDays(3),
            ],
            [
                'user_id' => $farmer1->id,
                'commodity_id' => 2,
                'type' => 'sale',
                'category' => 'penjualan',
                'amount' => 325000,
                'quantity' => 50,
                'price_per_unit' => 6500,
                'status' => 'pending',
                'description' => 'Penjualan jagung pipilan 50 kg',
                'transaction_date' => now()->subDays(1),
            ],
            [
                'user_id' => $farmer2->id,
                'commodity_id' => 4,
                'type' => 'sale',
                'category' => 'penjualan',
                'amount' => 170000,
                'quantity' => 20,
                'price_per_unit' => 8500,
                'status' => 'confirmed',
                'description' => 'Penjualan tomat sayur 20 kg',
                'transaction_date' => now(),
            ]
        ];

        foreach ($transactions as $transaction) {
            Transaction::create($transaction);
        }

        // Create Sample Weather Data
        $weatherData = [
            [
                'location' => 'Subang, Jawa Barat',
                'latitude' => -6.5692,
                'longitude' => 107.7581,
                'temperature' => 28.5,
                'humidity' => 75.2,
                'rainfall' => 2.5,
                'wind_speed' => 12.3,
                'wind_direction' => 'NW',
                'weather_condition' => 'Partly Cloudy',
                'visibility' => 10.0,
                'pressure' => 1013.2,
                'recorded_at' => now(),
            ],
            [
                'location' => 'Karawang, Jawa Barat',
                'latitude' => -6.3019,
                'longitude' => 107.3026,
                'temperature' => 29.1,
                'humidity' => 72.8,
                'rainfall' => 0.0,
                'wind_speed' => 8.7,
                'wind_direction' => 'SW',
                'weather_condition' => 'Sunny',
                'visibility' => 12.0,
                'pressure' => 1012.8,
                'recorded_at' => now(),
            ]
        ];

        foreach ($weatherData as $weather) {
            WeatherData::create($weather);
        }

        $this->command->info('Database seeded successfully!');
        $this->command->info('Admin login: admin@agrigo.com / admin123');
        $this->command->info('Farmer login: budi@farmer.com / password123');
    }
}
