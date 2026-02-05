const nodemailer = require('nodemailer');

const sendGeneralAlertMail = async ({ parent, title, message }) => {
  try {
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    const htmlContent = `
      <h2>${title}</h2>

      <p>Hello <strong>${parent.name}</strong>,</p>

      <p>${message}</p>

      <p style="margin-top:10px;">Warm regards,<br><strong>TinySteps Team</strong></p>
    `;

    await transporter.sendMail({
      from: `"TinySteps" <${process.env.EMAIL_USER}>`,
      to: parent.email,
      subject: title,
      html: htmlContent
    });

    console.log(`📧 General alert email sent to ${parent.email}`);
  } catch (error) {
    console.error("❌ Failed to send alert email:", error);
  }
};

module.exports = sendGeneralAlertMail;
