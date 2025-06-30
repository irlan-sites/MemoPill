import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricoEvento {
  final String nomeRemedio;
  final DateTime horario;
  final String status; // 'Tomado' ou 'Perdido'

  HistoricoEvento({
    required this.nomeRemedio,
    required this.horario,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'nomeRemedio': nomeRemedio,
    'horario': horario.toIso8601String(),
    'status': status,
  };

  static HistoricoEvento fromMap(Map<String, dynamic> map) => HistoricoEvento(
    nomeRemedio: map['nomeRemedio'],
    horario: DateTime.parse(map['horario']),
    status: map['status'],
  );
}

class HistoricoProvider extends ChangeNotifier {
  final List<HistoricoEvento> _eventos = [];

  List<HistoricoEvento> get eventos => List.unmodifiable(_eventos);

  HistoricoProvider() {
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final eventosJson = prefs.getStringList('historico') ?? [];
    _eventos.clear();
    _eventos.addAll(
      eventosJson.map((e) => HistoricoEvento.fromMap(jsonDecode(e))),
    );
    notifyListeners();
  }

  Future<void> adicionarEvento(HistoricoEvento evento) async {
    _eventos.insert(0, evento);
    final prefs = await SharedPreferences.getInstance();
    final eventosJson = _eventos.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('historico', eventosJson);
    notifyListeners();
  }
}
