const express = require('express');
const router = express.Router();
const { createInvestment, getMyInvestments, getInvestmentDetail } = require('../controllers/investmentController');
const { verifyToken } = require('../middlewares/auth');
const upload = require('../middlewares/upload');

router.post('/', verifyToken, upload.single('transfer_proof'), createInvestment);
router.get('/my', verifyToken, getMyInvestments);
router.get('/:id', verifyToken, getInvestmentDetail);

module.exports = router;

