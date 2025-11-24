import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/login/administrador.dart';
import 'package:sistema_objetos_perdidos/login/usuario.dart';

class LoginPersonas {
  final List<Administrador> _administradoresRegistrados = [];
  final List<UsuarioBasico> _usuariosRegistrados = [];

  static const Administrador e1 = Administrador("Link", "Hyrule");
  static const Administrador e2 = Administrador("Ganon", "Gerudo");

  static const UsuarioBasico u1 = UsuarioBasico("Jake el perro", "ay canijote");
  static const UsuarioBasico u2 = UsuarioBasico("correo@udec.cl", "12345678");
  static const UsuarioBasico u3 = UsuarioBasico("correo1@udec.cl", "87654321");

  LoginPersonas() {
    _administradoresRegistrados.add(e1);
    _administradoresRegistrados.add(e2);

    _usuariosRegistrados.add(u1);
    _usuariosRegistrados.add(u2);
    _usuariosRegistrados.add(u3);
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
    final bool esValido = _usuariosRegistrados.any(
      (usuario) =>
          usuario.nombreUsuario == nombreUsuario && usuario.contra == contra,
    );

    if (esValido) {
      debugPrint("Credenciales válidas como usuario: $nombreUsuario");
    }

    return esValido;
  }
}
