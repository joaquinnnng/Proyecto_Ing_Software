import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/administrador/ventanaAdmin.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/botones.dart';
import 'package:sistema_objetos_perdidos/login/administrador.dart';
import 'package:sistema_objetos_perdidos/login/Usuario.dart';
import 'package:sistema_objetos_perdidos/login/inicio_sesion.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final LoginPersonas _loginManager = LoginPersonas();

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contraController = TextEditingController();

  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _usuarioController.dispose();
    _contraController.dispose();
    super.dispose();
  }

  void _abrirVentanaAdministrador() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => ventanaAdmin()));
  }

  void _abrirVentanaUsuario(UsuarioBasico usuario) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainButtons() /*usuario: usuario*/,
      ),
    );
  }

  void _iniciarSesion() {
    final String usuario = _usuarioController.text.trim();
    final String contra = _contraController.text.trim();

    if (_loginManager.loginEditor(usuario, contra)) {
      debugPrint("Inicio de sesión como Administrador exitoso");
      setState(() {
        _mensajeError = null;
      });
      _abrirVentanaAdministrador();
    } else if (_loginManager.loginUsuario(usuario, contra)) {
      debugPrint("Inicio de sesión como usuario exitoso");

      setState(() {
        _mensajeError = null;
      });

      final UsuarioBasico user = UsuarioBasico(usuario, contra);
      _abrirVentanaUsuario(user);
    } else {
      setState(() {
        _mensajeError =
            'Credenciales inválidas. Por favor, verifica tu usuario y contraseña.';
      });
      debugPrint("Credenciales inválidas");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión UDEC'),
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Icono o Logo
              Icon(Icons.lock_open, size: 80, color: Colors.blueGrey.shade600),
              const SizedBox(height: 40),

              // Campo de Usuario
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Usuario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              TextField(
                controller: _contraController,
                obscureText: true, // Oculta el texto para la contraseña
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Inicio de Sesión
              ElevatedButton(
                onPressed: _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'INGRESAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // Mensaje de Error
              if (_mensajeError != null) ...[
                const SizedBox(height: 20),
                Text(
                  _mensajeError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
