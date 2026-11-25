import 'package:sqflite/sqflite.dart';
import '../models/atividade.dart';

class AgendaDao {
  static Future<Database> abrirBanco() {
    return openDatabase(
      'agenda_fatec.db',
      version: 1,
      onCreate: (banco, versao) async {
        await banco.execute('''CREATE TABLE atividades (
          id INTEGER PRIMARY KEY, titulo TEXT NOT NULL, tipo TEXT NOT NULL,
          disciplina TEXT NOT NULL, local TEXT NOT NULL, data TEXT NOT NULL,
          entregue INTEGER NOT NULL, topicos TEXT NOT NULL)''');
      },
    );
  }

  static Future<List<Atividade>> listar() async {
    final banco = await abrirBanco();
    final linhas = await banco.query('atividades', orderBy: 'data, id');
    return linhas.map(Atividade.fromMap).toList();
  }

  static Future<void> salvar(Atividade atividade) async {
    final banco = await abrirBanco();
    if (atividade.id == null) {
      await banco.insert('atividades', atividade.toMap());
    } else {
      await banco.update(
        'atividades',
        atividade.toMap(),
        where: 'id = ?',
        whereArgs: [atividade.id],
      );
    }
  }
}
