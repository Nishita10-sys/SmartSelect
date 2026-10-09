
const express = require('express');
const School = require('../models/School');
const {
  verifyToken,
  requireAdmin,
} = require('../middleware/authMiddleware');

const router = express.Router();

// Get all active schools
router.get('/', verifyToken, async (req, res) => {
  try {
    const schools = await School.find({ isActive: true }).sort({
      name: 1,
    });

    return res.status(200).json({ schools });
  } catch (error) {
    return res.status(500).json({
      message: 'Failed to fetch schools',
    });
  }
});

// Add a new school (admin only)
router.post('/', verifyToken, requireAdmin, async (req, res) => {
  try {
    const name = req.body.name?.trim();
    const description = req.body.description?.trim() || '';

    if (!name) {
      return res.status(400).json({
        message: 'School name is required',
      });
    }

    const existingSchool = await School.findOne({ name });

    if (existingSchool) {
      return res.status(409).json({
        message: 'A school with this name already exists',
      });
    }

    const school = await School.create({
      name,
      description,
    });

    return res.status(201).json({
      message: 'School added successfully',
      school,
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        message: 'A school with this name already exists',
      });
    }

    return res.status(500).json({
      message: 'Failed to add school',
    });
  }
});

module.exports = router;