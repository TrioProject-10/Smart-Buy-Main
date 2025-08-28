const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");

const app = express();
const port = 3000;

// Enable CORS so frontend can access backend
app.use(cors());

// Middleware to parse JSON
app.use(express.json());

// Connect to MySQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "rahul1911@!",
  database: "smartbuy"
});

db.connect((err) => {
  if (err) {
    console.error("Database connection failed:", err);
    return;
  }
  console.log("Connected to MySQL ✅");
});

// Test route
app.get("/", (req, res) => {
  res.send("Backend working fine ✅");
});

// Login route
app.post("/api/v1/users/login", (req, res) => {
  const { username, password } = req.body; // must match frontend names

  if (!username || !password) {
    return res.status(400).json({ success: false, message: "Username and password are required" });
  }

  const query = "SELECT * FROM users WHERE username = ? AND password = ?";
  db.query(query, [username, password], (err, results) => {
    if (err) {
      console.error("MySQL Error:", err);
      return res.status(500).json({ success: false, message: "Database error" });
    }

    if (results.length > 0) {
      res.json({ success: true, message: "Login successful" });
    } else {
      res.json({ success: false, message: "Invalid credentials" });
    }
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port} ✅`);
});
