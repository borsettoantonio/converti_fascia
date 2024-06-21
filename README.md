# converti
20.06.2024

Converte il formato del database di fascia dalla versione 1.x.x
alla versione 2.0.1

Nel database pazienti.db è stata cambiata la gestione dei punti
nella corona esterna, che ora può avere fino a tre sottopunti.

Per utilizzare il programma con Windows occorre compilare con:
flutter build windows

quindi nella cartella converti\build\windows\x64\runner\Release
si trovano i file da installare.

Occorre anche mettere nella stessa cartella i file di installazione di sqlite,
da: https://sqlite.org/download.html

In converti\build\windows\x64\runner\Release\.dart_tool\sqflite_common_ffi\databases
occorre inserire il database da convertire con il nome pazientiOld.db.

Il risultato della conversione si troverà nella stessa cartella con il nome pazienti.db

