const express = require('express');
const router = express.Router();
const { getActiveProject, getProjectLocation } = require('../controllers/projectController');
const { verifyToken } = require('../middlewares/auth');

router.get('/active', verifyToken, getActiveProject);
router.get('/location', verifyToken, getProjectLocation);

module.exports = router;

