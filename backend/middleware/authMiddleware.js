
const jwt = require('jsonwebtoken');

function verifyToken(req, res, next) {
  const authorization = req.headers.authorization;

  if (!authorization || !authorization.startsWith('Bearer ')) {
    return res.status(401).json({
      message: 'Authentication required',
    });
  }

  const token = authorization.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      message: 'Invalid or expired token',
    });
  }
}

function requireAdmin(req, res, next) {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({
      message: 'Admin access required',
    });
  }

  next();
}

function requireFaculty(req, res, next) {
  if (req.user?.role !== 'faculty') {
    return res.status(403).json({
      message: 'Faculty access required',
    });
  }

  next();
}

module.exports = {
  verifyToken,
  requireAdmin,
  requireFaculty,
};