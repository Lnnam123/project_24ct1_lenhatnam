-- ============================================================================
-- COINTAP - EXPENSE MANAGEMENT DATABASE SCHEMA (CƠ SỞ DỮ LIỆU QUẢN LÝ CHI TIÊU)
-- Hệ quản trị CSDL đề xuất: MySQL 8.0+ / PostgreSQL
-- Ngày tạo: 2026-08-30
-- Khóa học: Công nghệ phần mềm (CNPM-DAU)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `cointap_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `cointap_db`;

-- ----------------------------------------------------------------------------
-- 1. BẢNG NGUOI_DUNG (users)
-- Lưu trữ thông tin tài khoản người dùng ứng dụng
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh người dùng',
    `full_name` VARCHAR(100) NOT NULL COMMENT 'Họ và tên người dùng',
    `email` VARCHAR(150) NOT NULL UNIQUE COMMENT 'Địa chỉ email (Dùng đăng nhập)',
    `phone_number` VARCHAR(20) UNIQUE COMMENT 'Số điện thoại liên hệ',
    `password_hash` VARCHAR(255) NOT NULL COMMENT 'Mật khẩu đã mã hóa (BCrypt/Argon2)',
    `avatar_url` VARCHAR(500) COMMENT 'Đường dẫn ảnh đại diện',
    `currency` VARCHAR(10) NOT NULL DEFAULT 'VND' COMMENT 'Đơn vị tiền tệ mặc định',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo tài khoản',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời gian cập nhật gần nhất'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng thông tin người dùng';

-- ----------------------------------------------------------------------------
-- 2. BẢNG VI_TIEN (wallets)
-- Quản lý các nguồn tiền / tài khoản thanh toán của người dùng
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `wallets` (
    `wallet_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã tài khoản / ví tiền',
    `user_id` INT NOT NULL COMMENT 'Khóa ngoại tới bảng users',
    `wallet_name` VARCHAR(100) NOT NULL COMMENT 'Tên ví (Ví tiền mặt, Vietcombank, Techcombank, Thẻ Visa)',
    `wallet_type` ENUM('CASH', 'BANK', 'CREDIT', 'E_WALLET', 'SAVINGS') NOT NULL DEFAULT 'CASH' COMMENT 'Loại tài khoản',
    `balance` DECIMAL(15, 2) NOT NULL DEFAULT 0.00 COMMENT 'Số dư hiện tại của ví',
    `account_number` VARCHAR(50) COMMENT 'Số tài khoản / số thẻ (nếu có)',
    `icon` VARCHAR(50) DEFAULT 'account_balance_wallet' COMMENT 'Tên icon hiển thị UI',
    `color` VARCHAR(20) DEFAULT '#004AC6' COMMENT 'Màu đại diện dạng Hex Code',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Trạng thái hoạt động',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_wallets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng danh sách ví / tài khoản tiền';

