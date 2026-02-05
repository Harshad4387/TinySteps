const express = require("express");
const router = express.Router();

const {
  addPregnancyData,
  getAllPregnancyData,
  getPregnancyByMonth
} = require("../controllers/preganacycare/pre-birth.controller");

router.post("/add", addPregnancyData);
router.get("/all", getAllPregnancyData);
router.get("/month/:month", getPregnancyByMonth);

module.exports = router;
