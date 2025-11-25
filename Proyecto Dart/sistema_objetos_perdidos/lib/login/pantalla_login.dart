import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/administrador/ventana_admin.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/botones.dart';
import 'package:sistema_objetos_perdidos/login/administrador.dart';
import 'package:sistema_objetos_perdidos/login/usuario.dart';
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

  final TextEditingController _usuarionuevoController = TextEditingController();
  final TextEditingController _contranuevaController = TextEditingController();

  String? _mensajeError;

  bool _isOverlayVisible = false;

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

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
      _usuarioController.clear();
      _contraController.clear();
      _mensajeError = null;
    });
  }

  void _crearUsuario() {
    final String correo = _usuarionuevoController.text.trim();
    final String contra = _contranuevaController.text.trim();

    if (correo.isEmpty || contra.isEmpty) {
      setState(() {
        _mensajeError = "Ingrese un correo y una contraseña.";
      });
      return;
    }

    if (!correo.contains("@udec.cl")) {
      setState(() {
        _mensajeError = "Ingrese un correo udec.";
      });
      return;
    }
    UsuarioBasico u = UsuarioBasico(correo, contra);
    _loginManager.registrarUsuario(u);
    setState(() {
      _usuarionuevoController.clear();
      _contranuevaController.clear();

      _isOverlayVisible = false;

      _mensajeError =
          "Usuario '$correo' registrado con éxito. ¡Ya puedes ingresar!";
    });
  }

  void _iniciarSesion() {
    final String correo = _usuarioController.text.trim();
    final String contra = _contraController.text.trim();

    if (_loginManager.loginEditor(correo, contra)) {
      debugPrint("Inicio de sesión como Administrador exitoso");
      setState(() {
        _mensajeError = null;
      });
      _abrirVentanaAdministrador();
    } else if (_loginManager.loginUsuario(correo, contra)) {
      debugPrint("Inicio de sesión como usuario exitoso");

      setState(() {
        _mensajeError = null;
      });

      final UsuarioBasico user = UsuarioBasico(correo, contra);
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
                obscureText: true,
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
              if (_isOverlayVisible)
                GestureDetector(
                  onTap: _toggleOverlay,
                  child: Container(
                    color: Colors.black54.withOpacity(0.7),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5,
                            maxHeight: MediaQuery.of(context).size.height * 0.5,
                          ),
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 15.0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'CREAR USUARIO UDEC',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),

                              TextField(
                                controller: _usuarionuevoController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre de Usuario',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.person),
                                ),
                              ),
                              const SizedBox(height: 15),

                              TextField(
                                controller: _contranuevaController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Contraseña',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.lock),
                                ),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton(
                                onPressed: _crearUsuario,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Registrar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _toggleOverlay,
        backgroundColor: Colors.blue,
        tooltip: "Ingresar nuevo usuario UdeC",

        child: Icon(
          _isOverlayVisible ? Icons.close : Icons.app_registration,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
