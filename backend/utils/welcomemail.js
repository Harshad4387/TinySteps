const nodemailer = require('nodemailer');

const sendWelcomeMail = async ({ parent }) => {
  try {
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    const htmlContent = `
      <h2>Welcome to TinySteps 👶✨</h2>
      <p>Hello <strong>${parent.name}</strong>,</p>

      <p>Thank you for registering on <strong>TinySteps</strong>.</p>

      <p>We are excited to join you on this beautiful journey of parenting!</p>

      <p>Inside the app, you can:</p>
      <ul>
        <li>Track baby growth & milestones</li>
        <li>Get feeding reminders</li>
        <li>Record health & vaccination details</li>
        <li>Access customized tips for baby care</li>
      </ul>

      <p style="margin-top:15px;">Let’s grow together, one tiny step at a time! 💙</p>
    `;

    await transporter.sendMail({
      from: `"TinySteps" <${process.env.EMAIL_USER}>`,
      to: parent.email,
      subject: "Welcome to TinySteps 👶",
      html: htmlContent
    });

    console.log(`📧 Welcome email sent to ${parent.email}`);
  } catch (error) {
    console.error("❌ Failed to send welcome email:", error);
  }
};

module.exports = sendWelcomeMail;
