CREATE DATABASE  IF NOT EXISTS `tp_hr`;
USE `tp_hr`;
-- MySQL dump 10.13  Distrib 8.0.21, for Win64 (x86_64)
--
-- Host: localhost    Database: tp_hr
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
-- Table structure for table `hr_department`
--

DROP TABLE IF EXISTS `hr_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_department` (
  `departmentID` varchar(20) DEFAULT NULL,
  `description` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_department`
--

LOCK TABLES `hr_department` WRITE;
/*!40000 ALTER TABLE `hr_department` DISABLE KEYS */;
INSERT INTO `hr_department` VALUES ('1','Accounting'),('2','Corporate'),('3','Finance'),('4','HR'),('5','Marketing');
/*!40000 ALTER TABLE `hr_department` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_employee`
--

DROP TABLE IF EXISTS `hr_employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_employee` (
  `employeeID` varchar(20) NOT NULL,
  `firstName` varchar(20) DEFAULT NULL,
  `lastName` varchar(20) DEFAULT NULL,
  `emailID` varchar(50) DEFAULT NULL,
  `dateOfBirth` date DEFAULT NULL,
  `department` varchar(20) DEFAULT NULL,
  `location` varchar(20) DEFAULT NULL,
  `contactAddress` varchar(50) DEFAULT NULL,
  `employeeStatus` varchar(20) DEFAULT NULL,
  `contactNumber` bigint DEFAULT NULL,
  `jobCode` varchar(20) DEFAULT NULL,
  `managerID` varchar(20) DEFAULT NULL,
  `hireDate` date DEFAULT NULL,
  `rehireDate` date DEFAULT NULL,
  `terminationDate` date DEFAULT NULL,
  `createdDateTime` date DEFAULT NULL,
  `createdByUser` varchar(20) DEFAULT NULL,
  `updatedDateTime` date DEFAULT NULL,
  `updatedByUser` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`employeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_employee`
--

LOCK TABLES `hr_employee` WRITE;
/*!40000 ALTER TABLE `hr_employee` DISABLE KEYS */;
INSERT INTO `hr_employee` VALUES ('11','MS','Dhoni','MS.d@bcci.com','1983-12-12','Accounting','India','Kolkata','active',9876543210,'222','12','2003-12-12',NULL,NULL,'2003-12-12','14','2021-06-09','14'),('12','Sachin','Tendulkar','sachin.t@bcci.com','1973-04-24','Accounting','India','Mumbai','active',1234567890,'1111','14','1997-04-24',NULL,NULL,'1997-04-24','14','2021-06-09','14'),('13','Saurav','Ganguly','saurav.g@bcci.com','1972-07-08','Finance','India','Mumbai','active',1472583690,'3333','12','1992-07-08',NULL,NULL,'1992-07-08','14','2021-06-09','14'),('14','Tony','Stark','tony.s@stark.com','1985-06-19','HR','US','Washington D.C','active',258147360,'444','null','2005-06-19',NULL,NULL,'2005-06-19',NULL,'2021-06-09','14'),('15','Warner','Bros','Warner.B@bcci.com','1990-01-01','Finance','United','Broklyn','active',7894563210,'333','13','2010-01-01','2021-06-07','2021-06-07','2021-06-07','14','2021-06-09','14'),('16','Scarlett','Johan','Scarlett.j@bcci.com','1987-06-01','Corporate','United','California','active',1472583690,'222','13','2007-06-01',NULL,NULL,'2021-06-13','14',NULL,NULL),('17','Chris','Evains','Chris.E@bcci.com','1985-12-01','Accounting','US','Brooklyn','active',2581473690,'1111','12','2005-12-01',NULL,NULL,'2021-06-13','14',NULL,NULL),('sa_iiqrest','sa_iiqrest','sa_iiqrest',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `hr_employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_job`
--

DROP TABLE IF EXISTS `hr_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_job` (
  `jobCode` varchar(20) DEFAULT NULL,
  `description` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_job`
--

LOCK TABLES `hr_job` WRITE;
/*!40000 ALTER TABLE `hr_job` DISABLE KEYS */;
INSERT INTO `hr_job` VALUES ('1111','Accountant'),('111','Financial Analyst'),('222','Marketing Analyst'),('2222','Content Writer'),('333','Opeartions Manager'),('3333','Supply Chain Analyst'),('444','HR Executive'),('4444','HR Operations'),('555','Developer'),('5555','Senior Developer');
/*!40000 ALTER TABLE `hr_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_location`
--

DROP TABLE IF EXISTS `hr_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_location` (
  `locationID` varchar(20) DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_location`
--

LOCK TABLES `hr_location` WRITE;
/*!40000 ALTER TABLE `hr_location` DISABLE KEYS */;
INSERT INTO `hr_location` VALUES ('1','Dubai'),('2','India'),('3','Singapore'),('4','United Kingdom'),('5','US');
/*!40000 ALTER TABLE `hr_location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_login`
--

DROP TABLE IF EXISTS `hr_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_login` (
  `employeeID` varchar(20) DEFAULT NULL,
  `password` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_login`
--

LOCK TABLES `hr_login` WRITE;
/*!40000 ALTER TABLE `hr_login` DISABLE KEYS */;
INSERT INTO `hr_login` VALUES ('11','11'),('12','12'),('13','13'),('14','14'),('sa_iiqrest','sa_iiqrest'),('15','15'),('16','16'),('17','17');
/*!40000 ALTER TABLE `hr_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_role`
--

DROP TABLE IF EXISTS `hr_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_role` (
  `roleID` varchar(20) DEFAULT NULL,
  `description` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_role`
--

LOCK TABLES `hr_role` WRITE;
/*!40000 ALTER TABLE `hr_role` DISABLE KEYS */;
INSERT INTO `hr_role` VALUES ('1','Employee'),('2','Manager'),('3','HR');
/*!40000 ALTER TABLE `hr_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hr_user_roles`
--

DROP TABLE IF EXISTS `hr_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_user_roles` (
  `employeeID` varchar(20) DEFAULT NULL,
  `roleID` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hr_user_roles`
--

LOCK TABLES `hr_user_roles` WRITE;
/*!40000 ALTER TABLE `hr_user_roles` DISABLE KEYS */;
INSERT INTO `hr_user_roles` VALUES ('11','1'),('12','1'),('12','2'),('13','1'),('13','2'),('14','1'),('14','2'),('14','3'),('15','1'),('16','1'),('17','1');
/*!40000 ALTER TABLE `hr_user_roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-06-14 19:32:19
