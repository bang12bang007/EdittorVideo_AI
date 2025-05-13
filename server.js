const express = require('express');
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const app = express();
const port = 3000;

// Enable CORS
app.use(cors());

// Configure multer for file upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// Create uploads directory if it doesn't exist
const fs = require('fs');
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

// Handle image restoration
app.post('/restore', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded');
  }

  // For now, we'll just return the same image
  // In a real implementation, you would process the image here
  res.sendFile(req.file.path);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
}); 