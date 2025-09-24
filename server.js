const express = require("express");
const bodyParser = require("body-parser");
const sqlite3 = require("sqlite3").verbose();
const path = require("path");

const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, "public"))); // serve frontend

// DB setup
const db = new sqlite3.Database("./smartbuy.db", (err) => {
  if (err) {
    console.error("Error opening database:", err);
  } else {
    console.log("Connected to SQLite database ✅");
    db.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uname TEXT,
        umail TEXT UNIQUE,
        udob TEXT,
        upass TEXT
      )
    `);
  }
});

// -------- Signup Route --------
app.post("/api/v1/users/signup", (req, res) => {
  const { uname, umail, udob, upass } = req.body;

  if (!uname || !umail || !udob || !upass) {
    return res.status(400).json({ success: false, message: "All fields are required." });
  }

  db.run(
    "INSERT INTO users (uname, umail, udob, upass) VALUES (?, ?, ?, ?)",
    [uname, umail, udob, upass],
    function (err) {
      if (err) {
        console.error("Database error:", err.message);
        return res
          .status(500)
          .json({ success: false, message: "User already exists or DB error." });
      }
      res.json({ success: true, message: "Signup successful!" });
    }
  );
});

// -------- Login Route --------
app.post("/api/v1/users/login", (req, res) => {
  const { umail, upass } = req.body;

  if (!umail || !upass) {
    return res.status(400).json({ success: false, message: "Email and password are required." });
  }

  console.log("Login attempt:", umail);

  db.get(
    "SELECT id, uname, umail, udob FROM users WHERE umail = ? AND upass = ?",
    [umail, upass],
    (err, row) => {
      if (err) {
        console.error("Database error:", err.message);
        return res.status(500).json({ success: false, message: "Internal server error." });
      }

      if (!row) {
        return res.status(401).json({ success: false, message: "Invalid email or password." });
      }

      console.log("Login success:", row);
      res.json({ success: true, message: "Login successful!", user: row });
    }
  );
});

// -------- Start Server --------
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
