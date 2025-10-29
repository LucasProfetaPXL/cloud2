const express = require('express');
const carrouselRouter = express.Router();
const carrouselData = require('./../data/carrousel.json');

carrouselRouter.get('', (req, res) => {
    res.json(carrouselData);
});


module.exports = carrouselRouter;