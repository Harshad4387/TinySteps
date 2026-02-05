const mongoose = require("mongoose");

const connect = async () => {
  try {
    await mongoose.connect(`${process.env.MONGO_URL}/tinysteps`);
    console.log("✅ MongoDB connected successfully");
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
    process.exit(1);
  }
};

module.exports = connect;
