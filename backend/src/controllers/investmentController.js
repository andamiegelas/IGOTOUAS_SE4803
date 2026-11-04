const pool = require('../config/db');

const createInvestment = async (req, res) => {
  try {
    const { project_id, investor_name, phone, bank_name, account_number, amount } = req.body;
    const userId = req.user.id;

    if (!project_id || !investor_name || !phone || !bank_name || !account_number || !amount) {
      return res.status(400).json({ success: false, message: 'Semua field formulir wajib diisi' });
    }

    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Foto bukti transfer wajib diunggah (dari kamera)' });
    }

    const numericAmount = parseFloat(amount);
    if (isNaN(numericAmount) || numericAmount <= 0) {
      return res.status(400).json({ success: false, message: 'Nominal investasi harus lebih dari 0' });
    }

    // Get active project parameters
    const [projects] = await pool.query('SELECT * FROM projects WHERE id = ?', [project_id]);
    if (projects.length === 0) {
      return res.status(404).json({ success: false, message: 'Proyek tidak ditemukan' });
    }

    const project = projects[0];
    const profitPercentage = parseFloat(project.profit_percentage);
    const adminFee = parseFloat(project.admin_fee || 0);

    // Business calculations
    const grossProfit = numericAmount * (profitPercentage / 100);
    const netProfit = grossProfit - adminFee;
    const totalReturn = numericAmount + netProfit;
    const transferProofPath = `/uploads/${req.file.filename}`;

    const [result] = await pool.query(
      `INSERT INTO investments 
      (project_id, user_id, investor_name, phone, bank_name, account_number, amount, profit_percentage, gross_profit, admin_fee, net_profit, total_return, transfer_proof_path, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')`,
      [
        project_id,
        userId,
        investor_name,
        phone,
        bank_name,
        account_number,
        numericAmount,
        profitPercentage,
        grossProfit,
        adminFee,
        netProfit,
        totalReturn,
        transferProofPath
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Pengajuan investasi berhasil dikirim, menunggu verifikasi admin',
      data: {
        id: result.insertId,
        amount: numericAmount,
        profit_percentage: profitPercentage,
        gross_profit: grossProfit,
        net_profit: netProfit,
        total_return: totalReturn,
        transfer_proof_path: transferProofPath,
        status: 'pending'
      }
    });
  } catch (error) {
    console.error('Error createInvestment:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server saat memproses investasi' });
  }
};

const getMyInvestments = async (req, res) => {
  try {
    const userId = req.user.id;
    const [rows] = await pool.query(
      `SELECT i.*, p.project_name, p.company_name 
       FROM investments i
       JOIN projects p ON i.project_id = p.id
       WHERE i.user_id = ?
       ORDER BY i.created_at DESC`,
      [userId]
    );

    res.json({ success: true, data: rows });
  } catch (error) {
    console.error('Error getMyInvestments:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
};

const getInvestmentDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.query(
      `SELECT i.*, p.project_name, p.company_name, u.email as user_email
       FROM investments i
       JOIN projects p ON i.project_id = p.id
       JOIN users u ON i.user_id = u.id
       WHERE i.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Data investasi tidak ditemukan' });
    }

    const investment = rows[0];
    if (req.user.role !== 'admin' && investment.user_id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Anda tidak memiliki hak akses untuk melihat data ini' });
    }

    res.json({ success: true, data: investment });
  } catch (error) {
    console.error('Error getInvestmentDetail:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
};

module.exports = { createInvestment, getMyInvestments, getInvestmentDetail };

