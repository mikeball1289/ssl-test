const https = require('https');
const fs = require('fs');

https.globalAgent.options.ca = [fs.readFileSync('ssl/rootCA.crt')];

https.get('https://localhost:8080/', res => res.on('data', d => console.log(d.toString('ascii'))));