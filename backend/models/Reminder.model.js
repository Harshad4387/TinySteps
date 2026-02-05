const mongoose = require("mongoose");
const ReminderSchema = new mongoose.Schema({
  parentId: { type: mongoose.Schema.Types.ObjectId, ref: "Parent", required: true },
  infantId: { type: mongoose.Schema.Types.ObjectId, ref: "Infant" },
  type: { type: String, required: true },     // feeding, sleep, vaccination
  title: { type: String, required: true },
  reminderTime: { type: Date, required: true },
  status: { type: String, enum: ["active", "completed"], default: "active" }
}, { timestamps: true });

module.exports = mongoose.model("Reminder", ReminderSchema);
