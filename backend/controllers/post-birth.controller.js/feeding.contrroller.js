const FeedingSchedule = require("../../models/feeding.model");
const Reminder = require("../../models/Reminder.model");

// ADD FEEDING SCHEDULE
const addFeedingSchedule = async (req, res) => {
  try {
    const parentId = req.user?._id; 
    const { type, quantity, notes, isRecurring, times } = req.body;

    if (!parentId || !type || !quantity || !times) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const schedule = await FeedingSchedule.create({
      parentId,
      type,
      quantity,
      notes,
      isRecurring,
      times
    });

    res.status(201).json({
      message: "Feeding schedule added successfully",
      schedule
    });

  } catch (err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
};




const getTodayFeeding = async (req, res) => {
  console.log(req.body);
  try {
    const parentId = req.user?._id;

    if (!parentId) {
      return res.status(400).json({ error: "Missing parentId" });
    }

    // Fetch all feeding schedules for this parent
    const schedules = await FeedingSchedule.find({
      parentId,
      isRecurring: true
    });

    if (!schedules.length) {
      return res.status(200).json([]);
    }

    const today = new Date();
    const yyyy = today.getFullYear();
    const mm = String(today.getMonth() + 1).padStart(2, "0");
    const dd = String(today.getDate()).padStart(2, "0");

    const todayFeedingList = [];

    for (const schedule of schedules) {
      for (const timeString of schedule.times) {
        const reminderDate = new Date(`${yyyy}-${mm}-${dd}T${timeString}:00`);

        // Check duplicate reminder
        const exists = await Reminder.findOne({
          parentId,
          infantId: schedule.infantId,   // each schedule still belongs to an infant
          type: "feeding",
          reminderTime: reminderDate
        });

        // Create only if not exists
        if (!exists) {
          await Reminder.create({
            parentId,
            infantId: schedule.infantId,
            type: "feeding",
            title: `Feeding Time - ${schedule.type}`,
            reminderTime: reminderDate,
            status: "active"
          });
        }

        // Add to response
        todayFeedingList.push({
          infantId: schedule.infantId,  // identify which baby
          time: reminderDate,
          type: schedule.type,
          quantity: schedule.quantity,
          notes: schedule.notes
        });
      }
    }

    res.status(200).json(todayFeedingList);

  } catch (err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
};

module.exports = {
  addFeedingSchedule,
  getTodayFeeding
};