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

  app.post('/api/signup', async (req, res, next) =>
  {
    // incoming: firstName, lastName, login, password, email, phone
    // outgoing: error
    
    const { FirstName, LastName, Login, Password, Email, Phone } = req.body;

    const newUser = new User({ firstName: FirstName, lastName: LastName, login: Login, password: Password, email: Email, phone: Phone });
    var error = '';
    
    try 
    {
      newUser.save();
    }
    catch(e)
    {
      error = e.toString();
    }

    var ret = { error: error };
    res.status(200).json(ret);
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
        return res.status(400).json({ error: 'Missing login or password' });
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
        response = {
          error: 'Invalid credentials'
        };
  
        // Unauthorized response with 401 status
        res.status(401).json(response);
      }
    } catch (error) {
      // Error Handling
      console.error('Error occurred:', error);
  
      if (error instanceof jwt.JsonWebTokenError) {
        // JWT verification error with 401 status
        return res.status(401).json({ error: 'Invalid token' });
      }
  
      if (error.name === 'MongoError') {
        // MongoDB related error with 500 status
        return res.status(500).json({ error: 'Database error' });
      }
  
      // For other unhandled errors with 500 status
      res.status(500).json({ error: 'Something went wrong' });
    }
  });

  const axios = require('axios');

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