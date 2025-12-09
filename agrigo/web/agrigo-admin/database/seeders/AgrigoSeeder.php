<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\UserProfile;
use App\Models\Commodity;
use App\Models\Transaction;
use App\Models\Schedule;
use App\Models\WeatherData;
use App\Models\Article;
use App\Models\ChatbotFaq;
use App\Models\AppSetting;
use App\Models\Notification;
use Illuminate\Support\Facades\Hash;

class AgrigoSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create Admin User
        $admin = User::create([
            'name' => 'Admin Agrigo',
            'email' => 'admin@agrigo.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'is_active' => true,
        ]);

        // 2. Create Sample Farmers
        $farmer1 = User::create([
            'name' => 'Budi Santoso',
            'email' => 'budi@farmer.com',
            'password' => Hash::make('password123'),
            'role' => 'farmer',
            'is_active' => true,
        ]);

        UserProfile::create([
            'user_id' => $farmer1->id,
            'phone' => '08123456789',
            'address' => 'Subang, Jawa Barat',
            'location' => 'Subang',
        ]);

        $farmer2 = User::create([
            'name' => 'Siti Rahayu',
            'email' => 'siti@farmer.com',
            'password' => Hash::make('password123'),
            'role' => 'farmer',
            'is_active' => true,
        ]);

        UserProfile::create([
            'user_id' => $farmer2->id,
            'phone' => '08129876543',
            'address' => 'Karawang, Jawa Barat',
            'location' => 'Karawang',
        ]);

        // 3. Create Commodities - Nama dan Jenis saja (LENGKAP)
        $commodities = [
            // Padi-padian
            ['name' => 'Padi', 'type' => 'Padi-padian', 'description' => 'Tanaman padi untuk beras', 'is_active' => true],
            ['name' => 'Jagung', 'type' => 'Padi-padian', 'description' => 'Tanaman jagung', 'is_active' => true],
            ['name' => 'Gandum', 'type' => 'Padi-padian', 'description' => 'Tanaman gandum', 'is_active' => true],
            
            // Palawija
            ['name' => 'Kedelai', 'type' => 'Palawija', 'description' => 'Tanaman kedelai', 'is_active' => true],
            ['name' => 'Kacang Tanah', 'type' => 'Palawija', 'description' => 'Tanaman kacang tanah', 'is_active' => true],
            ['name' => 'Kacang Hijau', 'type' => 'Palawija', 'description' => 'Tanaman kacang hijau', 'is_active' => true],
            ['name' => 'Kacang Merah', 'type' => 'Palawija', 'description' => 'Tanaman kacang merah', 'is_active' => true],
            
            // Sayuran
            ['name' => 'Cabai', 'type' => 'Sayuran', 'description' => 'Tanaman cabai merah/rawit', 'is_active' => true],
            ['name' => 'Tomat', 'type' => 'Sayuran', 'description' => 'Tanaman tomat', 'is_active' => true],
            ['name' => 'Bayam', 'type' => 'Sayuran', 'description' => 'Tanaman bayam hijau', 'is_active' => true],
            ['name' => 'Kangkung', 'type' => 'Sayuran', 'description' => 'Tanaman kangkung', 'is_active' => true],
            ['name' => 'Sawi', 'type' => 'Sayuran', 'description' => 'Tanaman sawi hijau', 'is_active' => true],
            ['name' => 'Brokoli', 'type' => 'Sayuran', 'description' => 'Tanaman brokoli', 'is_active' => true],
            ['name' => 'Kubis', 'type' => 'Sayuran', 'description' => 'Tanaman kubis/kol', 'is_active' => true],
            ['name' => 'Wortel', 'type' => 'Sayuran', 'description' => 'Tanaman wortel', 'is_active' => true],
            ['name' => 'Bawang Merah', 'type' => 'Sayuran', 'description' => 'Tanaman bawang merah', 'is_active' => true],
            ['name' => 'Bawang Putih', 'type' => 'Sayuran', 'description' => 'Tanaman bawang putih', 'is_active' => true],
            ['name' => 'Terong', 'type' => 'Sayuran', 'description' => 'Tanaman terong', 'is_active' => true],
            ['name' => 'Timun', 'type' => 'Sayuran', 'description' => 'Tanaman timun', 'is_active' => true],
            
            // Buah-buahan
            ['name' => 'Pisang', 'type' => 'Buah-buahan', 'description' => 'Tanaman pisang', 'is_active' => true],
            ['name' => 'Mangga', 'type' => 'Buah-buahan', 'description' => 'Tanaman mangga', 'is_active' => true],
            ['name' => 'Jeruk', 'type' => 'Buah-buahan', 'description' => 'Tanaman jeruk', 'is_active' => true],
            ['name' => 'Pepaya', 'type' => 'Buah-buahan', 'description' => 'Tanaman pepaya', 'is_active' => true],
            ['name' => 'Semangka', 'type' => 'Buah-buahan', 'description' => 'Tanaman semangka', 'is_active' => true],
            ['name' => 'Melon', 'type' => 'Buah-buahan', 'description' => 'Tanaman melon', 'is_active' => true],
            ['name' => 'Strawberry', 'type' => 'Buah-buahan', 'description' => 'Tanaman strawberry', 'is_active' => true],
            
            // Umbi-umbian
            ['name' => 'Singkong', 'type' => 'Umbi-umbian', 'description' => 'Tanaman singkong/ketela pohon', 'is_active' => true],
            ['name' => 'Ubi Jalar', 'type' => 'Umbi-umbian', 'description' => 'Tanaman ubi jalar', 'is_active' => true],
            ['name' => 'Kentang', 'type' => 'Umbi-umbian', 'description' => 'Tanaman kentang', 'is_active' => true],
            ['name' => 'Talas', 'type' => 'Umbi-umbian', 'description' => 'Tanaman talas', 'is_active' => true],
            
            // Rempah-rempah
            ['name' => 'Jahe', 'type' => 'Rempah-rempah', 'description' => 'Tanaman jahe', 'is_active' => true],
            ['name' => 'Kunyit', 'type' => 'Rempah-rempah', 'description' => 'Tanaman kunyit', 'is_active' => true],
            ['name' => 'Lengkuas', 'type' => 'Rempah-rempah', 'description' => 'Tanaman lengkuas', 'is_active' => true],
            ['name' => 'Kencur', 'type' => 'Rempah-rempah', 'description' => 'Tanaman kencur', 'is_active' => true],
            ['name' => 'Serai', 'type' => 'Rempah-rempah', 'description' => 'Tanaman serai', 'is_active' => true],
        ];

        foreach ($commodities as $commodity) {
            Commodity::create($commodity);
        }

        // 4. Create Sample Schedules (Jadwal Tanam)
        Schedule::create([
            'user_id' => $farmer1->id,
            'commodity_id' => 1, // Padi
            'start_date' => now()->addDays(5),
            'end_date' => now()->addDays(125), // 120 hari masa tanam
            'status' => 'active',
            'notes' => 'Tanam padi varietas IR64',
        ]);

        Schedule::create([
            'user_id' => $farmer1->id,
            'commodity_id' => 5, // Cabai
            'start_date' => now()->subDays(30),
            'end_date' => now()->addDays(60),
            'status' => 'active',
            'notes' => 'Cabai merah keriting',
        ]);

        Schedule::create([
            'user_id' => $farmer2->id,
            'commodity_id' => 2, // Jagung
            'start_date' => now()->subDays(60),
            'end_date' => now()->subDays(5),
            'status' => 'completed',
            'notes' => 'Panen jagung manis',
        ]);

        // 5. Create Sample Transactions
        Transaction::create([
            'user_id' => $farmer1->id,
            'commodity_id' => 1,
            'type' => 'income',
            'source' => 'Penjualan Hasil Panen',
            'amount' => 5000000,
            'description' => 'Penjualan padi 500 kg',
            'date' => now()->subDays(10),
        ]);

        Transaction::create([
            'user_id' => $farmer1->id,
            'commodity_id' => 1,
            'type' => 'expense',
            'source' => 'Pembelian Pupuk',
            'amount' => 1500000,
            'description' => 'Pembelian pupuk dan pestisida',
            'date' => now()->subDays(15),
        ]);

        Transaction::create([
            'user_id' => $farmer2->id,
            'commodity_id' => 2,
            'type' => 'income',
            'source' => 'Penjualan Hasil Panen',
            'amount' => 3500000,
            'description' => 'Penjualan jagung 700 kg',
            'date' => now()->subDays(7),
        ]);

        // 6. Create Articles
        $articles = [
            [
                'title' => 'Tips Menanam Padi di Musim Hujan',
                'category' => 'Tips Pertanian',
                'content' => 'Menanam padi di musim hujan memerlukan perhatian khusus. Pastikan drainase lahan baik, pilih varietas yang tahan terhadap curah hujan tinggi, dan perhatikan pemupukan yang tepat.',
                'image_url' => 'https://via.placeholder.com/800x400/4CAF50/ffffff?text=Tips+Padi',
                'author' => 'Admin Agrigo',
                'is_published' => true,
                'tags' => ['padi', 'musim hujan', 'tips'],
                'view_count' => 125,
            ],
            [
                'title' => 'Cara Efektif Mengelola Keuangan Pertanian',
                'category' => 'Panduan',
                'content' => 'Pengelolaan keuangan yang baik adalah kunci sukses dalam bertani. Catat semua pemasukan dan pengeluaran dengan aplikasi Agrigo.',
                'image_url' => 'https://via.placeholder.com/800x400/2196F3/ffffff?text=Keuangan',
                'author' => 'Tim Agrigo',
                'is_published' => true,
                'tags' => ['keuangan', 'tips', 'manajemen'],
                'view_count' => 89,
            ],
        ];

        foreach ($articles as $article) {
            Article::create($article);
        }

        // 7. Create Chatbot FAQs
        $faqs = [
            [
                'category' => 'Jadwal Tanam',
                'keywords' => ['jadwal', 'tanam', 'mulai', 'kapan', 'waktu'],
                'question' => 'Bagaimana cara membuat jadwal tanam?',
                'answer' => 'Buka menu Jadwal, klik tombol +, isi informasi komoditas dan tanggal, lalu simpan. Notifikasi pengingat akan otomatis dikirim.',
                'is_active' => true,
                'usage_count' => 45,
            ],
            [
                'category' => 'Keuangan',
                'keywords' => ['transaksi', 'uang', 'pemasukan', 'pengeluaran'],
                'question' => 'Bagaimana cara mencatat transaksi?',
                'answer' => 'Buka halaman Keuangan, pilih Pemasukan/Pengeluaran, klik +, isi detail transaksi, lalu simpan.',
                'is_active' => true,
                'usage_count' => 67,
            ],
        ];

        foreach ($faqs as $faq) {
            ChatbotFaq::create($faq);
        }

        // 8. Create App Settings
        $settings = [
            ['key' => 'app_name', 'value' => 'Agrigo', 'type' => 'string', 'category' => 'general', 'description' => 'Nama aplikasi'],
            ['key' => 'app_version', 'value' => '1.0.0', 'type' => 'string', 'category' => 'general', 'description' => 'Versi aplikasi'],
            ['key' => 'maintenance_mode', 'value' => 'false', 'type' => 'boolean', 'category' => 'general', 'description' => 'Mode maintenance'],
            ['key' => 'enable_notifications', 'value' => 'true', 'type' => 'boolean', 'category' => 'features', 'description' => 'Aktifkan notifikasi'],
            ['key' => 'enable_chatbot', 'value' => 'true', 'type' => 'boolean', 'category' => 'features', 'description' => 'Aktifkan chatbot'],
        ];

        foreach ($settings as $setting) {
            AppSetting::create($setting);
        }

        // 9. Create Sample Notifications
        Notification::create([
            'user_id' => $farmer1->id,
            'title' => 'Jadwal Tanam Padi Dimulai',
            'description' => 'Jadwal tanam padi Anda akan dimulai 5 hari lagi. Persiapkan lahan dan bibit.',
            'icon_type' => 'schedule',
            'color_type' => 'green',
            'schedule_id' => 1,
            'is_read' => false,
            'is_sent' => true,
        ]);

        Notification::create([
            'user_id' => null, // Broadcast ke semua
            'title' => 'Tips Pertanian',
            'description' => 'Musim hujan tiba! Perhatikan drainase lahan Anda.',
            'icon_type' => 'info',
            'color_type' => 'blue',
            'is_read' => false,
            'is_sent' => true,
        ]);

        // 7. Seed Chatbot FAQs
        echo "Seeding chatbot FAQs...\n";
        
        // Pertanian
        ChatbotFaq::create([
            'category' => 'Pertanian',
            'keywords' => ['padi', 'tanaman padi', 'rice', 'beras'],
            'question' => 'Apa itu tanaman padi?',
            'answer' => 'Padi adalah tanaman makanan pokok yang menghasilkan beras. Padi ditanam di sawah dan membutuhkan air yang cukup. Waktu panen sekitar 3-4 bulan setelah tanam.',
            'is_active' => true,
        ]);

        ChatbotFaq::create([
            'category' => 'Pertanian',
            'keywords' => ['jagung', 'corn', 'tanaman jagung'],
            'question' => 'Bagaimana cara menanam jagung?',
            'answer' => 'Jagung ditanam dengan jarak 70-75 cm antar baris dan 20-25 cm antar tanaman. Gunakan benih berkualitas, berikan pupuk dasar saat tanam, dan lakukan penyiangan rutin. Panen setelah 90-110 hari.',
            'is_active' => true,
        ]);

        ChatbotFaq::create([
            'category' => 'Pertanian',
            'keywords' => ['pupuk', 'fertilizer', 'pemupukan'],
            'question' => 'Kapan waktu terbaik untuk memberi pupuk?',
            'answer' => 'Pemupukan pertama dilakukan saat tanam (pupuk dasar), pemupukan kedua 2-3 minggu setelah tanam, dan pemupukan ketiga menjelang fase generatif. Pupuk sebaiknya diberikan pagi atau sore hari.',
            'is_active' => true,
        ]);

        // Cuaca
        ChatbotFaq::create([
            'category' => 'Cuaca',
            'keywords' => ['cuaca', 'weather', 'ramalan cuaca', 'prakiraan'],
            'question' => 'Bagaimana cara cek cuaca?',
            'answer' => 'Anda bisa mengecek cuaca melalui fitur Weather di aplikasi Agrigo. Fitur ini menampilkan prakiraan cuaca real-time berdasarkan lokasi Anda, termasuk suhu, kelembaban, dan kondisi cuaca.',
            'is_active' => true,
        ]);

        ChatbotFaq::create([
            'category' => 'Cuaca',
            'keywords' => ['hujan', 'musim hujan', 'rain'],
            'question' => 'Apa yang harus dilakukan saat musim hujan?',
            'answer' => 'Saat musim hujan: 1) Pastikan drainase lahan baik, 2) Perhatikan hama penyakit yang sering muncul saat lembab, 3) Kurangi frekuensi penyiraman, 4) Lakukan perawatan ekstra pada tanaman.',
            'is_active' => true,
        ]);

        // Komoditas
        ChatbotFaq::create([
            'category' => 'Komoditas',
            'keywords' => ['komoditas', 'commodity', 'jenis tanaman'],
            'question' => 'Komoditas apa saja yang tersedia?',
            'answer' => 'Agrigo mendukung 6 kategori komoditas: Padi-padian (padi, jagung), Palawija (kedelai, kacang), Sayuran (cabai, tomat, bayam), Buah-buahan (pisang, mangga), Umbi-umbian (singkong, kentang), dan Rempah-rempah (jahe, kunyit).',
            'is_active' => true,
        ]);

        ChatbotFaq::create([
            'category' => 'Komoditas',
            'keywords' => ['cabai', 'chili', 'cabe'],
            'question' => 'Bagaimana merawat tanaman cabai?',
            'answer' => 'Perawatan cabai: 1) Siram teratur pagi dan sore, 2) Berikan pupuk NPK setiap 2 minggu, 3) Lakukan pemangkasan tunas air, 4) Semprot pestisida organik jika ada hama, 5) Panen saat cabai berwarna merah.',
            'is_active' => true,
        ]);

        // Keuangan
        ChatbotFaq::create([
            'category' => 'Keuangan',
            'keywords' => ['keuangan', 'finance', 'pencatatan', 'transaksi'],
            'question' => 'Bagaimana cara mencatat transaksi?',
            'answer' => 'Buka menu Finance, pilih Income untuk pemasukan atau Expense untuk pengeluaran. Isi jumlah, tanggal, komoditas, dan deskripsi. Data akan tersimpan otomatis dan dapat dilihat di laporan keuangan.',
            'is_active' => true,
        ]);

        ChatbotFaq::create([
            'category' => 'Keuangan',
            'keywords' => ['laporan', 'report', 'finance report'],
            'question' => 'Dimana melihat laporan keuangan?',
            'answer' => 'Laporan keuangan dapat dilihat di menu Finance. Anda akan melihat total pemasukan, pengeluaran, dan saldo. Laporan dapat difilter berdasarkan periode waktu tertentu.',
            'is_active' => true,
        ]);

        // Jadwal
        ChatbotFaq::create([
            'category' => 'Jadwal',
            'keywords' => ['jadwal', 'schedule', 'planning', 'tanam'],
            'question' => 'Bagaimana membuat jadwal tanam?',
            'answer' => 'Buka menu Schedule, klik Add New. Pilih komoditas, tentukan tanggal mulai dan selesai, tambahkan catatan jika perlu. Sistem akan mengirim notifikasi pengingat menjelang jadwal.',
            'is_active' => true,
        ]);

        ChatbotFaq::create([
            'category' => 'Jadwal',
            'keywords' => ['notifikasi', 'notification', 'pengingat', 'reminder'],
            'question' => 'Bagaimana cara kerja notifikasi?',
            'answer' => 'Notifikasi akan muncul otomatis untuk: 1) Pengingat jadwal tanam, 2) Update cuaca penting, 3) Informasi artikel baru, 4) Peringatan hama dan penyakit. Pastikan izin notifikasi aktif di aplikasi.',
            'is_active' => true,
        ]);

        // Umum
        ChatbotFaq::create([
            'category' => 'Umum',
            'keywords' => ['agrigo', 'aplikasi', 'fitur'],
            'question' => 'Apa itu Agrigo?',
            'answer' => 'Agrigo adalah aplikasi manajemen pertanian yang membantu petani dalam: 1) Mencatat transaksi keuangan, 2) Mengatur jadwal tanam, 3) Memantau cuaca, 4) Mendapat informasi komoditas, 5) Konsultasi via chatbot.',
            'is_active' => true,
        ]);

        ChatbotFaq::create([
            'category' => 'Umum',
            'keywords' => ['bantuan', 'help', 'support', 'kontak'],
            'question' => 'Bagaimana cara mendapat bantuan?',
            'answer' => 'Anda bisa: 1) Gunakan chatbot ini untuk pertanyaan umum, 2) Baca artikel di menu Articles, 3) Hubungi admin melalui menu Profile > Contact Support, 4) Email ke support@agrigo.com',
            'is_active' => true,
        ]);

        ChatbotFaq::create([
            'category' => 'Umum',
            'keywords' => ['login', 'register', 'akun', 'account'],
            'question' => 'Bagaimana cara membuat akun?',
            'answer' => 'Klik "Register" di halaman login. Isi nama, email, password, nomor HP, dan alamat. Setelah berhasil, Anda bisa langsung login dan menggunakan semua fitur Agrigo.',
            'is_active' => true,
        ]);

        echo "✅ Database seeded successfully!\n";
        echo "📧 Admin Login: admin@agrigo.com\n";
        echo "🔑 Password: admin123\n";
    }
}
