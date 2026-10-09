
require('dotenv').config();
const mongoose = require('mongoose');
const School = require('./models/School');

const schools = [
  {
    name: 'School of Computing',
    description: 'School of Computing',
  },
  {
    name: 'School of Drama',
    description: 'School of Drama',
  },
  {
    name: 'School of Engineering',
    description: 'School of Engineering',
  },
  {
    name: 'School of Food and Technology',
    description: 'School of Food and Technology',
  },
];

async function seedSchools() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB connected successfully');

    for (const school of schools) {
      await School.updateOne(
        { name: school.name },
        { $setOnInsert: school },
        { upsert: true }
      );
    }

    console.log('Initial schools added successfully.');
    console.log('Existing schools were preserved.');
  } catch (error) {
    console.error('Failed to add schools:', error.message);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
}

seedSchools();