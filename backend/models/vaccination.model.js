const mongoose = require("mongoose");
const VaccinationRecordSchema = new mongoose.Schema({
  parentId: { type: mongoose.Schema.Types.ObjectId, ref: "Parent", required: true },
  vaccineName: { type: String, required: true },
  dueDate: { type: Date, required: true },
  completedDate: { type: Date },
  status: { type: String, enum: ["Pending", "Completed", "Missed"], required: true },
  notes: String
}, { timestamps: true });

module.exports = mongoose.model("VaccinationRecord", VaccinationRecordSchema);
