-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 11, 2026 at 01:04 PM
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
-- Table structure for table `exercises`
--

CREATE TABLE `exercises` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `gif_url` varchar(255) NOT NULL,
  `target_muscle` varchar(50) DEFAULT NULL,
  `environment` enum('ev','salon','hepsi') DEFAULT 'hepsi',
  `gender_target` enum('erkek','kadin','hepsi') DEFAULT 'hepsi'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `exercises`
--

INSERT INTO `exercises` (`id`, `name`, `description`, `gif_url`, `target_muscle`, `environment`, `gender_target`) VALUES
(1, 'Wall Push-up', NULL, 'http://192.168.1.23/api/exercises/man/pushups_on_the_wall-man.gif', 'gogus', 'hepsi', 'hepsi'),
(2, 'Marching in Place', NULL, 'http://192.168.1.23/api/exercises/man/marching_in_place-man.gif', 'full_body', 'hepsi', 'hepsi'),
(3, 'Burpees', NULL, 'http://192.168.1.23/api/exercises/man/burpees-man.gif', 'full_body', 'hepsi', 'hepsi'),
(104, 'Dumbbell Bench Press', NULL, 'http://192.168.1.23/api/exercises/man/dumbell_bench_press-man.gif', 'gogus', 'salon', 'hepsi'),
(105, 'Lat Pulldown', NULL, 'http://192.168.1.23/api/exercises/man/lat_pulldown-man.gif', 'sirt', 'salon', 'hepsi'),
(106, 'Bodyweight Squat', NULL, 'http://192.168.1.23/api/exercises/man/bodyweight_squat-man.gif', 'bacak', 'hepsi', 'hepsi'),
(107, 'Jumping Jack', NULL, 'http://192.168.1.23/api/exercises/man/jumping_jack-man.gif', 'full_body', 'hepsi', 'hepsi'),
(108, 'Leg Press', NULL, 'http://192.168.1.23/api/exercises/man/leg_press-man.gif', 'bacak', 'salon', 'hepsi'),
(109, 'Crunch', NULL, 'http://192.168.1.23/api/exercises/man/crunch-man.gif', 'karin', 'hepsi', 'hepsi'),
(110, 'Plank', NULL, 'http://192.168.1.23/api/exercises/man/plank-man.gif', 'karin', 'hepsi', 'hepsi'),
(111, 'Knee Push-up', NULL, 'http://192.168.1.23/api/exercises/man/knee_pushups-man.gif', 'gogus', 'ev', 'hepsi'),
(112, 'Reverse Lunge', NULL, 'http://192.168.1.23/api/exercises/man/reverse_lunge-man.gif', 'bacak', 'hepsi', 'kadin'),
(113, 'Glute Bridge', NULL, 'http://192.168.1.23/api/exercises/man/glute_bridge-man.gif', 'bacak', 'hepsi', 'kadin'),
(114, 'Superman', NULL, 'http://192.168.1.23/api/exercises/man/superman-man.gif', 'sirt', 'hepsi', 'hepsi'),
(115, 'Russian Twist', NULL, 'http://192.168.1.23/api/exercises/man/russian_twist-man.gif', 'karin', 'hepsi', 'hepsi'),
(116, 'Chair Dips', NULL, 'http://192.168.1.23/api/exercises/man/chair_dips-man.gif', 'kol', 'ev', 'hepsi'),
(117, 'Side Step', NULL, 'http://192.168.1.23/api/exercises/man/side_step-man.gif', 'bacak', 'ev', 'kadin'),
(118, 'High Knees', NULL, 'http://192.168.1.23/api/exercises/man/high_knee-man.gif', 'bacak', 'hepsi', 'hepsi'),
(119, 'Squat Jump', NULL, 'http://192.168.1.23/api/exercises/man/squat_jump-man.gif', 'bacak', 'hepsi', 'hepsi'),
(120, 'Mountain Climber', NULL, 'http://192.168.1.23/api/exercises/man/mountain_climber-man.gif', 'karin', 'hepsi', 'hepsi'),
(121, 'Box Jump', NULL, 'http://192.168.1.23/api/exercises/man/box_jump-man.gif', 'bacak', 'salon', 'hepsi'),
(122, 'Barbell Squat', NULL, 'http://192.168.1.23/api/exercises/man/barbell_squat-man.gif', 'bacak', 'salon', 'erkek'),
(123, 'Deadlift', NULL, 'http://192.168.1.23/api/exercises/man/deadlift-man.gif', 'full_body', 'salon', 'hepsi'),
(125, 'Seated Cable Row', NULL, 'http://192.168.1.23/api/exercises/man/seated_cable_row-man.gif', 'sirt', 'salon', 'hepsi'),
(128, 'Hamstring Curl', NULL, 'http://192.168.1.23/api/exercises/man/hamstring_curl-man.gif', 'bacak', 'salon', 'hepsi'),
(129, 'Dumbbell Lateral Raise', NULL, 'http://192.168.1.23/api/exercises/man/dumbbell_lateral_raise-man.gif', 'kol', 'salon', 'hepsi'),
(130, 'Pec Deck Fly', NULL, 'http://192.168.1.23/api/exercises/man/pec_dec_fly-man.gif', 'gogus', 'salon', 'hepsi'),
(131, 'Diamond Push-up', NULL, 'http://192.168.1.23/api/exercises/man/diamond_pushups-man.gif', 'kol', 'ev', 'hepsi'),
(133, 'Push-up', NULL, 'http://192.168.1.23/api/exercises/man/pushup-man.gif', 'gogus', 'ev', 'hepsi'),
(136, 'Barbell Biceps Curl', NULL, 'http://192.168.1.23/api/exercises/man/barbell_biceps_curl-man.gif', 'kol', 'salon', 'hepsi'),
(137, 'Triceps Cable Pushdown', NULL, 'http://192.168.1.23/api/exercises/man/triceps_cable_pushdown-man.gif', 'kol', 'salon', 'hepsi'),
(138, 'Dumbbell Hammer Curl', NULL, 'http://192.168.1.23/api/exercises/man/dumbbell_hammer_curl-man.gif', 'kol', 'salon', 'hepsi'),
(139, 'Barbell Bench Press', NULL, 'http://192.168.1.23/api/exercises/man/barbell_bench_press-man.gif', 'gogus', 'salon', 'hepsi'),
(140, 'Incline Dumbbell Press', NULL, 'http://192.168.1.23/api/exercises/man/incline_dumbbell_press-man.gif', 'gogus', 'salon', 'hepsi'),
(141, 'Barbell Row', NULL, 'http://192.168.1.23/api/exercises/man/barbell_row-man.gif', 'sirt', 'salon', 'hepsi'),
(143, 'Leg Extension', NULL, 'http://192.168.1.23/api/exercises/man/leg_extension-man.gif', 'bacak', 'salon', 'hepsi'),
(144, 'Cable Crunch', NULL, 'http://192.168.1.23/api/exercises/man/cable_crunch-man.gif', 'karin', 'salon', 'hepsi'),
(145, 'Hanging Leg Raise', NULL, 'http://192.168.1.23/api/exercises/man/hanging_leg_raise-man.gif', 'karin', 'salon', 'hepsi');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `exercises`
--
ALTER TABLE `exercises`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `exercises`
--
ALTER TABLE `exercises`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=146;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
