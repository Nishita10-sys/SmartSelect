
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const facultyRoutes = require('./routes/facultyRoutes');
const electiveRoutes = require('./routes/electiveRoutes');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const schoolRoutes = require('./routes/schoolRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/schools', schoolRoutes);
app.use('/api/faculty', facultyRoutes);
app.use('/api/electives', electiveRoutes);

app.get('/', (req, res) => {
  res.json({
    message: 'SmartSelect Backend is running',
  });
});

const PORT = process.env.PORT || 5000;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected successfully');

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((error) => {
    console.error('MongoDB connection failed:', error.message);
  });