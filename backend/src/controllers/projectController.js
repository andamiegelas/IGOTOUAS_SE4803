const pool = require('../config/db');

const getActiveProject = async (req, res) => {
  try {
    const [projects] = await pool.query('SELECT * FROM projects WHERE status = "open" LIMIT 1');
    if (projects.length === 0) {
      return res.status(404).json({ success: false, message: 'Tidak ada proyek aktif' });
    }

    const project = projects[0];

    // Calculate total verified funding
    const [fundingRows] = await pool.query(
      'SELECT COALESCE(SUM(amount), 0) AS total_verified FROM investments WHERE project_id = ? AND status = "verified"',
      [project.id]
    );

    const totalVerified = parseFloat(fundingRows[0].total_verified || 0);
    const fundingTarget = parseFloat(project.funding_target);
    const percentage = fundingTarget > 0 ? (totalVerified / fundingTarget) * 100 : 0;

    // Get location for Google Maps
    const [locationRows] = await pool.query('SELECT * FROM locations WHERE project_id = ? LIMIT 1', [project.id]);

    res.json({
      success: true,
      data: {
        ...project,
        total_verified: totalVerified,
        funding_percentage: parseFloat(percentage.toFixed(2)),
        location: locationRows[0] || null
      }
    });
  } catch (error) {
    console.error('Error getActiveProject:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
};

const getProjectLocation = async (req, res) => {
  try {
    const [locations] = await pool.query('SELECT * FROM locations LIMIT 1');
    if (locations.length === 0) {
      return res.status(404).json({ success: false, message: 'Lokasi belum diatur' });
    }
    res.json({ success: true, data: locations[0] });
  } catch (error) {
    console.error('Error getProjectLocation:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
};

module.exports = { getActiveProject, getProjectLocation };

