const mongoose = require("mongoose");
const Schema = mongoose.Schema;

// Create Schema
const EventSchema = new Schema({
  userId: {
    type: Number,
    required: true,
    // Description: The unique identifier for the user associated with the event (required)
  },
  fridgeItemId: {
    type: String,
    required: true,
    // Description: The identifier for the food item associated with the event (required)
  },
  expirationDate: {
    type: Date,
    required: true,
    // Description: The date when the food item is set to expire (required)
  },
  eventLabel: {
    type: String,
    required: true,
    // Description: Additional description or note for the event (optional)
  },
});

module.exports = mongoose.model("Event", EventSchema);
