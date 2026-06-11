-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 11, 2026 at 01:05 PM
-- Server version: 8.0.46
-- PHP Version: 8.2.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `akilli_antreman`
--

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `gender` enum('erkek','kadin') NOT NULL,
  `age` int NOT NULL,
  `weight` float NOT NULL,
  `target_weight` float DEFAULT NULL,
  `height` int NOT NULL,
  `goal` enum('kilo_ver','kas_kazan','formda_kal') NOT NULL,
  `environment` enum('ev','salon') NOT NULL,
  `level` enum('baslangic','orta','ileri') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `workout_days` varchar(255) DEFAULT NULL,
  `target_muscles` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `gender`, `age`, `weight`, `target_weight`, `height`, `goal`, `environment`, `level`, `created_at`, `workout_days`, `target_muscles`) VALUES
(19, 'rozi', 'erkek', 20, 58, NULL, 175, 'kas_kazan', 'ev', 'baslangic', '2026-05-30 14:27:57', NULL, NULL),
(20, 'rozi', 'erkek', 21, 59, NULL, 175, 'kas_kazan', 'salon', 'orta', '2026-05-30 14:37:53', NULL, NULL),
(21, 'popi', 'erkek', 20, 70, NULL, 170, 'kas_kazan', 'ev', 'baslangic', '2026-05-30 16:02:01', 'Pazartesi,Çarşamba,Cuma', NULL),
(22, 'popu', 'erkek', 20, 70, NULL, 170, 'formda_kal', 'salon', 'orta', '2026-05-30 16:07:26', 'Pazartesi,Çarşamba,Cumartesi', NULL),
(23, '123', 'erkek', 20, 70, NULL, 170, 'kilo_ver', 'ev', 'baslangic', '2026-05-31 11:39:15', 'Pazartesi,Çarşamba,Cuma', 'bacak'),
(24, 'q1', 'erkek', 20, 70, NULL, 170, 'kilo_ver', 'ev', 'baslangic', '2026-05-31 11:39:55', 'Pazartesi,Çarşamba,Pazar', 'bacak'),
(25, '123', 'kadin', 25, 98, NULL, 175, 'kilo_ver', 'ev', 'baslangic', '2026-05-31 11:57:51', 'Pazartesi,Çarşamba,Pazar', 'bacak'),
(26, '111', 'erkek', 25, 94, NULL, 196, 'kas_kazan', 'salon', 'orta', '2026-05-31 12:00:01', 'Pazartesi,Çarşamba,Pazar', 'bacak'),
(27, '11111', 'erkek', 25, 97, NULL, 196, 'kas_kazan', 'salon', 'orta', '2026-05-31 12:22:51', 'Pazartesi,Çarşamba,Pazar', 'kol'),
(28, 'and', 'erkek', 25, 71, NULL, 175, 'kas_kazan', 'salon', 'orta', '2026-05-31 12:25:37', 'Pazartesi,Çarşamba,Pazar', 'full_body'),
(29, 'agg', 'erkek', 25, 87, NULL, 191, 'kas_kazan', 'ev', 'orta', '2026-05-31 12:53:55', 'Pazartesi,Çarşamba,Pazar', 'kol'),
(30, '777', 'kadin', 25, 72, NULL, 175, 'kilo_ver', 'salon', 'baslangic', '2026-06-01 13:04:08', 'Pazartesi,Çarşamba,Cuma', 'full_body'),
(31, 'qwery', 'erkek', 25, 70, NULL, 175, 'kilo_ver', 'ev', 'baslangic', '2026-06-01 13:05:20', 'Pazartesi,Çarşamba,Cuma', 'gogus'),
(32, 'qwer', 'erkek', 25, 70, NULL, 175, 'kilo_ver', 'ev', 'baslangic', '2026-06-01 13:08:22', 'Pazartesi,Çarşamba,Cuma', 'gogus'),
(33, 'qasdhdh', 'kadin', 25, 70, NULL, 175, 'kas_kazan', 'salon', 'baslangic', '2026-06-05 11:59:24', 'Pazartesi,Çarşamba,Cuma', 'bacak'),
(34, 'djsnxb', 'erkek', 25, 70, NULL, 175, 'formda_kal', 'salon', 'baslangic', '2026-06-05 12:37:12', 'Pazartesi,Çarşamba,Cuma', 'bacak,kol'),
(35, 'rozimurad ', 'erkek', 21, 59, 59, 175, 'kas_kazan', 'salon', 'baslangic', '2026-06-06 13:59:05', 'Pazartesi,Çarşamba,Cumartesi', 'full_body'),
(36, 'asd', 'erkek', 25, 70, 70, 175, 'formda_kal', 'ev', 'orta', '2026-06-06 14:00:08', 'Pazartesi,Çarşamba,Cuma', 'full_body'),
(37, 'Gemini oruspu ', 'erkek', 25, 71, 71, 175, 'kas_kazan', 'salon', 'ileri', '2026-06-06 14:04:16', 'Pazartesi,Çarşamba,Cumartesi', 'kol'),
(38, 'gem', 'erkek', 25, 59, 70.2, 175, 'kas_kazan', 'salon', 'ileri', '2026-06-06 14:15:39', 'Pazartesi,Çarşamba,Cumartesi,Cuma,Perşembe', 'kol,gogus'),
(39, 'qw', 'erkek', 25, 57, 70.1, 175, 'kas_kazan', 'salon', 'ileri', '2026-06-06 14:16:54', 'Pazartesi,Çarşamba,Cuma,Cumartesi,Perşembe', 'gogus,kol'),
(40, 'ertty', 'erkek', 25, 100, 88.6, 175, 'kilo_ver', 'salon', 'orta', '2026-06-08 18:02:47', 'Pazartesi,Çarşamba,Cuma', 'kol'),
(41, '123', 'erkek', 23, 70, 75.8, 182, 'kas_kazan', 'salon', 'baslangic', '2026-06-11 11:42:39', 'Pazartesi,Cuma,Perşembe', 'gogus,karin');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
