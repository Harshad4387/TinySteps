const mongoose = require("mongoose");

const ParentSchema = new mongoose.Schema({
  motherName: { type: String, required: true },
  motherEmail: { type: String, required: true },     

  fatherName: { type: String },
  fatherEmail: { type: String, required: false },    

  phoneNumber: { type: String, required: true },
  password: { type: String, required: true },

  role: { type: String, enum: ["mother", "father"], required: true },

  infants: [{ type: mongoose.Schema.Types.ObjectId, ref: "Infant" }],
}, { timestamps: true });

module.exports = mongoose.model("Parent", ParentSchema);
