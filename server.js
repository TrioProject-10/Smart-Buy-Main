import express from "express";
import bodyParser from "body-parser";
import pkg from "pg"; // PostgreSQL client
const { Pool } = pkg;

const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// 🔑 Replace with your Supabase Database URL (from Settings > Database > Connection string > URI)
const pool = new Pool({
  connectionString: "postgresql://postgres.qbtlzjnjvgktsyddwweo:192622MSrBvR@aws-1-ap-south-1.pooler.supabase.com:5432/postgres",
  ssl: {
    rejectUnauthorized: false, // required for Supabase
  },
});

// ✅ Test DB connection
pool.connect()
  .then(() => console.log("Connected to Supabase PostgreSQL ✅"))
  .catch((err) => console.error("DB connection error ❌", err));

// ---------------- ROUTES ---------------- //

// Signup
app.post("/signup", async (req, res) => {
  const { uname, umail, udob, upass } = req.body;

  try {
    const query = `
      INSERT INTO users (uname, umail, udob, upass)
      VALUES ($1, $2, $3, $4)
      RETURNING *;
    `;
    const values = [uname, umail, udob, upass];

    const result = await pool.query(query, values);
    res.status(201).json({
      message: "User created successfully!",
      user: result.rows[0],
    });
  } catch (err) {
    console.error("❌ Error inserting user:", err);
    res.status(500).json({ error: "Server error. Try again!" });
  }
});

// Login
app.post("/login", async (req, res) => {
  const { umail, upass } = req.body;

  try {
    const query = `SELECT * FROM users WHERE umail = $1 AND upass = $2`;
    const values = [umail, upass];

    const result = await pool.query(query, values);

    if (result.rows.length > 0) {
      res.json({ message: "Login successful!", user: result.rows[0] });
    } else {
      res.status(401).json({ error: "Invalid credentials" });
    }
  } catch (err) {
    console.error("❌ Error during login:", err);
    res.status(500).json({ error: "Server error. Try again!" });
  }
});

// Default route
app.get("/", (req, res) => {
  res.send("🚀 Supabase PostgreSQL Server Running");
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server running at http://localhost:${PORT}`);
});
