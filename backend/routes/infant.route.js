const express = require("express");
const router = express.Router();

const {addInfant ,getMyInfants} = require("../controllers/infant.controller");

const {verifyjwt} = require("../middleware/auth.middleware");
router.get("/my", verifyjwt, getMyInfants);
router.post("/add",verifyjwt ,addInfant);

module.exports = router;
