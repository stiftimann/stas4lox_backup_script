# -------------------------------------------------------------------------------------------------
# Sicherungsscript für InfluxDB Plugin.
# -------------------------------------------------------------------------------------------------

# Anzahl der zu sichernden Tage.
dat_hold=7

# Anzahl '-' Zeilentrennzeichen.
anz_minus=117

# E-Mail Adresse des Berichts.
email_address='XXXXX.XXXXX@XXX.XXX'

# Aktuelles Datum.
date_save=$(date +%Y%m%d_%H%M%S)    # Volles Datum, Teil 1 der abzuspeichernden Dateien.
date_save_cut=${date_save%_*}       # Gekürztes Datum.

# Quell- und Zielepfad.
path_influxdb_sour="/opt/loxberry/system/storage/usb/Stats4Lox/Stats4Lox_DB2/influxdb/"     # Pfad zum Quelle der InfluxDB auf USB-Stick.
path_influxdb_dest="/media/smb/XXXX.XXX.XXX.XXX/backup/usb_influx/"                         # Pfad zum Ziel der Sicherung auf NAS.

# Dateinamen.
name_text_save="_influx_inspect.txt"            # Teil 2 des Namens des txt-Datei die zur Sichwerungsdatei mit erzeugt wird.
file_influxdb_text=$date_save$name_text_save
name_usb_zip="_usb_stick_stats4lox_db2.zip"     # Teil 2 des Names der zip-Datei in der die InfluxDB-Daten gesichert werden.
file_influxdb_zip=$date_save$name_usb_zip

# Zusammengesetzte Pfade.
path_complete_sour="$path_influxdb_sour$file_influxdb_usb"
path_complete_dest_text="$path_influxdb_dest$file_influxdb_text"
path_complete_dest_zip="$path_influxdb_dest$file_influxdb_zip"

# Erstellung der Minuszeile als Trennzeile.
anz_minus=$(yes "-" | head -$anz_minus  | xargs | sed 's/ //g' | cut -c1-$anz_minus)
echo $anz_minus

# Ausgabe der Pfade in Textdatei.
printf 'Pfad Quelle InfluxDB auf Loxberry (USB-Stick): '$path_complete_sour'\n''Pfad Ziel InfluxDB (Synology): '$path_influxdb_dest'\n''Pfad der zu sichernen txt-Datei: '$path_complete_dest_text'\n''Pfad der zu sichernden zip-Datei: '$path_complete_dest_zip'\n' 2>&1 | tee -a $path_complete_dest_text
echo "" >> $path_complete_dest_text                         # Leerzeile.
echo $anz_minus 2>&1 | tee -a $path_complete_dest_text      # Minuszeile.

# Schreiben der Daten aus 'influx_inspect' command in Textdatei.
influx_inspect verify -dir $path_influxdb_sour 2>&1 | tee -a $path_complete_dest_text

# Auslesen des Status aus der letzten Zeile.
last_row=$(tail -1 $path_complete_dest_text)    # Statuszeile 'influx_inspect'
last_row_cut=${last_row%/*}                     # Abschneiden hinter '/', um nur die "broken blocks" anzuzeigen. 

# Sicherung der InfluxDB als zip-Datei.
zip $path_complete_dest_zip -r $path_influxdb_sour

# Löschen der alten Dateien, behalten der letzten 14 Dateien = 7 Tage. 'dat_hold' wird verdoppelt da zwei Dateien pro Tag geschrieben werden.
cd $path_influxdb_dest                          # Pfad für 'ls' command setzten.
anz_dat=$(ls | wc -l)                           # Gesamtanzahl Dateien im Ordner.
dat_hold=$(expr $dat_hold + $dat_hold)          # Anzahl der zu behaltenden Dateien.
anz_files_delete=$(expr $anz_dat - $dat_hold)   # Differenz zu löschenden Dateien.
# Abfangen wenn zu wenig Dateien im Ordner sind und nichts gelöscht werden kann.
if [ $anz_files_delete -lt 1 ]
    then
        anz_files_delete=0                                      # Anzahl zu löschende Dateien.
        files_delete="Keine_zu_löschenden_Dateien_vorhanden."   # Alternativtext wenn keine zu löschenden Daten vorhanden.
    else
        files_delete=$(ls -at | tail -n $anz_files_delete)      # Zu löschende Dateien als String.
        ls -at | tail -n $anz_files_delete | xargs rm           # Löschvorgang.
fi
anz_dat=$(ls | wc -l)                                           # Anzahl der behaltenen Dateien.

# Anhängen von Informationen an die Textdatei.
echo "" >> $path_complete_dest_text
echo $anz_minus 2>&1 | tee -a $path_complete_dest_text                          # Minuszeile.
echo "Anzahl behaltene Dateien: "$anz_dat >> $path_complete_dest_text           # Anzahl behaltene Dateien.
ls 2>&1 | tee -a $path_complete_dest_text                                       # Anhängen der im Ordner bedindlichen Datein.
echo "" >> $path_complete_dest_text                                             # Leerzeile.
echo $anz_minus 2>&1 | tee -a $path_complete_dest_text                          # Minuszeile.
echo "Anzahl gelöschte Dateien: "$anz_files_delete >> $path_complete_dest_text  # Anzahl gelöschte Dateien.
sed $'s/ /\\\n/g' <<< $files_delete | tee -a $path_complete_dest_text           # Abschneiden des Strings nach 'Broken Blocks: xxx'

# Mail schicken mit Informationen.
subject_complete="InfluxDB Save: "                                      # Teil 1: Betreffzeile.
subject_complete+=$date_save_cut                                        # Teil 2: Betreffzeile.
subject_complete+=' | '                                                 # Teil 3: Betreffzeile.
subject_complete+=$last_row_cut                                         # Teil 4: Betreffzeile.
influxdb_info=$(cat $path_complete_dest_text)                           # Betreffzeile komplatt als Variable.
mail -s "$subject_complete" $email_address <<< $influxdb_info           # E-Mail Versand.