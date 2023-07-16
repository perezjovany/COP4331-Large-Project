require('express');
require('mongodb');
const axios = require('axios')
const jwt = require('jsonwebtoken')

//load user model
const User = require("./models/user.js");

//JWT
const jwtKey = "8E9785A572443B71F4A15591F6B56" // TODO: store key as env variable

exports.setApp = function ( app, client )
{
  // Endpoint URL: /api/signup
  // HTTP Method: POST
  app.post('/api/signup', async (req, res, next) => {
    try {
      // incoming: firstName, lastName, login, password, email, phone
      // outgoing: error

      const { firstName, lastName, login, password, email, phone } = req.body;

      // Input Validation
      if (!firstName || !lastName || !login || !password || !email || !phone) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      // Unique User Check
      const existingUser = await User.findOne({ $or: [{ login: login }, { email: email }] });
      if (existingUser) {
        return res.status(409).json({ error: 'User with this login or email already exists' });
      }

      const newUser = new User({
        firstName: firstName,
        lastName: lastName,
        login: login,
        password: password,
        email: email,
        phone: phone
      });

      await newUser.save();

      // Successful response with 200 status
      res.status(200).json({ error: '' });
    } catch (error) {
      // Error Handling
      console.error('Error occurred:', error);

      if (error.name === 'ValidationError') {
        // Mongoose validation error with 400 status
        return res.status(400).json({ error: error.message });
      }

      if (error.name === 'MongoError') {
        // MongoDB related error with 500 status
        return res.status(500).json({ error: 'Database error' });
      }

      // For other unhandled errors with 500 status
      res.status(500).json({ error: 'Something went wrong' });
    }
  });

  
  // Endpoint URL: /api/login
  // HTTP Method: POST
  app.post('/api/login', async (req, res, next) => {
    try {
      // incoming: login, password
      // outgoing: userId, firstName, lastName, email, phone, token, error
  
      const { login, password } = req.body;
  
      // Input Validation
      if (!login || !password) {
        return res.status(400).json({ error: 'MISSING USERNAME OR PASSWORD' });
      }
  
      const results = await User.find({ login, password });
  
      let response = {
        error: ''
      };
  
      if (results.length > 0) {
        const { userId, firstName, lastName, email, phone } = results[0];
        const jwtToken = jwt.sign({ id: userId }, jwtKey);
  
        response = {
          userId,
          firstName,
          lastName,
          email,
          phone,
          token: jwtToken,
          error: ''
        };
  
        // Successful response with 200 status
        res.status(200).json(response);
      } else {  
        // Unauthorized response with 401 status
        res.status(401).json({ error: 'INCORRECT USERNAME/PASSWORD'});
      }
    } catch (error) {
      // Error Handling
      console.error('Error occurred:', error);
  
      if (error.name === 'MongoError') {
        // MongoDB related error with 500 status
        return res.status(500).json({ error: 'DATABASE ERROR' });
      }
  
      // For other unhandled errors with 500 status
      res.status(500).json({ error: 'SOMETHING WENT WRONG' });
    }
  });

  app.get('/api/parser', async (req, res, next) => 
  {
    // incoming: app_id, app_key, ing, nutrition_type
    // outgoing: {text,
    //            parsed[{food{foodId, label, knownAs, nutrients{ENERC_KCAL, PROCNT, FAT, CHOCDF, FIBTG}, category, categoryLabel, image}],
    //            hints[{food{foodId, label, knownAs, nutrients{ENERC_KCAL, PROCNT, FAT, CHOCDF, FIBTG}, category, categoryLabel, image},
    //                   measures[{uri, label, weight, qualified[{qualifiers[{uri, label}], weight}]?}]}}],
    //            _links{next{title, href}}}
    const { app_id, app_key, ing, nutrition_type } = req.body;

    const apiUrl = `https://api.edamam.com/api/food-database/v2/parser?app_id=${app_id}&app_key=${app_key}&ingr=${ing}&nutrition-type=${nutrition_type}`;

    try {
      const response = await axios.get(apiUrl);

      res.json(response.data);
    } catch (error) {
      if (error.response && error.response.status === 401) {
        // Handle the "Unauthorized" error
        console.error('Unauthorized: Invalid credentials');
        return res.status(401).json({ error: 'Unauthorized: Invalid credentials' });
      }

      console.error('Error response:', error.response.data);
      next(error);
    }
  });
}