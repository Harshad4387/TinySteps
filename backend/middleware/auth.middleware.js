const jwt = require("jsonwebtoken");
const Parent = require("../models/parent.model.js");

const verifyjwt = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
    
      return res.status(401).json({ message: "Unauthorized - No token provided" });
    }

    const token = authHeader.split(" ")[1];
   
    const decoded = jwt.verify(token, process.env.JWT_TOKEN_SECERT);

    const user = await Parent.findById(decoded.userid).select("-password");

    if (!user) {
      return res.status(404).json({ message: "Parent not found" });
    }

    req.user = user;
    next();

  } catch (error) {
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({ message: "Token expired, please login again" });
    }

    return res.status(401).json({ message: "Invalid token" });
  }
};

module.exports = { verifyjwt };
