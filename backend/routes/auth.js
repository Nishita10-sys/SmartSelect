
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();

// Student signup
router.post('/signup', async (req, res) => {
  try {
    const {
      name,
      email,
      enrollmentNumber,
      branch,
      specialization,
      password
    } = req.body;

    if (
      !name ||
      !email ||
      !enrollmentNumber ||
      !branch ||
      !specialization ||
      !password
    ) {
      return res.status(400).json({
        message: 'All fields are required'
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const existingUser = await User.findOne({
      $or: [
        { email: normalizedEmail },
        { enrollmentNumber: enrollmentNumber.trim() }
      ]
    });

    if (existingUser) {
      return res.status(409).json({
        message: 'Email or enrollment number already registered'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      name: name.trim(),
      email: normalizedEmail,
      enrollmentNumber: enrollmentNumber.trim(),
      branch: branch.trim(),
      specialization: specialization.trim(),
      password: hashedPassword,
      role: 'student'
    });

    await user.save();

    return res.status(201).json({
      message: 'Account created successfully',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        enrollmentNumber: user.enrollmentNumber,
        branch: user.branch,
        specialization: user.specialization,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Signup error:', error.message);

    return res.status(500).json({
      message: 'Server error'
    });
  }
});

// Common login for students, faculty, and admin
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: 'Email and password are required'
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const user = await User.findOne({
      email: normalizedEmail
    });

    if (!user) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    if (user.isActive === false) {
      return res.status(403).json({
        message: 'Your account has been disabled. Contact the administrator.'
      });
    }

    const isPasswordValid = await bcrypt.compare(
      password,
      user.password
    );

    if (!isPasswordValid) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    const token = jwt.sign(
      {
        userId: user._id.toString(),
        email: user.email,
        role: user.role
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    return res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        enrollmentNumber: user.enrollmentNumber,
        branch: user.branch,
        specialization: user.specialization,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Login error:', error.message);

    return res.status(500).json({
      message: 'Server error'
    });
  }
});

module.exports = router;