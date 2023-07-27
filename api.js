require('express');
require('mongodb');
const axios = require('axios');
const jwt = require('jsonwebtoken');

//Environment ENV
const environment = process.env.ENVIRONMENT

// Import the required models
const User = require("./models/user.js");
const List = require("./models/list.js");
const ListItem = require("./models/listItem.js");
const FridgeItem = require("./models/fridgeItem.js");

//JWT
const jwtKey = process.env.JWT_SECRET
const app_id = process.env.EDAMAM_ID
const app_key = process.env.EDAMAM_KEY

//Email
const nodemailer = require("nodemailer");
const apiPort = process.env.PORT || 5000;
const emailTransport = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: 'kitchenpal.cop4331@gmail.com',
    pass: 'alxkamgubxqorppk'
  }
});

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

    if (error.response && error.response.status === 403) {
      // Forbidden response with 403 status
      return res.status(403).json({ error: 'Forbidden', message: 'INVALID TOKEN' });
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

      //Save to DB
      await newUser.save();

      //Get the email verification url
      var verificationUrl = environment == 'Development' ? ("http://localhost:" + apiPort + "/api/verifyemail/" + email) : ("http://cop4331-20-fcdfeeaee1d5.herokuapp.com/api/verifyemail/" + email)

      //Send the email verification email.
      const info = await emailTransport.sendMail({
        from: '"Kitchen Pal" <kitchenpal.cop4331@gmail.com>', // sender address
        to: email, // list of receivers
        subject: "Please Verify your Email ✔", // Subject line
        html: "<b>Please click <a href='" + verificationUrl + "'>here</a> to verify your email.</b>", // html body
      });

      console.log("Message sent: %s", info.messageId);

      // Successful response with 200 status
      res.status(200).json({ error: '' });
    } catch (error) { 
      handleError(error, res)
    }
  });

  //Verify email address
  app.get('/api/verifyemail/:email', async (req, res, next) => {
    try {


      const email = req.params.email;

      // Input Validation
      if (!email) {
        return res.status(400).json({ error: 'MISSING EMAIL.' });
      }

      //Get the user from the email.
      const results = await User.find({ email });

      let response = {
        error: ''
      };

      if (results.length > 0) {

        //Update the verified flag
        await User.findOneAndUpdate({ email: email }, { isVerified: true });

        // Successful response with 200 status
        res.redirect(302, "https://cop4331-20-fcdfeeaee1d5.herokuapp.com/");
      } else {
        // Unauthorized response with 401 status
        res.status(401).json({ error: 'Invalid Email.'});
      }
    } catch (error) {
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
        const { userId, firstName, lastName, email, phone, isVerified } = results[0];
        const jwtToken = jwt.sign({ id: userId }, jwtKey);

        //Check for email verification
        if (!isVerified) {
          res.status(401).json({ error: 'EMAIL NOT VERIFIED'});
          return;
        }
  
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
      handleError(error, res)
    }
  });

  // Endpoint URL: /api/delete_user
  // Delete a user
  app.delete('/api/delete_user', authenticateToken, async (req, res, next) => {
    try {
      const { userId } = req.body;

      if (!userId) {
        return res.status(400).json({ error: 'Missing userId' });
      }

      const deletedUser = await User.findOneAndDelete({userId: userId});

      if (!deletedUser) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.status(200).json({ error: '' });
    } catch (error) {
      handleError(error, res);
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

      const apiUrl = `https://api.edamam.com/auto-complete?app_id=${app_id}&app_key=${app_key}&q=${encodeURIComponent(q)}`;

      const response = await axios.get(apiUrl);

      const suggestions = response.data || [];

      // Successful response with 200 status
      res.status(200).json(suggestions);
    } catch (error) {
      handleError(error, res)
    }
  });

  // Endpoint URL: /api/create_list
  // Create a new list
  app.post('/api/create_list', authenticateToken, async (req, res, next) => {
    try {
      const { userId, label } = req.body;
  
      // Input Validation
      if (!userId || !label) {
        return res.status(400).json({ error: 'Missing required fields' });
      }
  
      // Check if the list with the same label already exists for the user
      const existingList = await List.findOne({ userId, label });
      if (existingList) {
        return res.status(409).json({ error: 'A list with the same name already exists' });
      }
  
      const newList = new List({
        userId: userId,
        label: label,
      });
  
      // Save the new list
      await newList.save();
  
      // Retrieve the generated listId from the database
      const savedList = await List.findOne({ userId, label });
  
      res.status(200).json({ listId: savedList.listId, error: "" });
    } catch (error) {
      handleError(error, res);
    }
  });
  
  

  // Endpoint URL: /api/update_list
  // Update a list
  app.put('/api/update_list', authenticateToken, async (req, res, next) => {
    try {
      const { listId, label } = req.body;
  
      // Input Validation
      if (!listId || !label) {
        return res.status(400).json({ error: 'Missing required fields' });
      }
  
      const updatedList = await List.findOneAndUpdate({ listId: listId }, { label: label }, { new: true });
  
      if (!updatedList) {
        return res.status(404).json({ error: 'List not found' });
      }
  
      res.status(200).json({ error: '' });
    } catch (error) {
      handleError(error, res);
    }
  });
  

  // Endpoint URL: /api/delete_list
  // Delete a list
  app.delete('/api/delete_list', authenticateToken, async (req, res, next) => {
    try {
      const { listId } = req.body;

      if (!listId) {
        return res.status(400).json({ error: 'Missing listId' });
      }

      const deletedList = await List.findOneAndDelete({listId: listId});

      if (!deletedList) {
        return res.status(404).json({ error: 'List not found' });
      }

      // Delete all related list items
      await ListItem.deleteMany({ listId });

      res.status(200).json({ error: '' });
    } catch (error) {
      handleError(error, res);
    }
  });

  app.post('/api/create_list_item', authenticateToken, async (req, res, next) => {
    try {
      const { listId, label } = req.body;
  
      // Input Validation
      if (!listId || !label) {
        return res.status(400).json({ error: 'Missing required fields' });
      }
  
      // Check if the list item with the same label already exists for the list
      const existingListItem = await ListItem.findOne({ listId, label });
      if (existingListItem) {
        return res.status(409).json({ error: 'A list item with the same name already exists in this list' });
      }
  
      const newItem = new ListItem({
        listId: listId,
        label: label,
      });
  
      // Save the new list item
      await newItem.save();
  
      // Retrieve the generated listItemId from the database
      const savedItem = await ListItem.findOne({ listId, label });
  
      res.status(200).json({ listItemId: savedItem.listItemId, error: "" });
    } catch (error) {
      handleError(error, res);
    }
  });
  
  

  // Endpoint URL: /api/update_list_item
  // Update a list item
  app.put('/api/update_list_item', authenticateToken, async (req, res, next) => {
    try {
      const { listItemId, label, isChecked } = req.body;

      // Input Validation
      if (!listItemId) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      const updatedItem = await ListItem.findOneAndUpdate({listItemId: listItemId}, { label, isChecked }, { new: true });

      if (!updatedItem) {
        return res.status(404).json({ error: 'List item not found' });
      }

      res.status(200).json({ error: '' });
    } catch (error) {
      handleError(error, res);
    }
  });

  // Endpoint URL: /api/delete_list_item
  // Delete a list item
  app.delete('/api/delete_list_item', authenticateToken, async (req, res, next) => {
    try {
      const { listItemId } = req.body;

      if (!listItemId) {
        return res.status(400).json({ error: 'Missing listItemId' });
      }

      const deletedItem = await ListItem.findOneAndDelete({listItemId: listItemId});

      if (!deletedItem) {
        return res.status(404).json({ error: 'List item not found' });
      }

      res.status(200).json({ error: '' });
    } catch (error) {
      handleError(error, res);
    }
  });





  // Endpoint URL: /api/delete_list_item
  // Get a specific list item
  app.get('/api/get_list_item/:itemId', authenticateToken, async (req, res, next) => {
    try {
      const listItemId = req.params.itemId;

      const listItem = await ListItem.findOne({listItemId: listItemId});

      if (!listItem) {
        return res.status(404).json({ error: 'List item not found' });
      }

      res.status(200).json(listItem);
    } catch (error) {
      handleError(error, res);
    }
  });

  // Get all list items for a specific list
  app.get('/api/get_list_items/:listId', authenticateToken, async (req, res, next) => {
    try {
      const listId = req.params.listId;

      const listItems = await ListItem.find({ listId });

      res.status(200).json(listItems);
    } catch (error) {
      handleError(error, res);
    }
  });

  // Get all lists
  app.get('/api/get_all_lists/:userId', authenticateToken, async (req, res, next) => {
    try {
      const userId = req.query.userId;

      // Input Validation
      if (!userId) {
        return res.status(400).json({ error: 'Missing userId in the request body' });
      }

      const lists = await List.find({ userId }, { listId: 1, label: 1 });

      if (!lists) {
        return res.status(404).json({ error: 'No lists found for the user' });
      }

      res.status(200).json(lists);
    } catch (error) {
      handleError(error, res);
    }
  });
  
  // Endpoint URL: /api/nutrients
  // HTTP Method: POST
  app.post('/api/nutrients', authenticateToken, async (req, res, next) => {
    try {
      // incoming: ingredients
      // outgoing: response

      const { ingredients } = req.body; // Update the destructuring

      if (!ingredients) {
        return res.status(400).json({ error: "Missing required parameter 'ingredients'" });
      }

      var apiUrl = `https://api.edamam.com/api/food-database/v2/nutrients?app_id=${app_id}&app_key=${app_key}`;

      const requestBody = {
        ingredients: ingredients.map((ingredient) => ({
          quantity: ingredient.quantity,
          measureURI: ingredient.measureURI,
          qualifiers: ingredient.qualifiers || [],
          foodId: ingredient.foodId,
        })),
      };

      const response = await axios.post(apiUrl, requestBody);

      // Handle the provided output
      const nutrientData = response.data;
      const responseObj = {
        uri: nutrientData.uri,
        calories: nutrientData.calories,
        totalWeight: nutrientData.totalWeight,
        dietLabels: nutrientData.dietLabels,
        healthLabels: nutrientData.healthLabels,
        cautions: nutrientData.cautions,
        totalNutrients: nutrientData.totalNutrients,
        totalDaily: nutrientData.totalDaily,
        ingredients: nutrientData.ingredients.map((ingredientData) => ({
          parsed: ingredientData.parsed,
        })),
      };

      // Successful response with 200 status
      res.status(200).json(responseObj);
    } catch (error) {
      handleError(error, res);
    }
  });



  // Endpoint URL: /api/create_fridgeItem
  // HTTP Method: POST
  app.post('/api/create_fridge_item', authenticateToken, async (req, res, next) => {
    try {
      // incoming: userid, expirationDate, foodLabel, totalCalories, measure, ingredient
      // outgoing: error

      const { userId, expirationDate, foodLabel, totalCalories, measure, ingredients } = req.body;

      // Input Validation
      if (!userId || !expirationDate || !foodLabel || !totalCalories || !measure || !ingredients) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      const newFridgeItem = new FridgeItem({
        userId: userId,
        expirationDate: expirationDate,
        foodLabel: foodLabel,
        totalCalories: totalCalories,
        measure: measure,
        ingredients: ingredients
      });

      await newFridgeItem.save();

      // Successful response with 200 status
      res.status(200).json({ error: '' });
    } catch (error) {
      handleError(error, res);
    }
  });
  
  // Endpoint URL: /api/update_fridge_item
  // HTTP Method: PUT
  app.put('/api/update_fridge_item', authenticateToken, async (req, res, next) => {
    try {
      // incoming: fridgeItemId, experationDate, foodLabel, totalCalories, measure, ingredients
      // outgoing: error
  
      const { fridgeItemId, expirationDate, foodLabel, totalCalories, measure, ingredients } = req.body;
  
      // Input Validation
      if (!fridgeItemId || !expirationDate || !foodLabel || !totalCalories || !measure || !ingredients) {
        return res.status(400).json({ error: 'Missing required fields' });
      }
  
      const updatedFridgeItem = await FridgeItem.findOneAndUpdate(
        { fridgeItemId: fridgeItemId },
        {
          expirationDate: expirationDate,
          foodLabel: foodLabel,
          totalCalories: totalCalories,
          measure: measure,
          ingredients: ingredients
        },
        { new: true } // Returns the updated item
      );
  
      if (!updatedFridgeItem) {
        return res.status(404).json({ error: 'Fridge item not found' });
      }
  
      res.status(200).json({ error: '' });
    } catch (error) {
      handleError(error, res);
    }
  });
  
  // Endpoint URL: /api/get_fridge_item
  // HTTP Method: GET
  app.get('/api/get_fridge_item', authenticateToken, async (req, res, next) => {
    try {
      // incoming: fridgeItemId
      // outgoing: fridgeItem
  
      const { fridgeItemId } = req.body;
  
      if (!fridgeItemId) {
        return res.status(400).json({ error: 'Missing required fields' });
      }
  
      const fridgeItem = await FridgeItem.findOne({ fridgeItemId: fridgeItemId });
  
      if (!fridgeItem) {
        return res.status(404).json({ error: 'Fridge item not found' });
      }
  
      res.status(200).json({ fridgeItem });
    } catch (error) {
      handleError(error, res);
    }
  });

  // Endpoint URL: /api/get_all_fridge_items
  // HTTP Method: GET
  app.get('/api/get_all_fridge_items', authenticateToken, async (req, res, next) => {
    try {
      // incoming: userId
      // outgoing: fridgeItemIds

      const { userId } = req.body;

      if (!userId) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      const fridgeItems = await FridgeItem.find({ userId: userId }, 'fridgeItemId');

      if (!fridgeItems) {
        return res.status(404).json({ error: 'No fridge items found for the given user' });
      }

      // Extracting fridgeItemId from each fridgeItem
      const fridgeItemIds = fridgeItems.map(item => item.fridgeItemId);

      res.status(200).json(fridgeItemIds);
    } catch (error) {
      handleError(error, res);
    }
  });
  
  // Endpoint URL: /api/delete_fridge_item
  // HTTP Method: DELETE
  app.delete('/api/delete_fridge_item', authenticateToken, async (req, res, next) => {
    try {
      // incoming: fridgeItemId
      // outgoing: error

      const { fridgeItemId } = req.body;

      if (!fridgeItemId) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      const deletedFridgeItem = await FridgeItem.findOneAndDelete({ fridgeItemId: fridgeItemId });

      if (!deletedFridgeItem) {
        return res.status(404).json({ error: 'Fridge item not found' });
      }

      res.status(200).json({ error: '' });
    } catch (error) {
      handleError(error, res);
    }
  });
}
