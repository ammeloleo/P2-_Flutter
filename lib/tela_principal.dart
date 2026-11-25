import 'package:flutter/material.dart';
import 'agenda_dao.dart';
import 'calendario.dart';
import 'models/atividade.dart';
import 'tela_atividade.dart';
import 'cartao_atividade.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});
  @override
  State<TelaPrincipal> createState() {
    return _TelaPrincipalState();
  }
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int aba = 0;
  String filtro = 'Tudo';
  DateTime dia = DateUtils.dateOnly(DateTime.now());
  List<Atividade> _atividades = [];
  bool _carregando = true;
  bool _erroAoCarregar = false;

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  Future<void> _atualizarLista() async {
    setState(() {
      _carregando = true;
      _erroAoCarregar = false;
    });
    try {
      final listaNoBanco = await AgendaDao.listar();
      if (!mounted) return;
      setState(() {
        _atividades = listaNoBanco;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroAoCarregar = true;
        _carregando = false;
      });
    }
  }

  Future<void> abrirFormulario([Atividade? atividade]) async {
    final data = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaAtividade(atividade: atividade, dia: dia),
      ),
    );
    if (data == null || !mounted) return;
    setState(() {
      dia = DateUtils.dateOnly(data);
      filtro = 'Tudo';
    });
    await _atualizarLista();
  }

  Widget _mostrarAgenda(BuildContext context) {
    final inicio = DateTime(dia.year, dia.month, dia.day - dia.weekday + 1);
    final fim = DateTime(inicio.year, inicio.month, inicio.day + 7);
    final datas = MaterialLocalizations.of(context);

    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erroAoCarregar) {
      return Center(
        child: TextButton(
          onPressed: _atualizarLista,
          child: const Text('Erro ao abrir a agenda. Tentar novamente'),
        ),
      );
    }

    List<Atividade> atividades = [];
    for (final atividade in _atividades) {
      if (aba == 1) {
        if (DateUtils.isSameDay(atividade.data, dia)) {
          atividades.add(atividade);
        }
      } else {
        final naSemana =
            !atividade.data.isBefore(inicio) && atividade.data.isBefore(fim);
        final tipoSelecionado = filtro == 'Tudo' || atividade.tipo == filtro;
        if (naSemana && tipoSelecionado) {
          atividades.add(atividade);
        }
      }
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        Text(
          aba == 0 ? 'Minha semana' : 'Calendario',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (aba == 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Semana anterior',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(
                  () => dia = inicio.subtract(const Duration(days: 7)),
                ),
              ),
              Text(
                '${datas.formatShortDate(inicio)} a ${datas.formatShortDate(fim.subtract(const Duration(days: 1)))}',
              ),
              IconButton(
                tooltip: 'PrÃ³xima semana',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  dia = fim;
                }),
              ),
            ],
          ),
          Wrap(
            spacing: 6,
            children: [
              for (final tipo in ['Tudo', 'Prova', 'Trabalho', 'Evento'])
                ChoiceChip(
                  label: Text(tipo),
                  selected: filtro == tipo,
                  showCheckmark: false,
                  onSelected: (_) => setState(() {
                    filtro = tipo;
                  }),
                ),
            ],
          ),
        ] else ...[
          Calendario(
            dia: dia,
            atividades: _atividades,
            selecionar: (valor) => setState(() {
              dia = valor;
            }),
          ),
          Text(datas.formatFullDate(dia)),
        ],
        const SizedBox(height: 12),
        if (atividades.isEmpty)
          const Text('Nenhuma atividade neste perÃ­odo. Use + para adicionar.'),
        for (final a in atividades)
          CartaoAtividade(atividade: a, abrir: () => abrirFormulario(a)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda Fatec')),
      body: _mostrarAgenda(context),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova atividade',
        onPressed: _carregando ? null : () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: aba,
        onDestinationSelected: (valor) => setState(() {
          aba = valor;
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.view_week), label: 'Semana'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
        ],
      ),
    );
  }
}
