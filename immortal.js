#! /usr/bin/env node
/**
 * sleep.sh:
 * #!/bin/sh
 *
 * sleep 5
 */

var exec = require('child_process').exec;
var lifeCounter = 0;

var immortal = function() {
  var life = exec('./sleep.sh', function(err){
    if (err) throw err;
  }).on('exit', function(){
    lifeCounter += 1;
    console.log('I am revived for ' + lifeCounter + ' times');
    life = null;
    immortal();
  });
};

immortal();
