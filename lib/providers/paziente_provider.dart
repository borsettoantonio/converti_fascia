import 'dart:typed_data';
import 'dart:ui';

class Paziente {
  int id;
  String cognome;
  String nome;
  String? telefono;
  String? indirizzo;
  String? citta;
  String? email;
  Uint8List punti; // 4 bytes  per 32 segmanti
  String? note;

  Paziente({
    required this.id,
    required this.cognome,
    required this.nome,
    this.telefono,
    this.indirizzo,
    this.citta,
    this.email,
    required this.punti,
    this.note,
  });

  static Paziente mapToObj(Map<String, Object?> p) {
    return Paziente(
      id: p['id']! as int,
      cognome: p['cognome']! as String,
      nome: p['nome']! as String,
      telefono: p['telefono'] as String?,
      indirizzo: p['indirizzo'] as String?,
      citta: p['citta'] as String?,
      email: p['email'] as String?,
      punti: p['punti']! as Uint8List,
      note: p['note'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'cognome': cognome,
      'nome': nome,
      'telefono': telefono,
      'indirizzo': indirizzo,
      'citta': citta,
      'email': email,
      'punti': punti,
      'note': note,
    };
  }
}

class SegmentoInput {
  List<bool> attiviExt = [false, false, false, false, false, false];
  List<List<bool>> attiviInt = [
    [false, false, false],
    [false, false, false],
    [false, false, false],
    [false, false, false],
  ];
  Offset posizione = const Offset(0.0, 0.0); // centro del cerchio
}

class SegmentoOutput {
  List<List<bool>> attiviExt = [
    [false, false, false],
    [false, false, false],
    [false, false, false],
    [false, false, false],
    [false, false, false],
    [false, false, false],
  ];
  List<List<bool>> attiviInt = [
    [false, false, false],
    [false, false, false],
    [false, false, false],
    [false, false, false],
  ];
  Offset posizione = const Offset(0.0, 0.0); // centro del cerchio
}

class Conversione {
  // segmenti di un paziente
  static List<SegmentoInput> segmentiInput = [];
  static List<SegmentoOutput> segmentiOutput = [];

  static List<Paziente> converti(
      List<Paziente> lista) // lista di tutti i pazienti
  {
    List<Paziente> res = [];
    for (var paz in lista) {
      setPazienteCorrente(paz); // da lista di interi a segmenti
      segInpToOut(); // da segmenti vecchi a segmenti nuovi
      paz.punti = updatePunti(); // da segmenti a lista di interi
      res.add(paz);
    }
    return res;
  }

  static void setPazienteCorrente(Paziente paz) {
    initSegmentiInput();
    if (paz.punti.isEmpty) {
      return;
    }

    int k = 0; // indice nei bytes del blob
    for (int s = 0; s < 32; s++) {
      // elaboro i 32 segmenti
      int mask = 1;
      for (int j = 0; j < 6; j++) {
        //elaboro i 6 punti esterni
        segmentiInput[s].attiviExt[j] =
            (paz.punti[k] & mask) == 0 ? false : true;
        mask <<= 1;
      }
      for (int j = 0; j < 4; j++) {
        //elaboro i 4 punti interni
        for (int e = 0; e < 3; e++) {
          //elaboro i max 3 sottopunti punti interni
          segmentiInput[s].attiviInt[j][e] =
              (paz.punti[k] & mask) == 0 ? false : true;
          mask <<= 1;
          if (mask == 256) {
            mask = 1;
            k++;
          }
        }
      }
      k++;
    }
  }

  static void initSegmentiInput() {
    segmentiInput.clear();
    for (int i = 0; i < 32; i++) {
      segmentiInput.add(SegmentoInput());
    }
  }

  static void initSegmentiOutput() {
    segmentiOutput.clear();
    for (int i = 0; i < 32; i++) {
      segmentiOutput.add(SegmentoOutput());
    }
  }

  static void segInpToOut() {
    initSegmentiOutput();
    for (int s = 0; s < 32; s++) {
      for (int i = 0; i < 6; i++) {
        segmentiOutput[s].attiviExt[i][0] = segmentiInput[s].attiviExt[i];
        segmentiOutput[s].attiviExt[i][1] = false;
        segmentiOutput[s].attiviExt[i][2] = false;
      }
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
          segmentiOutput[s].attiviInt[i][j] = segmentiInput[s].attiviInt[i][j];
        }
      }
    }
  }

  static Uint8List updatePunti() {
    List<int> listaPunti = List<int>.empty(growable: true);

    for (int s = 0; s < 32; s++) {
      int dato = 0;
      int mask = 1;
      // punti esterni
      for (int i = 0; i < 6; i++) {
        for (int e = 0; e < 3; e++) {
          dato = segmentiOutput[s].attiviExt[i][e] ? dato + mask : dato;
          mask <<= 1;
          if (mask == 256) {
            mask = 1;
            listaPunti.add(dato);
            dato = 0;
          }
        }
      }
      // punti interni
      for (int i = 0; i < 4; i++) {
        for (int e = 0; e < 3; e++) {
          dato = segmentiOutput[s].attiviInt[i][e] ? dato + mask : dato;
          mask <<= 1;
          if (mask == 256) {
            mask = 1;
            listaPunti.add(dato);
            dato = 0;
          }
        }
      }
      listaPunti.add(dato);
    }

    Uint8List punti = Uint8List.fromList(listaPunti);
    return punti;
  }
}
