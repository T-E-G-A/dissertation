-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.20-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for oviasogie_school_mis_db_laravel
DROP DATABASE IF EXISTS `oviasogie_school_mis_db_laravel`;
CREATE DATABASE IF NOT EXISTS `oviasogie_school_mis_db_laravel` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `oviasogie_school_mis_db_laravel`;

-- Dumping structure for table oviasogie_school_mis_db_laravel.activity_logs
DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admin_id` bigint(20) unsigned NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `old_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `activity_logs_admin_id_foreign` (`admin_id`),
  CONSTRAINT `activity_logs_admin_id_foreign` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.activity_logs: ~6 rows (approximately)
INSERT INTO `activity_logs` (`id`, `admin_id`, `action`, `description`, `old_value`, `new_value`, `created_at`, `updated_at`) VALUES
	(1, 1, 'admission_status_change', 'Changed admission status for LNR/0001/2025 from unapproved to approved', '0', '1', '2025-02-17 04:23:37', '2025-02-17 04:23:37'),
	(2, 1, 'admission_status_change', 'Changed admission status for LNR/0002/2025 from unapproved to approved', '0', '1', '2025-02-17 04:23:37', '2025-02-17 04:23:37'),
	(3, 1, 'admission_status_change', 'Changed admission status for LNR/0004/2025 from unapproved to approved', '0', '1', '2025-02-17 04:23:48', '2025-02-17 04:23:48'),
	(4, 1, 'admission_status_change', 'Changed admission status for LNR/0005/2025 from unapproved to approved', '0', '1', '2025-02-17 04:26:41', '2025-02-17 04:26:41'),
	(5, 1, 'admission_status_change', 'Changed admission status for LNR/0008/2025 from unapproved to approved', '0', '1', '2025-02-17 06:14:46', '2025-02-17 06:14:46'),
	(6, 1, 'admission_status_change', 'Changed admission status for LNR/0006/2025 from unapproved to approved', '0', '1', '2025-02-17 18:53:19', '2025-02-17 18:53:19');

