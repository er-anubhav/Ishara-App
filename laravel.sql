-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 26, 2026 at 07:53 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `laravel`
--
CREATE DATABASE IF NOT EXISTS `laravel` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `laravel`;

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(60) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `specializations` longtext DEFAULT NULL,
  `role` enum('Admin','Sub-Admin') NOT NULL DEFAULT 'Sub-Admin',
  `is_active` enum('Yes','No') NOT NULL DEFAULT 'Yes',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `admins`
--

TRUNCATE TABLE `admins`;
-- --------------------------------------------------------

--
-- Table structure for table `banners`
--

DROP TABLE IF EXISTS `banners`;
CREATE TABLE `banners` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `image` varchar(191) DEFAULT NULL,
  `type` varchar(10) NOT NULL DEFAULT 'Normal' COMMENT 'e.g. Normal, Slider',
  `position` int(11) DEFAULT NULL,
  `url` longtext DEFAULT NULL,
  `url_type` enum('slug','link') NOT NULL DEFAULT 'slug',
  `remarks` varchar(191) DEFAULT NULL,
  `is_active` enum('Yes','No') NOT NULL DEFAULT 'Yes',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `banners`
--

TRUNCATE TABLE `banners`;
-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) NOT NULL,
  `icon` varchar(100) DEFAULT NULL,
  `position` smallint(6) NOT NULL DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `is_active` enum('Yes','No') NOT NULL DEFAULT 'Yes'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `categories`
--

TRUNCATE TABLE `categories`;
-- --------------------------------------------------------

--
-- Table structure for table `c_m_s`
--

DROP TABLE IF EXISTS `c_m_s`;
CREATE TABLE `c_m_s` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `tags` longtext DEFAULT NULL,
  `is_active` enum('Yes','No') NOT NULL DEFAULT 'Yes',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `c_m_s`
--

TRUNCATE TABLE `c_m_s`;
-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
CREATE TABLE `doctors` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) NOT NULL,
  `specializations` varchar(50) DEFAULT NULL,
  `experience_years` smallint(6) NOT NULL DEFAULT 0,
  `experience_months` smallint(6) NOT NULL DEFAULT 0,
  `time_from` time DEFAULT NULL,
  `time_to` time DEFAULT NULL,
  `degree` varchar(100) DEFAULT NULL,
  `services` longtext DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `verified` enum('Yes','No') NOT NULL DEFAULT 'No',
  `featured` enum('Yes','No') NOT NULL DEFAULT 'No',
  `is_active` enum('Yes','No') NOT NULL DEFAULT 'Yes',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `latitude` varchar(100) DEFAULT NULL,
  `longitude` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `doctors`
--

TRUNCATE TABLE `doctors`;
-- --------------------------------------------------------

--
-- Table structure for table `doctor_addresses`
--

DROP TABLE IF EXISTS `doctor_addresses`;
CREATE TABLE `doctor_addresses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `latitude` varchar(100) DEFAULT NULL,
  `longitude` varchar(100) DEFAULT NULL,
  `location` longtext DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `doctor_addresses`
--

TRUNCATE TABLE `doctor_addresses`;
-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `failed_jobs`
--

TRUNCATE TABLE `failed_jobs`;
-- --------------------------------------------------------

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
CREATE TABLE `files` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `folder_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `file_type` varchar(20) NOT NULL,
  `remarks` longtext DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `files`
--

TRUNCATE TABLE `files`;
-- --------------------------------------------------------

--
-- Table structure for table `folders`
--

