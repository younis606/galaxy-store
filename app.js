const express = require('express');
const mongoose = require('mongoose');
const planetsRoute = require('./routes/planets');

const app = express();
app.use(express.json());

mongoose.connect(process.env.MONGO_URI, {
  user: process.env.MONGO_USERNAME,
  pass: process.env.MONGO_PASSWORD,
  dbName: 'superData'
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.error(err));

app.use('/planets', planetsRoute);

app.listen(3000, () => console.log('Server running on port 3000'));

module.exports = app;
