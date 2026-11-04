const express = require('express');
const router = express.Router();
const {
  getAllInvestments,
  updateInvestmentStatus,
  getDashboardSummary,
  getReportData
} = require('../controllers/adminController');
const { verifyToken, verifyAdmin } = require('../middlewares/auth');

router.use(verifyToken, verifyAdmin);

router.get('/dashboard', getDashboardSummary);
router.get('/investments', getAllInvestments);
router.put('/investments/:id/status', updateInvestmentStatus);
router.get('/report-data', getReportData);

module.exports = router;

