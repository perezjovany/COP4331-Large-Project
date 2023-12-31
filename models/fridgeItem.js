const mongoose = require("mongoose");
const Schema = mongoose.Schema;

// Create Schema
const FoodSchema = new Schema({
  userId: {
    type: Number,
    required: true,
    // Description: The unique identifier for the user associated with the food (required)
  },
  expirationDate: {
    type: Date,
    required: true,
    // Description: The date when the food item is set to expire (required)
  },
  foodLabel: {
    type: String,
    required: true,
    // Description: The label/note for the food item (required)
  },
  totalCalories: {
    type: Number,
    required: true,
    // Description: The total calories in the food item (required)
  },
  measure: {
    type: String,
    required: true,
    // Description: The measurement unit of the food item (required)
  },
  ingredients: {
    type: [
      {
        quantity: {
          type: Number,
          default: 100,
          // Description: The quantity of the ingredient (default: 100)
        },
        measureURI: {
          type: String,
          required: true,
          // Description: The URI representing the measurement unit of the ingredient (required)
        },
        qualifiers: {
          type: [String],
          // Description: Additional qualifiers for the ingredient (optional)
        },
        foodId: {
          type: String,
          required: true,
          // Description: The unique identifier for the ingredient's food item (required)
        },
      },
    ],
    required: true,
    // Description: An array of ingredients with their quantity, measure URI, and food ID. 
    // Using the food ID and the measure URI, you can make a request to the
    // nutrients access point. (required)
  },
});

module.exports = food = mongoose.model("fridgeItems", FoodSchema, "fridgeItems");
