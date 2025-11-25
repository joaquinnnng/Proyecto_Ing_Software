import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/login/administrador.dart';
import 'package:sistema_objetos_perdidos/login/usuario.dart';

class LoginPersonas {
  final List<Administrador> _administradoresRegistrados = [];
  final List<UsuarioBasico> usuariosRegistrados = [];

  static const Administrador e1 = Administrador("Link", "Hyrule");
  static const Administrador e2 = Administrador("Admin@udec.cl", "admin");

  static const UsuarioBasico u1 = UsuarioBasico("correo@udec.cl", "12345678");
  static const UsuarioBasico u2 = UsuarioBasico("correo1@udec.cl", "87654321");

  LoginPersonas() {
    _administradoresRegistrados.add(e1);
    _administradoresRegistrados.add(e2);

    usuariosRegistrados.add(u1);
    usuariosRegistrados.add(u2);
  }

  bool loginEditor(String nombreUsuario, String contra) {
    final bool esValido = _administradoresRegistrados.any(
      (editor) =>
          editor.nombreUsuario == nombreUsuario && editor.contra == contra,
    );

    if (esValido) {
      debugPrint("Credenciales válidas como editor: $nombreUsuario");
    }

    return esValido;
  }

  bool loginUsuario(String nombreUsuario, String contra) {
    final bool esValido = usuariosRegistrados.any(
      (usuario) =>
          usuario.nombreUsuario == nombreUsuario && usuario.contra == contra,
    );

    if (esValido) {
      debugPrint("Credenciales válidas como usuario: $nombreUsuario");
    }

    return esValido;
  }

  void registrarUsuario(UsuarioBasico nuevoUsuario) {
    usuariosRegistrados.add(nuevoUsuario);
    debugPrint("Usuario registrado: ${nuevoUsuario.nombreUsuario}");
  }
}
