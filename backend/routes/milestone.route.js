const router = require("express").Router();
const {
  addMilestone,
  getAllMilestones
} = require("../controllers/post-birth.controller.js/milestone.controller");
const { verifyjwt } = require("../middleware/auth.middleware");


router.post("/add", verifyjwt, addMilestone);
router.get("/all", verifyjwt, getAllMilestones);


module.exports = router;
