const router = require("express").Router();
const {
  addVaccination,
  getAllVaccinations,
  getTodayVaccinations
} = require("../controllers/post-birth.controller.js/vaccination.controller");

const  {verifyjwt}  = require("../middleware/auth.middleware");

router.post("/add", verifyjwt, addVaccination);
router.get("/all",verifyjwt, getAllVaccinations);

router.get("/today", getTodayVaccinations);

module.exports = router;
