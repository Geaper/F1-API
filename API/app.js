const express = require('express');
const app = express();
const mysql = require('mysql');
const port = process.env.PORT | 3000;

var con = mysql.createConnection({
    host: 'localhost',
    port: '3310',
    user: 'root',
    password: 'admin'
});

con.connect(function(err) {
    if(err) throw err;
    console.log("Conencted to MySqL database");
});

app.listen(port, () => {
    console.log("Listening on port " + port);
});

// Add headers
app.use(function (req, res, next) {

    // Website you wish to allow to connect
    res.setHeader('Access-Control-Allow-Origin', '*');

    // Request methods you wish to allow
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');

    // Request headers you wish to allow
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

    // Pass to next layer of middleware
    next();
});

// Routing

// Circuits
app.get("/api/circuits", (req, res) => {
    const sql = "SELECT * from f1db.circuits";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Drivers
app.get("/api/drivers", (req, res) => {
    const sql = "SELECT * from f1db.drivers";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Status
app.get("/api/status", (req, res) => {
    const sql = "SELECT * from f1db.status";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Seasons
app.get("/api/seasons", (req, res) => {
    const sql = "SELECT * from f1db.seasons";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Races
app.get("/api/races", (req, res) => {
    const sql = "SELECT * from f1db.races";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Qualifying
app.get("/api/qualifying", (req, res) => {
    const sql = "SELECT * from f1db.qualifying";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Pitstops
app.get("/api/pitstops", (req, res) => {
    const sql = "SELECT * from f1db.pitstops";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Driver Standings
app.get("/api/driverStandings", (req, res) => {
    const sql = "SELECT * from f1db.driverStandings";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Constuctor Results
app.get("/api/constructorResults", (req, res) => {
    const sql = "SELECT * from f1db.constructorResults";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Constuctor Standings
app.get("/api/constructorStandings", (req, res) => {
    const sql = "SELECT * from f1db.constructorStandings";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Constuctors
app.get("/api/constructors", (req, res) => {
    const sql = "SELECT * from f1db.constructors";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// Results
app.get("/api/results", (req, res) => {
    const sql = "SELECT * from f1db.results";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});

// LapTimes
app.get("/api/lapTimes", (req, res) => {
    const sql = "SELECT * from f1db.lapTimes";
    con.query(sql, function(err, circuits) {
        if(err) throw err;
        res.send(circuits);
    })
});




