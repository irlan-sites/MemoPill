// ver_remedios.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:memopill/remedios_provider.dart';
import 'detalhes_remedio_screen.dart';

class VerRemediosScreen extends StatelessWidget {
  const VerRemediosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        title: const Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: colorScheme.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40.0),
                Text(
                  'Meus Remédios',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: colorScheme.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 32.0),
                Expanded(
                  child: Consumer<RemediosProvider>(
                    builder: (context, provider, child) {
                      final remedios = List<Remedio>.from(provider.remedios);
                      remedios.sort((a, b) {
                        final aTime = TimeOfDay.fromDateTime(a.dataHora);
                        final bTime = TimeOfDay.fromDateTime(b.dataHora);
                        final aMinutes = aTime.hour * 60 + aTime.minute;
                        final bMinutes = bTime.hour * 60 + bTime.minute;
                        return aMinutes.compareTo(bMinutes);
                      });
                      if (remedios.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhum remédio cadastrado.',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: remedios.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final remedio = remedios[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(15.0),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetalhesRemedioScreen(remedio: remedio),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  if (colorScheme.brightness ==
                                      Brightness.light)
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage:
                                        remedio.fotoPath != null &&
                                            File(remedio.fotoPath!).existsSync()
                                        ? FileImage(File(remedio.fotoPath!))
                                        : null,
                                    child:
                                        (remedio.fotoPath == null ||
                                            !File(
                                              remedio.fotoPath!,
                                            ).existsSync())
                                        ? Icon(
                                            Icons.medication,
                                            color: colorScheme.primary,
                                            size: 32,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          remedio.nome,
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Horário: ' +
                                              TimeOfDay.fromDateTime(
                                                remedio.dataHora,
                                              ).format(context),
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Compartimento: ${remedio.compartimento}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog de edição foi atualizado para usar o novo método do provider
class EditarRemedioDialog extends StatefulWidget {
  final Remedio remedio;
  const EditarRemedioDialog({super.key, required this.remedio});

  @override
  State<EditarRemedioDialog> createState() => _EditarRemedioDialogState();
}

class _EditarRemedioDialogState extends State<EditarRemedioDialog> {
  late String nome;
  late TimeOfDay horario;
  late int compartimento;
  late String? fotoPath;
  late DateTime data;

  @override
  void initState() {
    super.initState();
    nome = widget.remedio.nome;
    horario = TimeOfDay.fromDateTime(widget.remedio.dataHora);
    compartimento = widget.remedio.compartimento;
    fotoPath = widget.remedio.fotoPath;
    data = widget.remedio.dataHora;
  }

  Future<void> _selecionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horario,
    );
    if (picked != null && picked != horario) {
      setState(() {
        horario = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF32343A) : Colors.white,
      title: Text(
        'Editar Remédio',
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: nome),
              onChanged: (v) => nome = v,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.white : Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selecionarHorario(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Horário',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      horario.format(context),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: compartimento.toString()),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  compartimento = int.tryParse(v) ?? compartimento,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Compartimento',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.white : Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            if (nome.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('O nome não pode ficar em branco!'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            final provider = Provider.of<RemediosProvider>(
              context,
              listen: false,
            );

            // Cria o objeto do remédio novo
            final remedioNovo = Remedio(
              nome: nome,
              dataHora: DateTime(
                data.year,
                data.month,
                data.day,
                horario.hour,
                horario.minute,
              ),
              compartimento: compartimento,
              fotoPath: fotoPath,
            );

            // Usa o novo método do provider
            final sucesso = await provider.editarRemedio(
              widget.remedio,
              remedioNovo,
            );

            if (sucesso) {
              if (mounted) Navigator.of(context).pop();
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Este compartimento já está ocupado!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
