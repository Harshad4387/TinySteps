const express = require("express");
const router = express.Router();

const { addFeedingSchedule, getTodayFeeding } =
  require("../controllers/post-birth.controller.js/feeding.contrroller");
const { verifyjwt } = require("../middleware/auth.middleware");

router.post("/add", verifyjwt, addFeedingSchedule);
router.get("/today",verifyjwt, getTodayFeeding);

module.exports = router;