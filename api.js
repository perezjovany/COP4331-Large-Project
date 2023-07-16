require('express');
require('mongodb');
const axios = require('axios')

//load user model
const User = require("./models/user.js");

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


  app.post('/api/login', async (req, res, next) => 
  {
    // incoming: login, password
    // outgoing: id, firstName, lastName, email, phone, error
    
    var error = '';

    const { login, password } = req.body;

    const results = await User.find({ login: login, password: password });

    var id = -1;
    var fn = '';
    var ln = '';
    var em = '';
    var ph = '';

    if( results.length > 0 )
    {
      id = results[0].userId;
      fn = results[0].firstName;
      ln = results[0].lastName;
      em = results[0].email;
      ph = results[0].phone;
    }

    var ret = { id:id, firstName:fn, lastName:ln, email:em, phone:ph, error: error};
    res.status(200).json(ret);
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