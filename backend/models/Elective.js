
const mongoose = require('mongoose');

const electiveSchema = new mongoose.Schema(
  {
    subjectName: {
      type: String,
      required: true,
      trim: true,
    },
    subjectCode: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      default: '',
      trim: true,
    },
    schoolId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'School',
      required: true,
    },
    department: {
      type: String,
      required: true,
      trim: true,
    },
    specialization: {
      type: String,
      default: '',
      trim: true,
    },
    academicYear: {
      type: String,
      required: true,
      enum: ['FY', 'SY', 'TY', 'LY'],
    },
    semester: {
      type: Number,
      required: true,
      min: 1,
      max: 8,
    },
    totalSeats: {
      type: Number,
      required: true,
      min: 1,
    },
    availableSeats: {
      type: Number,
      required: true,
      min: 0,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Elective', electiveSchema);