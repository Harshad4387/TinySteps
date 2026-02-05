const Milestone = require("../../models/milestone.model");


// ADD MILESTONE (parent-based)
const addMilestone = async (req, res) => {
  try {
    const parentId = req.user?._id;
    const { milestoneType, dateAchieved, notes } = req.body;

    if (!parentId || !milestoneType || !dateAchieved) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const milestone = await Milestone.create({
      parentId,
      milestoneType,
      dateAchieved,
      notes
    });

    return res.status(201).json({
      message: "Milestone added successfully",
      milestone
    });

  } catch (error) {
    console.log(error);
    return res.status(500).json({ error: error.message });
  }
};



// GET all milestones for a parent
const getAllMilestones = async (req, res) => {
  try {
    const parentId = req.user?._id;

    if (!parentId) {
      return res.status(400).json({ error: "Missing parentId" });
    }

    const milestones = await Milestone.find({ parentId })
      .sort({ dateAchieved: 1 });

    return res.status(200).json({
      message: "Milestones fetched successfully",
      milestones
    });

  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};


module.exports = { addMilestone, getAllMilestones };
