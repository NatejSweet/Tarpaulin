async function connect() {
    const mongoose = require('mongoose');

    let username = process.env.MONGO_USERNAME;
    let password = process.env.MONGO_PASSWORD;
    let host = process.env.MONGO_HOST;
    let port = process.env.MONGO_PORT;
    let database = process.env.MONGO_DB;

    let uri = `mongodb://${username}:${password}@${host}:${port}/${database}`;

    console.log(uri);

    try {
        await mongoose.connect(uri);
        console.log('mongo connected');
    } catch (error) {
        console.error('failed to connect to mongo', error);
    }
}

module.exports = connect;