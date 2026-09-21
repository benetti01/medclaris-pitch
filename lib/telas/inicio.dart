import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/botoes.dart';
import '../widgets/textos.dart';
import 'medicamentos.dart';
import 'diario.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
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
    super.dispose();
  }

  Future<void> carregarMedicamentos() async {
    final dados = await SharedPreferences.getInstance();

    setState(() {
      medicamentos = dados.getStringList('medicamentos') ?? [];
      horarios = dados.getStringList('horarios') ?? [];
    });
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

  int quantidadePendentes() {
    int quantidade = 0;

    for (int i = 0; i < horarios.length; i++) {
      if (statusHorario(horarios[i]) != 'Horário já passou') {
        quantidade++;
      }
    }

    return quantidade;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MedClaris')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titulo('Olá!'),

            const SizedBox(height: 8),

            texto('Veja seus medicamentos de hoje.'),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.medication, size: 40),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medicamentos hoje',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text('${quantidadePendentes()} pendentes'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            titulo('Próximos medicamentos'),

            const SizedBox(height: 10),

            if (medicamentos.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Nenhum medicamento cadastrado.'),
                ),
              ),

            for (int i = 0; i < medicamentos.length; i++)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(
                    medicamentos[i],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${horarios[i]} - ${statusHorario(horarios[i])}',
                  ),
                  trailing: const Icon(Icons.access_time),
                ),
              ),

            const SizedBox(height: 20),

            botao('Meus medicamentos', () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Medicamentos()),
              );

              carregarMedicamentos();
            }),

            const SizedBox(height: 10),

            botao('Diário de saúde', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Diario()),
              );
            }),
          ],
        ),
      ),
    );
  }
}
