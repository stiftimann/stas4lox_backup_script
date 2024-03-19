# stas4lox_backup_scrip
Hallo Zusammen, ich habe mir jetzt ein kleines für mich passendes Sicherungssystem der InfluxDB aufgebaut. Für meinen defekten USB-Stick war die zip-Funktion über das Terminal das einzige was geholfen hat mir die Daten zu retten, sichern und wieder mit einzubinden. Über die Conjobfunktionalität des Loxberrys habe ich in den Loxberry-Ordner /system/cron/cron.daily ein das Skript Influx_DB_Save (ohne Dateierweiterung) abgelegt. Dieses ruft das Script Influx_DB_Save.sh im Legacy-Ordner /webfrontend/legacy auf. Folgende Funktionen waren mir wichtig und konnte ich umsetzten:
- Tägliches automatisches Abspeichern der InfluxDB als zip-Datei vom USB-Stick am Loxberry auf eine NAS-Platte im LAN.
- Prüfung der InfluxDB auf korrupte Daten (mit den internen Funktionen von InfluxDB).
- E-Mailbenachrichtigung nach dem Speichern der InfluxDB mit einem Ministatus in der Betreffzeile (siehe Screenshot) und den Details im Text der E-Mail.
- Löschen alter Sicherungen wenn Anzahl der zu behaltenen Tage erreicht ist.
- Speicherintervalle über die Ablage in den con.xxx Ordnern frei wählbar.
- Dokumentation befindet sich im Skript.

Die fertigen Dateien habe ich hier mit als zip-Datei hinzugefügt. Im oberen Teil der Influx_DB_Save.sh müssen ein paar Anpassungen eingebracht. Das sind Pfade, Dateinamen, Anzahl der zu behaltenden Dateien und die E-Mail Adresse für den Bericht.

Vielleicht passt es nicht für jeden, aber man kann sich an den Codeschnipsel bedienen und sich Schritt für Schritt über bspw. Visual-Studio-Code und dem Terminal durchhangeln.
