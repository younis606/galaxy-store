const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json([{ name: 'Mercury' }, { name: 'Venus' }, { name: 'Earth' }]);
});

module.exports = router;
