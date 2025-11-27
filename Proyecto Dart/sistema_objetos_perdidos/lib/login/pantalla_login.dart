import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/administrador/ventana_admin.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/botones.dart';
import 'package:sistema_objetos_perdidos/login/administrador.dart';
import 'package:sistema_objetos_perdidos/login/usuario.dart';
import 'package:sistema_objetos_perdidos/login/inicio_sesion.dart';
import 'dart:math';

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
  return LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      // Escalado para mantener proporciones 
      final double escaladoW = w / 1600;
      final double escaladoH = h / 900;
      final double escaladoUsado = min(escaladoW, escaladoH);

      final double wReal = 1600 * escaladoUsado;
      final double hReal = 900 * escaladoUsado;

      final double offsetX = (w - wReal) / 2.0;
      final double offsetY = (h - hReal) / 2.0;

      Rect escaladoRectPx({
        required double left,
        required double top,
        required double width,
        required double height,
      }) {
        return Rect.fromLTWH(
          offsetX + left * escaladoUsado,
          offsetY + top * escaladoUsado,
          width * escaladoUsado,
          height * escaladoUsado,
        );
      }

      final Rect userPx   = escaladoRectPx(left: 670, top: 439, width: 270, height: 95);
      final Rect passPx   = escaladoRectPx(left: 670, top: 548, width: 270, height: 95);
      final Rect inicioPx = escaladoRectPx(left: 650, top: 656, width: 270, height: 95);
      final Rect registroPx = escaladoRectPx(left: 573, top: 1, width: 455, height: 899);
      final Rect crearPx = escaladoRectPx(left: 660, top: 820, width: 283, height: 33);
      final Rect registroUserPx = escaladoRectPx(left: 666, top: 497, width: 270, height: 95);
      final Rect registroPassPx = escaladoRectPx(left: 666, top: 596, width: 270, height: 95);
      final Rect registroinicioPx = escaladoRectPx(left: 666, top: 766, width: 270, height: 95);

      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    'images/fondo1.png',
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                  ),
                ),
              ),
            ),

            if (!_isOverlayVisible) ...[
              //boton de crear usuario
              Positioned.fromRect(
                rect: crearPx,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  splashColor: Colors.white24,
                  onTap: () {
                    setState(() {
                      _isOverlayVisible = true;
                    });
                  },
                  child: const SizedBox.expand(),
                ),
              ),
              // Nombre de usuario
              Positioned.fromRect(
                rect: userPx,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _usuarioController,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    

                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: "Nombre de Usuario",
                      hintStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Contraseña
              Positioned.fromRect(
                rect: passPx,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _contraController,
                    obscureText: true,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: "Contraseña",
                      hintStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              //iniciar sesion
              Positioned.fromRect(
                rect: inicioPx,
                child: InkWell(
                  onTap: _iniciarSesion,
                  borderRadius: BorderRadius.circular(8),
                  splashColor: Colors.white24,
                  child: const SizedBox.expand(),
                ),
              ),


              if (_mensajeError != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.black.withOpacity(0.6),
                      child: Text(
                        _mensajeError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          
        
          if (_isOverlayVisible) ...[

            Positioned.fromRect(
              rect: registroPx,
              child: Image.asset(
                'images/registrousuario.png',
                fit: BoxFit.fill,
              ),
            ),


            Positioned.fromRect(
              rect: registroUserPx,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: TextField(
                  controller: _usuarionuevoController,
                  style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nombre de Usuario',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                ),
              ),
            ),
          ),


            Positioned.fromRect(
              rect: registroPassPx,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child:TextField(
                controller: _contranuevaController,
                obscureText: true,
                style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                ),
              ),
            )     
          ),

/*              Positioned.fromRect(
                rect: passPx,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _contraController,
                    obscureText: true,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: "Contraseña",
                      hintStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),*/ 


            Positioned.fromRect(
              rect: registroinicioPx,
              child: InkWell(
                onTap: _crearUsuario,
              ),
            ),
          ]
        ],
      ),
    );
    },
  );
}
}
