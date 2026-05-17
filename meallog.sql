-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 15, 2026 at 08:30 AM
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
-- Database: `meallog`
--

-- --------------------------------------------------------

--
-- Table structure for table `foods`
--

CREATE TABLE `foods` (
  `id` int(11) NOT NULL,
  `food_name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `calories_per_100g` decimal(7,2) NOT NULL DEFAULT 0.00,
  `protein_per_100g` decimal(5,2) NOT NULL DEFAULT 0.00,
  `carbs_per_100g` decimal(5,2) NOT NULL DEFAULT 0.00,
  `fats_per_100g` decimal(5,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `foods`
--

INSERT INTO `foods` (`id`, `food_name`, `category`, `calories_per_100g`, `protein_per_100g`, `carbs_per_100g`, `fats_per_100g`) VALUES
(1, 'Rice', 'Carbs & Grains', 130.00, 2.70, 28.00, 0.30),
(2, 'Bread', 'Carbs & Grains', 265.00, 9.00, 49.00, 3.20),
(3, 'Pasta', 'Carbs & Grains', 131.00, 5.00, 25.00, 1.10),
(4, 'Oats', 'Carbs & Grains', 389.00, 17.00, 66.00, 7.00),
(5, 'Potato', 'Carbs & Grains', 77.00, 2.00, 17.00, 0.10),
(6, 'Noodles', 'Carbs & Grains', 138.00, 4.50, 25.00, 2.20),
(7, 'Corn', 'Carbs & Grains', 86.00, 3.20, 19.00, 1.20),
(8, 'Sweet Potato', 'Carbs & Grains', 86.00, 1.60, 20.00, 0.10),
(9, 'Chicken Breast', 'Proteins & Meat', 165.00, 31.00, 0.00, 3.60),
(10, 'Mutton', 'Proteins & Meat', 294.00, 25.00, 0.00, 21.00),
(11, 'Pork', 'Proteins & Meat', 242.00, 27.00, 0.00, 14.00),
(12, 'Beef', 'Proteins & Meat', 250.00, 26.00, 0.00, 15.00),
(13, 'Tuna', 'Proteins & Meat', 132.00, 28.00, 0.00, 1.30),
(14, 'Salmon', 'Proteins & Meat', 208.00, 20.00, 0.00, 13.00),
(15, 'Eggs', 'Proteins & Meat', 155.00, 13.00, 1.10, 11.00),
(16, 'Shrimp', 'Proteins & Meat', 99.00, 24.00, 0.20, 0.30),
(17, 'Tofu', 'Proteins & Meat', 76.00, 8.00, 1.90, 4.80),
(18, 'Broccoli', 'Vegetables', 34.00, 2.80, 7.00, 0.40),
(19, 'Spinach', 'Vegetables', 23.00, 2.90, 3.60, 0.40),
(20, 'Carrot', 'Vegetables', 41.00, 0.90, 10.00, 0.20),
(21, 'Tomato', 'Vegetables', 18.00, 0.90, 3.90, 0.20),
(22, 'Cucumber', 'Vegetables', 15.00, 0.70, 3.60, 0.10),
(23, 'Cabbage', 'Vegetables', 25.00, 1.30, 6.00, 0.10),
(24, 'Bell Pepper', 'Vegetables', 31.00, 1.00, 6.00, 0.30),
(25, 'Onion', 'Vegetables', 40.00, 1.10, 9.30, 0.10),
(26, 'Mushroom', 'Vegetables', 22.00, 3.10, 3.30, 0.30),
(27, 'Apple', 'Fruits', 52.00, 0.30, 14.00, 0.20),
(28, 'Banana', 'Fruits', 89.00, 1.10, 23.00, 0.30),
(29, 'Orange', 'Fruits', 47.00, 0.90, 12.00, 0.10),
(30, 'Mango', 'Fruits', 60.00, 0.80, 15.00, 0.40),
(31, 'Grapes', 'Fruits', 69.00, 0.70, 18.00, 0.20),
(32, 'Strawberry', 'Fruits', 32.00, 0.70, 7.70, 0.30),
(33, 'Watermelon', 'Fruits', 30.00, 0.60, 7.60, 0.20),
(34, 'Pineapple', 'Fruits', 50.00, 0.50, 13.00, 0.10),
(35, 'Milk', 'Dairy', 42.00, 3.40, 5.00, 1.00),
(36, 'Cheese', 'Dairy', 402.00, 25.00, 1.30, 33.00),
(37, 'Yogurt', 'Dairy', 59.00, 10.00, 3.60, 0.40),
(38, 'Butter', 'Dairy', 717.00, 0.90, 0.10, 81.00),
(39, 'Cream', 'Dairy', 340.00, 2.10, 2.80, 36.00),
(40, 'Scrambled Eggs', 'Proteins & Meat', 150.00, 11.50, 2.00, 12.00),
(41, 'Bacon', 'Proteins & Meat', 541.00, 37.00, 1.40, 42.00);

-- --------------------------------------------------------

--
-- Table structure for table `meals`
--

CREATE TABLE `meals` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `meal_type` varchar(20) DEFAULT NULL,
  `meal_name` varchar(100) DEFAULT NULL,
  `calories` int(11) DEFAULT NULL,
  `protein` decimal(5,2) DEFAULT NULL,
  `carbs` decimal(5,2) DEFAULT NULL,
  `fats` decimal(5,2) DEFAULT NULL,
  `meal_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `meals`
--

INSERT INTO `meals` (`id`, `user_id`, `meal_type`, `meal_name`, `calories`, `protein`, `carbs`, `fats`, `meal_date`, `created_at`) VALUES
(3, 11, 'Lunch', 'Bread(20g), Pork(20g), Spinach(20g), Orange(20g), Cheese(30g)', 56, 15.46, 13.31, 13.44, '2026-05-05', '2026-05-04 12:15:45'),
(4, 12, 'Lunch', 'Rice(500g), Potato(30g)', 673, 14.10, 145.10, 1.53, NULL, '2026-05-04 13:21:27'),
(5, 13, 'Lunch', 'Rice(1000g), Chicken Breast(500g), Spinach(99g), Apple(150g), Yogurt(100g)', 2265, 195.32, 308.16, 22.10, NULL, '2026-05-08 09:37:39'),
(6, 11, '', 'Rice(1000g), Chicken Breast(500g)', 2085, 182.00, 280.00, 21.00, NULL, '2026-05-08 09:41:31'),
(7, 10, '', 'Scrambled Eggs(100g)', 150, 11.50, 2.00, 12.00, NULL, '2026-05-11 17:18:08'),
(8, 16, 'Breakfast', 'Rice(350g), Eggs(50g), Pork(80g)', 726, 37.55, 98.55, 17.75, NULL, '2026-05-14 16:25:22');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `height_cm` decimal(5,2) DEFAULT NULL,
  `weight_kg` decimal(5,2) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `calorie_goal` int(11) DEFAULT 2000,
  `protein_goal` decimal(5,2) DEFAULT 150.00,
  `carbs_goal` decimal(5,2) DEFAULT 250.00,
  `fats_goal` decimal(5,2) DEFAULT 65.00,
  `profile_setup_done` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `password`, `created_at`, `height_cm`, `weight_kg`, `age`, `gender`, `calorie_goal`, `protein_goal`, `carbs_goal`, `fats_goal`, `profile_setup_done`) VALUES
