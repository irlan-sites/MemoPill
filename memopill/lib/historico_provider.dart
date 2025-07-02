import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricoEvento {
  final int id; // ID do remédio, para referência
  final String nomeRemedio;
  final DateTime horario;
  String status; // 'Tomado' ou 'Perdido' (agora pode ser alterado)

  HistoricoEvento({
    required this.id,
    required this.nomeRemedio,
    required this.horario,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nomeRemedio': nomeRemedio,
    'horario': horario.toIso8601String(),
    'status': status,
  };

  static HistoricoEvento fromMap(Map<String, dynamic> map) => HistoricoEvento(
    id: map['id'],
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

  Future<void> _salvarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final eventosJson = _eventos.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('historico', eventosJson);
    notifyListeners();
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
    // Garante que a lista está sincronizada antes de adicionar
    await _carregarHistorico();
    _eventos.insert(0, evento);
    await _salvarHistorico();
  }

  // Nova função para atualizar um evento para "Tomado"
  Future<void> marcarComoTomado(int eventoId) async {
    // *** CORREÇÃO IMPORTANTE: Garante que o provider tem o estado mais recente do disco. ***
    await _carregarHistorico();

    try {
      final evento = _eventos.firstWhere((e) => e.id == eventoId);
      if (evento.status == 'Perdido') {
        evento.status = 'Tomado';
        // Salva a lista agora atualizada e sincronizada.
        await _salvarHistorico();
      }
    } catch (e) {
      // Evento não encontrado, não faz nada.
      debugPrint(
        "Tentativa de marcar como tomado falhou: evento com id $eventoId não encontrado.",
      );
    }
  }
}
