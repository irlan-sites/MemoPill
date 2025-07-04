// lib/adicionar_remedio_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:memopill/remedios_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // 1. Importe o permission_handler

class AdicionarRemedioScreen extends StatefulWidget {
  const AdicionarRemedioScreen({super.key});

  @override
  State<AdicionarRemedioScreen> createState() => _AdicionarRemedioScreenState();
}

class _AdicionarRemedioScreenState extends State<AdicionarRemedioScreen> {
  // ... (código existente sem alterações)
  int compartimento = 1;
  TimeOfDay horario = const TimeOfDay(hour: 12, minute: 0);
  File? _fotoRemedio;
  String nomeRemedio = '';
  DateTime? dataRemedio;

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() {
        _fotoRemedio = File(foto.path);
      });
    }
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

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataRemedio ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        dataRemedio = picked;
      });
    }
  }
  // ... (código existente sem alterações)

  // 2. Adicione a função para checar e solicitar permissões
  Future<bool> _verificarPermissoes() async {
    // Solicita permissão para notificações
    var statusNotificacao = await Permission.notification.request();
    if (statusNotificacao.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Permissão de notificação é necessária para os alarmes.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Solicita permissão para alarmes exatos
    if (await Permission.scheduleExactAlarm.request().isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissão de alarme exato é necessária.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  // ... (Widget build e outras funções)
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<RemediosProvider>(context);
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
      body: Stack(
        children: [
          // Conteúdo normal da tela
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40.0),
                    Text(
                      'Adicionar Remédios',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: _fotoRemedio != null
                                      ? FileImage(_fotoRemedio!)
                                      : null,
                                  child: _fotoRemedio == null
                                      ? Icon(
                                          Icons.camera_alt,
                                          color: colorScheme.primary,
                                          size: 32,
                                        )
                                      : null,
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(32),
                                      onTap: _tirarFoto,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            'Nome do remédio',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            onChanged: (value) => nomeRemedio = value,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Horário',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () => _selecionarHorario(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.transparent,
                              ),
                              child: Text(
                                horario.format(context),
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Data',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () => _selecionarData(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.transparent,
                              ),
                              child: Text(
                                dataRemedio != null
                                    ? '${dataRemedio!.day.toString().padLeft(2, '0')}/${dataRemedio!.month.toString().padLeft(2, '0')}/${dataRemedio!.year}'
                                    : 'Selecione a data',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Compartimento',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: compartimento > 1
                                    ? () {
                                        setState(() {
                                          compartimento--;
                                        });
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(8.0),
                                  backgroundColor: Colors.red.shade200,
                                  foregroundColor: Colors.black87,
                                  minimumSize: const Size(40, 40),
                                ),
                                child: const Icon(Icons.remove),
                              ),
                              const SizedBox(width: 16.0),
                              Text(
                                '$compartimento',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              ElevatedButton(
                                onPressed: compartimento < 28
                                    ? () {
                                        setState(() {
                                          compartimento++;
                                        });
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(8.0),
                                  backgroundColor: Colors.green.shade200,
                                  foregroundColor: Colors.black87,
                                  minimumSize: const Size(40, 40),
                                ),
                                child: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50.0),
                          InkWell(
                            onTap: () async {
                              // 3. Chame a função de verificação antes de salvar
                              final permissoesConcedidas =
                                  await _verificarPermissoes();
                              if (!permissoesConcedidas) return;

                              final provider = Provider.of<RemediosProvider>(
                                context,
                                listen: false,
                              );

                              if (dataRemedio == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Selecione a data para tomar o remédio!',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return; // Encerra a execução aqui
                              }

                              if (nomeRemedio.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'O nome do remédio não pode ficar em branco!',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return; // Encerra a execução aqui
                              }

                              final sucesso = await provider.adicionarRemedio(
                                Remedio(
                                  nome: nomeRemedio,
                                  dataHora: DateTime(
                                    dataRemedio!.year,
                                    dataRemedio!.month,
                                    dataRemedio!.day,
                                    horario.hour,
                                    horario.minute,
                                  ),
                                  compartimento: compartimento,
                                  fotoPath: _fotoRemedio?.path,
                                ),
                                context,
                              );

                              // O 'mounted' verifica se o widget ainda está na árvore de widgets
                              if (!mounted) return;

                              if (sucesso) {
                                // Primeiro fecha a tela atual
                                Navigator.of(context).pop();
                                // Opcional: Mostra o SnackBar na tela anterior (se necessário)
                                // ScaffoldMessenger.of(context).showSnackBar( ... );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Compartimento já ocupado! Escolha outro.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8e2DE2),
                                    Color(0xFF4A00E0),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: const Center(
                                child: Text(
                                  'Enviar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading sobreposto
          if (!provider.carregado)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
