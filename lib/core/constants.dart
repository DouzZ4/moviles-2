// constants.dart
// Archivo de constantes globales para la app CheckINC.
// Incluye colores, nombres de tablas, rutas y mensajes de uso común.

import 'package:flutter/material.dart';

// Colores principales de la app
const Color azulPrincipal = Color(0xFF3058a6); // Color azul corporativo
const Color naranjaPrincipal = Color(0xFFf45501); // Color naranja para botones

// Nombres de tablas en SQLite
const String tablaUsuarios = 'usuarios';
const String tablaGlucosa = 'glucosa';

// Rutas de navegación usadas en la app
const String rutaLogin = '/login';
const String rutaRegister = '/register';
const String rutaDashboard = '/dashboard';

// Mensajes de error y sistema
const String msgErrorConexion = 'Error de conexión. Inténtalo de nuevo.';
const String msgUsuarioNoEncontrado = 'Usuario no encontrado.';
