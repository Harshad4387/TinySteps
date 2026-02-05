const mongoose = require("mongoose");

const MilestoneSchema = new mongoose.Schema({
  parentId: { type: mongoose.Schema.Types.ObjectId, ref: "Parent", required: true },
  milestoneType: { type: String, required: true },
  dateAchieved: { type: Date, required: true },
  notes: { type: String, default: "" }
}, { timestamps: true });

module.exports = mongoose.model("Milestone", MilestoneSchema);
