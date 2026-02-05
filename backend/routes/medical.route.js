const express = require("express");
const { searchMedicine } = require("../controllers/medical.controller");

const router = express.Router();

router.get("/search", searchMedicine);

module.exports = router;
