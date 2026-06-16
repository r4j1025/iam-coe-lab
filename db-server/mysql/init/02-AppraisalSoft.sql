CREATE DATABASE IF NOT EXISTS `tp_appraisal`;
USE `tp_appraisal`;
-- MySQL dump 10.13  Distrib 8.0.21, for Win64 (x86_64)
--
-- Host: localhost    Database: tp_appraisal
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
-- Table structure for table `ap_login`
--

DROP TABLE IF EXISTS `ap_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_login` (
  `employeeID` varchar(20) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ap_login`
--

LOCK TABLES `ap_login` WRITE;
/*!40000 ALTER TABLE `ap_login` DISABLE KEYS */;
INSERT INTO `ap_login` VALUES ('11','11'),('12','12'),('14','14'),('13','13'),('16','16'),('17','17');
/*!40000 ALTER TABLE `ap_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ap_role`
--

DROP TABLE IF EXISTS `ap_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_role` (
  `roleID` varchar(20) DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ap_role`
--

LOCK TABLES `ap_role` WRITE;
/*!40000 ALTER TABLE `ap_role` DISABLE KEYS */;
INSERT INTO `ap_role` VALUES ('1','Employee'),('2','Appraiser'),('3','Reviewer'),('4','SysAdmin');
/*!40000 ALTER TABLE `ap_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ap_user_roles`
--

DROP TABLE IF EXISTS `ap_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_user_roles` (
  `employeeID` varchar(20) DEFAULT NULL,
  `roleID` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ap_user_roles`
--

LOCK TABLES `ap_user_roles` WRITE;
/*!40000 ALTER TABLE `ap_user_roles` DISABLE KEYS */;
INSERT INTO `ap_user_roles` VALUES ('11','1'),('12','1'),('12','2'),('14','1'),('14','4'),('13','1'),('16','1'),('17','1');
/*!40000 ALTER TABLE `ap_user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ap_useraccount`
--

DROP TABLE IF EXISTS `ap_useraccount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_useraccount` (
  `employeeID` varchar(20) NOT NULL,
  `firstName` varchar(50) DEFAULT NULL,
  `department` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `userStatus` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`employeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ap_useraccount`
--

LOCK TABLES `ap_useraccount` WRITE;
/*!40000 ALTER TABLE `ap_useraccount` DISABLE KEYS */;
INSERT INTO `ap_useraccount` VALUES ('11','MS','Finance','India','active'),('12','Sachin','Accounting','India','active'),('13','Saurav','Finance','India','active'),('14','Tony','HR','US','active'),('16','Scarlett','Corporate','United','active'),('17','Chris','Accounting','US','active');
/*!40000 ALTER TABLE `ap_useraccount` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-06-14 19:32:37
