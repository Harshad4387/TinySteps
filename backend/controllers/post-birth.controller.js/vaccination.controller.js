const VaccinationRecord = require("../../models/vaccination.model");

const addVaccination = async (req, res) => {
  try {
    // ✅ Auth check (DO NOT rely on optional chaining)
    if (!req.user || !req.user._id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const parentId = req.user._id;
    const { vaccineName, dueDate, notes = "", status } = req.body;

    // ✅ Required fields check
    if (!vaccineName || !dueDate || !status) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // ✅ Enforce valid status values (matches Flutter)
    const allowedStatus = ["Pending", "Completed", "Missed"];
    if (!allowedStatus.includes(status)) {
      return res.status(400).json({ error: "Invalid status value" });
    }

    const record = await VaccinationRecord.create({
      parentId,
      vaccineName,
      dueDate: new Date(dueDate), // ensure Date type
      notes,
      status,
    });

    return res.status(201).json({
      message: "Vaccination record added",
      record,
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ error: error.message });
  }
};

/**
 * 📥 GET ALL VACCINATIONS
 */
const getAllVaccinations = async (req, res) => {
  try {
    if (!req.user || !req.user._id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const records = await VaccinationRecord.find({
      parentId: req.user._id,
    }).sort({ dueDate: 1 });

    return res.status(200).json({
      message: "Vaccination records fetched",
      records,
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

/**
 * 📅 GET TODAY'S VACCINATIONS
 */
const getTodayVaccinations = async (req, res) => {
  try {
    if (!req.user || !req.user._id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const parentId = req.user._id;

    // ✅ Correct date range for "today"
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const records = await VaccinationRecord.find({
      parentId,
      dueDate: {
        $gte: startOfDay,
        $lte: endOfDay,
      },
      status: "Pending", // 👈 matches Flutter logic
    }).sort({ dueDate: 1 });

    return res.status(200).json({
      message: "Today's vaccinations fetched",
      records,
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

module.exports = {
  addVaccination,
  getAllVaccinations,
  getTodayVaccinations,
};
