require('dotenv').config();
const mongoose = require('mongoose');
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs'); // Password hash කරන්න
const Question = require('./Question'); 
const User = require('./User'); // User model එක

// JWT Secret Key (දැන් මේක .env file එකෙන් ගන්නේ)
const JWT_SECRET = process.env.JWT_SECRET;

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json()); 

const dbURI = process.env.MONGO_URI;

mongoose.connect(dbURI)
  .then(() => console.log('Database ekata connect una!'))
  .catch((err) => console.log('Database error: ', err));

app.get('/', (req, res) => {
    res.send("Welcome to My First Backend API!");
});

// 1. Register Route (අලුත් User කෙනෙක් ඇතුළත් කිරීම)
app.post('/api/register', async (req, res) => {
    try {
        const { username, email, password } = req.body;

        // Password එක hash කරනවා (ආරක්ෂාවට)
        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = new User({
            username,
            email,
            password: hashedPassword
        });

        await newUser.save();
        res.status(201).json({ message: "User registered successfully!" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 2. Login Route (ඇතුළත් වීමට සහ Token එකක් ලබාගැනීමට)
app.post('/api/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // User ඉන්නවද කියලා බලනවා
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ error: "User not found!" });
        }

        // Password එක ගැලපෙනවද බලනවා
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({ error: "Invalid password!" });
        }

        // Token එකක් හදනවා
        const token = jwt.sign({ userId: user._id, username: user.username }, JWT_SECRET, { expiresIn: '1h' });
        res.status(200).json({ message: "Login successful!", token });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 2. Token එක හරියට තියෙනවද කියලා බලන Middleware එක
const authenticateToken = (req, res, next) => {
    // Header එකෙන් token එක ගන්නවා (Format: "Bearer <token>")
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ error: "Access denied. Token is missing!" });

    // Token එක හරිද කියලා check කරනවා
    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: "Invalid or expired token!" });
        req.user = user; // ඊළඟ route එකට user ගේ විස්තර යවනවා
        next(); // Token එක හරි නම් ඊළඟ වැඩේට යන්න දෙනවා
    });
};

// 3. authenticateToken එක දාලා මේ route එක protect කරනවා (දැන් token එකක් නැතුව මෙතනට එන්න බෑ)
app.post('/api/add-question', authenticateToken, async (req, res) => {
    try {
        console.log("Postman data:", req.body); 
        const newQuestion = new Question(req.body); 
        await newQuestion.save();
        res.status(201).json({ message: "Question saved successfully!" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});


// Database එකේ තියෙන ඔක්කොම ප්‍රශ්න ලබාගැනීම
app.get('/api/get-questions', async (req, res) => {
    try {
        // Question Model එක හරහා database එකේ තියෙන ඔක්කොම දත්ත හොයනවා
        const questions = await Question.find(); 
        
        // සාර්ථක නම් දත්ත ටික JSON එකක් විදියට යවනවා
        res.status(200).json(questions);
    } catch (err) {
        // මොකක් හරි වැරැද්දක් වුණොත් error එක පෙන්වනවා
        res.status(500).json({ error: err.message });
    }
});