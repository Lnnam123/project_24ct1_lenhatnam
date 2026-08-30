const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Kết nối MySQL
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'cointap_db',
    multipleStatements: true
});

db.connect((err) => {
    if (err) {
        console.error('Lỗi kết nối MySQL:', err.message);
    } else {
        console.log('Connected to the MySQL database.');
    }
});

// Đăng nhập
app.post('/api/login', (req, res) => {
    const { email, password } = req.body;
    const query = `SELECT user_id AS id, full_name AS name, email FROM users WHERE email = ? AND password_hash = ?`;
    
    db.query(query, [email, password], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length > 0) res.json(results[0]);
        else res.status(401).json({ error: 'Sai email hoặc mật khẩu' });
    });
});

// Đăng ký
app.post('/api/register', (req, res) => {
    const { name, email, password } = req.body;
    const insertUser = `INSERT INTO users (full_name, email, password_hash) VALUES (?, ?, ?)`;
    
    db.query(insertUser, [name, email, password], (err, result) => {
        if (err) {
            // Error 1062 is duplicate entry for unique key
            if (err.code === 'ER_DUP_ENTRY') return res.status(400).json({ error: 'Email đã tồn tại' });
            return res.status(500).json({ error: err.message });
        }
        
        const userId = result.insertId;
        // Tạo ví mặc định
        const insertWallet = `INSERT INTO wallets (user_id, wallet_name, wallet_type, balance, icon, color) VALUES (?, 'Ví Tiền Mặt', 'CASH', 0, 'payments', '#10B981')`;
        db.query(insertWallet, [userId], (err2) => {
            if (err2) console.error("Lỗi tạo ví mặc định:", err2.message);
        });
        
        res.json({ id: userId, name, email });
    });
});

// Lấy danh sách ví
app.get('/api/wallets/:userId', (req, res) => {
    const query = `SELECT wallet_id AS id, wallet_name AS name, balance FROM wallets WHERE user_id = ? AND is_active = 1`;
    db.query(query, [req.params.userId], (err, results) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json(results);
    });
});

// Thêm ví mới
app.post('/api/wallets', (req, res) => {
    const { user_id, wallet_name, wallet_type, balance, icon, color } = req.body;
    const insertWallet = `INSERT INTO wallets (user_id, wallet_name, wallet_type, balance, icon, color) VALUES (?, ?, ?, ?, ?, ?)`;
    db.query(insertWallet, [user_id, wallet_name, wallet_type, balance, icon, color], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ id: result.insertId });
    });
});

// Lấy danh sách danh mục (Mặc định + Của người dùng)
app.get('/api/categories/:userId', (req, res) => {
    const query = `SELECT category_id AS id, name, type, icon, color FROM categories WHERE user_id IS NULL OR user_id = ?`;
    db.query(query, [req.params.userId], (err, results) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json(results);
    });
});

// Thêm danh mục mới
app.post('/api/categories', (req, res) => {
    const { user_id, name, type, icon, color } = req.body;
    const insertCat = `INSERT INTO categories (user_id, name, type, icon, color) VALUES (?, ?, ?, ?, ?)`;
    db.query(insertCat, [user_id, name, type, icon, color], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ id: result.insertId });
    });
});

// Cập nhật danh mục
app.put('/api/categories/:id', (req, res) => {
    const { name, type, icon, color } = req.body;
    const updateCat = `UPDATE categories SET name = ?, type = ?, icon = ?, color = ? WHERE category_id = ?`;
    db.query(updateCat, [name, type, icon, color, req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

// Xóa danh mục
app.delete('/api/categories/:id', (req, res) => {
    const deleteCat = `DELETE FROM categories WHERE category_id = ?`;
    db.query(deleteCat, [req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});


// Thêm giao dịch
app.post('/api/transactions', (req, res) => {
    const { user_id, wallet_id, amount, type, date, note } = req.body;
    
    // Ở MySQL, vì chúng ta đã tạo Trigger trg_after_transaction_insert trong schema.sql, 
    // khi thêm giao dịch thì số dư ví sẽ tự động được cập nhật. Chúng ta không cần thủ công update wallets nữa!
    // Tuy nhiên, category_id hiện đang không gửi từ Flutter hoặc gửi nhưng thiếu, ta tạm fix category_id = 1 (Ăn uống) 
    // vì schema MySQL yêu cầu category_id NOT NULL.
    
    const category_id = req.body.category_id || 1; // Lấy category_id nếu có, mặc định là 1
    
    const insertTx = `INSERT INTO transactions (user_id, wallet_id, category_id, amount, type, transaction_date, note) VALUES (?, ?, ?, ?, ?, ?, ?)`;
    
    db.query(insertTx, [user_id, wallet_id, category_id, amount, type, date, note], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ id: result.insertId });
    });
});

// Lấy giao dịch
app.get('/api/transactions/:userId', (req, res) => {
    const query = `SELECT transaction_id AS id, note, amount, type, wallet_id, category_id, transaction_date AS date FROM transactions WHERE user_id = ? ORDER BY transaction_date DESC, transaction_id DESC`;
    db.query(query, [req.params.userId], (err, results) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json(results);
    });
});

// Cập nhật danh mục / thông tin giao dịch
app.put('/api/transactions/:id', (req, res) => {
    const { category_id, note, amount, wallet_id } = req.body;
    const query = `UPDATE transactions SET category_id = COALESCE(?, category_id), note = COALESCE(?, note), amount = COALESCE(?, amount), wallet_id = COALESCE(?, wallet_id) WHERE transaction_id = ?`;
    db.query(query, [category_id, note, amount, wallet_id, req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
