// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// Importa tus ViewModels
import 'package:checkinc/viewmodels/usuario_viewmodel.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';

// Importa tu vista inicial
import 'package:checkinc/views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ),
    );
  }
}
