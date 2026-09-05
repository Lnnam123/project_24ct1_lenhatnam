-- ============================================================================
-- BẢNG LƯU TRỮ CUỘC TRÒ CHUYỆN VÀ TIN NHẮN TRỢ LÝ AI (SUPABASE)
-- Hỗ trợ cơ chế đa phiên (Multi-sessions) như Gemini / ChatGPT của Google
-- ============================================================================

-- 0. Xóa bảng cũ (nếu có) để cập nhật cấu trúc mới hỗ trợ session_id
DROP TABLE IF EXISTS ai_chat_messages CASCADE;
DROP TABLE IF EXISTS ai_conversations CASCADE;

-- 1. Bảng lưu từng phiên / cuộc trò chuyện
CREATE TABLE ai_conversations (
    session_id TEXT PRIMARY KEY,
    user_id INT NOT NULL,
    title TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_ai_conv_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- 2. Bảng lưu từng tin nhắn trong phiên
CREATE TABLE ai_chat_messages (
    message_id BIGSERIAL PRIMARY KEY,
    session_id TEXT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    is_user BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_ai_msg_conv FOREIGN KEY (session_id) REFERENCES ai_conversations (session_id) ON DELETE CASCADE,
    CONSTRAINT fk_ai_msg_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- 3. Chỉ mục tối ưu tốc độ truy vấn
CREATE INDEX IF NOT EXISTS idx_ai_conv_user ON ai_conversations(user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_msg_session ON ai_chat_messages(session_id, created_at ASC);

-- 4. Cho phép truy cập qua Anon Key (như các bảng khác)
ALTER TABLE ai_conversations DISABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_messages DISABLE ROW LEVEL SECURITY;
