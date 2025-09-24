const express = require("express");
const router = express.Router();

module.exports = (db) => {
  // Signup route
  router.post("/signup", (req, res) => {
    const { uname, umail, udob, upass } = req.body;

    // Check required fields
    if (!uname || !umail || !udob || !upass) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    // Check if email already exists
    const checkQuery = "SELECT * FROM users WHERE umail = ?";
    db.get(checkQuery, [umail], (err, row) => {
      if (err) {
        console.error("SQLite Error:", err);
        return res.status(500).json({ success: false, message: "Database error" });
      }

      if (row) {
        return res.status(400).json({ success: false, message: "Email already registered" });
      }

      // Insert new user
      const insertQuery =
        "INSERT INTO users (uname, umail, udob, upass) VALUES (?, ?, ?, ?)";
      db.run(insertQuery, [uname, umail, udob, upass], function (err) {
        if (err) {
          console.error("SQLite Error:", err);
          return res.status(500).json({ success: false, message: "Database error" });
        }

        res.json({ success: true, message: "Signup successful" });
      });
    });
  });

  return router;
};