DROP TABLE IF EXISTS `folders`;
CREATE TABLE `folders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `belongs_to` varchar(100) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `folders`
--

TRUNCATE TABLE `folders`;
-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `migrations`
--

TRUNCATE TABLE `migrations`;
--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_resets_table', 1),
(3, '2019_08_19_000000_create_failed_jobs_table', 1),
(4, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(5, '2022_05_16_091244_create_admins_table', 2),
(6, '2022_05_16_093710_create_secretes_table', 2),
(7, '2022_05_16_094105_create_specializations_table', 2),
(8, '2022_05_16_094146_create_doctors_table', 2),
(9, '2022_05_16_094206_create_banners_table', 2),
(10, '2022_05_16_094240_create_notifications_table', 2),
(11, '2022_05_16_094308_create_categories_table', 2),
(12, '2022_05_16_094325_create_tags_table', 2),
(13, '2022_05_16_094344_create_posts_table', 2),
(14, '2022_05_16_094421_create_settings_table', 2),
(15, '2022_05_16_094440_create_c_m_s_table', 2),
(16, '2022_05_16_113648_create_user_profiles_table', 2),
(17, '2022_05_18_073314_add_column_type_in_notifications_table', 2),
(18, '2022_05_19_152032_add_column_is_active_in_categories_table', 2),
(19, '2022_06_03_111622_create_folders_table', 2),
(20, '2022_06_03_112007_create_files_table', 2),
(21, '2022_06_07_180221_add_columns_latitude_and_logitude_in_doctors_table', 2),
(22, '2022_06_10_151802_create_doctor_addresses_table', 2);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `user_type` varchar(10) DEFAULT NULL,
  `title` varchar(191) NOT NULL,
  `message` longtext DEFAULT NULL,
  `image` varchar(100) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `type` enum('auto','manual') NOT NULL DEFAULT 'auto'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `notifications`
--

TRUNCATE TABLE `notifications`;
-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `password_resets`
--

TRUNCATE TABLE `password_resets`;
-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `personal_access_tokens`
--

TRUNCATE TABLE `personal_access_tokens`;
-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `heading` varchar(255) NOT NULL,
  `description` longtext DEFAULT NULL,
  `image` varchar(100) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `tags` longtext DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `status` enum('Active','Draft') NOT NULL DEFAULT 'Draft',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `posts`
--

TRUNCATE TABLE `posts`;
-- --------------------------------------------------------

--
-- Table structure for table `secretes`
--

DROP TABLE IF EXISTS `secretes`;
CREATE TABLE `secretes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(10) DEFAULT NULL,
  `phone` varchar(100) NOT NULL,
  `otp` int(10) UNSIGNED NOT NULL,
  `is_used` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `secretes`
--

TRUNCATE TABLE `secretes`;
--
-- Dumping data for table `secretes`
--

