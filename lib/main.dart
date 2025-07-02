// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Importa tus ViewModels
import 'package:checkinc/viewmodels/usuario_viewmodel.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';

// Importa tu vista inicial
import 'package:checkinc/views/login_view.dart';
import 'package:checkinc/views/glucosa/glucosa_form_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa databaseFactoryFfi para escritorio
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioViewModel()),
        ChangeNotifierProvider(create: (_) => GlucosaViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CheckINC',
        theme: ThemeData(
          primaryColor: const Color(0xFF3058a6),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const LoginView(),
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
