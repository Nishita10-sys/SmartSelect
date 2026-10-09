
const express = require('express');
const bcrypt = require('bcryptjs');
const Faculty = require('../models/Faculty');
const School = require('../models/School');

const {
  verifyToken,
  requireAdmin,
} = require('../middleware/authMiddleware');

const router = express.Router();

// Get faculty members belonging to a school
router.get(
  '/school/:schoolId',
  verifyToken,
  requireAdmin,
  async (req, res) => {
    try {
      const { schoolId } = req.params;

      if (!schoolId.match(/^[0-9a-fA-F]{24}$/)) {
        return res.status(400).json({
          message: 'Invalid school ID',
        });
      }

      const school = await School.findById(schoolId);

      if (!school || !school.isActive) {
        return res.status(404).json({
          message: 'School not found',
        });
      }

      const faculty = await Faculty.find({
        schoolId,
        isActive: true,
      })
        .select('-password')
        .sort({ name: 1 });

      return res.status(200).json({ faculty });
    } catch (error) {
      return res.status(500).json({
        message: 'Failed to fetch faculty members',
      });
    }
  }
);

// Register a faculty member (admin only)
router.post(
  '/',
  verifyToken,
  requireAdmin,
  async (req, res) => {
    try {
      const {
        name,
        email,
        employeeId,
        department,
        specialization,
        schoolId,
        password,
      } = req.body;

      if (
        !name?.trim() ||
        !email?.trim() ||
        !employeeId?.trim() ||
        !department?.trim() ||
        !schoolId ||
        !password
      ) {
        return res.status(400).json({
          message: 'Please provide all required faculty details',
        });
      }

      if (!schoolId.match(/^[0-9a-fA-F]{24}$/)) {
        return res.status(400).json({
          message: 'Invalid school ID',
        });
      }

      if (password.length < 8) {
        return res.status(400).json({
          message: 'Password must be at least 8 characters long',
        });
      }

      const school = await School.findById(schoolId);

      if (!school || !school.isActive) {
        return res.status(404).json({
          message: 'School not found',
        });
      }

      const normalizedEmail = email.trim().toLowerCase();
      const normalizedEmployeeId = employeeId.trim();

      const existingFaculty = await Faculty.findOne({
        $or: [
          { email: normalizedEmail },
          { employeeId: normalizedEmployeeId },
        ],
      });

      if (existingFaculty) {
        return res.status(409).json({
          message: 'Email or employee ID is already registered',
        });
      }

      const hashedPassword = await bcrypt.hash(password, 12);

      const faculty = await Faculty.create({
        name: name.trim(),
        email: normalizedEmail,
        employeeId: normalizedEmployeeId,
        department: department.trim(),
        specialization: specialization?.trim() || '',
        schoolId,
        password: hashedPassword,
      });

      const safeFaculty = faculty.toObject();
      delete safeFaculty.password;

      return res.status(201).json({
        message: 'Faculty registered successfully',
        faculty: safeFaculty,
      });
    } catch (error) {
      if (error.code === 11000) {
        return res.status(409).json({
          message: 'Email or employee ID is already registered',
        });
      }

      return res.status(500).json({
        message: 'Failed to register faculty member',
      });
    }
  }
);

module.exports = router;