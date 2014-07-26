#! /usr/bin/env node

// usage: userAgent.js <port> to set up the server, then use browser to navigate
if (process.argv.length <= 2) {
  console.error('a port number should be given!');
  return;
}

var http = require('http');
console.log('the server is set up on ' + process.argv[2] + '...\n');
http.createServer(function (req, res) {
  res.write('<html><head><title>show the userAgent</title></head><body>');
  res.write('Your userAgent is ' + req.headers['user-agent'] + '</body>');
  res.write('</html>');
  res.end();
}).listen(Number(process.argv[2]));

