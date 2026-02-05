const { sendMail } = require("../utils/sendmail");

const sendVaccinationScheduledMail = async (req, res) => {
  try {
    const { email, vaccineName, dueDate, childName } = req.query;

    if (!email || !vaccineName || !dueDate) {
      return res.status(400).json({
        success: false,
        message: "email, vaccineName, dueDate are required in query",
      });
    }

    const formattedDate = new Date(dueDate).toDateString();

    const subject = `💉 Vaccination Scheduled: ${vaccineName}`;

    const text = `Vaccination Reminder: ${vaccineName} is scheduled on ${formattedDate}.`;

    const html = `
      <div style="font-family: Arial, sans-serif; padding: 20px; background:#f7f7f7;">
        <div style="max-width: 650px; margin:auto; background:white; padding: 25px; border-radius: 12px;">

          <h1 style="margin:0; color:#2c3e50;">💉 TinySteps Vaccination Reminder</h1>
          <p style="color:#555; font-size:15px;">
            Hello Parent,
          </p>

          <p style="font-size:16px; color:#333;">
            This is a confirmation that the following vaccination has been <b>scheduled</b>.
          </p>

          <div style="padding: 15px; background:#f0f8ff; border-radius:10px; border:1px solid #d6eaff;">
            <p style="margin:6px 0;"><b>Child Name:</b> ${childName || "Your Baby"}</p>
            <p style="margin:6px 0;"><b>Vaccine:</b> ${vaccineName}</p>
            <p style="margin:6px 0;"><b>Scheduled Date:</b> ${formattedDate}</p>
          </div>

          <h3 style="margin-top:22px; color:#2c3e50;">📌 Important Notes</h3>
          <ul style="color:#444; line-height:22px;">
            <li>Please ensure your baby is healthy on the day of vaccination.</li>
            <li>Carry previous vaccination records if available.</li>
            <li>If your baby has fever, consult your pediatrician before vaccination.</li>
            <li>After vaccination, mild fever or swelling is normal in some cases.</li>
          </ul>

          <p style="margin-top:18px; color:#555;">
            If you have any questions, please contact your doctor or visit the nearest clinic.
          </p>

          <hr style="margin:25px 0; border:none; border-top:1px solid #eee;" />

          <p style="font-size:13px; color:#888;">
            This reminder was sent by <b>TinySteps</b>.  
            Please do not reply to this email.
          </p>

        </div>
      </div>
    `;

    await sendMail({
      to: email,
      subject,
      text,
      html,
    });

    return res.status(200).json({
      success: true,
      message: "Vaccination scheduled mail sent successfully",
      email,
      vaccineName,
      dueDate: formattedDate,
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: "Error while sending mail",
      error: err.message,
    });
  }
};

module.exports = { sendVaccinationScheduledMail };
