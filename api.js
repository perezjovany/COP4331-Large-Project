require('express');
require('mongodb');

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
      // const db = client.db();
      // const result = db.collection('Users').insertOne(newUser);
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

    //const db = client.db("COP4331Food");
    //const results = await db.collection('Users').find({login: login, password: password}).toArray();
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

}
