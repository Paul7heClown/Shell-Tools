# NotificationServer

## Server
Der Server lauscht standardmäßig auf jeder lokalen IP-Adresse und erfordert keine zusätzliche Konfiguration. Beachte, dass die Firewall entsprechend konfiguriert sein muss.

### Installation
Voraussetzungen:
- Node.js muss auf dem System installiert sein.

Installation der Module:
```bash
cd server
npm install
```
Starten des Servers:
```
node server.js
```

## Autostart des Servers
Die Konfiguration für den Autostart des Servers variiert je nach Betriebssystem. Weitere Informationen findest du durch Recherche im Internet oder durch Rücksprache mit Kollegen.

### Watcher-Konfiguration
Die Socket-Konfiguration im Watcher-Script (watcher.js) muss entsprechend angepasst werden. Ersetze <server.ip> durch die IP-Adresse des Notification Servers.

```
const socket = io.connect('http://<server.ip>:6969', { reconnect: true });
```
Wichtig ist, dass reconnect: true gesetzt ist, um mögliche Netzwerkprobleme zu behandeln.

## Autostart des Watchers (Nur für Linux)

Um den Watcher beim Systemstart zu aktivieren, folge diesen Schritten:

- Stelle sicher, dass der Watcher in der Shell ohne Probleme ausgeführt werden kann (node watcher.js im watcher-Verzeichnis).
- Falls Fehler auftreten, installiere fehlende Node-Module mit npm install im Watcher-Verzeichnis.
- Erstelle oder modifiziere die notification_watcher.service-Datei mit den entsprechenden Einstellungen.
- Kopiere die .service-Datei oder erstelle einen Symlink im /etc/systemd/system-Verzeichnis.
- Lade den Daemon neu und aktiviere den Dienst:
```
sudo systemctl daemon-reload
sudo systemctl enable notification_watcher
```

Beispiel für eine funktionierende .service-Datei (Pfade anpassen):

```text
[Unit]
Description=Notification Server (Watcher)
After=network.target

[Service]
User=<username>
Type=simple
ExecStart=/home/<username>/.nvm/versions/node/v18.12.1/bin/node /home/<username>/workspace/notificationServer/watcher/watcher.js
Restart=on-failure
KillMode=process
StartLimitBurst=0

[Install]
WantedBy=multi-user.target
```

Hinweis: Diese README.md kann weiter angepasst werden, um sie an spezifische Bedürfnisse anzupassen.



--- english part ---


# NotificationServer

## Server

The server listens by default on any local IP address and requires no additional configuration. Note that the firewall must be configured accordingly.
Installation

### Prerequisites:
- Node.js must be installed on the system.

### Install the modules:

```bash
cd server
npm install
```

## Start the server:

```bash
node server.js
```

## Autostart of the Server

The configuration for autostarting the server varies depending on the operating system. Find more information through online research or by consulting with colleagues.
Watcher Configuration

The socket configuration in the watcher script (watcher.js) needs to be adjusted accordingly. Replace <server.ip> with the IP address of the Notification Server.

```php
const socket = io.connect('http://<server.ip>:6969', { reconnect: true });
```

It's important that reconnect: true is set to handle potential network issues.
Autostart of the Watcher (Linux only)

To activate the watcher on system startup, follow these steps:

- Ensure that the watcher can be executed in the shell without issues (node watcher.js in the watcher directory).
- If errors occur, install missing Node modules with npm install in the watcher directory.
- Create or modify the notification_watcher.service file with the corresponding settings.
- Copy the .service file or create a symlink in the /etc/systemd/system directory.
- Reload the daemon and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable notification_watcher
``` 

Example of a working .service file (adjust paths):

```makefile
[Unit]
Description=Notification Server (Watcher)
After=network.target

[Service]
User=<username>
Type=simple
ExecStart=/home/<username>/.nvm/versions/node/v18.12.1/bin/node /home/<username>/workspace/notificationServer/watcher/watcher.js
Restart=on-failure
KillMode=process
StartLimitBurst=0

[Install]
WantedBy=multi-user.target
```

Note: This README.md can be further customized to meet specific needs.