(7, 'User 1', 'johndoe@gmail.com', '123456', '2026-05-03 09:55:24', 182.00, 80.00, 20, 'male', 2356, 176.00, 265.00, 65.00, 1),
(9, 'User 2', 'janedoe@gmail.com', '123456', '2026-05-03 09:55:24', NULL, NULL, NULL, NULL, 2000, 150.00, 250.00, 65.00, 0),
(10, 'Siddharth', 'siddop@gmail.com', '098765', '2026-05-03 10:03:15', 182.00, 80.00, 20, 'male', 2356, 176.00, 265.00, 65.00, 1),
(11, 'Papit Ghimire', 'papit@gmail.com', '123456', '2026-05-04 12:08:48', 183.00, 80.00, 19, 'male', 2373, 176.00, 267.00, 66.00, 1),
(12, 'Niraj Shrestha', 'nirajshrestha@gmail.com', '123456', '2026-05-04 13:19:15', 173.00, 78.00, 19, 'male', 2245, 172.00, 253.00, 62.00, 1),
(13, 'Saket Don', 'saketdon@gmail.cim', '123456', '2026-05-08 09:33:25', 182.00, 90.00, 20, 'male', 2511, 198.00, 282.00, 70.00, 1),
(14, 'EVADER', 'atishrsid@gmail.com', 'wallah123', '2026-05-13 16:07:30', NULL, NULL, NULL, NULL, 2000, 150.00, 250.00, 65.00, 0),
(15, 'Baka Boy', 'ssiiddhhaarrthhnnaatthh@gmail.com', 'sussybaka123', '2026-05-13 20:50:32', NULL, NULL, NULL, NULL, 2000, 150.00, 250.00, 65.00, 0),
(16, 'Nightie Winger', 'goodkitty165@gmail.com', '123456', '2026-05-14 16:22:34', 160.00, 46.00, 14, 'male', 2662, 83.00, 299.00, 74.00, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `foods`
--
ALTER TABLE `foods`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `meals`
--
ALTER TABLE `meals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_meals_user` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `foods`
--
ALTER TABLE `foods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `meals`
--
ALTER TABLE `meals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `meals`
--
ALTER TABLE `meals`
  ADD CONSTRAINT `fk_meals_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `meals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
