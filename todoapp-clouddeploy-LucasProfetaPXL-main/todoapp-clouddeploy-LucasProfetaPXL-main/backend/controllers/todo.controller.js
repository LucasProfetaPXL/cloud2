const Todo = require('../models/todo.model');

exports.getTodos = (req, res) => {
    Todo.find()
        .then(todos => res.json(todos))
        .catch(err => res.status(400).json('Error: ' + err));
};

exports.createTodo = (req, res) => {
    const newTodo = new Todo(req.body);

    newTodo.save()
        .then((todo) => res.json(todo))
        .catch(err => res.status(400).json('Error: ' + err));
}

exports.deleteTodo = (req, res) => {
    Todo.findByIdAndDelete(req.params.id)
        .then(() => res.json('Todo deleted.'))
        .catch(err => res.status(400).json('Error: ' + err));
}

exports.updateTodo = (req, res) => {
    Todo.findById(req.params.id)
        .then(todo => {
            todo.title = req.body.title;
            todo.label = req.body.label;
            todo.completed = req.body.completed;

            todo.save()
                .then((todo) => res.json(todo))
                .catch(err => res.status(400).json('Error: ' + err));
        })
        .catch(err => res.status(400).json('Error: ' + err));
}