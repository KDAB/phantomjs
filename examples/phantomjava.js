var javabinding = require('javabinding');
var system = require('system');

console.log("Hello World!");

javabinding.listen(function(data) {
    console.log("Recieved data from Java: " + data);
});

javabinding.call(JSON.stringify(system.args));
