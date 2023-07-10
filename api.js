require('express');
require('mongodb');

//load user model
const User = require("./models/user.js");
//load card model
const Card = require("./models/card.js");

exports.setApp = function ( app, client )
{

  app.post('/api/addcard', async (req, res, next) =>
  {
    // incoming: userId, card
    // outgoing: error
    
    const { userId, card } = req.body;

    //const newCard = { Card: card, UserId: userId };
    const newCard = new Card({ Card: card, UserId: userId });
    var error = '';
    
    try 
    {
      // const db = client.db();
      // const result = db.collection('Cards').insertOne(newCard);
      newCard.save();
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
    // outgoing: id, firstName, lastName, error
    
    var error = '';

    const { login, password } = req.body;

    // const db = client.db("COP4331Cards");
    // const results = await db.collection('Users').find({Login:login,Password:password}).toArray();
    const results = await User.find({ Login: login, Password: password });

    var id = -1;
    var fn = '';
    var ln = '';

    if( results.length > 0 )
    {
      id = results[0].UserId;
      fn = results[0].FirstName;
      ln = results[0].LastName;
    }

    var ret = { id:id, firstName:fn, lastName:ln, error:''};
    res.status(200).json(ret);
  });

  app.post('/api/searchcards', async (req, res, next) => 
  {
    // incoming: userId, search
    // outgoing: results[], error

    var error = '';

    const { userId, search } = req.body;

    var _search = search.trim();
    
    // const db = client.db("COP4331Cards");
    // const results = await db.collection('Cards').find({"Card":{$regex:_search+'.*', $options:'i'}}).toArray();
    const results = await Card.find({ "Card": { $regex: _search + '.*', $options: 'i' } });
    
    var _ret = [];
    for( var i=0; i<results.length; i++ )
    {
      _ret.push( results[i].Card );
    }
    
    var ret = {results:_ret, error:error};
    res.status(200).json(ret);
  });
    
}


// app.post('/api/addcard', async (req, res, next) =>
// {
//   // incoming: userId, card
//   // outgoing: error
	
//   const { userId, card } = req.body;

//   const newCard = {Card:card,UserId:userId};
//   var error = '';

//   try
//   {
//     const db = client.db("COP4331Cards");
//     const result = db.collection('Cards').insertOne(newCard);
//   }
//   catch(e)
//   {
//     error = e.toString();
//   }

//   var ret = { error: error };
//   res.status(200).json(ret);
// });


// app.post('/api/login', async (req, res, next) => 
// {
//   // incoming: login, password
//   // outgoing: id, firstName, lastName, error
	
//  var error = '';

//   const { login, password } = req.body;

//   const db = client.db("COP4331Cards");
//   const results = await db.collection('Users').find({Login:login,Password:password}).toArray();

//   var id = -1;
//   var fn = '';
//   var ln = '';

//   if( results.length > 0 )
//   {
//     id = results[0].UserID;
//     fn = results[0].FirstName;
//     ln = results[0].LastName;
//   }

//   var ret = { id:id, firstName:fn, lastName:ln, error:''};
//   res.status(200).json(ret);
// });

// app.post('/api/searchcards', async (req, res, next) => 
// {
//   // incoming: userId, search
//   // outgoing: results[], error

//   var error = '';

//   const { userId, search } = req.body;

//   var _search = search.trim();
  
//   const db = client.db("COP4331Cards");
//   const results = await db.collection('Cards').find({"Card":{$regex:_search+'.*', $options:'i'}}).toArray();
  
//   var _ret = [];
//   for( var i=0; i<results.length; i++ )
//   {
//     _ret.push( results[i].Card );
//   }
  
//   var ret = {results:_ret, error:error};
//   res.status(200).json(ret);
// });