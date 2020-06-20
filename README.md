# IOS-RM-PI
Mittels der IOS-RM-PI App ist es möglich die Ausgänge des Raspberry PI zu steuern.

## Bedienung der App
Um sich mit einem Server zu verbinden ist die IP/URL und den Port des Servers nötig.
Nach dem drücken auf **Verbinden** wird sich mit dem Server verbunden und eine Liste mit den zu schaltenden Ausgängen wird sichtbar.
Im Fehlerfall erscheint unter **Verbinden**:
<font color="red"> Verbindungsfehler </font>


## Installation von Server-Bibliotheken
```bash
sudo apt update
sudo apt install python3-gpiozero
```
oder:
```bash
sudo apt update
sudo pip3 install gpiozero
```

## Server starten
Um den Server auf dem PI, Linux, Mac zu starten muss folgendes in eure Shell eingeben:
```bash
cd ./{Pfad zum Ordner von server.py}
sudo python3 server.py
```
Falls die Firewall auf dem PI aktiviert ist, muss vorher, wenn noch nicht geändert, der Port 1000 für eine TCP-Verbindung frei geben.

## Server konfigurieren
###### Port einstellen
Der Server ist auf den Port 1000 eingestellt. Möchte man einen Port seiner Wahl haben, muss im folgenden Quelltextabschnitt die **1000** gegen einen beliebigen Port ersetzen. 

```python
class server:
    def __init__(self):
...
        try:
            self.__serverSocket.bind(("", 1000 ))
        except:
            print("Bind failed. Error : " + str(sys.exc_info()))
            sys.exit()
...       
```        
        

###### Ausgänge einstellen
Alle Ausgänge werden in der Main vom Server eingestellt. Mittels der Funktion **CreateIO()** der Klasse **server** werden die gewünschten Ausgänge mit einem dazugehörigen Namen registriert.

In dem folgenden Beispiel wird die GPIO 5 des Raspberry PI mit dem Namen Leuchte registriert. Zu diesem Zeitpunkt ist der Ausgang ausgeschaltet.
Beispiel:
```python
if __name__ == '__main__':
    Server = server()
    Server.ioStream.CreateIO( "Leuchte", 5)
    Server.Main()
```

Um den Ausgang nun beim starten des Servers einzuschalten wird die Funktion **ChangeIO()** benötigt.
Beispiel:
```python
if __name__ == '__main__':
    Server = server()
    Server.ioStream.CreateIO( "Leuchte", 5)
    Server.ioStream.ChangeIO("Leuchte", True)
    Server.Main()
```

Als Standardeinstellung sind folgende Ausgänge eingestellt:
```python
if __name__ == '__main__':
    Server = server()

    if DEBUG:
        print("Debug mode")
        Server.ioStream.CreateIO( "Licht1", 1)
        Server.ioStream.CreateIO( "Licht2", 1)
        Server.ioStream.CreateIO( "Licht3", 1)
        Server.ioStream.CreateIO( "MotorLinks", 1)
        Server.ioStream.CreateIO( "MotorRechts", 1)

        Server.ioStream.ChangeIO("Licht1", True)

    else:
        print("Live mode")
        Server.ioStream.CreateIO( "LED1", 4)

    Server.Main()
    input("End")
```

###### Server im Debug-Mode laufen lassen
Möchte man den Server auf einem Windows, Linux oder Mac testen, ist es möglich den Server im Debug Mode alufen zu lassen.
Am Anfang der **server.py** Datei steht folgendes:
```python
DEBUG = True
```
True : 
- Es wird jede Aktion im Quelltext in der Konsole ausgegeben. 
- PI spezifische Bibliotheken werden nicht verwendet. 
- Das Schalten der Ausgänge wird als Text in der Konsole ausgegeben.

False : 
- Der Server startet im Live-Mode
- Ausgänge des PIs werden geschaltet


