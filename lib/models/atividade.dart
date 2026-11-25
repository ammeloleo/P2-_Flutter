import 'dart:convert';

class Atividade {
  int? id;
  String titulo, tipo, disciplina, local;
  DateTime data;
  bool entregue;
  Map<String, bool> topicos;

  Atividade({
    this.id,
    required this.titulo,
    required this.tipo,
    required this.data,
    this.disciplina = '',
    this.local = '',
    this.entregue = false,
    required this.topicos,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'tipo': tipo,
      'disciplina': disciplina,
      'local': local,
      'data': data.toIso8601String(),
      'entregue': entregue ? 1 : 0,
      'topicos': jsonEncode(topicos),
    };
  }

  factory Atividade.fromMap(Map<String, dynamic> linha) {
    return Atividade(
      id: linha['id'],
      titulo: linha['titulo'],
      tipo: linha['tipo'],
      disciplina: linha['disciplina'],
      local: linha['local'],
      data: DateTime.parse(linha['data']),
      entregue: linha['entregue'] == 1,
      topicos: Map<String, bool>.from(jsonDecode(linha['topicos'])),
    );
  }
}
