const nodemailer = require('nodemailer');

const sendFeedingReminderMail = async ({ parent, infant, feedingTime }) => {
  try {
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    const htmlContent = `
      <h2>⏰ Feeding Reminder</h2>

      <p>Hello <strong>${parent.name}</strong>,</p>

      <p>This is a gentle reminder that it’s time for <strong>${infant.name}</strong>'s feeding.</p>

      <p><strong>Scheduled Time:</strong> ${feedingTime}</p>

      <p>Keeping consistent feeding times helps your baby grow strong and healthy. 💙</p>

      <p>Take a deep breath — you're doing an amazing job as a parent! 🌼</p>
    `;

    await transporter.sendMail({
      from: `"TinySteps" <${process.env.EMAIL_USER}>`,
      to: parent.email,
      subject: `Feeding Reminder for ${infant.name} ⏰`,
      html: htmlContent
    });

    console.log(`📧 Feeding reminder sent to ${parent.email}`);
  } catch (error) {
    console.error("❌ Failed to send feeding reminder email:", error);
  }
};

module.exports = sendFeedingReminderMail;
