// lib/remedios_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart';
import 'package:memopill/historico_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Remedio {
  final String nome;
  final DateTime dataHora;
  final int compartimento;
  final String? fotoPath;

  int get id => dataHora.millisecondsSinceEpoch.remainder(1000000);

  Remedio({
    required this.nome,
    required this.dataHora,
    required this.compartimento,
    this.fotoPath,
  });

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'dataHora': dataHora.toIso8601String(),
    'compartimento': compartimento,
    'fotoPath': fotoPath,
  };

  static Remedio fromMap(Map<String, dynamic> map) {
    return Remedio(
      nome: map['nome'],
      dataHora: DateTime.parse(map['dataHora']),
      compartimento: map['compartimento'],
      fotoPath: map['fotoPath'],
    );
  }
}

class RemediosProvider extends ChangeNotifier {
  final List<Remedio> _remedios = [];
  bool _carregado = false;
  bool get carregado => _carregado;

  List<Remedio> get remedios => List.unmodifiable(_remedios);

  RemediosProvider() {
    _carregarRemedios();
  }

  Future<void> _carregarRemedios() async {
    final prefs = await SharedPreferences.getInstance();
    final remediosJson = prefs.getStringList('remedios') ?? [];
    _remedios.clear();
    _remedios.addAll(remediosJson.map((e) => Remedio.fromMap(jsonDecode(e))));
    _carregado = true;
    notifyListeners();
  }

  bool compartimentoOcupado(int compartimento) {
    return _remedios.any((r) => r.compartimento == compartimento);
  }

  Future<bool> adicionarRemedio(Remedio remedio, BuildContext context) async {
    if (remedio.nome.trim().isEmpty) {
      return false;
    }
    if (compartimentoOcupado(remedio.compartimento)) {
      return false;
    }
    _remedios.add(remedio);
    await _salvarRemedios();
    await _agendarAlarme(remedio, context);
    notifyListeners();
    return true;
  }

  Future<void> removerRemedio(Remedio remedio) async {
    _remedios.removeWhere(
      (r) => r.nome == remedio.nome && r.compartimento == remedio.compartimento,
    );
    await _salvarRemedios();
    await Alarm.stop(remedio.id);
    notifyListeners();
  }

  Future<bool> editarRemedio(
    Remedio remedioAntigo,
    Remedio remedioNovo,
    BuildContext context,
  ) async {
    if (remedioNovo.compartimento != remedioAntigo.compartimento &&
        compartimentoOcupado(remedioNovo.compartimento)) {
      return false;
    }
    _remedios.removeWhere(
      (r) =>
          r.nome == remedioAntigo.nome &&
          r.compartimento == remedioAntigo.compartimento,
    );
    _remedios.add(remedioNovo);
    await _salvarRemedios();
    await Alarm.stop(remedioAntigo.id);
    await _agendarAlarme(remedioNovo, context);
    notifyListeners();
    return true;
  }

  Future<void> _salvarRemedios() async {
    final prefs = await SharedPreferences.getInstance();
    final remediosJson = _remedios.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('remedios', remediosJson);
  }

  Future<void> moverParaHistoricoComoPerdido(
    Remedio remedio,
    BuildContext context,
  ) async {
    // Adiciona ao histórico como Perdido
    final historicoProvider = Provider.of<HistoricoProvider>(
      context,
      listen: false,
    );
    await historicoProvider.adicionarEvento(
      HistoricoEvento(
        id: remedio.id,
        nomeRemedio: remedio.nome,
        horario: remedio.dataHora,
        status: 'Perdido',
      ),
    );
    // Remove da lista de remédios ativos
    await removerRemedio(remedio);
  }

  Future<void> _agendarAlarme(Remedio remedio, BuildContext context) async {
    await pedirPermissaoSobreporApps(); // Garante permissão antes de agendar
    final alarmSettings = AlarmSettings(
      id: remedio.id,
      dateTime: remedio.dataHora,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      notificationTitle: '',
      notificationBody: '',
      enableNotificationOnKill: true,
      // TODO: Adicionar parâmetro/callback para abrir tela de alarme em tela cheia
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  Remedio? getRemedioById(int id) {
    try {
      return _remedios.firstWhere((remedio) => remedio.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> pedirPermissaoSobreporApps() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }
  }
}
