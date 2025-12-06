<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Commodity;
use App\Models\Transaction;
use App\Models\User;

class SampleDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
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
            ]
        ];

        foreach ($commodities as $commodity) {
            Commodity::firstOrCreate(
                ['name' => $commodity['name']], 
                $commodity
            );
        }

        // Create Sample Transactions
        $users = User::all();
        $commodities = Commodity::all();

        if ($users->count() > 0 && $commodities->count() > 0) {
            $transactions = [
                [
                    'user_id' => $users->first()->id,
                    'commodity_id' => $commodities->first()->id,
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
                    'user_id' => $users->skip(1)->first()->id ?? $users->first()->id,
                    'commodity_id' => $commodities->skip(2)->first()->id ?? $commodities->first()->id,
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
                    'user_id' => $users->first()->id,
                    'commodity_id' => $commodities->skip(1)->first()->id ?? $commodities->first()->id,
                    'type' => 'sale',
                    'category' => 'penjualan',
                    'amount' => 325000,
                    'quantity' => 50,
                    'price_per_unit' => 6500,
                    'status' => 'pending',
                    'description' => 'Penjualan jagung pipilan 50 kg',
                    'transaction_date' => now()->subDays(1),
                ]
            ];

            foreach ($transactions as $transaction) {
                Transaction::create($transaction);
            }
        }

        $this->command->info('Sample data created successfully!');
    }
}