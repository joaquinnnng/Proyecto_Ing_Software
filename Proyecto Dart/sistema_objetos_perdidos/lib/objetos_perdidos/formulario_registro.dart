import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../usuarioUdec.dart';
//import 'helpers/guarda_txt_web.dart'; // debe exportar: Future<void> saveUserTxt(Usuarioudec user)

class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({super.key});

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final registroKey = GlobalKey<FormState>();

  final nombre = TextEditingController();
  final correo = TextEditingController();
  final telefono = TextEditingController();
  final matricula = TextEditingController();
  final bool admin = false;

  bool guardando = false;

  //validaciones necesarias
  String? _required(String? n, {String label = 'Este campo'}) {
    if (n == null || n.trim().isEmpty) {
      return '$label es obligatorio';
    }
    return null;
  }

  String? validarTelefono(String? n) {
    final base = _required(n, label: 'Teléfono');
    if (base != null) return base;
    if (n!.replaceAll(' ', '').length < 8) return 'Teléfono demasiado corto';
    return null;
  }

  String? validarCorreo(String? n) {
    final base = _required(n, label: 'Correo');
    if (base != null) return base;
    final v = n!.trim();
    if (!v.contains('@') || !v.contains('.')) return 'Correo inválido';
    return null;
  }

  String? validarMatricula(String? n) {
    final base = _required(n, label: 'Matrícula');
    if (base != null) return base;
    if (n!.trim().length < 10) return 'Matrícula inválida';
    return null;
  }

  Future<void> saveUserTxt(Usuarioudec user) async {
    final linea =
        '${user.nombre}, ${user.correo}, ${user.telefono}, ${user.matricula}, admin=${user.admin}';

    final bytes = utf8.encode(linea);
    final blob = html.Blob([bytes], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final a = html.AnchorElement(href: url)
      ..download = 'usuarios.txt'
      ..style.display = 'none';
    html.document.body!.children.add(a);
    a.click();
    a.remove();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> guardar() async {
    if (!registroKey.currentState!.validate()) return;

    setState(() => guardando = true);

    final usuario = Usuarioudec(
      nombre: nombre.text.trim(),
      correo: correo.text.trim(),
      telefono: telefono.text.trim(),
      matricula: matricula.text.trim(),
      admin: admin,
    );

    await saveUserTxt(usuario); // descarga el txt en Chrome

    if (!mounted) return;
    setState(() => guardando = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guardado')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nombre.dispose();
    correo.dispose();
    telefono.dispose();
    matricula.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de usuario'),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: registroKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nombre,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: (v) => _required(v, label: 'Nombre'),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: correo,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
              validator: validarCorreo,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: telefono,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              validator: validarTelefono,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: matricula,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Matrícula',
                border: OutlineInputBorder(),
              ),
              validator: validarMatricula,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: guardando ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: guardando ? null : () => guardar(),
                    icon: guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
