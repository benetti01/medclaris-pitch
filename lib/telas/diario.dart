import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../widgets/botoes.dart';
import '../widgets/textos.dart';

class Diario extends StatefulWidget {
  const Diario({super.key});

  @override
  State<Diario> createState() => _DiarioState();
}

class _DiarioState extends State<Diario> {
  final anotacao = TextEditingController();

  List<String> registros = [];

  int humorSelecionado = 3;

  final List<IconData> humores = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  @override
  void initState() {
    super.initState();
    carregarRegistros();
  }

  @override
  void dispose() {
    anotacao.dispose();
    super.dispose();
  }

  Future<void> carregarRegistros() async {
    final dados = await SharedPreferences.getInstance();

    setState(() {
      registros = dados.getStringList('registros') ?? [];
    });
  }

  Future<void> salvarRegistros() async {
    final dados = await SharedPreferences.getInstance();

    await dados.setStringList('registros', registros);
  }

  void salvarRegistro() {
    if (anotacao.text.trim().isEmpty) {
      return;
    }

    final agora = DateTime.now();
    final data = DateFormat('dd/MM/yyyy HH:mm').format(agora);

    setState(() {
      registros.insert(0, '$data|$humorSelecionado|${anotacao.text}');
    });

    salvarRegistros();

    anotacao.clear();

    Navigator.pop(context);
  }

  void removerRegistro(int index) {
    setState(() {
      registros.removeAt(index);
    });

    salvarRegistros();
  }

  void novoRegistro() {
    humorSelecionado = 3;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo registro'),

          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Como você está se sentindo?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < humores.length; i++)
                        GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              humorSelecionado = i + 1;
                            });
                          },
                          child: Icon(
                            humores[i],
                            size: humorSelecionado == i + 1 ? 42 : 32,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: anotacao,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Como você se sentiu hoje?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: salvarRegistro,
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diário de saúde')),

      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    '💙 Você não está sozinho!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Se estiver se sentindo mal ou apresentar sintomas '
                    'persistentes, procure um médico. Se estiver passando '
                    'por momentos de sofrimento emocional, tristeza intensa '
                    'ou outros sinais que estejam afetando sua rotina, '
                    'converse com um psicólogo ou profissional de saúde mental.',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'O MedClaris está aqui para ajudar no acompanhamento, '
                    'mas não substitui o acompanhamento de profissionais '
                    'de saúde.',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          if (registros.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Nenhum registro ainda.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            ...List.generate(registros.length, (index) {
              final partes = registros[index].split('|');

              String data = '';
              int humor = 3;
              String comentario = '';

              if (partes.length >= 3) {
                data = partes[0];
                humor = int.tryParse(partes[1]) ?? 3;
                comentario = partes.sublist(2).join('|');
              } else if (partes.length >= 2) {
                data = partes[0];
                comentario = partes.sublist(1).join('|');
              }

              if (humor < 1 || humor > 5) {
                humor = 3;
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              data,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Icon(humores[humor - 1], size: 30),

                          IconButton(
                            onPressed: () {
                              removerRegistro(index);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(comentario, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: novoRegistro,
        child: const Icon(Icons.add),
      ),
    );
  }
}
