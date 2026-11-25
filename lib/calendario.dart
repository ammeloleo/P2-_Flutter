import 'package:flutter/material.dart';
import 'models/atividade.dart';

class Calendario extends StatelessWidget {
  final DateTime dia;
  final List<Atividade> atividades;
  final ValueChanged<DateTime> selecionar;
  const Calendario({
    super.key,
    required this.dia,
    required this.atividades,
    required this.selecionar,
  });

  @override
  Widget build(BuildContext context) {
    final primeiro = DateTime(dia.year, dia.month);
    final ultimo = DateTime(dia.year, dia.month + 1, 0);
    final espacos = primeiro.weekday % 7;
    final diasOcupados = {
      for (final a in atividades)
        if (a.data.year == dia.year && a.data.month == dia.month) a.data.day,
    };
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Mês anterior',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => selecionar(DateTime(dia.year, dia.month - 1)),
            ),
            Text(MaterialLocalizations.of(context).formatMonthYear(dia)),
            IconButton(
              tooltip: 'Próximo mês',
              icon: const Icon(Icons.chevron_right),
              onPressed: () => selecionar(DateTime(dia.year, dia.month + 1)),
            ),
          ],
        ),
        Row(
          children: [
            for (final nome in [
              'Dom',
              'Seg',
              'Ter',
              'Qua',
              'Qui',
              'Sex',
              'Sáb',
            ])
              Expanded(child: Center(child: Text(nome))),
          ],
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          mainAxisExtent: 48,
          children: [
            for (int i = 0; i < espacos; i++) const SizedBox(),
            for (int i = 1; i <= ultimo.day; i++)
              TextButton(
                onPressed: () => selecionar(DateTime(dia.year, dia.month, i)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: i == dia.day ? Colors.red.shade800 : null,
                  foregroundColor: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$i'),
                    SizedBox(
                      height: 6,
                      child: diasOcupados.contains(i)
                          ? const Icon(Icons.circle, size: 6)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
