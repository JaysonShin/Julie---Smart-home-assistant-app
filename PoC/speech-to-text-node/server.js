const express = require('express');
const http = require('http');
const formidable = require('formidable');
const bodyParser = require('body-parser');
const util = require('util');
const SpeechToTextV1 = require('watson-developer-cloud/speech-to-text/v1');
const fs = require('fs');

var server = express();

server.use('/', express.static(__dirname + '/'));
server.use(bodyParser.json()); 

server.post('/sendVoice', function(request, response, next) {
	var form = new formidable.IncomingForm(),
	fields = [],
    files = [],
	filename = '';

	form.on('error', function(err){
		response.writeHead(200, {'content-type': 'text/plain'});
		response.end('error:\n\n' + util.inspect(err));
	});

	form.on('field', function(field, value){
		console.log(field, value);
		fields.push([field, value]);
	});

	form.on('file', function(field, file){
		console.log(field, file);
		filename = file.path.split("\\").slice(-1)[0];
		files.push([field, file]);
	});

	form.on('end', function(){
		console.log('Audio file upload done.\nSending it to IBM Watson for speech recognition...');
		const speech_to_text = new SpeechToTextV1({
		  username: '<your_username>',
		  password: '<your_password>'
		});

		const params = {
		  content_type: 'audio/wav'
		};

		const recognizeStream = speech_to_text.createRecognizeStream(params);
		fs.createReadStream(__dirname + '/tmp/' + filename).pipe(recognizeStream); 		
		recognizeStream.setEncoding('utf8');

		['results', 'speaker_labels', 'close'].forEach(function(eventName) {
		  recognizeStream.on(eventName, console.log.bind(console, eventName + ' event: '));
		});
		
		recognizeStream.on('error', function(data){ 
			console.log('Error  occurred!!!')
			response.sendStatus(500)		
		});
		
		var transcription = '';
		recognizeStream.on('data', function(data){ 
			transcription = data;
			console.log('We got something: ' + data);
		});
		
		recognizeStream.on('close', function(data){ 
			var returnRes = '"'+transcription+'"';
			response.writeHead(200, {'content-type': 'text/plain'});
			response.end(returnRes);
		});
		
	});
	form.uploadDir = 'tmp';
	form.keepExtensions = true;
	form.parse(request);
});

server.listen(5566, function () {
  console.log('Server started, listening on port 5566.')
})