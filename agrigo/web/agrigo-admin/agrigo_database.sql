-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 09, 2025 at 04:26 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `agrigo_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `module` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `app_settings`
--

CREATE TABLE `app_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'string',
  `category` varchar(255) NOT NULL DEFAULT 'general',
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `key`, `value`, `type`, `category`, `description`, `created_at`, `updated_at`) VALUES
(1, 'app_name', 'Agrigo', 'string', 'general', 'Nama aplikasi', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, 'app_version', '1.0.0', 'string', 'general', 'Versi aplikasi', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(3, 'maintenance_mode', 'false', 'boolean', 'general', 'Mode maintenance', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(4, 'enable_notifications', 'true', 'boolean', 'features', 'Aktifkan notifikasi', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(5, 'enable_chatbot', 'true', 'boolean', 'features', 'Aktifkan chatbot', '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `articles`
--

CREATE TABLE `articles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `author` varchar(255) NOT NULL DEFAULT 'Admin Agrigo',
  `is_published` tinyint(1) NOT NULL DEFAULT 1,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `articles`
--

INSERT INTO `articles` (`id`, `title`, `category`, `content`, `image_url`, `author`, `is_published`, `view_count`, `tags`, `created_at`, `updated_at`) VALUES
(1, 'Tips Menanam Padi di Musim Hujan', 'Tips Pertanian', 'Menanam padi di musim hujan memerlukan perhatian khusus. Pastikan drainase lahan baik, pilih varietas yang tahan terhadap curah hujan tinggi, dan perhatikan pemupukan yang tepat.', 'https://via.placeholder.com/800x400/4CAF50/ffffff?text=Tips+Padi', 'Admin Agrigo', 1, 125, '[\"padi\",\"musim hujan\",\"tips\"]', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, 'Cara Efektif Mengelola Keuangan Pertanian', 'Panduan', 'Pengelolaan keuangan yang baik adalah kunci sukses dalam bertani. Catat semua pemasukan dan pengeluaran dengan aplikasi Agrigo.', 'https://via.placeholder.com/800x400/2196F3/ffffff?text=Keuangan', 'Tim Agrigo', 1, 89, '[\"keuangan\",\"tips\",\"manajemen\"]', '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_faqs`
--

CREATE TABLE `chatbot_faqs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(255) NOT NULL,
  `keywords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`keywords`)),
  `question` text NOT NULL,
  `answer` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `usage_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chatbot_faqs`
--

INSERT INTO `chatbot_faqs` (`id`, `category`, `keywords`, `question`, `answer`, `is_active`, `usage_count`, `created_at`, `updated_at`) VALUES
(1, 'Jadwal Tanam', '[\"jadwal\",\"tanam\",\"mulai\",\"kapan\",\"waktu\"]', 'Bagaimana cara membuat jadwal tanam?', 'Buka menu Jadwal, klik tombol +, isi informasi komoditas dan tanggal, lalu simpan. Notifikasi pengingat akan otomatis dikirim.', 1, 45, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, 'Keuangan', '[\"transaksi\",\"uang\",\"pemasukan\",\"pengeluaran\"]', 'Bagaimana cara mencatat transaksi?', 'Buka halaman Keuangan, pilih Pemasukan/Pengeluaran, klik +, isi detail transaksi, lalu simpan.', 1, 67, '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `commodities`
--

CREATE TABLE `commodities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `commodities`
--

INSERT INTO `commodities` (`id`, `name`, `type`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Padi', 'Padi-padian', 'Tanaman padi untuk beras', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, 'Jagung', 'Padi-padian', 'Tanaman jagung', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(3, 'Gandum', 'Padi-padian', 'Tanaman gandum', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(4, 'Kedelai', 'Palawija', 'Tanaman kedelai', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(5, 'Kacang Tanah', 'Palawija', 'Tanaman kacang tanah', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(6, 'Kacang Hijau', 'Palawija', 'Tanaman kacang hijau', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(7, 'Kacang Merah', 'Palawija', 'Tanaman kacang merah', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(8, 'Cabai', 'Sayuran', 'Tanaman cabai merah/rawit', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(9, 'Tomat', 'Sayuran', 'Tanaman tomat', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(10, 'Bayam', 'Sayuran', 'Tanaman bayam hijau', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(11, 'Kangkung', 'Sayuran', 'Tanaman kangkung', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(12, 'Sawi', 'Sayuran', 'Tanaman sawi hijau', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(13, 'Brokoli', 'Sayuran', 'Tanaman brokoli', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(14, 'Kubis', 'Sayuran', 'Tanaman kubis/kol', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(15, 'Wortel', 'Sayuran', 'Tanaman wortel', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(16, 'Bawang Merah', 'Sayuran', 'Tanaman bawang merah', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(17, 'Bawang Putih', 'Sayuran', 'Tanaman bawang putih', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(18, 'Terong', 'Sayuran', 'Tanaman terong', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(19, 'Timun', 'Sayuran', 'Tanaman timun', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(20, 'Pisang', 'Buah-buahan', 'Tanaman pisang', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(21, 'Mangga', 'Buah-buahan', 'Tanaman mangga', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(22, 'Jeruk', 'Buah-buahan', 'Tanaman jeruk', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(23, 'Pepaya', 'Buah-buahan', 'Tanaman pepaya', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(24, 'Semangka', 'Buah-buahan', 'Tanaman semangka', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(25, 'Melon', 'Buah-buahan', 'Tanaman melon', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(26, 'Strawberry', 'Buah-buahan', 'Tanaman strawberry', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(27, 'Singkong', 'Umbi-umbian', 'Tanaman singkong/ketela pohon', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(28, 'Ubi Jalar', 'Umbi-umbian', 'Tanaman ubi jalar', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(29, 'Kentang', 'Umbi-umbian', 'Tanaman kentang', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(30, 'Talas', 'Umbi-umbian', 'Tanaman talas', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(31, 'Jahe', 'Rempah-rempah', 'Tanaman jahe', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(32, 'Kunyit', 'Rempah-rempah', 'Tanaman kunyit', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(33, 'Lengkuas', 'Rempah-rempah', 'Tanaman lengkuas', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(34, 'Kencur', 'Rempah-rempah', 'Tanaman kencur', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(35, 'Serai', 'Rempah-rempah', 'Tanaman serai', 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2024_12_08_100000_create_agrigo_tables', 1);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `icon_type` varchar(255) NOT NULL DEFAULT 'info',
  `color_type` varchar(255) NOT NULL DEFAULT 'green',
  `schedule_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `is_sent` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `description`, `icon_type`, `color_type`, `schedule_id`, `is_read`, `scheduled_at`, `is_sent`, `created_at`, `updated_at`) VALUES
(1, 2, 'Jadwal Tanam Padi Dimulai', 'Jadwal tanam padi Anda akan dimulai 5 hari lagi. Persiapkan lahan dan bibit.', 'schedule', 'green', 1, 0, NULL, 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, NULL, 'Tips Pertanian', 'Musim hujan tiba! Perhatikan drainase lahan Anda.', 'info', 'blue', NULL, 0, NULL, 1, '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schedules`
--

CREATE TABLE `schedules` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `commodity_id` bigint(20) UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('active','completed','cancelled') NOT NULL DEFAULT 'active',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `schedules`
--

INSERT INTO `schedules` (`id`, `user_id`, `commodity_id`, `start_date`, `end_date`, `status`, `notes`, `created_at`, `updated_at`) VALUES
(1, 2, 1, '2025-12-13', '2026-04-12', 'active', 'Tanam padi varietas IR64', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, 2, 5, '2025-11-08', '2026-02-06', 'active', 'Cabai merah keriting', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(3, 3, 2, '2025-10-09', '2025-12-03', 'completed', 'Panen jagung manis', '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `commodity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` enum('income','expense') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `description` text DEFAULT NULL,
  `date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`id`, `user_id`, `commodity_id`, `type`, `amount`, `description`, `date`, `created_at`, `updated_at`) VALUES
(1, 2, 1, 'income', 5000000.00, 'Penjualan padi 500 kg', '2025-11-28', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, 2, 1, 'expense', 1500000.00, 'Pembelian pupuk dan pestisida', '2025-11-23', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(3, 3, 2, 'income', 3500000.00, 'Penjualan jagung 700 kg', '2025-12-01', '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','farmer') NOT NULL DEFAULT 'farmer',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `is_active`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Admin Agrigo', 'admin@agrigo.com', NULL, '$2y$12$TIfSmb.Q.YbOJX4NkBFRt.GdymuL0kWFWFNGATqPYuGL0GLauEI0C', 'admin', 1, NULL, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, 'Budi Santoso', 'budi@farmer.com', NULL, '$2y$12$iEK7gAmsF9L.ly0gKRGBzO/hPBHVTLkBljNuoqCtQpk5B/JZcYCF2', 'farmer', 1, NULL, '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(3, 'Siti Rahayu', 'siti@farmer.com', NULL, '$2y$12$ADxmmdsHjt1cuBEqLkm2C.4MANmkHhS3QnL2mN7IrK7FS4lDUF8F6', 'farmer', 1, NULL, '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
--

CREATE TABLE `user_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_profiles`
--

INSERT INTO `user_profiles` (`id`, `user_id`, `phone`, `address`, `location`, `created_at`, `updated_at`) VALUES
(1, 2, '08123456789', 'Subang, Jawa Barat', 'Subang', '2025-12-08 05:35:45', '2025-12-08 05:35:45'),
(2, 3, '08129876543', 'Karawang, Jawa Barat', 'Karawang', '2025-12-08 05:35:45', '2025-12-08 05:35:45');

-- --------------------------------------------------------

--
-- Table structure for table `weather_data`
--

CREATE TABLE `weather_data` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `location` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `temperature` decimal(5,2) NOT NULL,
  `humidity` int(11) NOT NULL,
  `rainfall` decimal(8,2) NOT NULL DEFAULT 0.00,
  `wind_speed` decimal(5,2) NOT NULL DEFAULT 0.00,
  `condition` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_logs_user_id_foreign` (`user_id`);

--
-- Indexes for table `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `app_settings_key_unique` (`key`);

--
-- Indexes for table `articles`
--
ALTER TABLE `articles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `chatbot_faqs`
--
ALTER TABLE `chatbot_faqs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `commodities`
--
ALTER TABLE `commodities`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_user_id_foreign` (`user_id`),
  ADD KEY `notifications_schedule_id_foreign` (`schedule_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `schedules`
--
ALTER TABLE `schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `schedules_user_id_foreign` (`user_id`),
  ADD KEY `schedules_commodity_id_foreign` (`commodity_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `transactions_commodity_id_foreign` (`commodity_id`),
  ADD KEY `transactions_user_id_type_index` (`user_id`,`type`),
  ADD KEY `transactions_date_index` (`date`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_profiles_user_id_foreign` (`user_id`);

--
-- Indexes for table `weather_data`
--
ALTER TABLE `weather_data`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `articles`
--
ALTER TABLE `articles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `chatbot_faqs`
--
ALTER TABLE `chatbot_faqs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `commodities`
--
ALTER TABLE `commodities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `schedules`
--
ALTER TABLE `schedules`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `weather_data`
--
ALTER TABLE `weather_data`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `activity_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_schedule_id_foreign` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `schedules_commodity_id_foreign` FOREIGN KEY (`commodity_id`) REFERENCES `commodities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedules_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_commodity_id_foreign` FOREIGN KEY (`commodity_id`) REFERENCES `commodities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

<?php
$user = App\Models\User::find(1);
$user->password = bcrypt('admin123');
$user->save();
exit
