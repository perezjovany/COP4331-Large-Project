const mongoose = require("mongoose");
const Schema = mongoose.Schema;

// Create Schema
const UserSchema = new Schema({
  listId: {
    type: String,
    required: true,
    // Description: The identifier for the list to which this item belongs (required)
  },
  isChecked: {
    type: Boolean,
    required: true,
    default: false,
    // Description: Indicates whether the list item is checked/completed (required, default: false)
  },
  label: {
    type: String,
    required: true,
    // Description: The label for the list item (required)
  }
});

module.exports = list = mongoose.model("list_items", UserSchema, "list_items");
