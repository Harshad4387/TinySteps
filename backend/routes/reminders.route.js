const express = require("express");
const router = express.Router();

const {
  getTodaysReminders,
 
} = require("../controllers/post-birth.controller.js/reminder.conrtoller");

router.get("/today/:parentId", getTodaysReminders);


module.exports = router;
