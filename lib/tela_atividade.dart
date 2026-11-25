import 'package:flutter/material.dart';
import 'agenda_dao.dart';
import 'models/atividade.dart';

class TelaAtividade extends StatefulWidget {
  final Atividade? atividade;
  final DateTime dia;
  const TelaAtividade({super.key, this.atividade, required this.dia});

  @override
  State<TelaAtividade> createState() {
    return _TelaAtividadeState();
  }
}

class _TelaAtividadeState extends State<TelaAtividade> {
  final formulario = GlobalKey<FormState>();
  final titulo = TextEditingController();
  final disciplina = TextEditingController();
  final local = TextEditingController();
  final topico = TextEditingController();
  late DateTime data;
  late TimeOfDay hora;
  String tipo = 'Trabalho';
  bool entregue = false;
  bool salvando = false;
  Map<String, bool> topicos = {};

  @override
  void initState() {
    super.initState();
    final a = widget.atividade;
    data = a?.data ?? widget.dia;
    hora = TimeOfDay.fromDateTime(a?.data ?? DateTime.now());
    if (a != null) {
      titulo.text = a.titulo;
      disciplina.text = a.disciplina;
      local.text = a.local;
      tipo = a.tipo;
      entregue = a.entregue;
      topicos = Map.of(a.topicos);
    }
  }

  @override
  void dispose() {
    titulo.dispose();
    disciplina.dispose();
    local.dispose();
    topico.dispose();
    super.dispose();
  }

  void adicionarTopico() {
    final nome = topico.text.trim();
    if (nome.isEmpty) return;
    if (!topicos.containsKey(nome)) {
      setState(() {
        topicos[nome] = false;
      });
    }
    topico.clear();
  }

  Future<void> salvar() async {
    if (salvando || !formulario.currentState!.validate()) return;
    if (tipo == 'Prova') adicionarTopico();
    setState(() {
      salvando = true;
    });
    final horario = DateTime(
      data.year,
      data.month,
      data.day,
      hora.hour,
      hora.minute,
    );
    final atividade = Atividade(
      id: widget.atividade?.id,
      titulo: titulo.text.trim(),
      disciplina: disciplina.text.trim(),
      tipo: tipo,
      data: horario,
      local: tipo == 'Evento' ? local.text.trim() : '',
      entregue: tipo == 'Trabalho' && entregue,
      topicos: tipo == 'Prova' ? topicos : {},
    );
    try {
      await AgendaDao.salvar(atividade);
      if (mounted) Navigator.pop(context, horario);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        salvando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar a atividade.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.atividade == null ? 'Nova atividade' : 'Editar atividade',
        ),
      ),
      body: Form(
        key: formulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final opcao in ['Trabalho', 'Prova', 'Evento'])
                  ChoiceChip(
                    label: Text(opcao),
                    selected: opcao == tipo,
                    onSelected: (_) => setState(() {
                      tipo = opcao;
                    }),
                  ),
              ],
            ),
            TextFormField(
              controller: titulo,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Informe o título'
                  : null,
            ),
            TextField(
              controller: disciplina,
              decoration: const InputDecoration(labelText: 'Disciplina'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: Text(
                MaterialLocalizations.of(context).formatCompactDate(data),
              ),
              onTap: () async {
                final nova = await showDatePicker(
                  context: context,
                  initialDate: data,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100, 12, 31),
                );
                if (nova != null && mounted)
                  setState(() {
                    data = nova;
                  });
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(hora.format(context)),
              onTap: () async {
                final nova = await showTimePicker(
                  context: context,
                  initialTime: hora,
                );
                if (nova != null && mounted)
                  setState(() {
                    hora = nova;
                  });
              },
            ),
            if (tipo == 'Trabalho')
              CheckboxListTile(
                title: const Text('Trabalho entregue'),
                value: entregue,
                onChanged: (valor) => setState(() {
                  entregue = valor == true;
                }),
              ),
            if (tipo == 'Evento')
              TextField(
                controller: local,
                decoration: const InputDecoration(labelText: 'Local do evento'),
              ),
            if (tipo == 'Prova') ...[
              const Text('Conteúdo para revisar'),
              for (final nome in topicos.keys)
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        value: topicos[nome],
                        title: Text(nome),
                        onChanged: (valor) =>
                            setState(() => topicos[nome] = valor == true),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remover tópico',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => topicos.remove(nome)),
                    ),
                  ],
                ),
              TextField(
                controller: topico,
                onSubmitted: (_) => adicionarTopico(),
                decoration: InputDecoration(
                  labelText: 'Novo tópico',
                  suffixIcon: IconButton(
                    tooltip: 'Adicionar tópico',
                    icon: const Icon(Icons.add),
                    onPressed: adicionarTopico,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: salvando ? null : salvar,
              child: Text(
                widget.atividade == null
                    ? 'Salvar atividade'
                    : 'Salvar alterações',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
