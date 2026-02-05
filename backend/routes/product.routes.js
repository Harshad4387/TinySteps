// routes/product.routes.js
const express = require("express");
const router = express.Router();
const { getRecommendedProducts } = require("../controllers/product.controller");

router.get("/recommendations", getRecommendedProducts);

module.exports = router;
