CREATE DATABASE IF NOT EXISTS `tp_bi`;
USE `tp_bi`;
-- MySQL dump 10.13  Distrib 8.0.21, for Win64 (x86_64)
--
-- Host: localhost    Database: tp_bi
-- ------------------------------------------------------
-- Server version	8.0.21

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tp_bi_employee`
--

DROP TABLE IF EXISTS `tp_bi_employee`;

CREATE TABLE `tp_bi_employee` (
  `employeeID` varchar(20) DEFAULT NULL,
  `firstName` varchar(50) DEFAULT NULL,
  `department` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Dumping data for table `tp_bi_employee`
--

LOCK TABLES `tp_bi_employee` WRITE;
/*!40000 ALTER TABLE `tp_bi_employee` DISABLE KEYS */;
INSERT INTO `tp_bi_employee` VALUES ('14','Tony','HR','US'),('12','Sachin','Accounting','India'),('11','MS','Finance','India'),('13','Saurav','Finance','India'),('16','Scarlett','Corporate','United'),('17','Chris','Accounting','US');
/*!40000 ALTER TABLE `tp_bi_employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tp_bi_login`
--

DROP TABLE IF EXISTS `tp_bi_login`;

CREATE TABLE `tp_bi_login` (
  `employeeID` varchar(20) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Dumping data for table `tp_bi_login`
--

LOCK TABLES `tp_bi_login` WRITE;
/*!40000 ALTER TABLE `tp_bi_login` DISABLE KEYS */;
INSERT INTO `tp_bi_login` VALUES ('14','14'),('12','12'),('11','11'),('13','13'),('16','16'),('17','17');
/*!40000 ALTER TABLE `tp_bi_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tp_bi_role`
--

DROP TABLE IF EXISTS `tp_bi_role`;

CREATE TABLE `tp_bi_role` (
  `roleID` varchar(20) DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Dumping data for table `tp_bi_role`
--

LOCK TABLES `tp_bi_role` WRITE;
/*!40000 ALTER TABLE `tp_bi_role` DISABLE KEYS */;
INSERT INTO `tp_bi_role` VALUES ('1','Employee'),('2','IndiaAdmin'),('3','USAAdmin'),('4','SysAdmin');
/*!40000 ALTER TABLE `tp_bi_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tp_bi_userroles`
--

DROP TABLE IF EXISTS `tp_bi_userroles`;

CREATE TABLE `tp_bi_userroles` (
  `employeeID` varchar(20) DEFAULT NULL,
  `roleID` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Dumping data for table `tp_bi_userroles`
--

LOCK TABLES `tp_bi_userroles` WRITE;
/*!40000 ALTER TABLE `tp_bi_userroles` DISABLE KEYS */;
INSERT INTO `tp_bi_userroles` VALUES ('14','1'),('14','4'),('12','1'),('11','1'),('12','2'),('13','1'),('16','1'),('17','1');
/*!40000 ALTER TABLE `tp_bi_userroles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-06-14 19:32:54
