// lib/alarm_screen.dart

import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:memopill/historico_provider.dart';
import 'package:memopill/remedios_provider.dart';
import 'package:provider/provider.dart';

class AlarmScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmScreen({Key? key, required this.alarmSettings}) : super(key: key);

  Future<void> _snooze(BuildContext context) async {
    final now = DateTime.now();
    // Adia o alarme por 5 minutos a partir de agora.
    final snoozedTime = now.add(const Duration(minutes: 5));

    final newAlarmSettings = alarmSettings.copyWith(
      id: alarmSettings.id,
      dateTime: snoozedTime,
    );

    await Alarm.set(alarmSettings: newAlarmSettings);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirm(BuildContext context) async {
    final historicoProvider = Provider.of<HistoricoProvider>(
      context,
      listen: false,
    );
    // 1. Marca o remédio como 'Tomado' no histórico.
    // Esta função agora encontra o evento 'Perdido' e o atualiza.
    await historicoProvider.marcarComoTomado(alarmSettings.id);

    // 2. Remove o remédio da lista de remédios ativos.
    final remediosProvider = Provider.of<RemediosProvider>(
      context,
      listen: false,
    );
    final remedio = remediosProvider.getRemedioById(alarmSettings.id);
    if (remedio != null) {
      // O método removerRemedio também para o alarme associado.
      await remediosProvider.removerRemedio(remedio);
    } else {
      // Garante que o alarme pare, mesmo que o remédio não seja encontrado.
      await Alarm.stop(alarmSettings.id);
    }

    // 3. Fecha a tela do alarme.
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Hora de tomar seu remédio!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                alarmSettings.notificationBody,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _snooze(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      "Adiar",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _confirm(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Já Tomei",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
