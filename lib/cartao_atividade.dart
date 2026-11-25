import 'package:flutter/material.dart';
import 'models/atividade.dart';

class CartaoAtividade extends StatelessWidget {
  final Atividade atividade;
  final VoidCallback abrir;
  const CartaoAtividade({
    super.key,
    required this.atividade,
    required this.abrir,
  });

  @override
  Widget build(BuildContext context) {
    final datas = MaterialLocalizations.of(context);
    String detalhe = atividade.local;
    IconData icone = Icons.event;
    if (atividade.tipo == 'Trabalho') {
      detalhe = atividade.entregue ? 'Entregue' : 'Pendente';
      icone = Icons.assignment_outlined;
    } else if (atividade.tipo == 'Prova') {
      int revisados = 0;
      for (final marcado in atividade.topicos.values) {
        if (marcado) revisados++;
      }
      detalhe = '$revisados de ${atividade.topicos.length} tópicos revisados';
      icone = Icons.checklist;
    }
    final hoje = DateUtils.dateOnly(DateTime.now());
    final amanha = DateTime(hoje.year, hoje.month, hoje.day + 1);
    String prazo = datas.formatShortDate(atividade.data);
    if (DateUtils.isSameDay(atividade.data, hoje)) prazo = 'Hoje';
    if (DateUtils.isSameDay(atividade.data, amanha)) prazo = 'Amanhã';
    return Card(
      child: ListTile(
        onTap: abrir,
        leading: Icon(icone, color: Colors.redAccent),
        title: Text(atividade.titulo),
        subtitle: Text(
          [
            [
              atividade.tipo,
              atividade.disciplina,
            ].where((s) => s.isNotEmpty).join(' · '),
            '$prazo às ${TimeOfDay.fromDateTime(atividade.data).format(context)}',
            if (detalhe.isNotEmpty) detalhe,
          ].join('\n'),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
