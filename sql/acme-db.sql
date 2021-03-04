SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `acme`
--

-- build images table
DROP TABLE IF EXISTS `configuration`;
CREATE TABLE `configuration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `configuration_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `contactForms`;
 CREATE TABLE `contactForms` (
   `id` INT(11) NOT NULL AUTO_INCREMENT,
   `email` varchar(40) NOT NULL,
   `subject` varchar(50) NOT NULL,
   `message` varchar(255) NOT NULL,
   `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `flaggedComment`;

DROP TABLE IF EXISTS `comments`;
DROP TABLE IF EXISTS `users`;
 CREATE TABLE `users` (
   `id` varchar(32) NOT NULL,
   `email` varchar(40) NOT NULL,
   `displayName` varchar(40) NOT NULL,
   `displayImageUrl` varchar(500) NULL,
   `password` varchar(255) NOT NULL,
   `resetCode` varchar(32) NULL,
   `emailConfirmed` TINYINT NULL,
   `emailCode` varchar(32) NULL,
   `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
   `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   `clientLevel` enum('1','2','3') NOT NULL DEFAULT '1',
   PRIMARY KEY (`id`),
   UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
;;
DELIMITER ;;
CREATE TRIGGER before_insert_users
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
   SET new.id = replace(uuid(),'-','');
   SET new.emailCode = replace(uuid(),'-','');
END
;;
DELIMITER ;

DROP TABLE IF EXISTS `pages`;
CREATE TABLE `pages` (
  `id` varchar(32) NOT NULL,
  -- max unique length on mysql 5.6 is 191
  `slug` varchar(191) NOT NULL ,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  `lockedcomments` TINYINT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pages_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
;;
DELIMITER ;;
CREATE TRIGGER before_insert_pages
BEFORE INSERT ON pages
FOR EACH ROW
BEGIN
   SET new.id = replace(uuid(),'-','');
END
;;
DELIMITER ;

CREATE TABLE `comments` (
  `id` varchar(32) NOT NULL,
  `parentId` varchar(32) NULL,
  `commentText` TEXT NOT NULL,
  `userId` varchar(32) NOT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  `reviewed_at` DATETIME NULL,
  `pageId` varchar(32) NOT NULL,
  `approved` TINYINT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT FK_user_comment FOREIGN KEY (userId) REFERENCES users(id),
  CONSTRAINT FK_comment_parentComment FOREIGN KEY (parentId) REFERENCES comments(id),
  CONSTRAINT FK_comment_page FOREIGN KEY (pageId) REFERENCES pages(id)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
;;
DELIMITER ;;
CREATE TRIGGER before_insert_comments
BEFORE INSERT ON comments
FOR EACH ROW
BEGIN
   SET new.id = replace(uuid(),'-','');
END
;;
DELIMITER ;

-- do I need a type
CREATE TABLE `flaggedComment` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `commentId` varchar(32) NULL,
  `userId` varchar(32) NOT NULL,
  `message` varchar(255) NOT NULL,
  `type` enum('spam','offensive') NOT NULL DEFAULT 'spam',
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT FK_flaggedComment_reportingUser FOREIGN KEY (userId) REFERENCES users(id),
  CONSTRAINT FK_flaggedComment_comment FOREIGN KEY (commentId) REFERENCES comments(id)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO configuration(name, data)
VALUES('manualPages','false')
,('moderateComments','false')
,('contactFormEmails','admin@me.com,test@me.com')
,('unlimitedReplies','false')	
,('facebookToken','');
