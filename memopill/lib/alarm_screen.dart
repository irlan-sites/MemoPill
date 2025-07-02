// lib/alarm_screen.dart

import 'dart:async'; // 1. Importe a biblioteca 'async'
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:memopill/historico_provider.dart';
import 'package:memopill/remedios_provider.dart';
import 'package:provider/provider.dart';

class AlarmScreen extends StatefulWidget {
  // Converta para StatefulWidget
  final AlarmSettings alarmSettings;

  const AlarmScreen({Key? key, required this.alarmSettings}) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // 2. Inicia um timer de 1 minuto.
    _timeoutTimer = Timer(const Duration(minutes: 1), () {
      if (mounted) {
        // Remove o remédio da lista ativa, pois o usuário não interagiu.
        final remediosProvider = Provider.of<RemediosProvider>(
          context,
          listen: false,
        );
        final remedio = remediosProvider.getRemedioById(
          widget.alarmSettings.id,
        );
        if (remedio != null) {
          remediosProvider.removerRemedio(remedio); // Isso também para o alarme
        } else {
          Alarm.stop(widget.alarmSettings.id); // Garante que o alarme pare
        }
        Navigator.pop(context); // Fecha a tela do alarme
      }
    });
  }

  @override
  void dispose() {
    // 3. Cancela o timer para evitar erros se a tela for fechada manualmente.
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _snooze(BuildContext context) async {
    _timeoutTimer?.cancel(); // 4. Cancela o timer na interação do usuário
    final now = DateTime.now();
    final snoozedTime = now.add(const Duration(minutes: 5));

    final newAlarmSettings = widget.alarmSettings.copyWith(
      id: widget.alarmSettings.id,
      dateTime: snoozedTime,
    );

    await Alarm.set(alarmSettings: newAlarmSettings);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirm(BuildContext context) async {
    _timeoutTimer?.cancel(); // 5. Cancela o timer na interação do usuário
    final historicoProvider = Provider.of<HistoricoProvider>(
      context,
      listen: false,
    );
    await historicoProvider.marcarComoTomado(widget.alarmSettings.id);
    // Remove o remédio da lista ativa ao confirmar
    final remediosProvider = Provider.of<RemediosProvider>(
      context,
      listen: false,
    );
    final remedio = remediosProvider.getRemedioById(widget.alarmSettings.id);
    if (remedio != null) {
      await remediosProvider.removerRemedio(remedio);
    }
    if (context.mounted) {
      // A chamada `removerRemedio` já para o alarme, mas mantemos por segurança.
      await Alarm.stop(widget.alarmSettings.id);
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
                widget.alarmSettings.notificationBody,
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
