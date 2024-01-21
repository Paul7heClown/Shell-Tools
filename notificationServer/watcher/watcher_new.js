const io = require('socket.io-client');
const notifier = require("node-notifier");
const Tail = require('nodejs-tail');

// File operations
const fs = require('fs');

const filenames = [
  '/var/log/apache2/error.log',
  '/var/log/apache2/error.log.1'
];

const socket = io.connect('http://192.168.178.52:6969', {reconnect: true});

const tails = [];

for (const filename of filenames) {
  const tail = new Tail(filename);
  tails.push(tail);

  console.log("Watcher: " + filename);

  tail.on('line', (line) => {
    var pattern = /(deprecated|warning|notice|error): (.*)/ig;
    var match = pattern.exec(line);
    if (match !== null && match.length > 0) {
      log(match[1], match[2]);
      socket.emit('notification', 'php', match[1], match[2]);
    }
  });

  tail.on('close', () => {
    log('Connection', 'closed');
    console.log('Watcher stopped for: ' + filename);
  });

  tail.watch();
}

function timePad(t) {
  return t < 10 ? "0" + t : "" + t;
}

function getTime() {
  var date = new Date();

  const day = timePad(date.getDate());
  const month = timePad(date.getMonth() + 1);
  const year = date.getFullYear();
  const h = timePad(date.getHours());
  const i = timePad(date.getMinutes());
  const s = timePad(date.getSeconds());

  return year + "-" + month + "-" + day + " " + h + ":" + i + ":" + s + " ";
}

function log(title, msg) {
  var curTime = getTime();
  let logMsg = "[" + curTime + "] " + title + ": " + msg + "\n";
  console.log(logMsg);
  fs.appendFileSync('log.txt', logMsg);
}

console.log("    __      __  _________________________   ___ ________________________ ");
console.log("   /  \\    /  \\/  _  \\__    ___/\\_   ___ \\ /   |   \\_   _____/\\______   \\");
console.log("   \\   \\/\\/   /  /_\\  \\|    |   /    \\  \\//    ~    \\    __)_  |       _/");
console.log("    \\        /    |    \\    |   \\     \\___\\    Y    /        \\ |    |   \\");
console.log("     \\__/\\  /\\____|__  /____|    \\______  /\\___|_  /_______  / |____|_  /");
console.log("          \\/         \\/                 \\/       \\/        \\/         \\/ ");
