<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Commodity;

class CommoditySeeder extends Seeder
{
    public function run(): void
    {
        $commodities = [
            [
                'name' => 'Padi',
                'category' => 'Padi-padian',
                'description' => 'Tanaman pangan utama Indonesia',
                'unit' => 'Kg',
                'current_price' => 5000,
                'min_price' => 4500,
                'max_price' => 6000,
                'harvest_season' => 'Maret - Juni, September - Desember',
                'storage_requirements' => 'Simpan di tempat kering dengan kelembaban < 14%',
                'quality_standards' => 'Beras utuh minimal 90%, kadar air maksimal 14%',
                'is_active' => true,
            ],
            [
                'name' => 'Jagung',
                'category' => 'Palawija',
                'description' => 'Tanaman pangan serbaguna',
                'unit' => 'Kg',
                'current_price' => 3500,
                'min_price' => 3000,
                'max_price' => 4000,
                'harvest_season' => 'April - Juli',
                'storage_requirements' => 'Simpan di tempat sejuk dan kering',
                'quality_standards' => 'Kadar air maksimal 15%, bebas dari kutu',
                'is_active' => true,
            ],
            [
                'name' => 'Cabai',
                'category' => 'Sayuran',
                'description' => 'Tanaman hortikultura dengan harga fluktuatif',
                'unit' => 'Kg',
                'current_price' => 45000,
                'min_price' => 30000,
                'max_price' => 80000,
                'harvest_season' => 'Sepanjang tahun',
                'storage_requirements' => 'Simpan di tempat sejuk, hindari sinar matahari langsung',
                'quality_standards' => 'Cabai segar, tidak busuk, warna merah cerah',
                'is_active' => true,
            ],
            [
                'name' => 'Tomat',
                'category' => 'Sayuran',
                'description' => 'Sayuran sumber vitamin C',
                'unit' => 'Kg',
                'current_price' => 8000,
                'min_price' => 6000,
                'max_price' => 12000,
                'harvest_season' => 'Sepanjang tahun',
                'storage_requirements' => 'Simpan di suhu ruangan, hindari kulkas untuk rasa optimal',
                'quality_standards' => 'Tomat segar, tidak lembek, warna merah merata',
                'is_active' => true,
            ],
            [
                'name' => 'Singkong',
                'category' => 'Umbi-umbian',
                'description' => 'Tanaman umbi mudah dibudidayakan',
                'unit' => 'Kg',
                'current_price' => 2500,
                'min_price' => 2000,
                'max_price' => 3500,
                'harvest_season' => 'Sepanjang tahun',
                'storage_requirements' => 'Simpan di tempat sejuk, maksimal 2 hari setelah panen',
                'quality_standards' => 'Umbi utuh, tidak berlubang, bebas dari hama',
                'is_active' => true,
            ],
            [
                'name' => 'Kedelai',
                'category' => 'Palawija',
                'description' => 'Sumber protein nabati',
                'unit' => 'Kg',
                'current_price' => 9000,
                'min_price' => 8000,
                'max_price' => 10000,
                'harvest_season' => 'Mei - Agustus',
                'storage_requirements' => 'Simpan dalam wadah kedap udara, tempat kering',
                'quality_standards' => 'Biji utuh, kadar air < 12%, warna kuning cerah',
                'is_active' => true,
            ],
            [
                'name' => 'Kacang Tanah',
                'category' => 'Palawija',
                'description' => 'Tanaman kacang-kacangan bernutrisi tinggi',
                'unit' => 'Kg',
                'current_price' => 12000,
                'min_price' => 10000,
                'max_price' => 15000,
                'harvest_season' => 'April - Juli',
                'storage_requirements' => 'Simpan di tempat kering, hindari kelembaban tinggi',
                'quality_standards' => 'Polong bersih, biji penuh, bebas aflatoxin',
                'is_active' => true,
            ],
            [
                'name' => 'Bayam',
                'category' => 'Sayuran',
                'description' => 'Sayuran hijau kaya zat besi',
                'unit' => 'Ikat',
                'current_price' => 3000,
                'min_price' => 2000,
                'max_price' => 4000,
                'harvest_season' => 'Sepanjang tahun',
                'storage_requirements' => 'Simpan di kulkas, cuci sebelum disimpan',
                'quality_standards' => 'Daun segar, hijau cerah, tidak layu',
                'is_active' => true,
            ],
            [
                'name' => 'Kangkung',
                'category' => 'Sayuran',
                'description' => 'Sayuran hijau cepat panen',
                'unit' => 'Ikat',
                'current_price' => 2500,
                'min_price' => 2000,
                'max_price' => 3500,
                'harvest_season' => 'Sepanjang tahun',
                'storage_requirements' => 'Simpan di kulkas, segera konsumsi untuk kesegaran maksimal',
                'quality_standards' => 'Batang dan daun segar, tidak berlendir',
                'is_active' => true,
            ],
            [
                'name' => 'Ubi Jalar',
                'category' => 'Umbi-umbian',
                'description' => 'Umbi manis kaya beta-karoten',
                'unit' => 'Kg',
                'current_price' => 4000,
                'min_price' => 3500,
                'max_price' => 5000,
                'harvest_season' => 'Sepanjang tahun',
                'storage_requirements' => 'Simpan di tempat sejuk dan gelap',
                'quality_standards' => 'Umbi padat, kulit mulus, tidak berkecambah',
                'is_active' => true,
            ],
        ];

        foreach ($commodities as $commodity) {
            Commodity::create($commodity);
        }
    }
}
