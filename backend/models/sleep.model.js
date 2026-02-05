const mongoose = require("mongoose");

const SleepSchema = new mongoose.Schema(
  {
    parentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    sleepStart: {
      type: Date,
      required: true
    },
    sleepEnd: {
      type: Date,
      required: true
    },
    totalHours: {
      type: Number
    }
  },
  { timestamps: true }
);

// ✅ Auto-calc totalHours before saving (NO next)
SleepSchema.pre("save", function () {
  if (this.sleepStart && this.sleepEnd) {
    const diffMs = this.sleepEnd - this.sleepStart;
    this.totalHours = Number(
      (diffMs / (1000 * 60 * 60)).toFixed(2)
    );
  }
});

module.exports = mongoose.model("Sleep", SleepSchema);
