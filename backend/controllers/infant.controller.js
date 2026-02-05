const Infant = require("../models/infant.model");

const addInfant = async (req, res) => {
  try {
    const parentId = req.user._id; 

    const {
      name,
      dateOfBirth,
      gender,
      bloodGroup,
      birthWeight,
      currentWeight
    } = req.body;

    if (!name || !dateOfBirth) {
      return res.status(400).json({
        success: false,
        message: "Name and date of birth are required."
      });
    }
    const newInfant = new Infant({
      parentId,
      name,
      dateOfBirth,
      gender,
      bloodGroup,
      birthWeight,
      currentWeight
    });

    await newInfant.save();

    return res.status(201).json({
      success: true,
      message: "Infant added successfully",
      infant: newInfant
    });

  } catch (error) {
    console.error("Add Infant Error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
      error: error.message
    });
  }
};


const getMyInfants = async (req, res) => {
  try {
    const parentId = req.user._id;

    const infants = await Infant.find({ parentId }).sort({ createdAt: -1 });

    return res.status(200).json(infants);
  } catch (error) {
    return res.status(500).json({ message: "Server error" });
  }
};



module.exports = { addInfant , getMyInfants};