-- Dumping structure for table oviasogie_school_mis_db_laravel.admins
DROP TABLE IF EXISTS `admins`;
CREATE TABLE IF NOT EXISTS `admins` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `staffNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `login_attempts` int(11) NOT NULL DEFAULT 0,
  `locked_until` timestamp NULL DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admins_staffnumber_unique` (`staffNumber`),
  UNIQUE KEY `admins_username_unique` (`username`),
  UNIQUE KEY `admins_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.admins: ~2 rows (approximately)
INSERT INTO `admins` (`id`, `staffNumber`, `username`, `email`, `password`, `role`, `created_at`, `updated_at`, `is_active`, `login_attempts`, `locked_until`, `last_login_at`) VALUES
	(1, 'ADM/5729/2025', 'tanner72', 'edwardo96@example.com', '$2y$10$Q5mFKQLKJiIUosBRtrGp5.QgGmoBQ0ytten5X2QkV2WEiMzRy2bu.', 'admin', '2025-02-17 04:09:44', '2025-02-22 09:37:49', 1, 0, NULL, '2025-02-22 09:37:49'),
	(2, 'ADM/2187/2025', 'magnus.oconner', 'flo.kovacek@example.org', '$2y$10$5b7V6hDESxckFVB2Dq2QluXmejz9zN7cRADT/PO4fNGn7K2GP8prq', 'admin', '2025-02-17 04:09:44', '2025-02-17 05:47:25', 1, 0, NULL, '2025-02-17 05:47:25');

-- Dumping structure for table oviasogie_school_mis_db_laravel.attendance_records
DROP TABLE IF EXISTS `attendance_records`;
CREATE TABLE IF NOT EXISTS `attendance_records` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `week_number` tinyint(4) NOT NULL,
  `day_of_week` tinyint(4) NOT NULL,
  `present` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_att_rec_adm_wk_day` (`admissionNumber`,`week_number`,`day_of_week`),
  CONSTRAINT `attendance_records_admissionnumber_foreign` FOREIGN KEY (`admissionNumber`) REFERENCES `learners` (`admissionNumber`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.attendance_records: ~50 rows (approximately)
INSERT INTO `attendance_records` (`id`, `admissionNumber`, `week_number`, `day_of_week`, `present`, `created_at`, `updated_at`) VALUES
	(1, 'LNR/0001/2025', 1, 1, 1, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(2, 'LNR/0001/2025', 1, 2, 1, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(3, 'LNR/0001/2025', 1, 3, 1, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(4, 'LNR/0001/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(5, 'LNR/0001/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(6, 'LNR/0002/2025', 1, 1, 1, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(7, 'LNR/0002/2025', 1, 2, 1, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(8, 'LNR/0002/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(9, 'LNR/0002/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(10, 'LNR/0002/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(11, 'LNR/0003/2025', 1, 1, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(12, 'LNR/0003/2025', 1, 2, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(13, 'LNR/0003/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(14, 'LNR/0003/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(15, 'LNR/0003/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(16, 'LNR/0004/2025', 1, 1, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(17, 'LNR/0004/2025', 1, 2, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(18, 'LNR/0004/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(19, 'LNR/0004/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(20, 'LNR/0004/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(21, 'LNR/0005/2025', 1, 1, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(22, 'LNR/0005/2025', 1, 2, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(23, 'LNR/0005/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(24, 'LNR/0005/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(25, 'LNR/0005/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(26, 'LNR/0006/2025', 1, 1, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(27, 'LNR/0006/2025', 1, 2, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(28, 'LNR/0006/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(29, 'LNR/0006/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(30, 'LNR/0006/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(31, 'LNR/0007/2025', 1, 1, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(32, 'LNR/0007/2025', 1, 2, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(33, 'LNR/0007/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(34, 'LNR/0007/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(35, 'LNR/0007/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(36, 'LNR/0008/2025', 1, 1, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(37, 'LNR/0008/2025', 1, 2, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(38, 'LNR/0008/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(39, 'LNR/0008/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(40, 'LNR/0008/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(41, 'LNR/0009/2025', 1, 1, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(42, 'LNR/0009/2025', 1, 2, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(43, 'LNR/0009/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(44, 'LNR/0009/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(45, 'LNR/0009/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(46, 'LNR/0010/2025', 1, 1, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(47, 'LNR/0010/2025', 1, 2, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(48, 'LNR/0010/2025', 1, 3, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(49, 'LNR/0010/2025', 1, 4, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27'),
	(50, 'LNR/0010/2025', 1, 5, 0, '2025-02-17 04:26:06', '2025-02-17 18:53:27');

-- Dumping structure for table oviasogie_school_mis_db_laravel.failed_jobs
DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.failed_jobs: ~0 rows (approximately)

-- Dumping structure for table oviasogie_school_mis_db_laravel.fees
DROP TABLE IF EXISTS `fees`;
CREATE TABLE IF NOT EXISTS `fees` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `paid_amount` decimal(10,2) NOT NULL,
  `pending_amount` decimal(10,2) NOT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.fees: ~5 rows (approximately)
INSERT INTO `fees` (`id`, `admissionNumber`, `paid_amount`, `pending_amount`, `approved`, `created_at`, `updated_at`) VALUES
	(1, 'LNR/0008/2025', 869.59, 70.97, 0, '2025-02-17 04:09:45', '2025-02-17 19:26:50'),
	(2, 'LNR/0002/2025', 141.86, 382.12, 0, '2025-02-17 04:09:45', '2025-02-17 19:26:50'),
	(3, 'LNR/0004/2025', 1152.41, 0.00, 1, '2025-02-17 04:09:45', '2025-02-17 19:26:50'),
	(4, 'LNR/0010/2025', 173.35, 331.76, 1, '2025-02-17 04:09:45', '2025-02-17 19:26:50'),
	(5, 'LNR/0001/2025', 1500.00, 0.00, 1, '2025-02-17 04:09:45', '2025-02-17 19:26:50');

-- Dumping structure for table oviasogie_school_mis_db_laravel.learners
DROP TABLE IF EXISTS `learners`;
CREATE TABLE IF NOT EXISTS `learners` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `firstName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `age` int(11) NOT NULL,
  `gender` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parentName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parentEmail` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parentPhone` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `admitted` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` bigint(20) unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `login_attempts` int(11) NOT NULL DEFAULT 0,
  `locked_until` timestamp NULL DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `learners_admissionnumber_unique` (`admissionNumber`),
  UNIQUE KEY `learners_parentemail_unique` (`parentEmail`),
  KEY `learners_updated_by_foreign` (`updated_by`),
  CONSTRAINT `learners_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `admins` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.learners: ~10 rows (approximately)
INSERT INTO `learners` (`id`, `admissionNumber`, `firstName`, `lastName`, `age`, `gender`, `parentName`, `parentEmail`, `parentPhone`, `password`, `admitted`, `created_at`, `updated_at`, `updated_by`, `is_active`, `login_attempts`, `locked_until`, `last_login_at`) VALUES
	(1, 'LNR/0001/2025', 'Gerry', 'Koss', 14, 'Female', 'Jamison Schumm', 'arno.huels@yahoo.com', '+1-618-953-8125', '$2y$10$Z/nRAIsgkzyx6Gv.J1seCOUnI8IuPHlY8A6ex61gh9t3l/iwUvzvK', 1, '2025-02-17 04:09:45', '2025-02-25 09:04:21', 1, 1, 0, NULL, '2025-02-25 09:04:21'),
	(2, 'LNR/0002/2025', 'Rosalee', 'Dicki', 8, 'Female', 'Miguel Hudson', 'brooke.renner@morar.net', '332.508.6222', '$2y$10$4V3TqI00QP1tl.shFt7o6.viszZYEYIOjPpkmN7K7VAp/0jYMvsyi', 1, '2025-02-17 04:09:45', '2025-02-22 08:12:53', 1, 1, 0, NULL, '2025-02-22 08:12:53'),
	(3, 'LNR/0003/2025', 'Aliza', 'Will', 15, 'Female', 'Vicenta Wintheiser', 'kjohns@wilderman.com', '678-856-9393', '$2y$10$t25xTIzc/IdDixy7VtAgce9a7zwoGME.drVTTUx5lso/4EyFB4M9y', 0, '2025-02-17 04:09:45', '2025-02-17 04:09:45', NULL, 1, 0, NULL, NULL),
	(4, 'LNR/0004/2025', 'Cristian', 'Hyatt', 6, 'Female', 'Beaulah Hudson', 'norris00@yahoo.com', '+1 (689) 948-5533', '$2y$10$mPp9xcYyZuN5FpQuUwt.W.VazDztJLNTN07OzIF5u/7NyI.kHpZ6W', 1, '2025-02-17 04:09:45', '2025-02-17 04:23:48', 1, 1, 0, NULL, NULL),
	(5, 'LNR/0005/2025', 'Elsa', 'Becker', 12, 'Female', 'Leora Witting', 'wilkinson.vivianne@hotmail.com', '(870) 554-5408', '$2y$10$auFHoS5XgNK1Z1sKKeQsWOt4YmxiBy.Zcxf0buahY3.DGiKLHXBb.', 1, '2025-02-17 04:09:45', '2025-02-17 04:26:41', 1, 1, 0, NULL, NULL),
	(6, 'LNR/0006/2025', 'Maegan', 'Champlin', 15, 'Male', 'Marietta Ferry', 'ryan.roman@gibson.com', '+1-325-361-8897', '$2y$10$TaebZ0MGCuz8tMdJ9iDNUeqpnUJONC8m7LNK0Nz.JEgg5iwJU.eUO', 1, '2025-02-17 04:09:45', '2025-02-17 18:53:19', 1, 1, 0, NULL, NULL),
	(7, 'LNR/0007/2025', 'Darrion', 'Littel', 13, 'Female', 'Richie Marks DDS', 'drolfson@pollich.com', '+1.646.357.6578', '$2y$10$4nIjg5kZ4Xwsi1iAzqNzp.PerDpqSCO/KoBR2tAi4vnDAD4G8eYNG', 0, '2025-02-17 04:09:45', '2025-02-17 04:09:45', NULL, 1, 0, NULL, NULL),
	(8, 'LNR/0008/2025', 'Hadley', 'Harber', 18, 'Female', 'Jermey D\'Amore', 'hmraz@hotmail.com', '1-551-431-4191', '$2y$10$le.MqLESVbFkNhQt9vlSxe3AxyJuJ24LUifpKQXx8jr5HQJlUcwEa', 1, '2025-02-17 04:09:45', '2025-02-17 06:14:54', 1, 1, 0, NULL, '2025-02-17 06:14:54'),
	(9, 'LNR/0009/2025', 'Gretchen', 'Lesch', 6, 'Female', 'Bradley Runolfsdottir', 'halvorson.aaliyah@thompson.info', '+1 (430) 861-3089', '$2y$10$Gf76CvzFspryiyyzYDBp0.8LYaPeK191czesjHGPHPiTRDPqcbPIu', 0, '2025-02-17 04:09:45', '2025-02-17 04:09:45', NULL, 1, 0, NULL, NULL),
	(10, 'LNR/0010/2025', 'Devon', 'Crist', 7, 'Female', 'Lawson Smitham IV', 'cartwright.joanne@hotmail.com', '(440) 690-0596', '$2y$10$xrz6gciy60r8H8AHMyEnyOfbuazwrVCeoEQZDvNsQVmCbNcc0uap.', 0, '2025-02-17 04:09:45', '2025-02-17 04:09:45', NULL, 1, 0, NULL, NULL);

-- Dumping structure for table oviasogie_school_mis_db_laravel.migrations
DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.migrations: ~13 rows (approximately)
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
	(1, '2014_10_12_100000_create_password_resets_table', 1),
	(2, '2019_08_19_000000_create_failed_jobs_table', 1),
	(3, '2019_12_14_000001_create_personal_access_tokens_table', 1),
	(4, '2025_01_21_063219_create_admins_table', 1),
	(5, '2025_01_21_063244_create_learners_table', 1),
	(6, '2025_02_06_091247_create_fees_table', 1),
	(7, '2025_02_06_091317_create_results_table', 1),
	(8, '2025_02_06_091326_create_timetables_table', 1),
	(9, '2025_02_06_091336_create_notifications_table', 1),
	(10, '2025_02_14_185103_add_security_fields_to_admins_table', 1),
	(11, '2025_02_14_194611_add_security_fields_to_learners_table', 1),
	(12, '2025_02_15_090323_add_updated_by_to_learners_table', 1),
	(13, '2025_02_15_111217_create_attendance_records_table', 1);

-- Dumping structure for table oviasogie_school_mis_db_laravel.notifications
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.notifications: ~10 rows (approximately)
INSERT INTO `notifications` (`id`, `admissionNumber`, `message`, `category`, `created_at`, `updated_at`) VALUES
	(1, 'LNR/0008/2025', 'Clear fee please', 'fee_defaulters', '2025-02-17 06:48:02', '2025-02-17 06:48:02'),
	(2, 'LNR/0002/2025', 'Clear fee please', 'fee_defaulters', '2025-02-17 06:48:02', '2025-02-17 06:48:02'),
	(3, 'LNR/0004/2025', 'Clear fee please', 'fee_defaulters', '2025-02-17 06:48:02', '2025-02-17 06:48:02'),
	(4, 'LNR/0010/2025', 'Clear fee please', 'fee_defaulters', '2025-02-17 06:48:02', '2025-02-17 06:48:02'),
	(5, 'LNR/0001/2025', 'Clear fee please', 'fee_defaulters', '2025-02-17 06:48:02', '2025-02-17 06:48:02'),
	(6, 'LNR/0002/2025', 'pleasee clear bal', 'fee_defaulters', '2025-02-17 06:55:39', '2025-02-17 06:55:39'),
	(7, 'LNR/0004/2025', 'pleasee clear bal', 'fee_defaulters', '2025-02-17 06:55:39', '2025-02-17 06:55:39'),
	(8, 'LNR/0010/2025', 'pleasee clear bal', 'fee_defaulters', '2025-02-17 06:55:39', '2025-02-17 06:55:39'),
	(9, 'LNR/0001/2025', 'pleasee clear bal', 'fee_defaulters', '2025-02-17 06:55:39', '2025-02-17 06:55:39'),
	(10, 'LNR/0001/2025', 'Hello please come with any amount', 'individual', '2025-02-17 18:55:45', '2025-02-17 18:55:45');

-- Dumping structure for table oviasogie_school_mis_db_laravel.password_resets
DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE IF NOT EXISTS `password_resets` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.password_resets: ~0 rows (approximately)

-- Dumping structure for table oviasogie_school_mis_db_laravel.personal_access_tokens
DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.personal_access_tokens: ~5 rows (approximately)
INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `created_at`, `updated_at`) VALUES
	(1, 'App\\Models\\Learner', 1, 'learner-token', '498c0e2543d9e543c463c060d12da9449d126b4a571b698f78a1125fcf2c48ef', '["*"]', '2025-02-18 12:01:30', '2025-02-18 12:01:13', '2025-02-18 12:01:30'),
	(2, 'App\\Models\\Learner', 2, 'learner-token', '8896c118fa3db2aa36d33c040c0bb7c8bff33a2302b5187e81d38246636dfac0', '["*"]', '2025-02-18 12:05:01', '2025-02-18 12:03:55', '2025-02-18 12:05:01'),
	(7, 'App\\Models\\Admin', 1, 'admin-token', '679474cbe6ce92ac0f526bd5bc513297dcb9b7569ef273dfbe16e980a7d89c47', '["*"]', '2025-02-21 09:38:10', '2025-02-21 09:38:01', '2025-02-21 09:38:10'),
	(11, 'App\\Models\\Admin', 1, 'admin-token', '1aad170883cc69309469a1e774403eab64d97c87800b60507d2cc2aa27e56e2a', '["*"]', '2025-02-22 09:24:09', '2025-02-22 09:24:08', '2025-02-22 09:24:09'),
	(12, 'App\\Models\\Admin', 1, 'admin-token', '13144690ee0f51e4026267484f364dd7722fa9e4a2abfeae466f9be8f04adffd', '["*"]', '2025-02-22 09:37:50', '2025-02-22 09:37:49', '2025-02-22 09:37:50');

-- Dumping structure for table oviasogie_school_mis_db_laravel.results
DROP TABLE IF EXISTS `results`;
CREATE TABLE IF NOT EXISTS `results` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `maths` int(11) NOT NULL,
  `english` int(11) NOT NULL,
  `science` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.results: ~7 rows (approximately)
INSERT INTO `results` (`id`, `admissionNumber`, `maths`, `english`, `science`, `created_at`, `updated_at`) VALUES
	(1, 'LNR/0009/2025', 35, 50, 67, '2025-02-17 08:31:10', '2025-02-17 08:31:10'),
	(2, 'LNR/0010/2025', 60, 79, 77, '2025-02-17 08:31:10', '2025-02-17 08:31:10'),
	(3, 'LNR/0005/2025', 48, 72, 68, '2025-02-17 08:31:10', '2025-02-17 08:31:10'),
	(4, 'LNR/0003/2025', 78, 60, 61, '2025-02-17 08:31:10', '2025-02-17 08:31:10'),
	(5, 'LNR/0002/2025', 34, 70, 63, '2025-02-17 08:31:10', '2025-02-17 08:31:10'),
	(6, 'LNR/0001/2025', 75, 76, 90, '2025-02-17 08:31:10', '2025-02-17 18:54:04'),
	(7, 'LNR/0004/2025', 80, 45, 60, '2025-02-17 18:54:04', '2025-02-17 18:54:04');

-- Dumping structure for table oviasogie_school_mis_db_laravel.timetables
DROP TABLE IF EXISTS `timetables`;
CREATE TABLE IF NOT EXISTS `timetables` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `filepath` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` decimal(8,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_laravel.timetables: ~4 rows (approximately)
INSERT INTO `timetables` (`id`, `filename`, `filepath`, `description`, `file_type`, `file_size`, `created_at`, `updated_at`) VALUES
	(1, 'AES Print GreenCard.pdf', '/storage/timetables/1739796510_AES Print GreenCard.pdf', 'Timetable here', 'application/octet-stream', 100.42, '2025-02-17 09:48:30', '2025-02-17 09:48:30'),
	(2, 'school-mis-logo.pdf', '/storage/timetables/1739797710_school-mis-logo.pdf', 'Timetable test', 'application/octet-stream', 2755.28, '2025-02-17 10:08:30', '2025-02-17 10:08:30'),
	(3, 'FSWD Curriculum.pdf', '/storage/timetables/1739829277_FSWD Curriculum.pdf', 'Another timetable', 'application/octet-stream', 1925.59, '2025-02-17 18:54:38', '2025-02-17 18:54:38'),
	(4, 'FGCK PRAISE & WORSHIP MUSIC.xlsx', '/storage/timetables/1739829302_FGCK PRAISE & WORSHIP MUSIC.xlsx', 'An excel test', 'application/octet-stream', 9.21, '2025-02-17 18:55:02', '2025-02-17 18:55:02');


-- Dumping database structure for oviasogie_school_mis_db_nodejs
DROP DATABASE IF EXISTS `oviasogie_school_mis_db_nodejs`;
CREATE DATABASE IF NOT EXISTS `oviasogie_school_mis_db_nodejs` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `oviasogie_school_mis_db_nodejs`;

-- Dumping structure for table oviasogie_school_mis_db_nodejs.activitylogs
DROP TABLE IF EXISTS `activitylogs`;
CREATE TABLE IF NOT EXISTS `activitylogs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `action` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `activitylogs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.activitylogs: ~8 rows (approximately)
INSERT INTO `activitylogs` (`id`, `admin_id`, `action`, `description`, `old_value`, `new_value`, `createdAt`, `updatedAt`) VALUES
	(1, 2, 'LOGIN', 'Somnus vinculum provident comprehendo damno ventosus.', 'necessitatibus', 'vestigium', '2025-02-18 14:17:46', '2025-02-18 14:17:46'),
	(2, 2, 'LOGIN', 'Caterva volubilis vestrum.', 'cumque', 'vacuus', '2025-02-18 14:17:46', '2025-02-18 14:17:46'),
	(3, 1, 'UPDATE', 'Clibanus sordeo ea conicio comitatus.', 'paulatim', 'corrumpo', '2025-02-18 14:17:46', '2025-02-18 14:17:46'),
	(4, 1, 'LOGIN', 'Alioqui in antea velum esse sustineo valens cum.', 'spargo', 'vulgaris', '2025-02-18 14:17:46', '2025-02-18 14:17:46'),
	(5, 2, 'UPDATE', 'Calco amitto uterque ver bibo teres decerno villa.', 'curis', 'vacuus', '2025-02-18 14:17:46', '2025-02-18 14:17:46'),
	(6, 2, 'DELETE', 'Cariosus uterque quia quis vulgo.', 'nostrum', 'desipio', '2025-02-18 14:17:46', '2025-02-18 14:17:46'),
	(7, 2, 'admission_status_change', 'Changed admission status for LNR/0002/2025 from approved to unapproved', '1', '0', '2025-02-22 13:15:39', '2025-02-22 13:15:39'),
	(8, 2, 'admission_status_change', 'Changed admission status for LNR/0002/2025 from unapproved to approved', '0', '1', '2025-02-22 13:16:27', '2025-02-22 13:16:27'),
	(9, 2, 'admission_status_change', 'Changed admission status for LNR/0008/2025 from unapproved to approved', '0', '1', '2025-02-22 14:00:05', '2025-02-22 14:00:05');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.admins
DROP TABLE IF EXISTS `admins`;
CREATE TABLE IF NOT EXISTS `admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staffNumber` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `roleId` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `login_attempts` int(11) DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staffNumber` (`staffNumber`),
  UNIQUE KEY `email` (`email`),
  KEY `roleId` (`roleId`),
  CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`roleId`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.admins: ~2 rows (approximately)
INSERT INTO `admins` (`id`, `staffNumber`, `username`, `email`, `password`, `roleId`, `is_active`, `login_attempts`, `locked_until`, `last_login_at`, `createdAt`, `updatedAt`) VALUES
	(1, 'ADM/0001/2025', 'Haven94', 'Gillian78@gmail.com', '$2b$10$71EegIv8cUBkBSZqJKldiuzKUiIUAffdIGtLA9Vl6zc.5IqyA5Tme', 1, 1, 0, NULL, NULL, '2025-02-18 14:15:31', '2025-02-18 14:15:31'),
	(2, 'ADM/0002/2025', 'kkub', 'Devon15@hotmail.com', '$2b$10$Vp1IqvORHTgB5yuVcMeazei7nj0GDnXtqClwKe/yzn0y2iHsOEUg2', 2, 1, 0, NULL, '2025-02-22 15:15:18', '2025-02-18 14:15:31', '2025-02-22 15:15:18');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.attendancerecords
DROP TABLE IF EXISTS `attendancerecords`;
CREATE TABLE IF NOT EXISTS `attendancerecords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) NOT NULL,
  `week_number` tinyint(4) NOT NULL,
  `day_of_week` tinyint(4) NOT NULL,
  `present` tinyint(1) DEFAULT 0,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `admissionNumber` (`admissionNumber`),
  CONSTRAINT `attendancerecords_ibfk_1` FOREIGN KEY (`admissionNumber`) REFERENCES `learners` (`admissionNumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.attendancerecords: ~71 rows (approximately)
INSERT INTO `attendancerecords` (`id`, `admissionNumber`, `week_number`, `day_of_week`, `present`, `createdAt`, `updatedAt`) VALUES
	(7, 'LNR/0001/2025', 1, 1, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(8, 'LNR/0001/2025', 1, 2, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(9, 'LNR/0001/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(10, 'LNR/0001/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(11, 'LNR/0001/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(12, 'LNR/0002/2025', 1, 1, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(13, 'LNR/0002/2025', 1, 2, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(14, 'LNR/0002/2025', 1, 3, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(15, 'LNR/0002/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(16, 'LNR/0002/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(17, 'LNR/0003/2025', 1, 1, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(18, 'LNR/0003/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(19, 'LNR/0003/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(20, 'LNR/0003/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(21, 'LNR/0003/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(22, 'LNR/0004/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(23, 'LNR/0004/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(24, 'LNR/0004/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(25, 'LNR/0004/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(26, 'LNR/0004/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(27, 'LNR/0005/2025', 1, 1, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(28, 'LNR/0005/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(29, 'LNR/0005/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(30, 'LNR/0005/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(31, 'LNR/0005/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(32, 'LNR/0006/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(33, 'LNR/0006/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(34, 'LNR/0006/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(35, 'LNR/0006/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(36, 'LNR/0006/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(37, 'LNR/0007/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(38, 'LNR/0007/2025', 1, 2, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(39, 'LNR/0007/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(40, 'LNR/0007/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(41, 'LNR/0007/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(42, 'LNR/0008/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(43, 'LNR/0008/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(44, 'LNR/0008/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(45, 'LNR/0008/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(46, 'LNR/0008/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(47, 'LNR/0009/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(48, 'LNR/0009/2025', 1, 2, 1, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(49, 'LNR/0009/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(50, 'LNR/0009/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(51, 'LNR/0009/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(52, 'LNR/0010/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(53, 'LNR/0010/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(54, 'LNR/0010/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(55, 'LNR/0010/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(56, 'LNR/0010/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(57, 'LNR/0011/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(58, 'LNR/0011/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(59, 'LNR/0011/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(60, 'LNR/0011/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(61, 'LNR/0011/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(62, 'LNR/0012/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(63, 'LNR/0012/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(64, 'LNR/0012/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(65, 'LNR/0012/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(66, 'LNR/0012/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(67, 'LNR/0013/2025', 1, 1, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(68, 'LNR/0013/2025', 1, 2, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(69, 'LNR/0013/2025', 1, 3, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(70, 'LNR/0013/2025', 1, 4, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02'),
	(71, 'LNR/0013/2025', 1, 5, 0, '2025-02-22 14:43:02', '2025-02-22 14:43:02');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.fees
DROP TABLE IF EXISTS `fees`;
CREATE TABLE IF NOT EXISTS `fees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) NOT NULL,
  `paid_amount` decimal(10,2) DEFAULT 0.00,
  `pending_amount` decimal(10,2) DEFAULT 0.00,
  `approved` tinyint(1) DEFAULT 0,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admissionNumber` (`admissionNumber`),
  CONSTRAINT `fees_ibfk_1` FOREIGN KEY (`admissionNumber`) REFERENCES `learners` (`admissionNumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.fees: ~6 rows (approximately)
INSERT INTO `fees` (`id`, `admissionNumber`, `paid_amount`, `pending_amount`, `approved`, `createdAt`, `updatedAt`) VALUES
	(1, 'LNR/0009/2025', 2908.34, 2163.92, 0, '2025-02-18 14:19:35', '2025-02-22 12:50:07'),
	(2, 'LNR/0002/2025', 9863.72, 0.00, 1, '2025-02-18 14:19:35', '2025-02-22 12:50:07'),
	(3, 'LNR/0004/2025', 2293.26, 7727.55, 0, '2025-02-18 14:19:35', '2025-02-22 12:50:07'),
	(4, 'LNR/0008/2025', 7122.38, 1577.70, 0, '2025-02-18 14:19:35', '2025-02-22 12:50:07'),
	(5, 'LNR/0001/2025', 10000.00, 0.00, 1, '2025-02-18 14:19:35', '2025-02-22 12:50:07'),
	(6, 'LNR/0003/2025', 5475.55, 1781.45, 0, '2025-02-18 14:19:35', '2025-02-22 12:50:07');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.learners
DROP TABLE IF EXISTS `learners`;
CREATE TABLE IF NOT EXISTS `learners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `lastName` varchar(255) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `gender` enum('male','female') DEFAULT NULL,
  `parentName` varchar(255) NOT NULL,
  `parentEmail` varchar(255) NOT NULL,
  `parentPhone` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `admitted` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `login_attempts` int(11) DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admissionNumber` (`admissionNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.learners: ~12 rows (approximately)
INSERT INTO `learners` (`id`, `admissionNumber`, `firstName`, `lastName`, `age`, `gender`, `parentName`, `parentEmail`, `parentPhone`, `password`, `admitted`, `is_active`, `login_attempts`, `locked_until`, `last_login_at`, `createdAt`, `updatedAt`) VALUES
	(1, 'LNR/0001/2025', 'Christop', 'Von', 12, 'male', 'Dr. Marc Champlin-Parisian', 'Jan_Wyman40@hotmail.com', '1-509-944-1360 x340', '$2b$10$SlYCfgYAOJ6S/4IaOy4LAeg/L.if9L8/RtzejjUbt.I2KKTKXTAey', 1, 1, 0, NULL, '2025-02-22 15:25:46', '2025-02-18 14:16:19', '2025-02-22 15:25:46'),
	(2, 'LNR/0002/2025', 'Katarina', 'Wisoky', 6, 'male', 'Meghan Feest', 'Kathryn_Olson@hotmail.com', '271.403.8891', '$2b$10$3nElxUVOVCQVXDFhcJ2UNeT9hrmG6PBIc63tnv1mdYZ7m04hO9lf2', 1, 1, 0, NULL, '2025-02-22 15:29:46', '2025-02-18 14:16:19', '2025-02-22 15:29:46'),
	(3, 'LNR/0003/2025', 'Marlen', 'Boyle', 16, 'female', 'Nellie Gulgowski', 'Derrick54@gmail.com', '734.672.5376 x059', '$2b$10$MNqV5rE92quB464zC9YvNOKz75QF9lp2G4/qTZydydisUfYOM7lua', 0, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-18 14:16:20'),
	(4, 'LNR/0004/2025', 'Madilyn', 'Ritchie-Wuckert', 17, 'female', 'Andres Hahn', 'Shanie_Murazik11@gmail.com', '(707) 652-6107', '$2b$10$jqdCgX0fSQjnarDbzII3GOmp6k1BUGNUI8SYD..cv4E9PMN0xsVtq', 0, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-18 14:16:20'),
	(5, 'LNR/0005/2025', 'Stanford', 'Gottlieb', 5, 'female', 'Ollie Walter', 'Edward.Fay48@hotmail.com', '(925) 256-5876 x4906', '$2b$10$5Ga1svXr9/B7PnXsnHYaWenteYOuQkOfItu3QtVGitmQL7.2bp7zm', 0, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-18 14:16:20'),
	(6, 'LNR/0006/2025', 'Alex', 'Kohler', 10, 'female', 'Ella Stanton', 'Zaria_Cronin73@gmail.com', '(944) 764-2200 x477', '$2b$10$uY5uaofj3vF8TKawMmLn/uVBQdYHc910.vT2vsbe55fxRwQ6zH8cO', 1, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-18 14:16:20'),
	(7, 'LNR/0007/2025', 'Cassidy', 'Pacocha', 17, 'female', 'Juan Crist-Boyer Sr.', 'Bailee.Sanford@hotmail.com', '(751) 410-0096 x289', '$2b$10$ri0cKCLVkhYhu.49HrkNQup9fg9RIbYw8xi1h74kwDoH4vR91OYwu', 1, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-18 14:16:20'),
	(8, 'LNR/0008/2025', 'Alvah', 'Hartmann', 16, 'male', 'Ricardo Steuber', 'Meggie.Langworth13@hotmail.com', '458.623.5766 x4419', '$2b$10$0rMz0L23stHIFMv6kPKaTeSE8CFQphpNuXYwQuemMzdMTokPy7rhK', 1, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-22 14:00:05'),
	(9, 'LNR/0009/2025', 'Samson', 'Zieme', 7, 'female', 'Lena Larson I', 'Nya14@hotmail.com', '(292) 234-6954', '$2b$10$qJqcs4GDy7Ym/vpGxAGAouQiVThmMp1VRpxyydLO9jA.yhKrrtknm', 0, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-18 14:16:20'),
	(10, 'LNR/0010/2025', 'Marina', 'Kassulke', 8, 'female', 'Darnell Roberts', 'Laverna10@gmail.com', '544.479.0125 x37321', '$2b$10$hmn093MwWyAro9o10ave4em0ShMZhPL6m6.v8OSutzYuPr.DlGfFe', 0, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-18 14:16:20'),
	(11, 'LNR/0011/2025', 'Hermina', 'Roob', 10, 'male', 'Mrs. Agnes Goldner PhD', 'Caleigh.Mosciski84@gmail.com', '(560) 863-4868', '$2b$10$VCFoJ0IGu2xk2GJa7FnxMe6m0gAdnPYEaBf24YYXo5lv./aRljP/2', 1, 1, 0, NULL, NULL, '2025-02-18 14:16:20', '2025-02-18 14:16:20'),
	(12, 'LNR/0012/2025', 'Erna', 'Senger', 10, 'female', 'Timothy Hahn', 'Yessenia_Predovic@yahoo.com', '402.555.9067 x370', '$2b$10$oMCTLlVtvHXix2KuYq5dT.s/tyzfLY4FsrCCEGXVMMlI5zj0jAgeG', 0, 1, 0, NULL, NULL, '2025-02-18 14:16:21', '2025-02-18 14:16:21'),
	(13, 'LNR/0013/2025', 'Jamedy', 'Ali', 12, 'male', 'John Muddy', 'johnmuddy12@gmail.com', '254-722983321', '$2b$10$XL/pWGGlwfCVve5ngs7s.evMb.LCLRLYJbwKcXJN2h/GsgEI2fujm', 0, 1, 0, NULL, NULL, '2025-02-22 10:20:00', '2025-02-22 10:20:00');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.notifications
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `category` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `admissionNumber` (`admissionNumber`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`admissionNumber`) REFERENCES `learners` (`admissionNumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.notifications: ~20 rows (approximately)
INSERT INTO `notifications` (`id`, `admissionNumber`, `message`, `category`, `createdAt`, `updatedAt`) VALUES
	(1, 'LNR/0012/2025', 'Coniuratio cuius cupiditas laborum vesco vestigium. Correptius dignissimos complectus. Synagoga cogito concido conscendo commemoro articulus celer.', 'fee_defaulters', '2025-02-18 14:19:45', '2025-02-18 14:19:45'),
	(2, 'LNR/0006/2025', 'Sustineo vorax angulus summisse arguo. Sperno vito torqueo curis asperiores totidem tam. Rerum cito ulterius.', 'fee_defaulters', '2025-02-18 14:19:45', '2025-02-18 14:19:45'),
	(3, 'LNR/0002/2025', 'Absorbeo volaticus territo claustrum mollitia atqui. Nam vergo decumbo crinis curatio nostrum averto ustilo versus. Aliquid ancilla vir uberrime vociferor sui curis.', 'fee_defaulters', '2025-02-18 14:19:45', '2025-02-18 14:19:45'),
	(4, 'LNR/0010/2025', 'Tutamen asporto pariatur quaerat quibusdam carpo vaco aiunt via. Acer cum clarus surgo. Advenio traho tunc talio thesis corona.', 'individual', '2025-02-18 14:19:45', '2025-02-18 14:19:45'),
	(5, 'LNR/0007/2025', 'Tepesco clarus ea culpo degenero talus. Tenuis alveus casus careo curvo caput tardus. Spero laborum amicitia consequatur suffragium.', 'all', '2025-02-18 14:19:45', '2025-02-18 14:19:45'),
	(6, 'LNR/0007/2025', 'Confero custodia facilis contigo. Celer tollo sit veniam tamisium. Delinquo ciminatio voluptas iure sortitus amoveo comminor.', 'all', '2025-02-18 14:19:45', '2025-02-18 14:19:45'),
	(7, 'LNR/0002/2025', 'Please clear your fee balance', 'individual', '2025-02-22 16:41:24', '2025-02-22 16:41:24'),
	(8, 'LNR/0001/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(9, 'LNR/0002/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(10, 'LNR/0003/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(11, 'LNR/0004/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(12, 'LNR/0005/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(13, 'LNR/0006/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(14, 'LNR/0007/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(15, 'LNR/0008/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(16, 'LNR/0009/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(17, 'LNR/0010/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(18, 'LNR/0011/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(19, 'LNR/0012/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(20, 'LNR/0013/2025', 'Haez', 'all', '2025-02-22 16:41:39', '2025-02-22 16:41:39'),
	(21, 'LNR/0009/2025', 'Clear', 'fee_defaulters', '2025-02-22 16:46:38', '2025-02-22 16:46:38'),
	(22, 'LNR/0004/2025', 'Clear', 'fee_defaulters', '2025-02-22 16:46:38', '2025-02-22 16:46:38'),
	(23, 'LNR/0003/2025', 'Clear', 'fee_defaulters', '2025-02-22 16:46:38', '2025-02-22 16:46:38');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.results
DROP TABLE IF EXISTS `results`;
CREATE TABLE IF NOT EXISTS `results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admissionNumber` varchar(255) NOT NULL,
  `maths` int(11) DEFAULT NULL,
  `english` int(11) DEFAULT NULL,
  `science` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `admissionNumber` (`admissionNumber`),
  CONSTRAINT `results_ibfk_1` FOREIGN KEY (`admissionNumber`) REFERENCES `learners` (`admissionNumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.results: ~6 rows (approximately)
INSERT INTO `results` (`id`, `admissionNumber`, `maths`, `english`, `science`, `createdAt`, `updatedAt`) VALUES
	(1, 'LNR/0001/2025', 25, 37, 86, '2025-02-18 14:19:58', '2025-02-18 14:19:58'),
	(2, 'LNR/0008/2025', 94, 54, 19, '2025-02-18 14:19:58', '2025-02-18 14:19:58'),
	(3, 'LNR/0009/2025', 58, 57, 35, '2025-02-18 14:19:58', '2025-02-18 14:19:58'),
	(4, 'LNR/0003/2025', 22, 12, 31, '2025-02-18 14:19:58', '2025-02-18 14:19:58'),
	(5, 'LNR/0005/2025', 81, 46, 32, '2025-02-18 14:19:58', '2025-02-18 14:19:58'),
	(6, 'LNR/0002/2025', 54, 96, 27, '2025-02-18 14:19:58', '2025-02-18 14:19:58'),
	(22, 'LNR/0004/2025', 56, 40, 76, '2025-02-22 16:39:35', '2025-02-22 16:39:35');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.roles
DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roleName` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.roles: ~6 rows (approximately)
INSERT INTO `roles` (`id`, `roleName`, `createdAt`, `updatedAt`) VALUES
	(1, 'superAdmin', '2025-02-18 14:14:58', '2025-02-18 14:14:58'),
	(2, 'admin', '2025-02-18 14:14:58', '2025-02-18 14:14:58'),
	(3, 'teacher', '2025-02-18 14:14:58', '2025-02-18 14:14:58'),
	(4, 'accountant', '2025-02-18 14:14:58', '2025-02-18 14:14:58'),
	(5, 'librarian', '2025-02-18 14:14:58', '2025-02-18 14:14:58'),
	(6, 'receptionist', '2025-02-18 14:14:58', '2025-02-18 14:14:58');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.sequelizemeta
DROP TABLE IF EXISTS `sequelizemeta`;
CREATE TABLE IF NOT EXISTS `sequelizemeta` (
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`name`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table oviasogie_school_mis_db_nodejs.sequelizemeta: ~9 rows (approximately)
INSERT INTO `sequelizemeta` (`name`) VALUES
	('activitylog.js'),
	('admin.js'),
	('attendance.js'),
	('fee.js'),
	('learner.js'),
	('notification.js'),
	('result.js'),
	('role.js'),
	('timetable.js');

-- Dumping structure for table oviasogie_school_mis_db_nodejs.timetables
DROP TABLE IF EXISTS `timetables`;
CREATE TABLE IF NOT EXISTS `timetables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL,
  `filepath` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `file_type` varchar(255) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table oviasogie_school_mis_db_nodejs.timetables: ~1 rows (approximately)
INSERT INTO `timetables` (`id`, `filename`, `filepath`, `description`, `file_type`, `file_size`, `createdAt`, `updatedAt`) VALUES
	(9, 'User Training Cover.docx', 'uploads\\timetables\\1740242450373-User Training Cover.docx', 'Timetable', 'application/octet-stream', 248, '2025-02-22 16:40:50', '2025-02-22 16:40:50');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
