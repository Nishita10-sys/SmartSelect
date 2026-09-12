const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();

// Signup
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

    const existingUser = await User.findOne({
      $or: [
        { email: email.toLowerCase() },
        { enrollmentNumber: enrollmentNumber }
      ]
    });

    if (existingUser) {
      return res.status(409).json({
        message: 'Email or enrollment number already registered'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      name,
      email: email.toLowerCase(),
      enrollmentNumber,
      branch,
      specialization,
      password: hashedPassword
    });

    await user.save();

    res.status(201).json({
      message: 'Account created successfully',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        enrollmentNumber: user.enrollmentNumber,
        branch: user.branch,
        specialization: user.specialization
      }
    });
  } catch (error) {
    console.error('Signup error:', error.message);

    res.status(500).json({
      message: 'Server error'
    });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: 'Email and password are required'
      });
    }

    const user = await User.findOne({
      email: email.toLowerCase()
    });

    if (!user) {
      return res.status(401).json({
        message: 'Invalid email or password'
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
        userId: user._id,
        email: user.email
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        enrollmentNumber: user.enrollmentNumber,
        branch: user.branch,
        specialization: user.specialization
      }
    });
  } catch (error) {
    console.error('Login error:', error.message);

    res.status(500).json({
      message: 'Server error'
    });
  }
});

module.exports = router;