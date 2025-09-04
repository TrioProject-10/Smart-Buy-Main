const express = require("express");
const router = express.Router();

module.exports = (db) => {
  // Signup route
  router.post("/signup", (req, res) => {
    const { fullName, email, password, confirmPassword } = req.body;

    // Check if all fields are provided
    if (!fullName || !email || !password || !confirmPassword) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    // Check if passwords match
    if (password !== confirmPassword) {
      return res.status(400).json({ success: false, message: "Passwords do not match" });
    }

    // Check if email already exists
    const checkQuery = "SELECT * FROM users WHERE email = ?";
    db.query(checkQuery, [email], (err, results) => {
      if (err) {
        console.error("MySQL Error:", err);
        return res.status(500).json({ success: false, message: "Database error" });
      }

      if (results.length > 0) {
        return res.status(400).json({ success: false, message: "Email already registered" });
      }

      // Insert new user
      const insertQuery = "INSERT INTO users (fullName, email, password) VALUES (?, ?, ?)";
      db.query(insertQuery, [fullName, email, password], (err, result) => {
        if (err) {
          console.error("MySQL Error:", err);
          return res.status(500).json({ success: false, message: "Database error" });
        }

        res.json({ success: true, message: "Signup successful" });
      });
    });
  });

  return router;
};
