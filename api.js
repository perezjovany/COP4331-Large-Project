require('express');
require('mongodb');
const axios = require('axios')
const jwt = require('jsonwebtoken')

//load user model
const User = require("./models/user.js");

//JWT
const jwtKey = process.env.JWT_SECRET
const app_id = process.env.EDAMAM_ID
const app_key = process.env.EDAMAM_KEY
const default_limit = process.env.DEFAULT_AUTO_COMPLETE_LIMIT || 5

exports.setApp = function ( app, client )
{
  // Middleware to authenticate the JWT token
  function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (token == null) {
      return res.status(401).json({ error: 'MISSING AUTHORIZATION HEADER' });
    }

    jwt.verify(token, jwtKey, (err, user) => {
      if (err) {
        console.error('Invalid token:', err);
        return res.status(403).json({ error: 'INVALID TOKEN' });
      }

      // Valid token, add the user data to the request object
      req.user = user;
      next();
    });
  }

  // Custom error handling middleware
  function handleError(error, res) {
    console.error('Error occurred:', error);

    if (error.name === 'ValidationError') {
      // Mongoose validation error with 400 status
      return res.status(400).json({ error: 'Validation Error', message: error.message });
    }

    if (error.name === 'MongoError') {
      // MongoDB related error with 500 status
      return res.status(500).json({ error: 'Database Error', message: 'A database error occurred' });
    }

    if (error.response && error.response.status === 401) {
      // Unauthorized response with 401 status
      return res.status(401).json({ error: 'Unauthorized Access', message: 'You are not authorized to access this resource' });
    }

    // Handle other specific error cases here

    // Generic error message for unhandled errors
    res.status(500).json({ error: 'Internal Server Error', message: 'An unexpected error occurred' });
  }

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
      console.error('Error occurred:', error);  
      handleError(error, res)
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
      console.error('Error occurred:', error);  
      handleError(error, res)
    }
  });

  // Endpoint URL: /api/parser
  // HTTP Method: POST
  app.post('/api/parser', authenticateToken, async (req, res, next) => {
    try {
      // incoming: ing/upc, nutrition_type
      // outgoing: text, foodResults, nextPage
  
      const { ing, upc, nutrition_type } = req.body; // Update the destructuring
  
      var apiUrl = `https://api.edamam.com/api/food-database/v2/parser?app_id=${app_id}&app_key=${app_key}`;
  
      if (ing) {
        apiUrl += `&ingr=${ing}`; // Append 'ingr' parameter if 'ing' is provided
      } else if (upc) {
        apiUrl += `&upc=${upc}`; // Append 'upc' parameter if 'upc' is provided
      } else {
        return res.status(400).json({ error: 'Missing required parameter' });
      }
  
      apiUrl += `&nutrition-type=${nutrition_type}`;
  
      const response = await axios.get(apiUrl);
  
      const text = response.data.text;
      const foodResults = response.data.hints || [];
      const nextPage = response.data._links || null;
  
      const formattedResponse = {
        text: text,
        foodResults: foodResults,
        nextPage: nextPage,
      };
  
      // Successful response with 200 status
      res.status(200).json(formattedResponse);
    } catch (error) {
      console.error('Error occurred:', error);  
      handleError(error, res)
    }
  });

  // Endpoint URL: /api/manual_search
  // HTTP Method: POST
  app.post('/api/manual_search', authenticateToken, async (req, res, next) => {
    try {
      // incoming: q, limit (optional)
      // outgoing: suggestions

      const { q } = req.body;

      if (!q) {
        return res.status(400).json({ error: "Missing required parameter 'q'" });
      }

      const apiUrl = `https://api.edamam.com/auto-complete?app_id=${app_id}&app_key=${app_key}&q=${encodeURIComponent(
        q
      )}`;

      const response = await axios.get(apiUrl);

      const suggestions = response.data || [];

      // Successful response with 200 status
      res.status(200).json(suggestions);
    } catch (error) {
      console.error('Error occurred:', error);  
      handleError(error, res)
    }
  });
}