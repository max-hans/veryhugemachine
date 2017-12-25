const WebSocket = require('ws');
brain = require('brain');

const fs = require('fs');
var argv = require('minimist')(process.argv.slice(2));
console.log(argv);
var wsPort = argv.p;

const wss = new WebSocket.Server({ port: wsPort });

var clientIp;
var net = new brain.NeuralNetwork({
  hiddenLayers: [5,5],
  learningRate: 0.3
});

var inData = [];



var netParams = {
	iterations: 10000,
	log: true,
	errorThresh: 0.0001,
	logPeriod: 50
}

wss.on('connection', function connection(ws,req) {
  console.log("new connection");

	console.log(req.connection.remoteAddress);
	ws.on('message', function incoming(message) {

		console.log('received: %s', message);

		var cmd = message.split(",");

		switch(cmd[0]){

			case "ip":{
				console.log("received position data");
				console.log(cmd);
				addToDatasetPos(cmd);
				break;
			}

      case "l":{
        console.log("starting learning procedure");
        console.log(cmd);
        startLearning();
        break;
      }

			case "o":{
				console.log("received request");
				console.log(cmd);
				getDataPos(cmd);
				break;
			}

		}


	});

	ws.on('open', function open(){
		console.log("new connection established");
	});
});

function startLearning(){
	net.train(inData, netParams);
	console.log("training done! - error rate: ")
}

function addToDatasetPos(data){
	var pair = {};

	// data structure (normalized)
	// input: 	startposition.x,startposition.y
	// output:  steps1,steps2

	pair.input = [data[1],data[2]];
	pair.output = [data[3],data[4]];
	console.log(pair);
	inData.push(pair);
}

function getDataPos(data){
	/*var pair = {
		input:[data[1],data[2]]
	};*/
	var output = net.run([data[1],data[2]]);
	var outString = "data," + output[0] + ',' + output[1];
	sendData(outString);
	console.log(outString);
}

function sendData(inData){
	console.log(inData);
  // add send command
}

function saveNet(path){
	var jsonNet = net.toJSON();
	const content = JSON.stringify(jsonNet);
	fs.writeFile(path + ".json", content, 'utf8', function (err) {
		if (err) {
			return console.log(err);
		}
		console.log("net was saved successfully");
	});
}

function loadNet(path){
	fs.readFile(path + ".json", 'utf8', function (err,data) {
		if (err) {
			return console.log(err);
		}
		console.log(data);
	});
	net.fromJSON(json);
}


////////////////////////////////////////////////////////////////////////

function getDataVec(data){
	var pair = {
		input:[data[1],data[2],data[3],data[4]]
	};
	var output = net.run(input);
	var outString = "data," + output[0] + ',' + output[1];
	sendData(outString);
	console.log(outString);
}

function addToDatasetVec(data){
	var pair = {};

	// data structure (normalized)
	// input: 	startposition.x,startposition.y,targetposition.x,targetposition.y
	// output:  steps1,steps2

	pair.input = [data[1],data[2],data[3],data[4]];
	pair.output = [data[5],data[6]];
	inData.push(pair);
}
