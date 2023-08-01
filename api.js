require("express");
require("mongodb");
const axios = require("axios");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const PNF = require('google-libphonenumber').PhoneNumberFormat;
const phoneUtil = require('google-libphonenumber').PhoneNumberUtil.getInstance();

//Environment ENV
const environment = process.env.ENVIRONMENT;

// Import the required models
const User = require("./models/user.js");
const List = require("./models/list.js");
const ListItem = require("./models/listItem.js");
const FridgeItem = require("./models/fridgeItem.js");
const Event = require("./models/event.js");
const UserSettings = require("./models/userSettings.js");

//JWT
const jwtKey = process.env.JWT_SECRET;
const app_id = process.env.EDAMAM_ID;
const app_key = process.env.EDAMAM_KEY;

//Hashing
const password_salt = process.env.PASSWORD_SALT;

//Email
var emailValidator = require("email-validator");
const nodemailer = require("nodemailer");
const apiPort = process.env.PORT || 5000;
const emailTransport = nodemailer.createTransport({
	host: process.env.EMAIL_SMTP,
	port: process.env.EMAIL_PORT,
	secure: true,
	auth: {
		user: process.env.EMAIL_LOGIN,
		pass: process.env.EMAIL_PASS,
	},
});

exports.setApp = function (app, client) {
	// Middleware to authenticate the JWT token
	function authenticateToken(req, res, next) {
		const authHeader = req.headers["authorization"];
		const token = authHeader && authHeader.split(" ")[1];
		if (token == null) {
			return res.status(401).json({ error: "MISSING AUTHORIZATION HEADER" });
		}

		jwt.verify(token, jwtKey, (err, user) => {
			if (err) {
				console.error("Invalid token:", err);
				return res.status(403).json({ error: "INVALID TOKEN" });
			}

			// Valid token, add the user data to the request object
			req.user = user;
			next();
		});
	}

	// Custom error handling middleware
	function handleError(error, res) {
		console.error("Error occurred:", error);

		if (error.name === "ValidationError") {
			// Mongoose validation error with 400 status
			return res
				.status(400)
				.json({ error: "Validation Error", message: error.message });
		}

		if (error.name === "MongoError") {
			// MongoDB related error with 500 status
			return res.status(500).json({
				error: "Database Error",
				message: "A database error occurred",
			});
		}

		if (error.response && error.response.status === 401) {
			// Unauthorized response with 401 status
			return res.status(401).json({
				error: "Unauthorized Access",
				message: "You are not authorized to access this resource",
			});
		}

		if (error.response && error.response.status === 403) {
			// Forbidden response with 403 status
			return res
				.status(403)
				.json({ error: "Forbidden", message: "INVALID TOKEN" });
		}

		// Handle other specific error cases here

		// Generic error message for unhandled errors
		res.status(500).json({
			error: "Internal Server Error",
			message: "An unexpected error occurred",
		});
	}

	// Endpoint URL: /api/signup
	// HTTP Method: POST
	app.post("/api/signup", async (req, res, next) => {
		try {
			// incoming: firstName, lastName, login, password, email, phone
			// outgoing: error

			const { firstName, lastName, login, password, email, phone } = req.body;

			// Input Validation
			if (!firstName || !lastName || !login || !password || !email || !phone) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			//Check phone format
			const phoneNumber = phoneUtil.parse(phone, 'US');
			if (!phoneUtil.isValidNumber(phoneNumber)) {
				return res.status(400).json({ error: "Invalid phone number." });
			}

			//Check email format
			if (!emailValidator.validate(email)) {
				return res.status(400).json({ error: "Invalid email address." });
			}

			// Unique User Check
			const existingUser = await User.findOne({
				$or: [{ login: login }, { email: email }],
			});
			if (existingUser) {
				return res
					.status(409)
					.json({ error: "User with this login or email already exists" });
			}


			//Hash the password
			var hashedPassword = crypto
				.pbkdf2Sync(password, password_salt, 1000, 64, `sha512`)
				.toString(`hex`);

			const newUser = new User({
				firstName: firstName,
				lastName: lastName,
				login: login,
				password: hashedPassword,
				email: email,
				phone: phone,
			});

			//Save to DB
			await newUser.save();

			//Get the email verification url
			var verificationUrl =
				environment == "Development"
					? "http://localhost:" + apiPort + "/api/verifyemail/" + email
					: "http://cop4331-20-fcdfeeaee1d5.herokuapp.com/api/verifyemail/" +
					  email;

			//Send the email verification email.
			const info = await emailTransport.sendMail({
				from: '"Kitchen Pal" <kitchenpal.cop4331@gmail.com>', // sender address
				to: email, // list of receivers
				subject: "Please Verify your Email ✔", // Subject line
				html:
					"<b>Please click <a href='" +
					verificationUrl +
					"'>here</a> to verify your email.</b>", // html body
			});

			console.log("Message sent: %s", info.messageId);

			// Successful response with 200 status
			res.status(200).json({ error: "" });
		} catch (error) {
			handleError(error, res);
		}
	});

	//Verify email address
	app.get("/api/verifyemail/:email", async (req, res, next) => {
		try {
			const email = req.params.email;

			// Input Validation
			if (!email) {
				return res.status(400).json({ error: "MISSING EMAIL." });
			}

			//Get the user from the email.
			const results = await User.find({ email });

			let response = {
				error: "",
			};

			if (results.length > 0) {
				//Update the verified flag
				await User.findOneAndUpdate({ email: email }, { isVerified: true });

				// Successful response with 200 status
				res.redirect(302, "https://cop4331-20-fcdfeeaee1d5.herokuapp.com/");
			} else {
				// Unauthorized response with 401 status
				res.status(401).json({ error: "Invalid Email." });
			}
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/login
	// HTTP Method: POST
	app.post("/api/login", async (req, res, next) => {
		try {
			// incoming: login, password
			// outgoing: userId, firstName, lastName, email, phone, token, error

			const { login, password } = req.body;

			// Input Validation
			if (!login || !password) {
				return res.status(400).json({ error: "MISSING USERNAME OR PASSWORD" });
			}

			//Get result from DB
			const results = await User.find({ login });

			let response = {
				error: "",
			};

			//Check if it even exists in the DB.
			if (results.length > 0) {
				//Parse the DB results
				const { userId, firstName, lastName, email, phone, isVerified } =
					results[0];

				//Hash the incoming password
				var hashedPassword = crypto
					.pbkdf2Sync(password, password_salt, 1000, 64, `sha512`)
					.toString(`hex`);

				//Check if the hash is equal. Also === and not == for type comparison as well.
				if (hashedPassword === results[0].password) {
					const jwtToken = jwt.sign({ id: userId }, jwtKey);

					//Check for email verification
					if (!isVerified) {
						res.status(401).json({ error: "EMAIL NOT VERIFIED" });
						return;
					}

					response = {
						userId,
						firstName,
						lastName,
						email,
						phone,
						token: jwtToken,
						error: "",
					};

					// Successful response with 200 status
					res.status(200).json(response);
				} else {
					// Unauthorized response with 401 status
					res.status(401).json({ error: "INCORRECT USERNAME/PASSWORD" });
				}
			} else {
				// Unauthorized response with 401 status
				res.status(401).json({ error: "INCORRECT USERNAME/PASSWORD" });
			}
		} catch (error) {
			handleError(error, res);
		}
	});

	app.post(
		"/api/change_password",
		authenticateToken,
		async (req, res, next) => {
			try {
				//Get http params
				const { password } = req.body;

				//Get the actual user object from the token
				const user = req.user;

				// Input Validation
				if (!password) {
					return res.status(400).json({ error: "Missing required fields" });
				}

				//Get the user from the email.
				const results = await User.find({ userId: user.id });

				let response = {
					error: "",
				};

				if (results.length > 0) {
					//Hash the incoming password
					var hashedPassword = crypto
						.pbkdf2Sync(password, password_salt, 1000, 64, `sha512`)
						.toString(`hex`);

					//Update the verified flag
					await User.findOneAndUpdate(
						{ userId: user.id },
						{ password: hashedPassword }
					);

					// Successful response with 200 status
					res.status(200).json({ error: "" });
				} else {
					// Unauthorized response with 401 status
					res.status(401).json({ error: "Not authorized." });
				}
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	//Verify email address
	app.post("/api/reset_password/", async (req, res, next) => {
		try {
			//Parse params
			const { email } = req.body;

			// Input Validation
			if (!email) {
				return res.status(400).json({ error: "MISSING EMAIL." });
			}

			//Get the user from the email.
			const results = await User.find({ email: email });

			let response = {
				error: "",
			};

			if (results.length > 0) {
				//Get the reset token.
				const resetToken = jwt.sign({ id: results[0].userId }, jwtKey);

				//Get the password reset url
				const resetUrl =
					environment == "Development"
						? "http://localhost:" +
						  apiPort +
						  "/api/verify_reset_password/" +
						  resetToken
						: "http://cop4331-20-fcdfeeaee1d5.herokuapp.com/api/verify_reset_password/" +
						  resetToken;

				//Send the email verification email.
				const info = await emailTransport.sendMail({
					from: '"Kitchen Pal" <kitchenpal.cop4331@gmail.com>', // sender address
					to: email, // list of receivers
					subject: "Click to reset your password. ✔", // Subject line
					html:
						"<b>Please click <a href='" +
						resetUrl +
						"'>HERE</a> to reset your password.</b>", // html body
				});

				console.log("Message sent: %s", info.messageId);

				//Successful response with 200 status
				res.status(200).json({ error: "" });
			} else {
				// Unauthorized response with 401 status
				res.status(401).json({ error: "Invalid Email." });
			}
		} catch (error) {
			handleError(error, res);
		}
	});

	//Verify email address
	app.get("/api/verify_reset_password/:token", async (req, res, next) => {
		try {
			const resetToken = req.params.token;

			// Input Validation
			if (!resetToken) {
				return res.status(400).json({ error: "MISSING TOKEN." });
			}

			jwt.verify(resetToken, jwtKey, async (err, userInfo) => {
				if (err) {
					console.error("Invalid token:", err);
					return res.status(403).json({ error: "INVALID TOKEN" });
				}

				//Get the user from the email.
				const results = await User.find({ userId: userInfo.id });

				let response = {
					error: "",
				};

				if (results.length > 0) {
					//Create a random password
					let randomPassword = (Math.random() + 1).toString(36).substring(5);

					//Hash the randomly generated password
					var hashedPassword = crypto
						.pbkdf2Sync(randomPassword, password_salt, 1000, 64, `sha512`)
						.toString(`hex`);

					//Send the email verification email.
					const info = await emailTransport.sendMail({
						from: '"Kitchen Pal" <kitchenpal.cop4331@gmail.com>', // sender address
						to: results[0].email, // list of receivers
						subject: "Your Password Has Been Reset ✔", // Subject line
						html: "<b>Your new password is: " + randomPassword + "</b>", // html body
					});

					console.log("Message sent: %s", info.messageId);

					//Update the verified flag
					await User.findOneAndUpdate(
						{ userId: userInfo.id },
						{ password: hashedPassword }
					);

					//Successful response with 200 status
					res.redirect(302, "https://cop4331-20-fcdfeeaee1d5.herokuapp.com/");
				} else {
					// Unauthorized response with 401 status
					res.status(401).json({ error: "Invalid Email." });
				}
			});
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/delete_user
	// Delete a user
	app.delete("/api/delete_user", authenticateToken, async (req, res, next) => {
		try {
			const { userId } = req.body;

			if (!userId) {
				return res.status(400).json({ error: "Missing userId" });
			}

			const deletedUser = await User.findOneAndDelete({ userId: userId });

			if (!deletedUser) {
				return res.status(404).json({ error: "User not found" });
			}

			res.status(200).json({ error: "" });
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/parser
	// HTTP Method: POST
	app.post("/api/parser", authenticateToken, async (req, res, next) => {
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
				return res.status(400).json({ error: "Missing required parameter" });
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
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/manual_search
	// HTTP Method: POST
	app.post("/api/manual_search", authenticateToken, async (req, res, next) => {
		try {
			// incoming: q, limit (optional)
			// outgoing: suggestions

			const { q } = req.body;

			if (!q) {
				return res
					.status(400)
					.json({ error: "Missing required parameter 'q'" });
			}

			const apiUrl = `https://api.edamam.com/auto-complete?app_id=${app_id}&app_key=${app_key}&q=${encodeURIComponent(
				q
			)}`;

			const response = await axios.get(apiUrl);

			const suggestions = response.data || [];

			// Successful response with 200 status
			res.status(200).json(suggestions);
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/create_list
	// Create a new list
	app.post("/api/create_list", authenticateToken, async (req, res, next) => {
		try {
			const { userId, label } = req.body;

			// Input Validation
			if (!userId || !label) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			// Check if the list with the same label already exists for the user
			const existingList = await List.findOne({ userId, label });
			if (existingList) {
				return res
					.status(409)
					.json({ error: "A list with the same name already exists" });
			}

			const newList = new List({
				userId: userId,
				label: label,
			});

			// Save the new list
			await newList.save();

			// Retrieve the generated listId from the database
			res.status(200).json({ listId: newList._id.toString(), error: "" });
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/update_list
	// Update a list
	app.put("/api/update_list", authenticateToken, async (req, res, next) => {
		try {
			const { listId, label } = req.body;

			// Input Validation
			if (!listId || !label) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			const updatedList = await List.findOneAndUpdate(
				{ _id: listId },
				{ label: label },
				{ new: true }
			);

			if (!updatedList) {
				return res.status(404).json({ error: "List not found" });
			}

			res.status(200).json({ error: "" });
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/delete_list
	// Delete a list
	app.delete("/api/delete_list", authenticateToken, async (req, res, next) => {
		try {
			const { listId } = req.body;

			if (!listId) {
				return res.status(400).json({ error: "Missing listId" });
			}

			const deletedList = await List.findOneAndDelete({ _id: listId });

			if (!deletedList) {
				return res.status(404).json({ error: "List not found" });
			}

			// Delete all related list items
			await ListItem.deleteMany({ listId });

			res.status(200).json({ error: "" });
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/create_list_item
	// Create a new list item
	app.post(
		"/api/create_list_item",
		authenticateToken,
		async (req, res, next) => {
			try {
				const { listId, label } = req.body;

				// Input Validation
				if (!listId || !label) {
					return res.status(400).json({ error: "Missing required fields" });
				}

				// Check if the list item with the same label already exists for the list
				const existingListItem = await ListItem.findOne({ listId, label });
				if (existingListItem) {
					return res.status(409).json({
						error: "A list item with the same name already exists in this list",
					});
				}

				const newItem = new ListItem({
					listId: listId,
					label: label,
				});

				// Save the new list item
				await newItem.save();

				// Retrieve the generated listItemId from the database
				res.status(200).json({ listItemId: newItem._id.toString(), error: "" });
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/update_list_item
	// Update a list item
	app.put(
		"/api/update_list_item",
		authenticateToken,
		async (req, res, next) => {
			try {
				const { listItemId, label, isChecked } = req.body;

				// Input Validation
				if (!listItemId) {
					return res.status(400).json({ error: "Missing required fields" });
				}

				const updatedItem = await ListItem.findOneAndUpdate(
					{ _id: listItemId },
					{ label, isChecked },
					{ new: true }
				);

				if (!updatedItem) {
					return res.status(404).json({ error: "List item not found" });
				}

				res.status(200).json({ error: "" });
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/delete_list_item
	// Delete a list item
	app.delete(
		"/api/delete_list_item",
		authenticateToken,
		async (req, res, next) => {
			try {
				const { listItemId } = req.body;

				if (!listItemId) {
					return res.status(400).json({ error: "Missing listItemId" });
				}

				const deletedItem = await ListItem.findOneAndDelete({
					_id: listItemId,
				});

				if (!deletedItem) {
					return res.status(404).json({ error: "List item not found" });
				}

				res.status(200).json({ error: "" });
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/delete_list_item
	// Get a specific list item
	app.get(
		"/api/get_list_item/:itemId",
		authenticateToken,
		async (req, res, next) => {
			try {
				const listItemId = req.params.itemId;

				const listItem = await ListItem.findOne({ _id: listItemId });

				if (!listItem) {
					return res.status(404).json({ error: "List item not found" });
				}

				res.status(200).json(listItem);
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Get all list items for a specific list
	app.get(
		"/api/get_list_items/:listId",
		authenticateToken,
		async (req, res, next) => {
			try {
				const listId = req.params.listId;

				const listItems = await ListItem.find({ listId });

				res.status(200).json(listItems);
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Get all lists
	app.get(
		"/api/get_all_lists/:userId",
		authenticateToken,
		async (req, res, next) => {
			try {
				const userId = req.params.userId;

				// Input Validation
				if (!userId) {
					return res
						.status(400)
						.json({ error: "Missing userId in the request body" });
				}

				const lists = await List.find({ userId });

				if (!lists) {
					return res.status(404).json({ error: "No lists found for the user" });
				}

				res.status(200).json(lists);
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/nutrients
	// HTTP Method: POST
	app.post("/api/nutrients", authenticateToken, async (req, res, next) => {
		try {
			// incoming: ingredients
			// outgoing: response

			const { ingredients } = req.body; // Update the destructuring

			if (!ingredients) {
				return res
					.status(400)
					.json({ error: "Missing required parameter 'ingredients'" });
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
	app.post(
		"/api/create_fridge_item",
		authenticateToken,
		async (req, res, next) => {
			try {
				// incoming: userid, expirationDate, foodLabel, totalCalories, measure, ingredient
				// outgoing: _id, error

				const {
					userId,
					expirationDate,
					foodLabel,
					totalCalories,
					measure,
					ingredients,
				} = req.body;

				// Input Validation
				if (
					!userId ||
					!expirationDate ||
					!foodLabel ||
					!totalCalories ||
					!measure ||
					!ingredients
				) {
					return res.status(400).json({ error: "Missing required fields" });
				}

				const newFridgeItem = new FridgeItem({
					userId: userId,
					expirationDate: expirationDate,
					foodLabel: foodLabel,
					totalCalories: totalCalories,
					measure: measure,
					ingredients: ingredients,
				});

				const savedFridgeItem = await newFridgeItem.save();

				// Successful response with 200 status and _id field in the response
				res.status(200).json({ _id: savedFridgeItem._id, error: "" });
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/update_fridge_item
	// HTTP Method: PUT
	app.put(
		"/api/update_fridge_item",
		authenticateToken,
		async (req, res, next) => {
			try {
				// incoming: fridgeItemId, expirationDate, foodLabel, totalCalories, measure, ingredients
				// outgoing: fridgeItem

				const {
					fridgeItemId,
					expirationDate,
					foodLabel,
					totalCalories,
					measure,
					ingredients,
				} = req.body;

				// Input Validation
				if (
					!fridgeItemId ||
					!expirationDate ||
					!foodLabel ||
					!totalCalories ||
					!measure ||
					!ingredients
				) {
					return res.status(400).json({ error: "Missing required fields" });
				}

				const updatedFridgeItem = await FridgeItem.findOneAndUpdate(
					{ _id: fridgeItemId }, // Use "_id" instead of "fridgeItemId"
					{
						expirationDate: expirationDate,
						foodLabel: foodLabel,
						totalCalories: totalCalories,
						measure: measure,
						ingredients: ingredients,
					},
					{ new: true } // Returns the updated item
				);

				if (!updatedFridgeItem) {
					return res.status(404).json({ error: "Fridge item not found" });
				}

				// Return the updated fridgeItem object directly without a wrapper object
				res.status(200).json(updatedFridgeItem);
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/get_fridge_item
	// HTTP Method: GET
	app.get(
		"/api/get_fridge_item/:fridgeItemId",
		authenticateToken,
		async (req, res, next) => {
			try {
				// incoming: fridgeItemId
				// outgoing: fridgeItem

				const fridgeItemId = req.params.fridgeItemId;

				if (!fridgeItemId) {
					return res.status(400).json({ error: "Missing required fields" });
				}

				const fridgeItem = await FridgeItem.findOne({ _id: fridgeItemId });

				if (!fridgeItem) {
					return res.status(404).json({ error: "Fridge item not found" });
				}

				// Return the fridgeItem object directly without a wrapper object
				res.status(200).json(fridgeItem);
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/get_all_fridge_items
	// HTTP Method: GET
	app.get(
		"/api/get_all_fridge_items/:userId",
		authenticateToken,
		async (req, res, next) => {
			try {
				// incoming: userId
				// outgoing: fridgeItems

				const userId = req.params.userId;

				if (!userId) {
					return res.status(400).json({ error: "Missing required fields" });
				}

				const fridgeItems = await FridgeItem.find({ userId: userId }, "_id");

				if (!fridgeItems) {
					return res
						.status(404)
						.json({ error: "No fridge items found for the given user" });
				}

				res.status(200).json(fridgeItems);
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/delete_fridge_item
	// HTTP Method: DELETE
	app.delete(
		"/api/delete_fridge_item",
		authenticateToken,
		async (req, res, next) => {
			try {
				// incoming: fridgeItemId
				// outgoing: error

				const { fridgeItemId } = req.body;

				if (!fridgeItemId) {
					return res.status(400).json({ error: "Missing required fields" });
				}

				// Use "_id" instead of "fridgeItemId" in the query
				const deletedFridgeItem = await FridgeItem.findOneAndDelete({
					_id: fridgeItemId,
				});

				if (!deletedFridgeItem) {
					return res.status(404).json({ error: "Fridge item not found" });
				}

				// Delete the corresponding events associated with the fridgeItemId
				const deletedEvents = await Event.deleteMany({ fridgeItemId: fridgeItemId });

				res.status(200).json({ error: "" });
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/create_event
	// HTTP Method: POST
	app.post("/api/create_event", authenticateToken, async (req, res, next) => {
		try {
			// incoming: fridgeItemId, expirationDate, description
			// outgoing: eventId

			const { userId, fridgeItemId, expirationDate, foodLabel } = req.body;

			// Input Validation
			if (!fridgeItemId || !expirationDate) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			const newEvent = new Event({
				userId,
				fridgeItemId,
				expirationDate,
				eventLabel: `${foodLabel} expires`,
			});

			const savedEvent = await newEvent.save();

			// Successful response with 200 status and the eventId
			return res.status(200).json({ eventId: savedEvent._id.toString() });
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/update_event
	// HTTP Method: PUT
	app.put("/api/update_event", authenticateToken, async (req, res, next) => {
		try {
			// incoming: eventId, expirationDate, description
			// outgoing: error

			const { eventId, expirationDate, foodLabel } = req.body;

			// Input Validation
			if (!eventId) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			const updatedEvent = await Event.findOneAndUpdate(
				{ _id: eventId },
				{
					expirationDate: expirationDate,
					foodLabel: foodLabel,
				},
				{ new: true } // Returns the updated event
			);

			if (!updatedEvent) {
				return res.status(404).json({ error: "Event not found" });
			}

			res.status(200).json({ error: "" });
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/get_event
	// HTTP Method: GET
	app.get("/api/get_event/:eventId", authenticateToken, async (req, res, next) => {
		try {
			// incoming: eventId
			// outgoing: event

			const eventId = req.params.eventId;

			if (!eventId) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			const event = await Event.findOne({ _id: eventId }); // Using _id instead of eventId

			if (!event) {
				return res.status(404).json({ error: "Event not found" });
			}

			res.status(200).json({ event });
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/get_all_events
	// HTTP Method: GET
	app.get("/api/get_all_events/:userId", authenticateToken, async (req, res, next) => {
		try {
			// incoming: userId
			// outgoing: events

			const userId = req.params.userId;

			if (!userId) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			const events = await Event.find({ userId: userId });

			if (!events) {
				return res
					.status(404)
					.json({ error: "No events found for the given user" });
			}

			res.status(200).json(events);
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/delete_event
	// HTTP Method: DELETE
	app.delete("/api/delete_event", authenticateToken, async (req, res, next) => {
		try {
			// incoming: eventId
			// outgoing: error

			const { eventId } = req.body;

			if (!eventId) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			const deletedEvent = await Event.findOneAndDelete({ _id: eventId }); // Using _id instead of eventId

			if (!deletedEvent) {
				return res.status(404).json({ error: "Event not found" });
			}

			res.status(200).json({ error: "" });
		} catch (error) {
			handleError(error, res);
		}
	});

	// Endpoint URL: /api/get_user
	// HTTP Method: GET
	app.get(
		"/api/get_user/:userId",
		authenticateToken,
		async (req, res, next) => {
			try {
				// incoming: userId
				// outgoing: user

				const userId = req.params.userId;

				if (!userId) {
					return res.status(400).json({ error: "Missing required field" });
				}

				const user = await User.findOne({ userId: userId });

				if (!user) {
					return res.status(404).json({ error: "User not found" });
				}

				res.status(200).json({ user });
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/get_user_settings
	// HTTP Method: GET
	app.get(
		"/api/get_user_settings/:userId",
		authenticateToken,
		async (req, res, next) => {
			try {
				// incoming: userId
				// outgoing: user_settings

				const userId = req.params.userId;

				if (!userId) {
					return res.status(400).json({ error: "Missing required field" });
				}

				const user_settings = await UserSettings.findOne({ userId: userId });

				if (!user_settings) {
					return res.status(404).json({ error: "User Settings not found" });
				}

				res.status(200).json({ user_settings });
			} catch (error) {
				handleError(error, res);
			}
		}
	);

	// Endpoint URL: /api/update_user
	// HTTP Method: PUT
	app.put("/api/update_user", authenticateToken, async (req, res, next) => {
		try {
			const { userId, firstName, lastName, phone, daysLeft, isLightMode } =
				req.body;

			// Logging the incoming data:
			console.log("Incoming data: ", req.body);

			if (
				!userId ||
				!firstName ||
				!lastName ||
				!phone ||
				daysLeft === undefined ||
				isLightMode === undefined
			) {
				return res.status(400).json({ error: "Missing required fields" });
			}

			const updatedUser = await User.findOneAndUpdate(
				{ userId: userId },
				{
					firstName: firstName,
					lastName: lastName,
					phone: phone,
				},
				{ new: true }
			);

			// Logging the updated user:
			console.log("Updated user: ", updatedUser);

			const updatedUserSettings = await UserSettings.findOneAndUpdate(
				{ userId: userId },
				{
					daysLeft: daysLeft,
					isLightMode: isLightMode,
				},
				{ new: true, upsert: true } // Add the upsert option to create a new document if not found
			);

			// Logging the updated user settings:
			console.log("Updated user settings: ", updatedUserSettings);

			if (updatedUserSettings === null) {
				return res.status(404).json({ error: "User Settings not found" });
			}

			res.status(200).json({ error: "" });
		} catch (error) {
			handleError(error, res);
		}
	});
};
