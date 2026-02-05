const mongoose = require("mongoose");

const PregnancyCareSchema = new mongoose.Schema({
  parentId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: "Parent", 
    required: true 
  },

  month: { 
    type: Number, 
    required: true 
  },

  checklist: [
    {
      item: { type: String, required: true },
      done: { type: Boolean, default: false }
    }
  ],

  testsAndScans: [
    {
      name: { type: String, required: true },   // test/scan name
      date: { type: Date, required: true }      // date of test
    }
  ]

}, { timestamps: true });

module.exports = mongoose.model("PregnancyCare", PregnancyCareSchema);
