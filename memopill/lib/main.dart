// lib/main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memopill/remedios_provider.dart';
import 'package:memopill/historico_provider.dart';
import 'package:memopill/historico_screen.dart';
import 'package:memopill/adicionar_remedio_screen.dart';
import 'package:memopill/ver_remedios.dart';
import 'package:alarm/alarm.dart';
import 'package:memopill/alarm_screen.dart';

// Chave global para navegação, agora acessível em todo o aplicativo.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Manipulador de alarme centralizado que funciona em segundo plano.
Future<void> handleAlarmRing(AlarmSettings alarmSettings) async {
  final prefs = await SharedPreferences.getInstance();
  // Garante que estamos lendo os dados mais recentes do disco.
  await prefs.reload();

  final remediosJson = prefs.getStringList('remedios') ?? [];
  final historicoJson = prefs.getStringList('historico') ?? [];

  Remedio? remedio;
  try {
    final remedioMap = remediosJson
        .map((e) => jsonDecode(e))
        .firstWhere((map) => Remedio.fromMap(map).id == alarmSettings.id);
    remedio = Remedio.fromMap(remedioMap);
  } catch (e) {
    debugPrint("Alarme tocou para remédio não encontrado: ${alarmSettings.id}");
    // Se o remédio não existe mais, apenas para o alarme para evitar toques futuros.
    await Alarm.stop(alarmSettings.id);
    return;
  }

  // Cria um evento no histórico com o status 'Perdido' assim que o alarme toca.
  // Se o usuário confirmar, o status será atualizado para 'Tomado'.
  final evento = HistoricoEvento(
    id: remedio.id,
    nomeRemedio: remedio.nome,
    horario: DateTime.now(), // Usa o horário atual do disparo
    status: 'Perdido',
  );

  // Evita adicionar um evento duplicado de 'Perdido' para o mesmo alarme.
  final eventoExistente = historicoJson
      .map((e) => jsonDecode(e))
      .any(
        (map) =>
            HistoricoEvento.fromMap(map).id == evento.id &&
            HistoricoEvento.fromMap(map).status == 'Perdido',
      );

  if (!eventoExistente) {
    historicoJson.insert(0, jsonEncode(evento.toMap()));
    await prefs.setStringList('historico', historicoJson);
  }

  // Abre a tela do alarme para o usuário interagir.
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => AlarmScreen(alarmSettings: alarmSettings),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  Alarm.ringStream.stream.listen(handleAlarmRing);
  runApp(const MemoPillAppWithKey());
}

class MemoPillAppWithKey extends StatelessWidget {
  const MemoPillAppWithKey({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoPillApp(navigatorKey: navigatorKey);
  }
}

class MemoPillApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MemoPillApp({super.key, required this.navigatorKey});

  @override
  State<MemoPillApp> createState() => _MemoPillAppState();
}

class _MemoPillAppState extends State<MemoPillApp> {
  bool _darkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _darkMode = !_darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RemediosProvider()),
        ChangeNotifierProvider(create: (_) => HistoricoProvider()),
      ],
      child: MaterialApp(
        navigatorKey: widget.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'MemoPill',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF2196F3),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF1976D2),
            background: Colors.white,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: Colors.black,
            onSurface: Colors.black,
          ),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF2196F3)),
            titleTextStyle: TextStyle(
              color: Color(0xFF2196F3),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontFamily: 'Roboto',
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: 0.5,
                fontFamily: 'Roboto',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.w800,
              fontSize: 62,
              letterSpacing: 1.2,
              fontFamily: 'Roboto',
            ),
            titleLarge: TextStyle(
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.w700,
              fontSize: 26,
              letterSpacing: 0.8,
              fontFamily: 'Roboto',
            ),
            bodyLarge: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.5,
              fontFamily: 'Roboto',
            ),
            bodyMedium: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              letterSpacing: 0.3,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1976D2),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1976D2),
            secondary: Color(0xFF2196F3),
            background: Color(0xFF181C22),
            surface: Color(0xFF23272F),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: Colors.white,
            onSurface: Colors.white,
          ),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFF181C22),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF23272F),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF2196F3)),
            titleTextStyle: TextStyle(
              color: Color(0xFF2196F3),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontFamily: 'Roboto',
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: 0.5,
                fontFamily: 'Roboto',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.w800,
              fontSize: 62,
              letterSpacing: 1.2,
              fontFamily: 'Roboto',
            ),
            titleLarge: TextStyle(
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.w700,
              fontSize: 26,
              letterSpacing: 0.8,
              fontFamily: 'Roboto',
            ),
            bodyLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.5,
              fontFamily: 'Roboto',
            ),
            bodyMedium: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              letterSpacing: 0.3,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
        home: MainScreen(
          onToggleDarkMode: _toggleDarkMode,
          darkMode: _darkMode,
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onToggleDarkMode;
  final bool darkMode;
  const MainScreen({
    super.key,
    required this.onToggleDarkMode,
    required this.darkMode,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              widget.darkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: widget.darkMode
                                  ? Colors.yellow[600]
                                  : Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.darkMode ? 'Modo escuro' : 'Modo claro',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Switch(
                              value: widget.darkMode,
                              onChanged: (_) {
                                Navigator.of(context).pop();
                                widget.onToggleDarkMode();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistoricoScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MemoPill',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 80.0),
                _buildMenuButton(
                  context: context,
                  iconData: Icons.medication_liquid_outlined,
                  iconColor: const Color(0xFFE67E22),
                  text: 'Adicionar\nRemédios',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdicionarRemedioScreen(),
                      ),
                    );
                  },
                  darkMode: widget.darkMode,
                ),
                const SizedBox(height: 24.0),
                _buildMenuButton(
                  context: context,
                  iconData: Icons.medication_outlined,
                  iconColor: const Color(0xFF3498DB),
                  text: 'Ver\nRemédios',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerRemediosScreen(),
                      ),
                    );
                  },
                  darkMode: widget.darkMode,
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildMenuButton({
  required BuildContext context,
  required IconData iconData,
  required Color iconColor,
  required String text,
  required VoidCallback onPressed,
  bool darkMode = false,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 8,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    ),
    child: Row(
      children: [
        Icon(iconData, color: Colors.white, size: 40.0),
        const SizedBox(width: 20.0),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
      ],
    ),
  );
}
