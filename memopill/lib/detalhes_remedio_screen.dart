import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memopill/remedios_provider.dart';
import 'ver_remedios.dart' show EditarRemedioDialog;

class DetalhesRemedioScreen extends StatelessWidget {
  final Remedio remedio;
  const DetalhesRemedioScreen({Key? key, required this.remedio})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Remédio'),
        backgroundColor: colorScheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  remedio.fotoPath != null &&
                      File(remedio.fotoPath!).existsSync()
                  ? FileImage(File(remedio.fotoPath!))
                  : null,
              child:
                  (remedio.fotoPath == null ||
                      !File(remedio.fotoPath!).existsSync())
                  ? const Icon(Icons.medication, color: Colors.grey, size: 60)
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              remedio.nome,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Horário: ' +
                      TimeOfDay.fromDateTime(remedio.dataHora).format(context),
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data: ' + remedio.dataHora.toString().substring(0, 10),
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.medical_services, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Compartimento: ${remedio.compartimento}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label: const Text('Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white10 : Colors.blue[50],
                    foregroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) =>
                          EditarRemedioDialog(remedio: remedio),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Excluir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white10 : Colors.red[50],
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remover remédio'),
                        content: const Text(
                          'Tem certeza que deseja remover este remédio?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Remover',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      Provider.of<RemediosProvider>(
                        context,
                        listen: false,
                      ).removerRemedio(remedio);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
