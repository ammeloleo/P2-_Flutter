import 'dart:convert';
import 'dart:js_interop';
import '../models/atividade.dart';

@JS('listarAgenda')
external JSPromise<JSString> _listar();

@JS('salvarAgenda')
external JSPromise<JSAny?> _salvar(JSString dados);

class AgendaDao {
  static Future<List<Atividade>> listar() async {
    final resposta = await _listar().toDart;
    final linhas = jsonDecode(resposta.toDart) as List;
    final atividades = linhas.map((linha) => Atividade.fromMap(linha)).toList();
    atividades.sort((a, b) {
      final ordem = a.data.compareTo(b.data);
      return ordem == 0 ? a.id!.compareTo(b.id!) : ordem;
    });
    return atividades;
  }

  static Future<void> salvar(Atividade atividade) async {
    final dados = atividade.toMap();
    if (atividade.id != null) dados['id'] = atividade.id;
    await _salvar(jsonEncode(dados).toJS).toDart;
  }
}
