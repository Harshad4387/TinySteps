const PregnancyCare = require("../../models/pregancycare.model");

const addPregnancyData = async (req, res) => {
  try {
    const { parentId, month, checklist, testsAndScans } = req.body;

    // Validate checklist items
    if (checklist && Array.isArray(checklist)) {
      for (let item of checklist) {
        if (!item.item) {
          return res.status(400).json({
            success: false,
            message: "Each checklist item must contain an 'item' field"
          });
        }
      }
    }

    // Validate tests And scans (name + date)
    if (testsAndScans && Array.isArray(testsAndScans)) {
      for (let t of testsAndScans) {
        if (!t.name || !t.date) {
          return res.status(400).json({
            success: false,
            message: "Each test/scan must include 'name' and 'date'"
          });
        }
      }
    }

    // Check if month already exists
    const existing = await PregnancyCare.findOne({ parentId, month });

    if (existing) {
      // Update checklist
      if (checklist && checklist.length > 0) {
        existing.checklist.push(...checklist);
      }

      // Update tests & scans
      if (testsAndScans && testsAndScans.length > 0) {
        existing.testsAndScans.push(...testsAndScans);
      }

      await existing.save();

      return res.status(200).json({
        success: true,
        message: "Pregnancy data updated successfully",
        data: existing
      });
    }

    // Create new month entry
    const data = await PregnancyCare.create({
      parentId,
      month,
      checklist,
      testsAndScans
    });

    return res.status(201).json({
      success: true,
      message: "Pregnancy month data created successfully",
      data
    });

  } catch (error) {
    console.error("Add Pregnancy Error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
      error: error.message
    });
  }
};

const getAllPregnancyData = async (req, res) => {
  try {
    const { parentId } = req.query;

    if (!parentId) {
      return res.status(400).json({
        success: false,
        message: "parentId is required"
      });
    }

    const data = await PregnancyCare.find({ parentId }).sort({ month: 1 });

    return res.status(200).json({
      success: true,
      count: data.length,
      data
    });

  } catch (error) {
    console.error("Get All Pregnancy Error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
      error: error.message
    });
  }
};



// GET pregnancy data for a month
const getPregnancyByMonth = async (req, res) => {
  try {
    const { month } = req.params;
    const { parentId } = req.query;

    if (!parentId) {
      return res.status(400).json({
        success: false,
        message: "parentId is required"
      });
    }

    const data = await PregnancyCare.findOne({ parentId, month });

    if (!data) {
      return res.status(404).json({
        success: false,
        message: "Data not found for this month"
      });
    }

    return res.status(200).json({
      success: true,
      data
    });

  } catch (error) {
    console.error("Get Pregnancy Month Error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
      error: error.message
    });
  }
};


module.exports = {
  addPregnancyData,
  getAllPregnancyData,
  getPregnancyByMonth
};
