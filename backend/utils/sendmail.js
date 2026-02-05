const nodemailer = require("nodemailer");

const sendMail = async ({ to, subject, text, html }) => {
  try {
    let transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL,
        pass: process.env.PASS,
      },
    });

    let info = await transporter.sendMail({
      from: `Vaccination Reminder <${process.env.EMAIL}>`,
      to,
      subject,
      text,
      html,
    });

    console.log("✅ Mail sent:", info.messageId);
    return info;
  } catch (err) {
    console.error("❌ Mail error:", err);
    throw err;
  }
};

module.exports = { sendMail };
