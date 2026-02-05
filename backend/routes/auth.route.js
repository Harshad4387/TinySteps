const express = require("express");
const router = express.Router();
const {  registerParent, loginParent ,authenticated} = require("../controllers/auth/auth.controller");
const { verifyjwt } = require("../middleware/auth.middleware");

router.post("/login", loginParent);
router.post("/register" ,registerParent);
router.post("/authenticated" , verifyjwt , authenticated);

module.exports = router;