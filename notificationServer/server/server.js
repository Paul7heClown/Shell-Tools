const fs = require('fs');
const http = require('http');
const io = require('socket.io');
const notifier = require('node-notifier');

const port = 6969;

const server = http.createServer();
const socketServer = io(server);

server.listen(port, () => {
    console.log('Notification Server available on Port %d', port);
    printLogo();
});

function printLogo() {
    const logo = `
    _______   ___________________.______________.____________     ________________.___________    _______
    \\      \\  \\_____  \\__    ___/|   \\_   _____/|   \\_   ___ \\   /  _  \\__    ___/|   \\_____  \\   \\      \\
    /   |   \\  /   |   \\|    |   |   ||    __)  |   /    \\  \\/  /  /_\\  \\|    |   |   |/   |   \\  /   |   \\
   /    |    \\/    |    \\    |   |   ||     \\   |   \\     \\____/    |    \\    |   |   /    |    \\/    |    \\
   \\____|__  /\\_______  /____|   |___|\\___  /   |___|\\______  /\\____|__  /____|   |___\\_______  /\\____|__  /
           \\/         \\/                \\/                \\/         \\/                     \\/         \\/
                   __________________________________   _________________________
                  /   _____/\\_   _____/\\______   \\   \\ /   /\\_   _____/\\______   \\
                  \\_____  \\  |    __)_  |       _/\\   Y   /  |    __)_  |       _/
                  /        \\ |        \\ |    |   \\ \\     /   |        \\ |    |   \\
                 /_______  //_______  / |____|_  /  \\___/   /_______  / |____|_  /
                         \\/         \\/         \\/                   \\/         \\/
    `;
    console.log(logo.replace(/\\n/g, '\n').replace(/\\t/g, '\t'));
}

function timePad(t) {
    return t < 10 ? '0' + t : '' + t;
}

function getTime() {
    const date = new Date();

    const day = timePad(date.getDate());
    const month = timePad(date.getMonth() + 1);
    const year = date.getFullYear();
    const h = timePad(date.getHours());
    const i = timePad(date.getMinutes());
    const s = timePad(date.getSeconds());

    return  year + '-' + month +  '-' + day + ' ' + h + ':' + i + ':' + s + ' ';
}

socketServer.on('connection', (socket) => {
    const socketId = socket.id;
    const clientIp = socket.request.connection.remoteAddress;
    const clientPort = socket.request.connection.remotePort;
    const curTime = getTime();
    console.log(`[${curTime.trim()}] New connection from ${clientIp}:${clientPort}`);

    socket.on('notification', (icon, title, msg) => {
        const iconPath = `./icons/${icon}.png`;
        const defaultIconPath = './icons/terminal.png';

        if (fs.existsSync(iconPath)) {
            icon = iconPath;
        } else {
            icon = defaultIconPath;
        }

        notifier.notify({
            title,
            message: msg,
            sound: true,
            icon,
        });

        const logMsg = `[${icon}] ${curTime} ${title}: ${msg}\n`;
        console.log(logMsg);
        fs.appendFileSync('log.txt', logMsg);
    });

    socket.on('done', () => {
        socket.emit('ack');
    });
});
