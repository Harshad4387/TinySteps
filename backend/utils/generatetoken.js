const jwt = require("jsonwebtoken");   // ADD THIS LINE

const generatejwt = (userid) => {
  return jwt.sign(
    { userid },
    process.env.JWT_TOKEN_SECERT, 
    { expiresIn: process.env.JWT_TOKEN_EXPIRY || "7d" }
  );
};

module.exports = generatejwt;
