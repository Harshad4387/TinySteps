const Reminder = require("../../models/Reminder.model");

const getTodaysReminders = async (req, res) => {
  try {
    const { parentId } = req.params;

    const startOfDay = new Date();
    startOfDay.setUTCHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setUTCHours(23, 59, 59, 999);

    const reminders = await Reminder.find({
      parentId,
      reminderTime: { $gte: startOfDay, $lte: endOfDay },
      status: "active",
    }).sort({ reminderTime: 1 });

    res.status(200).json(reminders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { getTodaysReminders };


