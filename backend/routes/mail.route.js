const express = require("express");
const router = express.Router();

const { sendVaccinationScheduledMail } = require("../controllers/sendmail.controller");

router.get("/send", sendVaccinationScheduledMail);

module.exports = router;
