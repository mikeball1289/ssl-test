const https = require('https');
const fs = require('fs');

const server = https.createServer({
    cert: fs.readFileSync('ssl/server.crt'),
    key: fs.readFileSync('ssl/server.key'),
    ca: fs.readFileSync('ssl/rootCA.crt'),
}, (req, res) => res.end('pong'));

server.listen(8080, () => console.log('https://localhost:8080'));