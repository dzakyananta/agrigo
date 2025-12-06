-- --------------------------------------------------------
-- Database: agrigo_admin
-- Struktur dan Data untuk Sistem Manajemen Pertanian Agrigo
-- --------------------------------------------------------

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- --------------------------------------------------------
-- Struktur dari tabel `users`
-- --------------------------------------------------------

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('farmer','admin','buyer') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'farmer',
  `status` enum('active','inactive','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Dumping data untuk tabel `users`
-- --------------------------------------------------------

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `status`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Admin Agrigo', 'admin@agrigo.com', '2025-12-01 08:00:00', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'active', NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(2, 'Budi Santoso', 'budi@farmer.com', '2025-12-01 08:00:00', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'farmer', 'active', NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(3, 'Siti Rahayu', 'siti@farmer.com', '2025-12-01 08:00:00', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'farmer', 'active', NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(4, 'Ahmad Wijaya', 'ahmad@farmer.com', '2025-12-01 08:00:00', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'farmer', 'active', NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(5, 'PT. Agro Mandiri', 'buyer@agromandiri.com', '2025-12-01 08:00:00', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'buyer', 'active', NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(6, 'CV. Tani Makmur', 'buyer@tanimakmur.com', '2025-12-01 08:00:00', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'buyer', 'active', NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00');

-- --------------------------------------------------------
-- Struktur dari tabel `user_profiles`
-- --------------------------------------------------------

CREATE TABLE `user_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `farm_size` decimal(10,2) DEFAULT NULL,
  `farm_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `crops_grown` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `experience_years` int(11) DEFAULT NULL,
  `profile_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Dumping data untuk tabel `user_profiles`
-- --------------------------------------------------------

INSERT INTO `user_profiles` (`id`, `user_id`, `phone`, `address`, `date_of_birth`, `gender`, `farm_size`, `farm_location`, `crops_grown`, `experience_years`, `profile_picture`, `created_at`, `updated_at`) VALUES
(1, 2, '08123456789', 'Jl. Sawah Indah No. 123, Subang, Jawa Barat', '1980-05-15', 'male', 2.50, 'Subang, Jawa Barat', 'Padi, Jagung, Cabai', 15, NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(2, 3, '08234567890', 'Jl. Tani Makmur No. 456, Karawang, Jawa Barat', '1985-08-22', 'female', 1.80, 'Karawang, Jawa Barat', 'Tomat, Kentang, Wortel', 10, NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(3, 4, '08345678901', 'Jl. Pertanian No. 789, Bogor, Jawa Barat', '1975-12-10', 'male', 3.20, 'Bogor, Jawa Barat', 'Sayuran Hijau, Cabai, Tomat', 20, NULL, '2025-12-01 08:00:00', '2025-12-01 08:00:00');

-- --------------------------------------------------------
-- Struktur dari tabel `commodities`
-- --------------------------------------------------------

CREATE TABLE `commodities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'kg',
  `current_price` decimal(15,2) NOT NULL DEFAULT 0.00,
  `min_price` decimal(15,2) DEFAULT NULL,
  `max_price` decimal(15,2) DEFAULT NULL,
  `harvest_season` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `storage_requirements` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quality_standards` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Dumping data untuk tabel `commodities`
-- --------------------------------------------------------

INSERT INTO `commodities` (`id`, `name`, `category`, `description`, `unit`, `current_price`, `min_price`, `max_price`, `harvest_season`, `storage_requirements`, `quality_standards`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Beras Premium', 'Biji-bijian', 'Beras premium kualitas terbaik hasil panen lokal dengan tekstur pulen dan rasa yang nikmat', 'kg', 15000.00, 12000.00, 18000.00, 'Maret-Juni, September-Desember', 'Suhu ruang (25-30°C), kelembaban rendah (14%), tempat kering dan bersih', 'Beras putih bersih, tidak berbau apek, kadar air maksimal 14%, bebas hama dan penyakit', 1, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(2, 'Jagung Pipilan', 'Biji-bijian', 'Jagung pipilan kering siap giling dengan kualitas terbaik untuk pakan ternak dan industri pangan', 'kg', 6500.00, 5500.00, 7500.00, 'Februari-Mei, Juli-Oktober', 'Tempat kering dengan ventilasi baik, suhu ruang, hindari kelembaban tinggi', 'Kadar air maksimal 14%, tidak berjamur, biji utuh dan bersih, warna kuning cerah', 1, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(3, 'Cabai Merah Keriting', 'Sayuran', 'Cabai merah keriting segar kualitas export dengan tingkat kepedasan sedang hingga tinggi', 'kg', 35000.00, 25000.00, 50000.00, 'Sepanjang tahun', 'Suhu dingin 10-15°C, kelembaban 85-90%, simpan dalam kemasan berlubang', 'Segar, tidak layu, warna merah cerah, ukuran seragam, bebas dari hama dan penyakit', 1, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(4, 'Tomat Sayur', 'Sayuran', 'Tomat sayur segar untuk kebutuhan rumah tangga dan industri pengolahan makanan', 'kg', 8500.00, 6000.00, 12000.00, 'Sepanjang tahun', 'Suhu sejuk 13-18°C, hindari sinar matahari langsung, kelembaban sedang', 'Matang merata, tidak busuk, kulit mulus, ukuran seragam, warna merah segar', 1, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(5, 'Kentang', 'Umbi-umbian', 'Kentang segar berkualitas tinggi untuk konsumsi langsung maupun industri pengolahan', 'kg', 12000.00, 10000.00, 15000.00, 'Juni-September', 'Tempat gelap dan sejuk 4-7°C, kelembaban 85-90%, ventilasi baik', 'Kulit mulus, tidak bertunas, tekstur keras, bebas dari penyakit dan hama', 1, '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(6, 'Wortel', 'Sayuran', 'Wortel segar dengan kandungan vitamin A tinggi untuk kebutuhan gizi keluarga', 'kg', 7500.00, 6000.00, 9000.00, 'Mei-Agustus, November-Februari', 'Suhu dingin 0-2°C, kelembaban tinggi 90-95%, simpan dalam plastik berlubang', 'Bentuk lurus, warna orange cerah, tekstur renyah, bebas dari kerusakan fisik', 1, '2025-12-01 08:00:00', '2025-12-01 08:00:00');

-- --------------------------------------------------------
-- Struktur dari tabel `transactions`
-- --------------------------------------------------------

CREATE TABLE `transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `commodity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `quantity` decimal(10,2) DEFAULT NULL,
  `price_per_unit` decimal(15,2) DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','confirmed','completed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `transaction_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Dumping data untuk tabel `transactions`
