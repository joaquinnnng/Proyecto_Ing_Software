import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'package:sistema_objetos_perdidos/objetos_perdidos/reporte_modelo.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final formularioKey =
      GlobalKey<
        FormState
      >(); //key para guardar los datos una vez finalizado el formulario
  String? selectedCategory;
  final List<String> categorias = [
    'Billetera',
    'Celular',
    'Llaves',
    'Documentos',
    'Joyas',
    'Mochila/Bolso',
    'Prenda de Vestir',
    'Otros...',
  ];
  final lugarController = TextEditingController(); //Para el lugar

  final dateController = TextEditingController(); //Para la fecha
  DateTime? fecha;

  final timeController = TextEditingController(); //para la hora
  TimeOfDay? time;

  final descriptionController = TextEditingController(); //Para la descripción

  Uint8List imagebytes = Uint8List(0); //variable para almacenar la imagen
  String imagestatus = "no hay imagen"; // variable para mostrar estado imagen

  @override
  void dispose() {
    //función para liberar memoria cuando la página se destruye
    lugarController.dispose();
    dateController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }


  Future<String> convertirImagenABase64(File imagen) async {
  final bytes = await imagen.readAsBytes();
  return base64Encode(bytes);
}

  Future<void> datePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024), //fecha más antigua que se puede seleccionar
      lastDate: DateTime.now(), // fecha mas nueva (hoy)
      helpText: 'Seleccione fecha',
    );
    if (pickedDate != null && pickedDate != fecha) {
      //Actualizamos el estado
      setState(() {
        fecha = pickedDate;
        dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> timePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Hora aproximada',
    );
    if (pickedTime != null && pickedTime != time) {
      setState(() {
        time = pickedTime;
        timeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      maxHeight: 1080,
      maxWidth: 1080,
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      XFile? imageFile = XFile(pickedImage.path);
      imagebytes = await imageFile.readAsBytes();
      setState(() {
        imagestatus = "imagen cargada correctamente";
      });
    }
  }
  

  Future<void> _saveReport() async {
    if (formularioKey.currentState!.validate()) {

      String? imagenBase64;
      if (imagebytes.isNotEmpty) {
        imagenBase64 = base64Encode(imagebytes);
      }
      
      //CREAR EL OBJETO MODELO
      final nuevoReporte = ReporteModelo(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único basado en la hora
        tipo: "PERDIDO", // <--- IMPORTANTE: Identificador para el admin
        titulo: "${selectedCategory!} en ${lugarController.text}",
        categoria: selectedCategory!,
        lugar: lugarController.text.trim(),
        fecha: "${dateController.text} ${timeController.text}",
        descripcion: descriptionController.text.trim(),
        imagenBase64: imagenBase64,
        
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Obtenemos la lista actual
      List<String> reportesGuardados = prefs.getStringList('reportes_data_v2') ?? [];

      reportesGuardados.insert(0, jsonEncode(nuevoReporte.toJson()));

      await prefs.setStringList('reportes_data_v2', reportesGuardados);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aviso enviado al Administrador')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (Text('Registro de Objetos Perdidos')),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: formularioKey,
        child: ListView(
          //Listview para que sea scrolleable
          padding: const EdgeInsets.all(15.0),
          children: [
            // ===Campo para Categoría del Objeto===
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoría de Objeto',
                border: OutlineInputBorder(),
              ),
              value: selectedCategory,
              hint: Text('Selecciona una categoría'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: categorias.map((String category) {
                return DropdownMenuItem<String>(
                  value: category, //el valor a guardar
                  child: Text(category),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, debe seleccionar una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            //===Campo para Lugar===
            TextFormField(
              controller: lugarController,
              decoration: InputDecoration(
                labelText: 'Lugar donde se perdió',
                hintText: 'Ejemplo: CFM, Cubo 4, Los pastos...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                //valida
                if (value == null || value.trim().isEmpty) {
                  //trim() para que no acepte espacios en blanco
                  return 'Por favor, ingresa el lugar';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            //===Campo para la Fecha===
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: datePicker, //llamamos a la función datepicker()
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, Selecciona una fecha';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            //===Campo para la Hora===
            TextFormField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Hora aproximada',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: timePicker,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, Selecciona una hora';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            //===Campo para Descripción multilinea===
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción detallada',
                hintText:
                    'Incluya máximo detalle. Ej: Color, marca, rasgos distintivos (manchas, detalles estéticos)...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, Ingresa descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                pickImage();
              },
              child: const Text('agregar foto del objeto'),
            ),

            const SizedBox(height: 40),
            if (imagestatus == "imagen cargada correctamente")
              ClipOval(
                child: Image.memory(
                  imagebytes,
                  width: 200,
                  height: 200,
                  fit: BoxFit
                      .contain, // mantiene la imagen completa sin hacer zoom
                ),
              ),
            if (imagestatus != "imagen cargada correctamente")
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(height: 40),

            // === Botón de Guardado ===
            ElevatedButton.icon(
              onPressed: _saveReport,
              icon: const Icon(Icons.check),
              label: const Text(
                'Registrar Objeto Encontrado',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
