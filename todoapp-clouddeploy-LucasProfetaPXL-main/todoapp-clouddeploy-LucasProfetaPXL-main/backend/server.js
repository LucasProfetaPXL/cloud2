const express = require('express');
const cors = require('cors');
const healthRoutes = require('./routes/health.routes');
const todoRoutes = require('./routes/todo.routes');
const carrouselRoutes = require('./routes/carrousel.routes');

const app = express();
const db = require('./db');


const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/health', healthRoutes);
app.use('/todo', todoRoutes);
app.use('/carrousel', carrouselRoutes)

app.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
});