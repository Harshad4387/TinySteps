const mongoose = require("mongoose");
const InfantSchema = new mongoose.Schema({
  parentId: { type: mongoose.Schema.Types.ObjectId, ref: "Parent", required: true },
  name: { type: String, required: true },
  dateOfBirth: { type: Date, required: true },
  gender: { type: String },
  bloodGroup: { type: String },
  birthWeight: { type: Number },
  currentWeight: { type: Number },
}, { timestamps: true });

module.exports = mongoose.model("Infant", InfantSchema);
