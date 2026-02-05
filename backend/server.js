require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const connect = require('./database/db');
const app = express();
const cors = require("cors");
app.use(cors());
app.use(express.json());
app.use(express.urlencoded());
app.use(morgan('dev'));
connect();

app.get('/', async(req,res)=>{
    res.status(200).send("server is running fine ~ made by harshu added cron");
})

const auth = require("./routes/auth.route");
app.use("/api/tinysteps/auth",auth);


const cron = require("node-cron");
const axios = require("axios");


const pregnancy = require("./routes/pregrancy-birth.route");
app.use("/api/tinysteps/pregnancy",pregnancy);

const vaccinationMailRoute = require("./routes/mail.route");
app.use("/api/tinysteps/vaccination-mail", vaccinationMailRoute);


const sleep = require("./routes/sleep.route");
app.use("/api/tinysteps/sleep",sleep);

const feeding = require("./routes/feeding.route");
app.use("/api/tinysteps/feeding",feeding);


const reminder = require("./routes/reminders.route");
app.use("/api/tinysteps/reminder",reminder);

const infant = require("./routes/infant.route");
app.use("/api/tinysteps/infant",infant);

const productRoutes = require("./routes/product.routes");
app.use("/api/products", productRoutes);



const milestone = require("./routes/milestone.route");
app.use("/api/tinysteps/milestone",milestone);

const Vaccination = require("./routes/vaccination.route");
app.use("/api/tinysteps/vaccination",Vaccination);

const medicine = require("./routes/medical.route");
app.use("/api/tinysteps/medicine" , medicine);

const port = process.env.PORT;
app.listen(port,(req,res)=>{
    console.log(`server is running on port ${port}`);
})

