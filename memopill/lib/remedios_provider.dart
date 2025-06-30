import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart';
import 'dart:io';

class Remedio {
  final String nome;
  final DateTime dataHora;
  final int compartimento;
  final String? fotoPath;

  // Usa um getter para o ID para garantir consistência.
  // O ID é derivado do timestamp, então cada remédio tem um ID único para o alarme.
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

    final alarmSettings = AlarmSettings(
      id: remedio.id,
      dateTime: remedio.dataHora,
      assetAudioPath: 'assets/som_alarme.mp3', // Use um som de alarme real
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: 'MemoPill - Hora do Remédio!',
        body: 'Está na hora de tomar seu remédio: ${remedio.nome}.',
        stopButton: 'Tomar',
      ),
      androidFullScreenIntent: true,
      warningNotificationOnKill: Platform.isIOS,
    );

    await Alarm.set(alarmSettings: alarmSettings);
    print("Alarme agendado para ${remedio.nome} às ${remedio.dataHora}");

    notifyListeners();
    return true;
  }

  Future<void> removerRemedio(Remedio remedio) async {
    await Alarm.stop(remedio.id);
    print("Alarme ${remedio.id} cancelado.");

    _remedios.removeWhere(
      (r) => r.nome == remedio.nome && r.compartimento == remedio.compartimento,
    );
    await _salvarRemedios();
    notifyListeners();
  }

  Future<bool> editarRemedio(Remedio remedioAntigo, Remedio remedioNovo) async {
    if (remedioNovo.compartimento != remedioAntigo.compartimento &&
        compartimentoOcupado(remedioNovo.compartimento)) {
      return false;
    }

    await Alarm.stop(remedioAntigo.id);
    print("Alarme antigo ${remedioAntigo.id} cancelado para edição.");

    _remedios.removeWhere(
      (r) =>
          r.nome == remedioAntigo.nome &&
          r.compartimento == remedioAntigo.compartimento,
    );
    _remedios.add(remedioNovo);
    await _salvarRemedios();

    final alarmSettings = AlarmSettings(
      id: remedioNovo.id,
      dateTime: remedioNovo.dataHora,
      assetAudioPath: 'assets/som_alarme.mp3', // Use um som de alarme real
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: 'MemoPill - Hora do Remédio!',
        body: 'Está na hora de tomar seu remédio: ${remedioNovo.nome}.',
        stopButton: 'Tomar',
      ),
      androidFullScreenIntent: true,
      warningNotificationOnKill: Platform.isIOS,
    );

    await Alarm.set(alarmSettings: alarmSettings);
    print(
      "Novo alarme agendado para ${remedioNovo.nome} às ${remedioNovo.dataHora}",
    );

    notifyListeners();
    return true;
  }

  Future<void> _salvarRemedios() async {
    final prefs = await SharedPreferences.getInstance();
    final remediosJson = _remedios.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('remedios', remediosJson);
  }
}