INSERT INTO `secretes` (`id`, `user_id`, `user_type`, `phone`, `otp`, `is_used`, `created_at`, `updated_at`) VALUES
(1, NULL, 'User', '9999999999', 123456, 1, '2026-02-19 10:18:24', '2026-02-19 10:18:48'),
(2, NULL, 'User', '9506736531', 123456, 1, '2026-02-19 10:29:14', '2026-02-19 10:32:52'),
(3, 2, 'User', '9506736531', 123456, 1, '2026-02-21 10:48:54', '2026-02-21 10:49:08'),
(4, 2, 'User', '9506736531', 123456, 1, '2026-02-21 10:49:45', '2026-02-21 10:49:49'),
(5, 2, 'User', '9506736531', 123456, 1, '2026-02-21 10:59:27', '2026-02-21 11:08:04'),
(6, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:09:09', '2026-02-21 11:09:10'),
(7, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:10:39', '2026-02-21 11:10:40'),
(8, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:10:42', '2026-02-21 11:10:42'),
(9, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:11:50', '2026-02-21 11:11:50'),
(10, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:12:18', '2026-02-21 11:12:18'),
(11, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:12:41', '2026-02-21 11:12:42'),
(12, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:12:56', '2026-02-21 11:12:56'),
(13, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:13:10', '2026-02-21 11:13:11'),
(14, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:22:46', '2026-02-21 11:22:51'),
(15, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:25:59', '2026-02-21 11:26:05'),
(16, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:30:02', '2026-02-21 11:30:03'),
(17, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:30:15', '2026-02-21 11:30:15'),
(18, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:36:27', '2026-02-21 11:37:07'),
(19, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:37:53', '2026-02-21 11:37:53'),
(20, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:38:07', '2026-02-21 11:38:07'),
(21, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:40:45', '2026-02-21 11:40:46'),
(22, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:41:00', '2026-02-21 11:41:00'),
(23, 2, 'User', '9506736531', 123456, 1, '2026-02-21 11:41:24', '2026-02-21 11:41:24');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(255) DEFAULT NULL,
  `value` longtext DEFAULT NULL,
  `is_active` enum('Yes','No') NOT NULL DEFAULT 'Yes',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `settings`
--

TRUNCATE TABLE `settings`;
-- --------------------------------------------------------

--
-- Table structure for table `specializations`
--

DROP TABLE IF EXISTS `specializations`;
CREATE TABLE `specializations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `position` smallint(6) NOT NULL DEFAULT 0,
  `is_active` enum('Yes','No') NOT NULL DEFAULT 'Yes',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `specializations`
--

TRUNCATE TABLE `specializations`;
-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `tags`
--

TRUNCATE TABLE `tags`;
-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(60) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(191) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `location` longtext DEFAULT NULL,
  `is_active` enum('Yes','No') NOT NULL DEFAULT 'Yes',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `users`
--

TRUNCATE TABLE `users`;
--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `phone`, `email_verified_at`, `password`, `remember_token`, `location`, `is_active`, `created_at`, `updated_at`) VALUES
(1, NULL, NULL, '9999999999', NULL, NULL, NULL, NULL, 'Yes', '2026-02-19 10:18:48', '2026-02-19 10:18:48'),
(2, 'Anubhav Tripathi', 'er.tripathianubhav@gmail.com', '9506736531', NULL, NULL, NULL, NULL, 'Yes', '2026-02-19 10:32:52', '2026-02-21 11:41:24');

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
--

DROP TABLE IF EXISTS `user_profiles`;
CREATE TABLE `user_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('Self','Add-On') NOT NULL DEFAULT 'Self',
  `gender` enum('Male','Female','Other') NOT NULL DEFAULT 'Other',
  `dob` date DEFAULT NULL,
  `relation` varchar(50) DEFAULT NULL,
  `location` longtext DEFAULT NULL,
  `icon` varchar(100) DEFAULT NULL,
  `device_token` varchar(255) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Truncate table before insert `user_profiles`
--

TRUNCATE TABLE `user_profiles`;
--
-- Dumping data for table `user_profiles`
--

INSERT INTO `user_profiles` (`id`, `parent_id`, `user_id`, `name`, `type`, `gender`, `dob`, `relation`, `location`, `icon`, `device_token`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, NULL, 2, 'Anubhav Tripathi', 'Self', 'Other', NULL, NULL, NULL, 'user-black.png', NULL, NULL, '2026-02-21 11:10:41', '2026-02-21 11:10:41'),
(2, 2, NULL, 'Anubhav', 'Add-On', 'Other', NULL, 'Brother', NULL, 'user.png', 'fFpgWOmCSAufZUGIh8D0HW:APA91bHmxxtNgZeX-AFOjL_xXFjZ6HQKk3VCJr-AKlvqGbHbgUbteCyqfKXvI0iiB4tRhqh4bdjtleKd7KKA__aEtib19iKRDCpog8WDODd46kUYeXBJj9o', NULL, '2026-02-21 11:26:18', '2026-02-21 11:53:42');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admins_email_unique` (`email`),
  ADD UNIQUE KEY `admins_phone_unique` (`phone`);

--
-- Indexes for table `banners`
--
ALTER TABLE `banners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `c_m_s`
--
ALTER TABLE `c_m_s`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `doctor_addresses`
--
ALTER TABLE `doctor_addresses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `files`
--
ALTER TABLE `files`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `folders`
--
ALTER TABLE `folders`
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
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `secretes`
--
ALTER TABLE `secretes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `specializations`
--
ALTER TABLE `specializations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tags`
--
ALTER TABLE `tags`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_phone_unique` (`phone`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `banners`
--
ALTER TABLE `banners`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `c_m_s`
--
ALTER TABLE `c_m_s`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `doctors`
--
ALTER TABLE `doctors`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `doctor_addresses`
--
ALTER TABLE `doctor_addresses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `files`
--
ALTER TABLE `files`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `folders`
--
ALTER TABLE `folders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `posts`
--
ALTER TABLE `posts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `secretes`
--
ALTER TABLE `secretes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `specializations`
--
ALTER TABLE `specializations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tags`
--
ALTER TABLE `tags`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
