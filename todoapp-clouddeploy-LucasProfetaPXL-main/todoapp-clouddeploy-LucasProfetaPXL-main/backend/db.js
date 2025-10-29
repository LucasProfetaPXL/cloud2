const mongoose = require('mongoose');
(async () => {
    try {
      const db = await mongoose.connect(process.env.DBURL || 'mongodb://localhost/sampledb');
      console.log("Db connectect to", db.connection.name);
    } catch (error) {
      console.error(error);
    }
  })();