-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 02, 2018 at 12:46 PM
-- Server version: 10.1.24-MariaDB
-- PHP Version: 7.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lab2`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `bookingid` int(11) NOT NULL,
  `room` int(11) NOT NULL,
  `time_start` datetime NOT NULL DEFAULT '2018-01-01 00:00:00',
  `time_end` datetime NOT NULL,
  `booked_by` int(11) DEFAULT NULL,
  `booked_by_team` int(11) DEFAULT NULL,
  `cost` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`bookingid`, `room`, `time_start`, `time_end`, `booked_by`, `booked_by_team`, `cost`) VALUES
(52, 1, '2018-02-28 18:30:00', '2018-02-28 23:10:00', 1, 2, 60.6667),
(56, 3, '2018-04-13 09:30:00', '2018-04-13 18:30:00', 5, 4, 18),
(57, 2, '2018-03-03 14:10:00', '2018-03-03 15:20:00', 2, 2, 3.5);

-- --------------------------------------------------------

--
-- Table structure for table `companies`
--

CREATE TABLE `companies` (
  `compID` int(11) NOT NULL,
  `name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `companies`
--

INSERT INTO `companies` (`compID`, `name`) VALUES
(1, 'DE EZ'),
(2, 'NUTS AB'),
(3, 'GGWP ');

-- --------------------------------------------------------

--
-- Table structure for table `facilities`
--

CREATE TABLE `facilities` (
  `facilityID` int(11) NOT NULL,
  `name` varchar(1000) NOT NULL,
  `cost_per_hour` double NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `facilities`
--

INSERT INTO `facilities` (`facilityID`, `name`, `cost_per_hour`) VALUES
(1, 'Tv', 10),
(2, 'Lamp', 1),
(3, 'Projector', 10),
(4, 'Whiteboard', 2),
(5, 'Phone', 2),
(6, 'Speaker', 2),
(7, 'Microphone', 1),
(8, 'Over head', 0.5);

-- --------------------------------------------------------

--
-- Table structure for table `has_facility`
--

CREATE TABLE `has_facility` (
  `room` int(11) NOT NULL,
  `facility` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `has_facility`
--

INSERT INTO `has_facility` (`room`, `facility`) VALUES
(1, 1),
(1, 2),
(1, 5),
(2, 7),
(2, 4),
(3, 6),
(4, 7),
(4, 2),
(4, 4),
(5, 7),
(5, 8),
(5, 2),
(5, 3),
(6, 3);

-- --------------------------------------------------------

--
-- Table structure for table `meeting_participants`
--

CREATE TABLE `meeting_participants` (
  `booking` int(11) NOT NULL,
  `participant` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `meeting_participants`
--

INSERT INTO `meeting_participants` (`booking`, `participant`) VALUES
(56, 4),
(56, 5),
(56, 6),
(57, 2),
(57, 6),
(57, 10),
(57, 11);

-- --------------------------------------------------------

--
-- Table structure for table `meeting_rooms`
--

CREATE TABLE `meeting_rooms` (
  `roomID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `meeting_rooms`
--

INSERT INTO `meeting_rooms` (`roomID`) VALUES
(1),
(2),
(3),
(4),
(5),
(6);

-- --------------------------------------------------------

--
-- Table structure for table `people`
--

CREATE TABLE `people` (
  `id` int(11) NOT NULL,
  `name` varchar(1000) NOT NULL,
  `company` int(11) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `team` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `people`
--

INSERT INTO `people` (`id`, `name`, `company`, `position`, `team`, `is_active`) VALUES
(1, 'bob', 1, 'boss', 2, 1),
(2, 'bob2', 1, 'vice boss', 2, 1),
(3, 'bob3', 2, 'janitor', 4, 1),
(4, 'bob4', 2, 'receptionist', 4, 1),
(5, 'bob5', 3, 'Tea-boi assistant assistant', 4, 1),
(6, 'bob6', 1, 'Boss assistant', 2, 0),
(10, 'bob7', 1, 'Tea-boi', 5, 1),
(11, 'bob8', 2, 'Tea-boi assistant', 5, 1),
(12, 'bob32', 1, 'developer', 6, 0),
(13, 'bob33', 1, 'developer', 6, 1);

--
-- Triggers `people`
--
DELIMITER $$
CREATE TRIGGER `teamExists` BEFORE UPDATE ON `people` FOR EACH ROW IF NEW.team NOT IN (SELECT teamID FROM team where is_active = 1) THEN
	SET NEW.team = OLD.team;
end IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `teamExistsIns` BEFORE INSERT ON `people` FOR EACH ROW IF NEW.team NOT IN (SELECT teamID from team WHERE is_active = 1) THEN
	SET NEW.team = 1;
    end IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `team`
--

CREATE TABLE `team` (
  `teamID` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `costs_accrued` int(11) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `team`
--

INSERT INTO `team` (`teamID`, `name`, `costs_accrued`, `is_active`) VALUES
(1, 'Team-less', 0, 1),
(2, 'Lions', 0, 1),
(3, 'tigers', 0, 0),
(4, 'Foxes', 0, 1),
(5, 'Elephants', 0, 1),
(6, 'eagles', 0, 1);

--
-- Triggers `team`
--
DELIMITER $$
CREATE TRIGGER `removeTeam` BEFORE UPDATE ON `team` FOR EACH ROW IF NEW.teamID = 1 THEN
	SET NEW.is_active = 1;
  ELSEIF NEW.teamID IN (SELECT team FROM people) AND NEW.is_active = 0 THEN
    	UPDATE people SET team = 1 WHERE team = NEW.teamID;
    END IF
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`bookingid`);

--
-- Indexes for table `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`compID`);

--
-- Indexes for table `facilities`
--
ALTER TABLE `facilities`
  ADD PRIMARY KEY (`facilityID`);

--
-- Indexes for table `meeting_participants`
--
ALTER TABLE `meeting_participants`
  ADD PRIMARY KEY (`booking`,`participant`);

--
-- Indexes for table `meeting_rooms`
--
ALTER TABLE `meeting_rooms`
  ADD PRIMARY KEY (`roomID`);

--
-- Indexes for table `people`
--
ALTER TABLE `people`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `team`
--
ALTER TABLE `team`
  ADD PRIMARY KEY (`teamID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `bookingid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;
--
-- AUTO_INCREMENT for table `companies`
--
ALTER TABLE `companies`
  MODIFY `compID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `facilities`
--
ALTER TABLE `facilities`
  MODIFY `facilityID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `meeting_rooms`
--
ALTER TABLE `meeting_rooms`
  MODIFY `roomID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `people`
--
ALTER TABLE `people`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT for table `team`
--
ALTER TABLE `team`
  MODIFY `teamID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
