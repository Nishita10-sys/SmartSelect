
const express = require('express');
const mongoose = require('mongoose');
const Elective = require('../models/Elective');
const School = require('../models/School');

const {
  verifyToken,
  requireAdmin,
} = require('../middleware/authMiddleware');

const router = express.Router();

// Get active electives for a school
router.get(
  '/school/:schoolId',
  verifyToken,
  async (req, res) => {
    try {
      const { schoolId } = req.params;

      if (!mongoose.isValidObjectId(schoolId)) {
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

      const electives = await Elective.find({
        schoolId,
        isActive: true,
      }).sort({
        academicYear: 1,
        semester: 1,
        subjectName: 1,
      });

      return res.status(200).json({ electives });
    } catch (error) {
      return res.status(500).json({
        message: 'Failed to fetch electives',
      });
    }
  }
);

// Create an elective (admin only)
router.post(
  '/',
  verifyToken,
  requireAdmin,
  async (req, res) => {
    try {
      const {
        subjectName,
        subjectCode,
        description,
        schoolId,
        department,
        specialization,
        academicYear,
        semester,
        totalSeats,
      } = req.body;

      if (
        !subjectName?.trim() ||
        !subjectCode?.trim() ||
        !schoolId ||
        !department?.trim() ||
        !academicYear ||
        semester === undefined ||
        totalSeats === undefined
      ) {
        return res.status(400).json({
          message: 'Please provide all required elective details',
        });
      }

      if (!mongoose.isValidObjectId(schoolId)) {
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

      const validYears = ['FY', 'SY', 'TY', 'LY'];

      if (!validYears.includes(academicYear)) {
        return res.status(400).json({
          message: 'Academic year must be FY, SY, TY, or LY',
        });
      }

      const parsedSemester = Number(semester);
      const parsedSeats = Number(totalSeats);

      if (
        !Number.isInteger(parsedSemester) ||
        parsedSemester < 1 ||
        parsedSemester > 8
      ) {
        return res.status(400).json({
          message: 'Semester must be a number from 1 to 8',
        });
      }

      if (!Number.isInteger(parsedSeats) || parsedSeats < 1) {
        return res.status(400).json({
          message: 'Total seats must be a positive whole number',
        });
      }

      const elective = await Elective.create({
        subjectName: subjectName.trim(),
        subjectCode: subjectCode.trim().toUpperCase(),
        description: description?.trim() || '',
        schoolId,
        department: department.trim(),
        specialization: specialization?.trim() || '',
        academicYear,
        semester: parsedSemester,
        totalSeats: parsedSeats,
        availableSeats: parsedSeats,
        createdBy: req.user.userId,
      });

      return res.status(201).json({
        message: 'Elective created successfully',
        elective,
      });
    
    } catch (error) {
      console.error('Failed to create elective:', error);

      return res.status(500).json({
        message: 'Failed to create elective',
      });
    }
  }
);

module.exports = router;