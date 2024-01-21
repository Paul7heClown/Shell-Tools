const io = require('socket.io-client');
const notifier = require('node-notifier');

const socket = io.connect('http://192.168.178.52:6969', { reconnect: false });

const notifications = [
  { type: 'php', title: 'DEPRECATED', message: 'Depricated Warning on file deprecated.class.php:231 \nmore details\n......' },
  { type: 'node', title: 'NodeJS', message: 'Error: Cannot find module \'socket.io-client\'' },
  { type: 'java', title: 'ERROR PersistenceManager', message: ' - Failed to load entity ActiveDirectory ContinousIntegration-AD (#3): 14 propertie' },
  { type: 'terminal', title: 'set-proxy.sh', message: 'File can be executed by all users' }
];

const sleep = (waitTimeInMs) => new Promise(resolve => setTimeout(resolve, waitTimeInMs));

async function sendNotifications() {
  for (const notification of notifications) {
    socket.emit('notification', notification.type, notification.title, notification.message);
    await sleep(1000); // Adjust the delay as needed
  }

  socket.emit('done');
}

sendNotifications();

socket.on('ack', function () {
  process.exit();
});