-- ----------------------------------------------------------------------------
-- 3. BẢNG DANH_MUC (categories)
-- Danh mục phân loại chi tiêu và thu nhập (Có hỗ trợ danh mục cha/con)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `categories` (
    `category_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã danh mục',
    `user_id` INT NULL COMMENT 'Khóa ngoại (NULL = Danh mục hệ thống mặc định)',
    `parent_id` INT NULL COMMENT 'Khóa ngoại tự tham chiếu (NULL = Danh mục gốc)',
    `name` VARCHAR(100) NOT NULL COMMENT 'Tên danh mục (Ăn uống, Mua sắm, Đội xe, Lương)',
    `type` ENUM('EXPENSE', 'INCOME') NOT NULL DEFAULT 'EXPENSE' COMMENT 'Loại danh mục: Chi tiêu hoặc Thu nhập',
    `icon` VARCHAR(50) NOT NULL DEFAULT 'category' COMMENT 'Mã icon Material Symbols',
    `color` VARCHAR(20) NOT NULL DEFAULT '#712AE2' COMMENT 'Màu mã hóa giao diện',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_categories_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng danh mục phân loại Thu / Chi';

-- ----------------------------------------------------------------------------
-- 4. BẢNG GIAO_DICH (transactions)
-- Nhật ký biến động số dư / các giao dịch thu, chi, chuyển khoản
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `transactions` (
    `transaction_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã giao dịch',
    `user_id` INT NOT NULL COMMENT 'Khóa ngoại người thực hiện',
    `wallet_id` INT NOT NULL COMMENT 'Khóa ngoại ví nguồn',
    `category_id` INT NOT NULL COMMENT 'Khóa ngoại danh mục giao dịch',
    `amount` DECIMAL(15, 2) NOT NULL COMMENT 'Số tiền giao dịch (Dương)',
    `type` ENUM('EXPENSE', 'INCOME', 'TRANSFER') NOT NULL DEFAULT 'EXPENSE' COMMENT 'Loại giao dịch',
    `destination_wallet_id` INT NULL COMMENT 'Ví đích (Dùng cho giao dịch chuyển khoản giữa các ví)',
    `transaction_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày giờ thực hiện giao dịch',
    `note` TEXT COMMENT 'Ghi chú thêm về giao dịch',
    `receipt_image_url` VARCHAR(500) COMMENT 'Ảnh hóa đơn / chứng từ',
    `is_recurring` BOOLEAN DEFAULT FALSE COMMENT 'Giao dịch định kỳ hay không',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_trans_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_trans_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`wallet_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_trans_dest_wallet` FOREIGN KEY (`destination_wallet_id`) REFERENCES `wallets` (`wallet_id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_trans_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng ghi nhận giao dịch chi tiêu & thu nhập';

-- ----------------------------------------------------------------------------
-- 5. BẢNG NGAN_SACH (budgets)
-- Thiết lập hạn mức chi tiêu cho từng danh mục hoặc tổng thể theo chu kỳ
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `budgets` (
    `budget_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã ngân sách',
    `user_id` INT NOT NULL COMMENT 'Khóa ngoại người dùng',
    `category_id` INT NULL COMMENT 'Khóa ngoại danh mục áp dụng (NULL = Tổng ngân sách)',
    `amount_limit` DECIMAL(15, 2) NOT NULL COMMENT 'Hạn mức chi tiêu cho phép',
    `period` ENUM('WEEKLY', 'MONTHLY', 'YEARLY') NOT NULL DEFAULT 'MONTHLY' COMMENT 'Chu kỳ ngân sách',
    `start_date` DATE NOT NULL COMMENT 'Ngày bắt đầu áp dụng',
    `end_date` DATE NOT NULL COMMENT 'Ngày kết thúc áp dụng',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_budgets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_budgets_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng lập ngân sách và hạn mức chi tiêu';

-- ----------------------------------------------------------------------------
-- 6. BẢNG THONG_BAO (notifications)
-- Cảnh báo vượt ngân sách, nhắc nhở chi tiêu, thông báo hệ thống
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
    `notification_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã thông báo',
    `user_id` INT NOT NULL COMMENT 'Khóa ngoại người nhận',
    `title` VARCHAR(200) NOT NULL COMMENT 'Tiêu đề thông báo',
    `message` TEXT NOT NULL COMMENT 'Nội dung chi tiết thông báo',
    `type` ENUM('BUDGET_ALERT', 'TRANSACTION_REMINDER', 'SYSTEM') NOT NULL DEFAULT 'SYSTEM',
    `is_read` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã đọc hay chưa',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng thông báo ứng dụng';

-- ----------------------------------------------------------------------------
-- 7. BẢNG QUET_HOA_DON_AI (ai_receipt_scans)
-- Bóc tách hóa đơn tự động bằng AI / OCR (Theo quy trình PlantUML codeump.txt)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `ai_receipt_scans` (
    `scan_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã lượt quét hóa đơn',
    `user_id` INT NOT NULL COMMENT 'Khóa ngoại người dùng',
    `image_url` VARCHAR(500) NOT NULL COMMENT 'Đường dẫn ảnh chụp hóa đơn',
    `extracted_amount` DECIMAL(15, 2) COMMENT 'Số tiền AI bóc tách được',
    `extracted_merchant` VARCHAR(150) COMMENT 'Tên đơn vị bán hàng AI nhận diện',
    `extracted_date` DATETIME COMMENT 'Thời gian trên hóa đơn do AI trích xuất',
    `status` ENUM('PENDING', 'PROCESSED', 'CONFIRMED', 'FAILED') DEFAULT 'PENDING' COMMENT 'Trạng thái xử lý',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_ai_scans_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng dữ liệu AI OCR bóc tách hóa đơn';

-- ============================================================================
-- INDEXES (CHỈ MỤC TỐI ƯU HÓA TRUY VẤN TỐC ĐỘ CAO)
-- ============================================================================
CREATE INDEX `idx_transactions_user_date` ON `transactions` (`user_id`, `transaction_date`);
CREATE INDEX `idx_transactions_wallet` ON `transactions` (`wallet_id`);
CREATE INDEX `idx_transactions_category` ON `transactions` (`category_id`);
CREATE INDEX `idx_budgets_user_period` ON `budgets` (`user_id`, `start_date`, `end_date`);
CREATE INDEX `idx_notifications_user_read` ON `notifications` (`user_id`, `is_read`);

-- ============================================================================
-- TRIGGERS (TỰ ĐỘNG CẬP NHẬT SỐ DƯ VÍ KHI PHÁT SINH GIAO DỊCH)
-- ============================================================================
DELIMITER //

-- Trigger 1: Tự động cộng/trừ số dư ví khi chèn giao dịch mới
CREATE TRIGGER `trg_after_transaction_insert`
AFTER INSERT ON `transactions`
FOR EACH ROW
BEGIN
    IF NEW.type = 'EXPENSE' THEN
        UPDATE `wallets` SET `balance` = `balance` - NEW.amount WHERE `wallet_id` = NEW.wallet_id;
    ELSEIF NEW.type = 'INCOME' THEN
        UPDATE `wallets` SET `balance` = `balance` + NEW.amount WHERE `wallet_id` = NEW.wallet_id;
    ELSEIF NEW.type = 'TRANSFER' THEN
        UPDATE `wallets` SET `balance` = `balance` - NEW.amount WHERE `wallet_id` = NEW.wallet_id;
        IF NEW.destination_wallet_id IS NOT NULL THEN
            UPDATE `wallets` SET `balance` = `balance` + NEW.amount WHERE `wallet_id` = NEW.destination_wallet_id;
        END IF;
    END IF;
END//

DELIMITER ;

-- ============================================================================
-- SEED DATA (DỮ LIỆU MẪU BAN ĐẦU)
-- ============================================================================

-- 1. Thêm người dùng mẫu
INSERT INTO `users` (`user_id`, `full_name`, `email`, `phone_number`, `password_hash`, `avatar_url`) VALUES
(1, 'Nguyễn Văn A', 'nguyenvana@gmail.com', '0901234567', '$2a$12$eImiTXuWVxfM37uY4JANjOL.81F8Rkhv5hX1u.gO7tZ8S5q/kE9gS', 'https://lh3.googleusercontent.com/aida-public/avatar_sample.png');

-- 2. Thêm các Ví tiền mặt & Tài khoản mẫu
INSERT INTO `wallets` (`wallet_id`, `user_id`, `wallet_name`, `wallet_type`, `balance`, `account_number`, `icon`, `color`) VALUES
(1, 1, 'Ví Tiền Mặt', 'CASH', 1500000.00, NULL, 'payments', '#10B981'),
(2, 1, 'Tài Khoản Vietcombank', 'BANK', 3000000.00, '9988112233', 'account_balance', '#004AC6'),
(3, 1, 'Thẻ Tín Dụng VISA', 'CREDIT', 10000000.00, '4123****7890', 'credit_card', '#712AE2');

-- 3. Thêm các Danh mục Chi tiêu & Thu nhập hệ thống
INSERT INTO `categories` (`category_id`, `user_id`, `parent_id`, `name`, `type`, `icon`, `color`) VALUES
-- Danh mục Chi tiêu
(1, NULL, NULL, 'Ăn uống', 'EXPENSE', 'restaurant', '#EF4444'),
(2, NULL, NULL, 'Đi lại & Mua sắm', 'EXPENSE', 'shopping_cart', '#F59E0B'),
(3, NULL, NULL, 'Giải trí & Du lịch', 'EXPENSE', 'sports_esports', '#8B5CF6'),
(4, NULL, NULL, 'Hóa đơn & Tiện ích', 'EXPENSE', 'receipt_long', '#3B82F6'),

-- Danh mục Thu nhập
(5, NULL, NULL, 'Lương cố định', 'INCOME', 'payments', '#10B981'),
(6, NULL, NULL, 'Thưởng & Đầu tư', 'INCOME', 'trending_up', '#06B6D4');

-- 4. Thêm Ngân sách mẫu
INSERT INTO `budgets` (`budget_id`, `user_id`, `category_id`, `amount_limit`, `period`, `start_date`, `end_date`) VALUES
(1, 1, NULL, 5000000.00, 'MONTHLY', '2026-08-01', '2026-08-31');

-- 5. Thêm các Giao dịch mẫu (Theo đúng giao diện Stitch Dashboard)
INSERT INTO `transactions` (`transaction_id`, `user_id`, `wallet_id`, `category_id`, `amount`, `type`, `transaction_date`, `note`) VALUES
(1, 1, 2, 5, 15000000.00, 'INCOME', '2026-08-25 08:00:00', 'Lương tháng 10 năm 2026'),
(2, 1, 1, 1, 120000.00, 'EXPENSE', '2026-08-29 19:30:00', 'Nhà hàng Phở 24'),
(3, 1, 2, 2, 350000.00, 'EXPENSE', '2026-08-30 10:24:00', 'Siêu thị Co.opmart');

-- 6. Thêm Thông báo mẫu
INSERT INTO `notifications` (`notification_id`, `user_id`, `title`, `message`, `type`, `is_read`) VALUES
(1, 1, 'Cảnh báo Ngân sách', 'Bạn đã chi tiêu 90% ngân sách tháng 8!', 'BUDGET_ALERT', FALSE),
(2, 1, 'Giao dịch thành công', 'Nhận +15.000.000đ Lương tháng 10 vào tài khoản VCB', 'SYSTEM', TRUE);
