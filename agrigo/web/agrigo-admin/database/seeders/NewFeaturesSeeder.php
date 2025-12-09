<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Article;
use App\Models\ChatbotFaq;
use App\Models\AppSetting;
use App\Models\Commodity;

class NewFeaturesSeeder extends Seeder
{
    public function run(): void
    {
        // Seed Commodities - Simple list dengan nama dan jenis saja
        $commodities = [
            ['name' => 'Padi', 'type' => 'Padi-padian', 'description' => 'Tanaman padi untuk beras', 'is_active' => true],
            ['name' => 'Jagung', 'type' => 'Padi-padian', 'description' => 'Tanaman jagung', 'is_active' => true],
            ['name' => 'Kedelai', 'type' => 'Palawija', 'description' => 'Tanaman kedelai', 'is_active' => true],
            ['name' => 'Kacang Tanah', 'type' => 'Palawija', 'description' => 'Tanaman kacang tanah', 'is_active' => true],
            ['name' => 'Cabai', 'type' => 'Sayuran', 'description' => 'Tanaman cabai', 'is_active' => true],
            ['name' => 'Tomat', 'type' => 'Sayuran', 'description' => 'Tanaman tomat', 'is_active' => true],
            ['name' => 'Bayam', 'type' => 'Sayuran', 'description' => 'Tanaman bayam', 'is_active' => true],
            ['name' => 'Kangkung', 'type' => 'Sayuran', 'description' => 'Tanaman kangkung', 'is_active' => true],
            ['name' => 'Singkong', 'type' => 'Umbi-umbian', 'description' => 'Tanaman singkong', 'is_active' => true],
            ['name' => 'Ubi Jalar', 'type' => 'Umbi-umbian', 'description' => 'Tanaman ubi jalar', 'is_active' => true],
        ];

        foreach ($commodities as $commodity) {
            Commodity::create($commodity);
        }

        // Seed Articles
        $articles = [
            [
                'title' => 'Tips Menanam Padi di Musim Hujan',
                'category' => 'Tips Pertanian',
                'content' => 'Menanam padi di musim hujan memerlukan perhatian khusus. Pastikan drainase lahan baik, pilih varietas yang tahan terhadap curah hujan tinggi, dan perhatikan pemupukan yang tepat. Lakukan penyemprotan fungisida untuk mencegah penyakit akibat kelembaban tinggi.',
                'image_url' => 'https://via.placeholder.com/800x400/4CAF50/ffffff?text=Tips+Padi',
                'author' => 'Admin Agrigo',
                'is_published' => true,
                'tags' => ['padi', 'musim hujan', 'tips'],
                'view_count' => 125,
            ],
            [
                'title' => 'Cara Efektif Mengelola Keuangan Pertanian',
                'category' => 'Panduan',
                'content' => 'Pengelolaan keuangan yang baik adalah kunci sukses dalam bertani. Catat semua pemasukan dan pengeluaran, pisahkan modal dari keuntungan, dan buat perencanaan anggaran untuk musim tanam berikutnya. Gunakan aplikasi Agrigo untuk memudahkan pencatatan transaksi Anda.',
                'image_url' => 'https://via.placeholder.com/800x400/2196F3/ffffff?text=Keuangan',
                'author' => 'Tim Agrigo',
                'is_published' => true,
                'tags' => ['keuangan', 'tips', 'manajemen'],
                'view_count' => 89,
            ],
            [
                'title' => 'Teknologi IoT untuk Pertanian Modern',
                'category' => 'Teknologi',
                'content' => 'Internet of Things (IoT) menghadirkan revolusi dalam dunia pertanian. Dengan sensor tanah, sistem irigasi otomatis, dan monitoring cuaca real-time, petani dapat meningkatkan produktivitas hingga 40%. Pelajari bagaimana teknologi ini dapat diterapkan di lahan Anda.',
                'image_url' => 'https://via.placeholder.com/800x400/FF9800/ffffff?text=IoT+Pertanian',
                'author' => 'Dr. Budi Santoso',
                'is_published' => true,
                'tags' => ['teknologi', 'iot', 'modern'],
                'view_count' => 156,
            ],
            [
                'title' => 'Jadwal Tanam Optimal untuk Cabai',
                'category' => 'Tutorial',
                'content' => 'Cabai merupakan komoditas yang menguntungkan jika ditanam dengan jadwal yang tepat. Musim tanam terbaik adalah April-Mei atau September-Oktober. Persiapan lahan dimulai 2 minggu sebelum tanam, dengan pemupukan dasar dan penggemburan tanah.',
                'image_url' => 'https://via.placeholder.com/800x400/F44336/ffffff?text=Cabai',
                'author' => 'Pak Tani Sukses',
                'is_published' => true,
                'tags' => ['cabai', 'jadwal tanam', 'tutorial'],
                'view_count' => 203,
            ],
            [
                'title' => 'Mengenal Hama dan Penyakit Tanaman Jagung',
                'category' => 'Tips Pertanian',
                'content' => 'Hama dan penyakit adalah musuh utama petani jagung. Penggerek batang, ulat grayak, dan penyakit bulai adalah yang paling umum. Kenali gejala awal dan lakukan pengendalian terpadu dengan pestisida organik dan nabati untuk hasil maksimal.',
                'image_url' => 'https://via.placeholder.com/800x400/FFEB3B/000000?text=Hama+Jagung',
                'author' => 'Admin Agrigo',
                'is_published' => false, // Draft
                'tags' => ['jagung', 'hama', 'penyakit'],
                'view_count' => 0,
            ],
        ];

        foreach ($articles as $article) {
            Article::create($article);
        }

        // Seed Chatbot FAQs
        $faqs = [
            [
                'category' => 'Jadwal Tanam',
                'keywords' => ['jadwal', 'tanam', 'mulai', 'kapan', 'waktu'],
                'question' => 'Bagaimana cara membuat jadwal tanam di aplikasi?',
                'answer' => 'Anda bisa membuat jadwal tanam dengan:\n1. Buka menu Jadwal\n2. Klik tombol + di kanan bawah\n3. Isi informasi: komoditas, tanggal mulai, tanggal selesai\n4. Tambahkan catatan jika perlu\n5. Klik Simpan\n\nJadwal akan otomatis mengirim notifikasi pengingat.',
                'is_active' => true,
                'usage_count' => 45,
            ],
            [
                'category' => 'Keuangan',
                'keywords' => ['transaksi', 'uang', 'pemasukan', 'pengeluaran', 'keuangan'],
                'question' => 'Bagaimana cara mencatat transaksi?',
                'answer' => 'Untuk mencatat transaksi:\n1. Buka halaman Keuangan\n2. Pilih Pemasukan atau Pengeluaran\n3. Klik tombol + untuk tambah transaksi\n4. Isi detail: jumlah, komoditas, tanggal, catatan\n5. Simpan\n\nSemua transaksi akan tercatat dan bisa dilihat di dashboard keuangan.',
                'is_active' => true,
                'usage_count' => 67,
            ],
            [
                'category' => 'Cuaca',
                'keywords' => ['cuaca', 'ramalan', 'hujan', 'panas', 'suhu'],
                'question' => 'Bagaimana cara melihat prakiraan cuaca?',
                'answer' => 'Prakiraan cuaca dapat dilihat di:\n1. Menu Cuaca di halaman utama\n2. Izinkan akses lokasi untuk mendapat info cuaca akurat\n3. Lihat cuaca saat ini, per jam, dan mingguan\n4. Gunakan informasi ini untuk perencanaan kegiatan pertanian',
                'is_active' => true,
                'usage_count' => 23,
            ],
            [
                'category' => 'Komoditas',
                'keywords' => ['komoditas', 'harga', 'jenis', 'tanaman'],
                'question' => 'Komoditas apa saja yang tersedia?',
                'answer' => 'Agrigo mendukung berbagai komoditas:\n- Padi-padian: Padi, Jagung\n- Palawija: Kedelai, Kacang Tanah\n- Sayuran: Cabai, Tomat, Bayam, Kangkung\n- Umbi-umbian: Singkong, Ubi Jalar\n\nAnda bisa pilih komoditas saat membuat jadwal atau transaksi.',
                'is_active' => true,
                'usage_count' => 34,
            ],
            [
                'category' => 'Umum',
                'keywords' => ['bantuan', 'help', 'cara', 'gunakan', 'tutorial'],
                'question' => 'Bagaimana cara menggunakan aplikasi Agrigo?',
                'answer' => 'Agrigo memiliki 4 fitur utama:\n\n1. DASHBOARD - Ringkasan dan akses cepat\n2. JADWAL - Kelola jadwal tanam\n3. KEUANGAN - Catat transaksi income/expense\n4. CUACA - Lihat prakiraan cuaca\n\nSetiap fitur memiliki panduan dan chatbot siap membantu Anda!',
                'is_active' => true,
                'usage_count' => 112,
            ],
            [
                'category' => 'Jadwal Tanam',
                'keywords' => ['edit', 'ubah', 'hapus', 'jadwal'],
                'question' => 'Bagaimana cara mengedit atau menghapus jadwal?',
                'answer' => 'Untuk mengedit jadwal:\n1. Buka menu Jadwal\n2. Klik pada jadwal yang ingin diedit\n3. Klik tombol Edit (ikon pensil)\n4. Ubah informasi yang diperlukan\n5. Simpan\n\nUntuk menghapus, klik icon hapus pada detail jadwal.',
                'is_active' => true,
                'usage_count' => 28,
            ],
            [
                'category' => 'Keuangan',
                'keywords' => ['analisis', 'laporan', 'grafik', 'statistik'],
                'question' => 'Bagaimana melihat analisis keuangan?',
                'answer' => 'Analisis keuangan tersedia di halaman Keuangan:\n- Grafik income vs expense\n- Total per komoditas\n- Trend bulanan\n- Filter berdasarkan periode\n\nGunakan data ini untuk evaluasi dan perencanaan usaha tani Anda.',
                'is_active' => true,
                'usage_count' => 19,
            ],
            [
                'category' => 'Umum',
                'keywords' => ['notifikasi', 'pengingat', 'pemberitahuan'],
                'question' => 'Apa fungsi notifikasi di aplikasi?',
                'answer' => 'Notifikasi di Agrigo membantu Anda:\n- Pengingat jadwal tanam (mulai, tengah, akhir)\n- Update informasi penting\n- Tips pertanian\n- Peringatan cuaca\n\nAktifkan notifikasi agar tidak ketinggalan informasi penting!',
                'is_active' => true,
                'usage_count' => 56,
            ],
        ];

        foreach ($faqs as $faq) {
            ChatbotFaq::create($faq);
        }

        // Seed App Settings
        $settings = [
            [
                'key' => 'app_name',
                'value' => 'Agrigo',
                'type' => 'string',
                'category' => 'general',
                'description' => 'Nama aplikasi',
            ],
            [
                'key' => 'app_version',
                'value' => '1.0.0',
                'type' => 'string',
                'category' => 'general',
                'description' => 'Versi aplikasi saat ini',
            ],
            [
                'key' => 'maintenance_mode',
                'value' => 'false',
                'type' => 'boolean',
                'category' => 'general',
                'description' => 'Mode maintenance untuk aplikasi',
            ],
            [
                'key' => 'weather_api_key',
                'value' => 'YOUR_OPENWEATHER_API_KEY',
                'type' => 'string',
                'category' => 'api',
                'description' => 'API key untuk OpenWeather',
            ],
            [
                'key' => 'weather_update_interval',
                'value' => '3600',
                'type' => 'number',
                'category' => 'weather',
                'description' => 'Interval update cuaca (dalam detik)',
            ],
            [
                'key' => 'enable_notifications',
                'value' => 'true',
                'type' => 'boolean',
                'category' => 'features',
                'description' => 'Aktifkan sistem notifikasi',
            ],
            [
                'key' => 'enable_chatbot',
                'value' => 'true',
                'type' => 'boolean',
                'category' => 'features',
                'description' => 'Aktifkan fitur chatbot',
            ],
            [
                'key' => 'notification_schedule_reminder',
                'value' => 'true',
                'type' => 'boolean',
                'category' => 'notifications',
                'description' => 'Kirim pengingat jadwal tanam',
            ],
            [
                'key' => 'max_schedules_per_user',
                'value' => '50',
                'type' => 'number',
                'category' => 'general',
                'description' => 'Maksimal jadwal per pengguna',
            ],
            [
                'key' => 'supported_commodities',
                'value' => '["Padi","Jagung","Cabai","Tomat","Kedelai","Singkong","Bayam","Kangkung"]',
                'type' => 'json',
                'category' => 'general',
                'description' => 'Daftar komoditas yang didukung',
            ],
        ];

        foreach ($settings as $setting) {
            AppSetting::create($setting);
        }
    }
}
