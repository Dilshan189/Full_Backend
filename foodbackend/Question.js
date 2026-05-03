const mongoose = require('mongoose');

const questionSchema = new mongoose.Schema({
    questionText: { type: String, required: true },
    options: [String],
    correctAnswerIndex: { type: Number, required: true },
    points: { type: Number, default: 10 }
});

module.exports = mongoose.model('Question', questionSchema);