-- --------------------------------------------------------

INSERT INTO `transactions` (`id`, `user_id`, `commodity_id`, `type`, `category`, `amount`, `quantity`, `price_per_unit`, `description`, `status`, `transaction_date`, `created_at`, `updated_at`) VALUES
(1, 2, 1, 'sale', 'penjualan', 750000.00, 50.00, 15000.00, 'Penjualan beras premium hasil panen musim kemarau', 'completed', '2025-11-26', '2025-11-26 08:00:00', '2025-11-26 08:00:00'),
(2, 3, 3, 'sale', 'penjualan', 1050000.00, 30.00, 35000.00, 'Penjualan cabai merah keriting segar kualitas export', 'completed', '2025-11-28', '2025-11-28 08:00:00', '2025-11-28 08:00:00'),
(3, 2, 2, 'sale', 'penjualan', 325000.00, 50.00, 6500.00, 'Penjualan jagung pipilan kering siap giling', 'pending', '2025-11-30', '2025-11-30 08:00:00', '2025-11-30 08:00:00'),
(4, 4, 4, 'sale', 'penjualan', 170000.00, 20.00, 8500.00, 'Penjualan tomat sayur segar untuk pasar tradisional', 'confirmed', '2025-12-01', '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(5, 3, 5, 'sale', 'penjualan', 240000.00, 20.00, 12000.00, 'Penjualan kentang segar untuk supplier restoran', 'completed', '2025-11-25', '2025-11-25 08:00:00', '2025-11-25 08:00:00'),
(6, 4, 6, 'sale', 'penjualan', 150000.00, 20.00, 7500.00, 'Penjualan wortel segar organik', 'confirmed', '2025-11-29', '2025-11-29 08:00:00', '2025-11-29 08:00:00'),
(7, 2, 1, 'sale', 'penjualan', 450000.00, 30.00, 15000.00, 'Penjualan beras premium untuk distributor lokal', 'pending', '2025-11-27', '2025-11-27 08:00:00', '2025-11-27 08:00:00'),
(8, 3, 3, 'sale', 'penjualan', 875000.00, 25.00, 35000.00, 'Penjualan cabai merah keriting untuk industri makanan', 'completed', '2025-11-24', '2025-11-24 08:00:00', '2025-11-24 08:00:00');

-- --------------------------------------------------------
-- Struktur dari tabel `weather_data`
-- --------------------------------------------------------

CREATE TABLE `weather_data` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `temperature` decimal(5,2) DEFAULT NULL,
  `humidity` decimal(5,2) DEFAULT NULL,
  `rainfall` decimal(8,2) DEFAULT NULL,
  `wind_speed` decimal(5,2) DEFAULT NULL,
  `wind_direction` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weather_condition` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visibility` decimal(5,2) DEFAULT NULL,
  `pressure` decimal(7,2) DEFAULT NULL,
  `recorded_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Dumping data untuk tabel `weather_data`
-- --------------------------------------------------------

INSERT INTO `weather_data` (`id`, `location`, `latitude`, `longitude`, `temperature`, `humidity`, `rainfall`, `wind_speed`, `wind_direction`, `weather_condition`, `visibility`, `pressure`, `recorded_at`, `created_at`, `updated_at`) VALUES
(1, 'Subang, Jawa Barat', -6.56920000, 107.75810000, 28.50, 75.20, 2.50, 12.30, 'NW', 'Partly Cloudy', 10.00, 1013.20, '2025-12-01 08:00:00', '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(2, 'Karawang, Jawa Barat', -6.30190000, 107.30260000, 29.10, 72.80, 0.00, 8.70, 'SW', 'Sunny', 12.00, 1012.80, '2025-12-01 08:00:00', '2025-12-01 08:00:00', '2025-12-01 08:00:00'),
(3, 'Bogor, Jawa Barat', -6.59440000, 106.78810000, 26.80, 82.50, 5.20, 15.40, 'W', 'Light Rain', 8.50, 1014.10, '2025-12-01 08:00:00', '2025-12-01 08:00:00', '2025-12-01 08:00:00');

-- --------------------------------------------------------
-- Indexes untuk tabel yang dibuang
-- --------------------------------------------------------

--
-- Indexes untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes untuk tabel `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_profiles_user_id_foreign` (`user_id`);

--
-- Indexes untuk tabel `commodities`
--
ALTER TABLE `commodities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `commodities_name_index` (`name`),
  ADD KEY `commodities_category_index` (`category`);

--
-- Indexes untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `transactions_user_id_foreign` (`user_id`),
  ADD KEY `transactions_commodity_id_foreign` (`commodity_id`),
  ADD KEY `transactions_transaction_date_index` (`transaction_date`),
  ADD KEY `transactions_status_index` (`status`);

--
-- Indexes untuk tabel `weather_data`
--
ALTER TABLE `weather_data`
  ADD PRIMARY KEY (`id`),
  ADD KEY `weather_data_location_index` (`location`),
  ADD KEY `weather_data_recorded_at_index` (`recorded_at`);

-- --------------------------------------------------------
-- AUTO_INCREMENT untuk tabel yang dibuang
-- --------------------------------------------------------

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `commodities`
--
ALTER TABLE `commodities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `weather_data`
--
ALTER TABLE `weather_data`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

-- --------------------------------------------------------
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
-- --------------------------------------------------------

--
-- Ketidakleluasaan untuk tabel `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_commodity_id_foreign` FOREIGN KEY (`commodity_id`) REFERENCES `commodities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

COMMIT;