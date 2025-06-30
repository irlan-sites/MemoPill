import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memopill/historico_provider.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Remédios'),
        backgroundColor: colorScheme.background,
      ),
      body: Consumer<HistoricoProvider>(
        builder: (context, provider, child) {
          if (provider.eventos.isEmpty) {
            return Center(
              child: Text(
                'Nenhum evento registrado.',
                style: TextStyle(color: colorScheme.primary),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.eventos.length,
            itemBuilder: (context, index) {
              final evento = provider.eventos[index];
              return ListTile(
                leading: Icon(
                  evento.status == 'Tomado' ? Icons.check_circle : Icons.cancel,
                  color: evento.status == 'Tomado' ? Colors.green : Colors.red,
                ),
                title: Text(
                  evento.nomeRemedio,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  '${evento.status} em ${evento.horario.day.toString().padLeft(2, '0')}/'
                  '${evento.horario.month.toString().padLeft(2, '0')}/'
                  '${evento.horario.year} às '
                  '${evento.horario.hour.toString().padLeft(2, '0')}:'
                  '${evento.horario.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
