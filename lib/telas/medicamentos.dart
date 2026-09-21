import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/botoes.dart';
import '../widgets/textos.dart';

class Medicamentos extends StatefulWidget {
  const Medicamentos({super.key});

  @override
  State<Medicamentos> createState() => _MedicamentosState();
}

class _MedicamentosState extends State<Medicamentos> {
  final nome = TextEditingController();
  final horario = TextEditingController();

  List<String> medicamentos = [];
  List<String> horarios = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();

    carregarMedicamentos();

    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    nome.dispose();
    horario.dispose();
    super.dispose();
  }

  Future<void> carregarMedicamentos() async {
    final dados = await SharedPreferences.getInstance();

    setState(() {
      medicamentos = dados.getStringList('medicamentos') ?? [];
      horarios = dados.getStringList('horarios') ?? [];
    });
  }

  Future<void> salvarMedicamentos() async {
    final dados = await SharedPreferences.getInstance();

    await dados.setStringList('medicamentos', medicamentos);

    await dados.setStringList('horarios', horarios);
  }

  void adicionarMedicamento() {
    if (nome.text.isEmpty || horario.text.isEmpty) {
      return;
    }

    final partes = horario.text.split(':');

    if (partes.length != 2) {
      return;
    }

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null ||
        minuto == null ||
        hora < 0 ||
        hora > 23 ||
        minuto < 0 ||
        minuto > 59) {
      return;
    }

    setState(() {
      medicamentos.add(nome.text);
      horarios.add(horario.text);
    });

    salvarMedicamentos();

    nome.clear();
    horario.clear();

    Navigator.pop(context);
  }

  void removerMedicamento(int index) {
    setState(() {
      medicamentos.removeAt(index);
      horarios.removeAt(index);
    });

    salvarMedicamentos();
  }

  String statusHorario(String horario) {
    final agora = TimeOfDay.now();
    final partes = horario.split(':');

    if (partes.length != 2) {
      return '';
    }

    final hora = int.parse(partes[0]);
    final minuto = int.parse(partes[1]);

    final minutosAgora = agora.hour * 60 + agora.minute;
    final minutosMedicamento = hora * 60 + minuto;

    if (minutosMedicamento == minutosAgora) {
      return 'Tomar agora';
    }

    if (minutosMedicamento > minutosAgora) {
      return 'Próximo medicamento';
    }

    return 'Horário já passou';
  }

  void abrirCadastro() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo medicamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nome,
                decoration: const InputDecoration(labelText: 'Medicamento'),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: horario,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Horário',
                  hintText: 'Ex: 08:30',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: adicionarMedicamento,
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus medicamentos')),

      body: medicamentos.isEmpty
          ? const Center(child: Text('Nenhum medicamento cadastrado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: medicamentos.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.medication),

                    title: Text(
                      medicamentos[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      '${horarios[index]} - ${statusHorario(horarios[index])}',
                    ),

                    trailing: IconButton(
                      onPressed: () {
                        removerMedicamento(index);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: abrirCadastro,
        child: const Icon(Icons.add),
      ),
    );
  }
}
