-- ============================================================================
-- BẢNG QUẢN TRỊ VIÊN HỆ THỐNG WEB ADMIN (SUPABASE)
-- Tách riêng biệt với bảng users thông thường của người dùng di động
-- ============================================================================

CREATE TABLE IF NOT EXISTS admins (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'Administrator',
    email VARCHAR(150),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Thêm tài khoản quản trị viên mặc định (admin / admin)
INSERT INTO admins (username, password_hash, full_name, role, email)
VALUES ('admin', 'admin', 'Quản Trị Viên Gốc', 'Super Admin', 'admin@cointap.vn')
ON CONFLICT (username) DO NOTHING;

-- Cho phép truy vấn qua Anon Key (như các bảng khác của CoinTap)
ALTER TABLE admins DISABLE ROW LEVEL SECURITY;
