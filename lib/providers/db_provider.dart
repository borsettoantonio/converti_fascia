import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'paziente_provider.dart';

typedef MapCallback = void Function(String testo);

class DB {
  Future<Database> openDbInput(MapCallback message) async {
    final nomeFile = join(
      await getDatabasesPath(),
      'pazientiOld.db',
    );
    var db = await openDatabase(
      nomeFile,
      onCreate: (database, version) {
        message('Il file pazientiOld.db non è presente');
      },
      version: 1,
    );
    return db;
  }

  Future<Database> openDbOutput() async {
    final nomeFile = join(
      await getDatabasesPath(),
      'pazienti.db',
    );
    var db = await openDatabase(
      nomeFile,
      onCreate: (database, version) {
        database.execute(
            'CREATE TABLE Pazienti(id INTEGER PRIMARY KEY, cognome TEXT, nome TEXT,telefono TEXT,'
            'indirizzo TEXT, citta TEXT, email TEXT, punti blob, note TEXT )');
      },
      version: 1,
    );
    return db;
  }

  Future<List<Paziente>> getPazienti(Database db) async {
    final List<Map<String, Object?>> paz = await db.query(
      'Pazienti',
    );
    return [for (var p in paz) Paziente.mapToObj(p)];
  }

  Future<void> scriviPazienti(Database db, List<Paziente> pazienti) async {
    for (Paziente paz in pazienti) {
      Map<String, Object?> values = paz.toMap();
      await db.insert(
        'Pazienti',
        values,
      );
    }
  }
}
