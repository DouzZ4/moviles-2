// main.dart
// Punto de entrada de la aplicación CheckINC.
// Configura Firebase, SQLite y el sistema de rutas principal.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importa los ViewModels globales para el manejo de estado
import 'package:checkinc/viewmodels/usuario_viewmodel.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';

// Importa la vista inicial y formularios principales
import 'package:checkinc/views/login_view.dart';
import 'package:checkinc/views/glucosa/glucosa_form_view.dart';

/// Función principal que inicializa servicios y ejecuta la app
void main() async {
  // Asegura la inicialización de los bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa SQLite FFI solo en plataformas de escritorio
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Inicializa Firebase con las opciones generadas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ejecuta la aplicación principal
  runApp(const MyApp());
}

/// Widget raíz de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provee los ViewModels a toda la app
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioViewModel()),
        ChangeNotifierProvider(create: (_) => GlucosaViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Oculta la etiqueta de debug
        title: 'CheckINC',
        theme: ThemeData(
          primaryColor: const Color(0xFF3058a6),
          scaffoldBackgroundColor: Colors.white,
        ),
        // Configuración de localización para widgets como DatePicker
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''), // Español
          Locale('en', ''), // Inglés (opcional)
        ],
        home: const LoginView(), // Vista inicial
        // Sistema de rutas dinámico para pasar argumentos
        onGenerateRoute: (settings) {
          if (settings.name == '/glucosa/formulario') {
            final idUsuario = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => GlucosaFormView(idUsuario: idUsuario),
            );
          }
          return null;
        },
      ),
    );
  }
}
