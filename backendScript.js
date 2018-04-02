/*
Node file where we make requests to the database
*/
var mysql = require('mysql');
var http = require('http');

// Make a request with requestobject and get result
function reqsql(sqlinput, _callback) {

  // Create connection to database, specify your own user/pass.
  var con = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: ""
  });

  // Connect and make queries.
  con.connect(function(err) {
    if (err) throw err;
    console.log("Connected!");


    // Selecting the database
    var sql = "use lab2";
    con.query(sql, function(err, result) {
      if (err) throw err;
    });

    sql = sqlinput;
    // Make query request to database
    con.query(sql, function(err, result) {
      if (err) throw err;
      _callback(result);
    });

    // close connection
    con.end();
  });
}

// Might get upgraded to a socket in future.
http.createServer(function(request, response) {
  console.log("request recieved");

  // Collect recieved data
  var body = '';
  request.on('data', function(data) {
    body += data;
  });
  request.on('end', function() {
    console.log("Data recieved: " + body);
    // Convert to Json object
    var sqlrecieved = body;

    // Get result and return to client
    reqsql(sqlrecieved, function(result) {

      // respond with result
      response.end(JSON.stringify(result));
      console.log("done");
    });
  });

  response.writeHead(200, {
    "Content-Type": "text/plain"
  });

}).listen(8001);
