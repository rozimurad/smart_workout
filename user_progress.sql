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
-- Table structure for table `user_progress`
--

CREATE TABLE `user_progress` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `total_time_spent` int NOT NULL,
  `total_sets` int NOT NULL,
  `total_exercises` int NOT NULL,
  `completed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_progress`
--

INSERT INTO `user_progress` (`id`, `user_id`, `total_time_spent`, `total_sets`, `total_exercises`, `completed_at`) VALUES
(1, 19, 2, 0, 1, '2026-05-30 14:36:12'),
(2, 19, 1, 0, 1, '2026-05-30 14:36:22'),
(3, 20, 22, 12, 4, '2026-05-30 14:38:28'),
(4, 22, 119, 16, 4, '2026-05-30 16:09:38'),
(5, 24, 3, 1, 1, '2026-05-31 11:40:10'),
(6, 29, 3, 0, 1, '2026-06-01 13:03:00'),
(7, 30, 5, 2, 1, '2026-06-01 13:04:28'),
(8, 31, 19, 10, 4, '2026-06-01 13:05:46'),
(9, 32, 19, 9, 4, '2026-06-01 13:08:46'),
(10, 33, 55, 12, 4, '2026-06-05 12:00:26'),
(11, 34, 26, 12, 4, '2026-06-05 12:37:44'),
(12, 40, 31, 16, 4, '2026-06-08 18:03:30'),
(13, 41, 95, 12, 4, '2026-06-11 11:44:23');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `user_progress`
--
ALTER TABLE `user_progress`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `user_progress`
--
ALTER TABLE `user_progress`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
