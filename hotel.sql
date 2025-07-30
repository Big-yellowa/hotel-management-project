 -- ===============================================================
-- Database: Hotel Reservation System
-- Author: Aime
-- Creation Date: 2025-07-22
-- Description: DDL script for creating tables for a hotel reservation system.
-- ===============================================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS Hotel;
USE Hotel;

-- Drop tables if they exist to ensure a clean slate
DROP TABLE IF EXISTS `review`;
DROP TABLE IF EXISTS `admin`;
DROP TABLE IF EXISTS `hotel_order`;
DROP TABLE IF EXISTS `room`;
DROP TABLE IF EXISTS `hotel`;
DROP TABLE IF EXISTS `user`;


-- ----------------------------
-- Table structure for user
-- ----------------------------
CREATE TABLE `user` (
  `user_id` INT NOT NULL AUTO_INCREMENT COMMENT '唯一标识用户',
  `username` VARCHAR(50) NOT NULL COMMENT '登录用户名，不可重复',
  `password` VARCHAR(100) NOT NULL COMMENT '加密后的密码（如 MD5）',
  `nickname` VARCHAR(50) DEFAULT '游客' COMMENT '显示昵称',
  `avatar_url` VARCHAR(255) DEFAULT NULL COMMENT '头像图片 URL',
  `phone` VARCHAR(20) NOT NULL COMMENT '联系电话，用于登录验证',
  `register_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `status` TINYINT DEFAULT 1 COMMENT '1 = 正常，0 = 封禁',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ----------------------------
-- Table structure for hotel
-- ----------------------------
CREATE TABLE `hotel` (
  `hotel_id` INT NOT NULL AUTO_INCREMENT COMMENT '唯一标识酒店',
  `name` VARCHAR(100) NOT NULL COMMENT '酒店名称',
  `address` VARCHAR(255) NOT NULL COMMENT '详细地址',
  `intro` TEXT DEFAULT NULL COMMENT '酒店简介',
  `star_level` TINYINT DEFAULT 0 COMMENT '星级（0-5，0 = 无星级）',
  `score` DECIMAL(2,1) DEFAULT 0.0 COMMENT '评分（0-5，保留 1 位小数）',
  `cover_url` VARCHAR(255) NOT NULL COMMENT '封面图 URL',
  `business_status` TINYINT DEFAULT 1 COMMENT '1 = 正常营业，0 = 停业',
  PRIMARY KEY (`hotel_id`),
  KEY `idx_hotel_star_score` (`star_level`, `score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='酒店表';

-- ----------------------------
-- Table structure for admin
-- ----------------------------
CREATE TABLE `admin` (
  `admin_id` INT NOT NULL AUTO_INCREMENT COMMENT '唯一标识管理员',
  `username` VARCHAR(50) NOT NULL COMMENT '登录用户名',
  `password` VARCHAR(100) NOT NULL COMMENT '加密后的密码',
  `role` VARCHAR(20) NOT NULL COMMENT '角色（超级管理员 / 酒店管理员）',
  `hotel_id` INT DEFAULT NULL COMMENT '关联酒店表 hotel_id（仅酒店管理员有值）',
  `phone` VARCHAR(20) NOT NULL COMMENT '联系电话',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `status` TINYINT DEFAULT 1 COMMENT '1 = 正常，0 = 禁用',
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `fk_admin_hotel_id` (`hotel_id`),
  CONSTRAINT `fk_admin_hotel_id` FOREIGN KEY (`hotel_id`) REFERENCES `hotel` (`hotel_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- ----------------------------
-- Table structure for room
-- ----------------------------
CREATE TABLE `room` (
  `room_id` INT NOT NULL AUTO_INCREMENT COMMENT '唯一标识客房',
  `hotel_id` INT NOT NULL COMMENT '关联酒店表 hotel_id',
  `type` VARCHAR(50) NOT NULL COMMENT '房型（如 “单人间”）',
  `price` DECIMAL(10,2) NOT NULL COMMENT '每日价格（元）',
  `area` DECIMAL(5,1) NOT NULL COMMENT '面积（㎡，保留 1 位小数）',
  `bed_type` VARCHAR(50) NOT NULL COMMENT '床型（如 “1.8m 大床”）',
  `max_people` TINYINT NOT NULL COMMENT '最大可住人数',
  `status` TINYINT NOT NULL COMMENT '状态（1=空闲，2=已预订，3=清洁中，4=维修中）',
  `floor` INT NOT NULL COMMENT '所在楼层',
  `room_number` VARCHAR(20) NOT NULL COMMENT '房间号（如 “801”）',
  `last_update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '状态最后更新时间',
  PRIMARY KEY (`room_id`),
  KEY `fk_room_hotel_id` (`hotel_id`),
  KEY `idx_room_status` (`status`),
  CONSTRAINT `fk_room_hotel_id` FOREIGN KEY (`hotel_id`) REFERENCES `hotel` (`hotel_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客房表';

-- ----------------------------
-- Table structure for `hotel_order`
-- ----------------------------
CREATE TABLE `hotel_order` (
  `order_id` INT NOT NULL AUTO_INCREMENT COMMENT '唯一标识订单',
  `user_id` INT NOT NULL COMMENT '关联用户表 user_id',
  `hotel_id` INT NOT NULL COMMENT '关联酒店表 hotel_id',
  `room_id` INT NOT NULL COMMENT '关联客房表 room_id',
  `check_in` DATETIME NOT NULL COMMENT '入住时间（YYYY-MM-DD HH:MM）',
  `check_out` DATETIME NOT NULL COMMENT '退房时间（YYYY-MM-DD HH:MM）',
  `contact_name` VARCHAR(50) NOT NULL COMMENT '预订人姓名',
  `contact_phone` VARCHAR(20) NOT NULL COMMENT '预订人电话',
  `status` TINYINT NOT NULL COMMENT '状态（1=待支付，2=已支付，3=已入住，4=已完成，5=已取消）',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '支付总金额（元）',
  `pay_time` DATETIME DEFAULT NULL COMMENT '支付时间（未支付则为 NULL）',
  `cancel_reason` VARCHAR(255) DEFAULT NULL COMMENT '取消原因（仅已取消订单有值）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '订单创建时间',
  PRIMARY KEY (`order_id`),
  KEY `fk_order_user_id` (`user_id`),
  KEY `fk_order_hotel_id` (`hotel_id`),
  KEY `fk_order_room_id` (`room_id`),
  KEY `idx_user_order_time` (`user_id`, `create_time`),
  CONSTRAINT `fk_order_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_hotel_id` FOREIGN KEY (`hotel_id`) REFERENCES `hotel` (`hotel_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_room_id` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ----------------------------
-- Table structure for review
-- ----------------------------
CREATE TABLE `review` (
  `review_id` INT NOT NULL AUTO_INCREMENT COMMENT '唯一标识评价',
  `user_id` INT NOT NULL COMMENT '关联用户表 user_id',
  `hotel_id` INT NOT NULL COMMENT '关联酒店表 hotel_id',
  `order_id` INT NOT NULL COMMENT '关联订单表 order_id（仅入住后可评价）',
  `score` TINYINT NOT NULL COMMENT '评分（1-5 星）',
  `content` TEXT NOT NULL COMMENT '评价内容',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评价提交时间',
  `audit_status` TINYINT DEFAULT 0 COMMENT '审核状态（0=待审核，1=已通过，2=已驳回）',
  `admin_id` INT DEFAULT NULL COMMENT '关联管理员表 admin_id（审核人）',
  `audit_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `uk_order_id` (`order_id`),
  KEY `fk_review_user_id` (`user_id`),
  KEY `fk_review_hotel_id` (`hotel_id`),
  KEY `fk_review_admin_id` (`admin_id`),
  KEY `idx_review_audit_status` (`audit_status`),
  CONSTRAINT `fk_review_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_hotel_id` FOREIGN KEY (`hotel_id`) REFERENCES `hotel` (`hotel_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_order_id` FOREIGN KEY (`order_id`) REFERENCES `hotel_order` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_admin_id` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';
