import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart';

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

  List<Remedio> get remedios => List.unmodifiable(_remedios);

  RemediosProvider() {
    _carregarRemedios();
  }

  Future<void> _carregarRemedios() async {
    final prefs = await SharedPreferences.getInstance();
    final remediosJson = prefs.getStringList('remedios') ?? [];
    _remedios.clear();
    _remedios.addAll(remediosJson.map((e) => Remedio.fromMap(jsonDecode(e))));
    notifyListeners();
  }

  bool compartimentoOcupado(int compartimento) {
    return _remedios.any((r) => r.compartimento == compartimento);
  }

  Future<bool> adicionarRemedio(Remedio remedio) async {
    if (remedio.nome.trim().isEmpty) {
      return false;
    }
    if (compartimentoOcupado(remedio.compartimento)) {
      return false;
    }
    _remedios.add(remedio);
    await _salvarRemedios();
    await _agendarAlarme(remedio);
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

  Future<bool> editarRemedio(Remedio remedioAntigo, Remedio remedioNovo) async {
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
    await _agendarAlarme(remedioNovo);
    notifyListeners();
    return true;
  }

  Future<void> _salvarRemedios() async {
    final prefs = await SharedPreferences.getInstance();
    final remediosJson = _remedios.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('remedios', remediosJson);
  }

  Future<void> _agendarAlarme(Remedio remedio) async {
    final alarmSettings = AlarmSettings(
      id: remedio.id,
      dateTime: remedio.dataHora,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      notificationTitle: 'Hora do Remédio!',
      notificationBody: remedio.nome,
      enableNotificationOnKill: true,
    );
    await Alarm.set(alarmSettings: alarmSettings);

    // Parar o alarme automaticamente após 1 minuto
    Future.delayed(const Duration(minutes: 1), () async {
      await Alarm.stop(remedio.id);
    });
  }

  Remedio? getRemedioById(int id) {
    try {
      return _remedios.firstWhere((remedio) => remedio.id == id);
    } catch (e) {
      return null;
    }
  }
}
