const pool = require('../config/db');

const getAllInvestments = async (req, res) => {
  try {
    const { status } = req.query;
    let query = `
      SELECT i.*, p.project_name, u.email as user_email
      FROM investments i
      JOIN projects p ON i.project_id = p.id
      JOIN users u ON i.user_id = u.id
    `;
    const params = [];

    if (status) {
      query += ' WHERE i.status = ?';
      params.push(status);
    }

    query += ' ORDER BY i.created_at DESC';

    const [rows] = await pool.query(query, params);
    res.json({ success: true, data: rows });
  } catch (error) {
    console.error('Error getAllInvestments:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
};

const updateInvestmentStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    if (!['verified', 'rejected', 'completed', 'pending'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Status tidak valid' });
    }

    const verifiedAt = status === 'verified' ? new Date() : null;

    const [result] = await pool.query(
      'UPDATE investments SET status = ?, notes = COALESCE(?, notes), verified_at = ? WHERE id = ?',
      [status, notes || null, verifiedAt, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Data investasi tidak ditemukan' });
    }

    res.json({ success: true, message: `Status investasi berhasil diubah menjadi ${status}` });
  } catch (error) {
    console.error('Error updateInvestmentStatus:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
};

const getDashboardSummary = async (req, res) => {
  try {
    const [projectRows] = await pool.query('SELECT * FROM projects WHERE status = "open" LIMIT 1');
    const project = projectRows[0] || {};

    const [summaryRows] = await pool.query(`
      SELECT 
        COUNT(*) as total_investments,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
        COUNT(CASE WHEN status = 'verified' THEN 1 END) as verified_count,
        COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_count,
        COALESCE(SUM(CASE WHEN status = 'verified' THEN amount ELSE 0 END), 0) as total_verified_amount
      FROM investments
    `);

    const summary = summaryRows[0];
    const totalVerified = parseFloat(summary.total_verified_amount || 0);
    const target = parseFloat(project.funding_target || 0);
    const percentage = target > 0 ? (totalVerified / target) * 100 : 0;

    res.json({
      success: true,
      data: {
        project,
        total_investments: summary.total_investments,
        pending_count: summary.pending_count,
        verified_count: summary.verified_count,
        rejected_count: summary.rejected_count,
        total_verified_amount: totalVerified,
        funding_percentage: parseFloat(percentage.toFixed(2))
      }
    });
  } catch (error) {
    console.error('Error getDashboardSummary:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
};

const getReportData = async (req, res) => {
  try {
    const [projects] = await pool.query('SELECT * FROM projects WHERE status = "open" LIMIT 1');
    const project = projects[0] || {};

    const [investors] = await pool.query(`
      SELECT 
        i.id,
        i.investor_name,
        i.phone,
        i.bank_name,
        i.account_number,
        i.amount,
        i.gross_profit,
        i.admin_fee,
        i.net_profit,
        i.total_return,
        i.status,
        i.created_at,
        i.verified_at
      FROM investments i
      ORDER BY i.created_at ASC
    `);

    const [totalRows] = await pool.query(`
      SELECT COALESCE(SUM(amount), 0) as total_verified
      FROM investments
      WHERE status = 'verified'
    `);

    const totalVerified = parseFloat(totalRows[0].total_verified || 0);
    const target = parseFloat(project.funding_target || 0);
    const percentage = target > 0 ? (totalVerified / target) * 100 : 0;

    res.json({
      success: true,
      data: {
        company_name: project.company_name || 'CV. Karya Amanah Sejati',
        project_name: project.project_name || 'Proyek Pengadaan Meja Kursi',
        funding_target: target,
        total_verified: totalVerified,
        funding_percentage: parseFloat(percentage.toFixed(2)),
        report_generated_at: new Date(),
        investors: investors
      }
    });
  } catch (error) {
    console.error('Error getReportData:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
};

module.exports = { getAllInvestments, updateInvestmentStatus, getDashboardSummary, getReportData };

