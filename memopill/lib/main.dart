import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memopill/remedios_provider.dart';
import 'package:memopill/historico_provider.dart';
import 'package:memopill/historico_screen.dart';
import 'package:memopill/adicionar_remedio_screen.dart';
import 'package:memopill/ver_remedios.dart';
import 'package:alarm/alarm.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();

  runApp(MemoPillAppWithKey());
}

class MemoPillAppWithKey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MemoPillApp();
  }
}

class MemoPillApp extends StatefulWidget {
  const MemoPillApp({super.key});

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
        debugShowCheckedModeBanner: false,
        title: 'MemoPill',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xFF2196F3),
          colorScheme: ColorScheme.light(
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
              backgroundColor: Color(0xFF2196F3),
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
          primaryColor: Color(0xFF1976D2),
          colorScheme: ColorScheme.dark(
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
          scaffoldBackgroundColor: Color(0xFF181C22),
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
              backgroundColor: Color(0xFF1976D2),
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
  late StreamSubscription<AlarmSet> subscription;

  @override
  void initState() {
    super.initState();
    // O ideal é ouvir o stream de alarmes para lidar com o toque do alarme
    // enquanto o app está aberto.
    subscription = Alarm.ringing.listen((alarmSettings) {
      // Aqui você pode, por exemplo, navegar para uma tela de alarme tocando
      print('Alarme ${alarmSettings.id} está tocando!');
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

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
                                style: TextStyle(
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
        color: Theme.of(
          context,
        ).colorScheme.background, // Corrige cor de fundo para modo claro/escuro
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
