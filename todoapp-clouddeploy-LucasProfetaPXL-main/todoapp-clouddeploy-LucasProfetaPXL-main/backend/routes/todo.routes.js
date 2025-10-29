const express = require('express');
const router = express.Router();
const todoController = require('../controllers/todo.controller');
const todoRouter = express.Router();

todoRouter.get('/', todoController.getTodos);
todoRouter.post('/', todoController.createTodo);
todoRouter.put('/:id', todoController.updateTodo);
todoRouter.delete('/:id', todoController.deleteTodo);


module.exports = todoRouter;