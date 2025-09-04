const express = require("express");
const bodyParser = require("body-parser");
const sqlite3 = require("sqlite3").verbose();
const cors = require("cors");

const app = express();
const PORT = 3000;

// Middleware
app.use(cors()); // ✅ allow requests from Live Server (5500)
app.use(bodyParser.json());

// DB setup
const db = new sqlite3.Database("./smartbuy.db", (err) => {
  if (err) {
    console.error("Error opening database:", err);
  } else {
    console.log("Connected to SQLite database");
    db.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullname TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    `);
  }
});

// Routes
app.post("/signup", (req, res) => {
  const { fullname, email, password } = req.body;

  if (!fullname || !email || !password) {
    return res.status(400).json({ message: "All fields are required." });
  }

  db.run(
    "INSERT INTO users (fullname, email, password) VALUES (?, ?, ?)",
    [fullname, email, password],
    function (err) {
      if (err) {
        console.error("Database error:", err.message);
        return res.status(500).json({ message: "User already exists or DB error." });
      }
      res.json({ message: "Signup successful!" });
    }
  );
});
// Login Route
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: "All fields are required." });
  }

  db.get(
    "SELECT * FROM users WHERE email = ? AND password = ?",
    [email, password],
    (err, row) => {
      if (err) {
        console.error("Database error:", err.message);
        return res.status(500).json({ success: false, message: "Database error." });
      }

      if (row) {
        res.json({ success: true, message: "Login successful!" });
      } else {
        res.json({ success: false, message: "Invalid email or password." });
      }
    }
  );
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
