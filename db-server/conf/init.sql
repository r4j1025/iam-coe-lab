-- Initial database and user setup executed by MySQL on first initialization
-- Avoid storing secrets in this file for production; use secure secret management.

CREATE DATABASE IF NOT EXISTS `app_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'app_pass';
GRANT ALL PRIVILEGES ON `app_db`.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
