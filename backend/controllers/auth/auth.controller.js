const Parent = require("../../models/parent.model");
const bcrypt = require("bcrypt");
const generatejwt = require("../../utils/generatetoken");
const sendWelcomeMail = require("../../utils/welcomemail");

const registerParent = async (req, res) => {
  try {
    const {
      motherName,
      motherEmail,
      fatherName,
      fatherEmail,
      phoneNumber,
      password,
      role
    } = req.body;

    if (!motherEmail) {
      return res.status(400).json({
        success: false,
        message: "Mother email is required."
      });
    }

    const existingMother = await Parent.findOne({ motherEmail });
    if (existingMother) {
      return res.status(400).json({
        success: false,
        message: "Mother email already registered."
      });
    }

    const existingPhone = await Parent.findOne({ phoneNumber });
    if (existingPhone) {
      return res.status(400).json({
        success: false,
        message: "Phone number already registered."
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newParent = new Parent({
      motherName,
      motherEmail,
      fatherName,
      fatherEmail: fatherEmail || null,
      phoneNumber,
      password: hashedPassword,
      role
    });

    await newParent.save();

    // 📧 SEND WELCOME EMAIL HERE
    // await sendWelcomeMail({
    //   parent: {
    //     name: motherName,
    //     email: motherEmail
    //   }
    // });

    return res.status(201).json({
      success: true,
      message: "Parent registered successfully!",
      parentId: newParent._id
    });

  } catch (error) {
    console.error("Register Error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal Server Error."
    });
  }
};

const loginParent = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required."
      });
    }

    // Find parent by mother or father email
    const parent = await Parent.findOne({
      $or: [{ motherEmail: email }, { fatherEmail: email }]
    });

    if (!parent) {
      return res.status(404).json({
        success: false,
        message: "Parent not found."
      });
    }

    // Compare password
    const isMatch = await bcrypt.compare(password, parent.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Incorrect password."
      });
    }

    // Generate JWT
    const token = generatejwt(parent._id);
    // Success response
    return res.status(200).json({
      success: true,
      message: "Login successful!",
      token,
      parent: {
        id: parent._id,
        motherName: parent.motherName,
        fatherName: parent.fatherName,
        motherEmail: parent.motherEmail,
        fatherEmail: parent.fatherEmail,
        phoneNumber: parent.phoneNumber,
        role: parent.role
      }
    });

  } catch (error) {
    console.error("Login Error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal Server Error"
    });
  }
};

const authenticated = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: "User is authenticated",
      user: req.user   // comes from your verifyjwt middleware
    });
  } catch (error) {
    console.error("Authenticated Controller Error:", error.message);

    return res.status(500).json({
      success: false,
      message: "Internal server error"
    });
  }
};

module.exports = {
  registerParent,
  loginParent,
  authenticated
};
