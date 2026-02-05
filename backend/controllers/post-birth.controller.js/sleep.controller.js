const Sleep = require("../../models/sleep.model");


const addSleepEntry = async (req, res) => {
  try {
    const parentId = req.user?.id; 
    const { sleepStart, sleepEnd } = req.body;

    if (!parentId || !sleepStart || !sleepEnd) {
      return res.status(400).json({
        success: false,
        message: "parentId (from token), sleepStart, and sleepEnd are required"
      });
    }

    const entry = await Sleep.create({
      parentId,
      sleepStart,
      sleepEnd
    });

    return res.status(201).json({
      success: true,
      message: "Sleep entry added",
      data: entry
    });

  } catch (error) {
    console.error("Add Sleep Error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
      error: error.message
    });
  }
};

const getTodaySleep = async (req, res) => {
  try {
    const parentId = req.user?.id;  

    if (!parentId) {
      return res.status(400).json({
        success: false,
        message: "parentId (from token) is required"
      });
    }

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const logs = await Sleep.find({
      parentId,
      sleepStart: { $gte: startOfDay, $lte: endOfDay }
    }).sort({ sleepStart: 1 });

    const totalHours = logs.reduce((sum, log) => sum + (log.totalHours || 0), 0);

    return res.status(200).json({
      success: true,
      totalHours,
      count: logs.length,
      logs
    });

  } catch (error) {
    console.error("Today Sleep Error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal Server Server Error",
      error: error.message
    });
  }
};


const getAllSleepLogs = async (req, res) => {
  try {
    const { infantId } = req.params;

    const logs = await Sleep.find({ infantId }).sort({ sleepStart: -1 });

    return res.status(200).json({
      success: true,
      count: logs.length,
      logs
    });

  } catch (error) {
    console.error("All Sleep Logs Error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
      error: error.message
    });
  }
};




module.exports = {
  addSleepEntry,
  getTodaySleep,
  getAllSleepLogs,

};
