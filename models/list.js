const mongoose = require("mongoose");
const Schema = mongoose.Schema;

// Create Schema
const UserSchema = new Schema({
  userId: {
    type: Number,
    required: true,
    // Description: The unique identifier for the user associated with the list (required)
  },
  label: {
    type: String,
    required: true,
    // Description: The label for the list (required)
  }
});

module.exports = list = mongoose.model("lists", UserSchema, "lists");
