const express = require("express");
const router = express.Router();

const {
  addSleepEntry,
  getTodaySleep,
  getAllSleepLogs,

} = require("../controllers/post-birth.controller.js/sleep.controller");
const  {verifyjwt}  = require("../middleware/auth.middleware");

// Add sleep entry
router.post("/add", verifyjwt, addSleepEntry);

// Get today's sleep summary
router.get("/today", verifyjwt, getTodaySleep);


// Get all logs
router.get("/all", verifyjwt, getAllSleepLogs);

// Delete entry


module.exports = router;
