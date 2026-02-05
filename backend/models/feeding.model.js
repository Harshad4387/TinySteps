const mongoose = require("mongoose");

const FeedingScheduleSchema = new mongoose.Schema({
  parentId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: "Parent", 
    required: true 
  },


  type: { type: String, required: true },
  quantity: { type: Number, required: true },
  notes: { type: String, default: "" },

  isRecurring: { type: Boolean, default: true },

  // multiple feeding times in HH:mm format for daily schedule
  times: [{ type: String, required: true }]
}, 
{ timestamps: true }
);

const FeedingSchedule = mongoose.model("FeedingSchedule", FeedingScheduleSchema);
module.exports = FeedingSchedule;