
const express = require('express');
const School = require('../models/School');
const Faculty = require('../models/Faculty');
const Elective = require('../models/Elective');

const {
  verifyToken,
  requireAdmin,
} = require('../middleware/authMiddleware');

const router = express.Router();

// Get dashboard statistics (admin only)
router.get('/stats', verifyToken, requireAdmin, async (req, res) => {
  try {
    const schools = await School.find({ isActive: true })
      .select('_id name')
      .sort({ name: 1 });

    const schoolIds = schools.map((school) => school._id);

    const [facultyCounts, electiveCounts] = await Promise.all([
      Faculty.aggregate([
        {
          $match: {
            schoolId: { $in: schoolIds },
            isActive: true,
          },
        },
        {
          $group: {
            _id: '$schoolId',
            count: { $sum: 1 },
          },
        },
      ]),

      Elective.aggregate([
        {
          $match: {
            schoolId: { $in: schoolIds },
            isActive: true,
          },
        },
        {
          $group: {
            _id: '$schoolId',
            count: { $sum: 1 },
          },
        },
      ]),
    ]);

    const facultyCountMap = new Map(
      facultyCounts.map((item) => [
        item._id.toString(),
        item.count,
      ])
    );

    const electiveCountMap = new Map(
      electiveCounts.map((item) => [
        item._id.toString(),
        item.count,
      ])
    );

    const schoolStats = schools.map((school) => {
      const schoolId = school._id.toString();

      return {
        schoolId,
        name: school.name,
        facultyCount: facultyCountMap.get(schoolId) || 0,
        electiveCount: electiveCountMap.get(schoolId) || 0,
      };
    });

    return res.status(200).json({
      totalSchools: schools.length,
      totalFaculty: schoolStats.reduce(
        (total, school) => total + school.facultyCount,
        0
      ),
      totalElectives: schoolStats.reduce(
        (total, school) => total + school.electiveCount,
        0
      ),
      schools: schoolStats,
    });
  } catch (error) {
    console.error('Failed to fetch dashboard statistics:', error);

    return res.status(500).json({
      message: 'Failed to fetch dashboard statistics',
    });
  }
});

// Get all active schools
router.get('/', verifyToken, async (req, res) => {
  try {
    const schools = await School.find({ isActive: true }).sort({
      name: 1,
    });

    return res.status(200).json({ schools });
  } catch (error) {
    console.error('Failed to fetch schools:', error);

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

    console.error('Failed to add school:', error);

    return res.status(500).json({
      message: 'Failed to add school',
    });
  }
});

module.exports = router;
