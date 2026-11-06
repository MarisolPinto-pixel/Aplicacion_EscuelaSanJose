import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const AppFusionada());
}

class AppFusionada extends StatelessWidget {
  const AppFusionada({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App TEA - Apoyo Escolar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PantallaBase(),
    );
  }
}

class PantallaBase extends StatefulWidget {
  const PantallaBase({super.key});
  
  @override
  State<PantallaBase> createState() => _PantallaBaseState();
}

class _PantallaBaseState extends State<PantallaBase> {
  // --- NAVEGACIÓN Y ESTADO DE TEMA ---
  String vistaActual = 'inicio_app'; 
  bool sonidoActivado = true; 
  String modoIluminacion = 'Calma'; // Calma, Activo, Oscuro

  // --- DATOS MAESTRAS Y SEGURIDAD ---
  String pinCorrecto = '1234';
  String nombreMaestra = 'Maestra';
  String apellidoMaestra = 'Principal';
  TextEditingController ctrlNombreMaestra = TextEditingController();
  TextEditingController ctrlApellidoMaestra = TextEditingController();
  TextEditingController ctrlNuevoPin = TextEditingController();

  // --- DATOS Y PERSISTENCIA ---
  var listaAlumnos = ['alumno'];
  String? alumnoActual; 
  
  var listaTareas = [];
  // ignore: strict_top_level_inference, prefer_typing_uninitialized_variables
  var tareaActiva; 
  String respuestaTemporal = '';
  TextEditingController ctrlRespuestaTexto = TextEditingController();

  // --- ECUACIONES ---
  var ecuacionesMatematicas = [];
  TextEditingController eqPregController = TextEditingController();
  TextEditingController eqRespController = TextEditingController();

  // --- VARIABLES MAESTRA ---
  String pinIngresado = '';
  String alumnoSeleccionado = 'Alumno de prueba';
  String materiaSeleccionada = 'Lengua';
  String tipoActividad = 'Letras Faltantes'; 
  String iconoPictogramaSeleccionado = '🍎';
  String nivelDificultad= 'Fácil';

  TextEditingController ctrlPregunta = TextEditingController();
  TextEditingController ctrlCorrecta = TextEditingController();
  TextEditingController ctrlOpcionesFalsas = TextEditingController(); 
  TextEditingController ctrlNuevoAlumno = TextEditingController();

  // --- RUTINAS Y COMUNICACIÓN ---
  var fraseActual = [];
  final pictogramas = [
    {'titulo': 'Quiero', 'icono': Icons.handshake, 'color': const Color(0xFF4A90E2)},
    {'titulo': 'No quiero', 'icono': Icons.do_not_disturb_alt, 'color': const Color(0xFFE57373)},
    {'titulo': 'Comer', 'icono': Icons.restaurant, 'color': const Color(0xFFFFB74D)},
    {'titulo': 'Agua', 'icono': Icons.water_drop, 'color': const Color(0xFF64B5F6)},
    {'titulo': 'Baño', 'icono': Icons.bathtub, 'color': const Color(0xFFBA68C8)},
    {'titulo': 'Descansar', 'icono': Icons.bed, 'color': const Color(0xFFA1887F)},
    {'titulo': 'Salir', 'icono': Icons.directions_walk, 'color': const Color(0xFF81C784)},
  ];

  var rutinas = [
    // --- MAÑANA ---
    {'titulo': 'Despertarse', 'icono': Icons.wb_sunny_rounded, 'color': const Color(0xFFFFD54F), 'completada': false},
    {'titulo': 'Hacer la cama', 'icono': Icons.bed_rounded, 'color': const Color(0xFFAED581), 'completada': false},
    {'titulo': 'Ir al baño', 'icono': Icons.wc_rounded, 'color': const Color(0xFF4DB6AC), 'completada': false},
    {'titulo': 'Lavarse los dientes', 'icono': Icons.clean_hands_rounded, 'color': const Color(0xFF4FC3F7), 'completada': false},
    {'titulo': 'Vestirse', 'icono': Icons.checkroom_rounded, 'color': const Color(0xFFFFB74D), 'completada': false},
    {'titulo': 'Desayunar', 'icono': Icons.free_breakfast_rounded, 'color': const Color(0xFFFF8A65), 'completada': false},
    {'titulo': 'Peinarse', 'icono': Icons.content_cut_rounded, 'color': const Color(0xFFF06292), 'completada': false},
    {'titulo': 'Preparar la mochila', 'icono': Icons.backpack_rounded, 'color': const Color(0xFF81C784), 'completada': false},

    // --- TARDE ---
    {'titulo': 'Almorzar', 'icono': Icons.restaurant_rounded, 'color': const Color(0xFFFF7043), 'completada': false},
    {'titulo': 'Hacer la tarea', 'icono': Icons.menu_book_rounded, 'color': const Color(0xFF9575CD), 'completada': false},
    {'titulo': 'Tiempo de juego', 'icono': Icons.sports_esports_rounded, 'color': const Color(0xFFBA68C8), 'completada': false},
    {'titulo': 'Ordenar los juguetes', 'icono': Icons.inventory_2_rounded, 'color': const Color(0xFF4DD0E1), 'completada': false},
    {'titulo': 'Merendar', 'icono': Icons.bakery_dining_rounded, 'color': const Color(0xFFFFD54F), 'completada': false},

    // --- NOCHE ---
    {'titulo': 'Bañarse', 'icono': Icons.bathtub_rounded, 'color': const Color(0xFF64B5F6), 'completada': false},
    {'titulo': 'Ponerse el pijama', 'icono': Icons.checkroom_outlined, 'color': const Color(0xFF7986CB), 'completada': false},
    {'titulo': 'Cenar', 'icono': Icons.dinner_dining_rounded, 'color': const Color(0xFFFF8A65), 'completada': false},
    {'titulo': 'Lavarse los dientes (Noche)', 'icono': Icons.clean_hands_rounded, 'color': const Color(0xFF4FC3F7), 'completada': false},
    {'titulo': 'Leer un cuento', 'icono': Icons.auto_stories_rounded, 'color': const Color(0xFF90A4AE), 'completada': false},
    {'titulo': 'Ir a dormir', 'icono': Icons.bedtime_rounded, 'color': const Color(0xFF5C6BC0), 'completada': false},
  ];

  int tablaSeleccionadaVer = 2;

  // --- PAUSA DE RESPIRACIÓN (MIND FULLNESS) ---
  Timer? timerRespiracion;
  int segundosRespiracion = 4;
  String estadoRespiracion = 'Inhala profundamente'; 
  int ciclosCompletados = 0;
  bool respiracionPausada = false;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _inicializarVoz();
    _cargarDatos();
  }

  @override
  void dispose() {
    timerRespiracion?.cancel();
    super.dispose();
  }

  void _inicializarVoz() async {
    await flutterTts.setLanguage("es-MX");
    await flutterTts.setPitch(1.2);        
    await flutterTts.setSpeechRate(0.45);  
    await flutterTts.setVolume(1.0);       

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      List<dynamic> voces = await flutterTts.getVoices;
      for (var v in voces) {
        String name = v["name"].toString().toLowerCase();
        String locale = v["locale"].toString().toLowerCase();

        bool esEspanol = locale.contains("es") || name.contains("spanish") || name.contains("español");
        bool esFemenina = name.contains("female") || 
                          name.contains("femenino") || 
                          name.contains("sabina") || 
                          name.contains("elena") || 
                          name.contains("monica") || 
                          name.contains("zira") || 
                          name.contains("hilda") || 
                          name.contains("paulina") ||
                          name.contains("sfc");

        if (esEspanol && esFemenina) {
          await flutterTts.setVoice({"name": v["name"], "locale": v["locale"]});
          break;
        }
      }
    } catch (e) {
      // Mantiene parámetros si el sistema no permite listar voces
    }
  }

  // --- OBTENER COLORES SEGÚN MODO ILUMINACIÓN ---
  Color _obtenerColorFondo() {
    if (modoIluminacion == 'Oscuro') return const Color(0xFF121212);
    if (modoIluminacion == 'Activo') return const Color.fromARGB(255, 206, 203, 170);
    return const Color(0xFFF7F4EE); // Calma
  }

  Color _obtenerColorTexto() {
    if (modoIluminacion == 'Oscuro') return Colors.white;
    return Colors.black87;
  }

  Color _obtenerColorTarjeta() {
    if (modoIluminacion == 'Oscuro') return const Color(0xFF1E1E1E);
    return Colors.white;
  }

  // --- GUARDAR Y CARGAR DATOS ---
  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sonidoActivado = prefs.getBool('sonidoActivado') ?? true;
      modoIluminacion = prefs.getString('modoIluminacion') ?? 'Calma';
      pinCorrecto = prefs.getString('pinCorrecto') ?? '1234';
      nombreMaestra = prefs.getString('nombreMaestra') ?? 'Maestra';
      apellidoMaestra = prefs.getString('apellidoMaestra') ?? 'Principal';
      
      listaAlumnos = prefs.getStringList('listaAlumnos') ?? ['Alumno de prueba'];
      if (!listaAlumnos.contains(alumnoSeleccionado)) alumnoSeleccionado = listaAlumnos.first.toString();
      
      String? tareasJson = prefs.getString('listaTareas');
      if (tareasJson != null) listaTareas = List.from(jsonDecode(tareasJson));

      String? eqJson = prefs.getString('ecuacionesMatematicas');
      if (eqJson != null) ecuacionesMatematicas = List.from(jsonDecode(eqJson));

      String? rutinasJson = prefs.getString('rutinasGuardadas');
      if (rutinasJson != null) {
        var dec = jsonDecode(rutinasJson);
        for (int i = 0; i < dec.length; i++) {
          if (i < rutinas.length) rutinas[i]['completada'] = dec[i]['completada'] ?? false;
        }
      }
    });
  }

  Future<void> _sincronizar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sonidoActivado', sonidoActivado);
    await prefs.setString('modoIluminacion', modoIluminacion);
    await prefs.setString('pinCorrecto', pinCorrecto);
    await prefs.setString('nombreMaestra', nombreMaestra);
    await prefs.setString('apellidoMaestra', apellidoMaestra);
    await prefs.setStringList('listaAlumnos', listaAlumnos.map((e) => e.toString()).toList());
    await prefs.setString('listaTareas', jsonEncode(listaTareas));
    await prefs.setString('ecuacionesMatematicas', jsonEncode(ecuacionesMatematicas));
    await prefs.setString('rutinasGuardadas', jsonEncode(rutinas.map((r) => {'completada': r['completada']}).toList()));
  }

  void leerTexto(String texto) async {
    if (sonidoActivado) {
      await flutterTts.stop();
      await flutterTts.speak(texto);
    }
  }

  // --- FUNCIÓN PARA GENERAR REPORTE EN PDF ---
  Future<void> _generarReportePDF(String nombreAlumno) async {
    final doc = pw.Document();
    final tareasDelAlumno = listaTareas.where((t) => t['alumno'] == nombreAlumno).toList();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Reporte de Desempeño Escolar', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
              pw.SizedBox(height: 10),
              pw.Text('Alumno: $nombreAlumno', style: const pw.TextStyle(fontSize: 18)),
              pw.Text('Docente: $nombreMaestra $apellidoMaestra'),
              pw.Text('Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
              pw.SizedBox(height: 20),
              if (tareasDelAlumno.isEmpty)
                pw.Text('No hay tareas registradas para este alumno.', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey))
              else
                pw.TableHelper.fromTextArray(
                  context: context,
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  data: [
                    ['Materia', 'Actividad', 'Estado', 'Hora', 'Nota'],
                    ...tareasDelAlumno.map((t) => [
                      t['materia'].toString(),
                      t['pregunta'].toString(),
                      t['estado'].toString(),
                      t['horaCompletado']?.toString() ?? 'Pendiente',
                      t['notaMaestra']?.toString() ?? 'Sin calificar'
                    ])
                  ],
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Reporte_$nombreAlumno',
    );
  }

  // --- FUNCIÓN PARA MOSTRAR LA VENTANA DE CRÉDITOS ---
  void _mostrarCreditos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _obtenerColorTarjeta(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 30),
            const SizedBox(width: 10),
            Text("Créditos del Proyecto", style: TextStyle(fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("App Inclusiva - Apoyo Escolar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent)),
            const SizedBox(height: 10),
            Text("Aplicación pedagógica e interactiva diseñada para la comunicación y el aprendizaje adaptado.", style: TextStyle(color: _obtenerColorTexto())),
            const Divider(height: 25),
            Text("Desarrollado por:", style: TextStyle(fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
            const SizedBox(height: 5),
            
            Text("Instituto de Enseñanza Superior N° 6.030 - Las Lajitas, Anta, Salta - Argentina", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _obtenerColorTexto())),
            const SizedBox(height: 15),
            
            Text("Mariana Serrato G. - Marisol Pinto", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _obtenerColorTexto())),
            const SizedBox(height: 15),
            Text("Versión: 1.0.0", style: TextStyle(color: _obtenerColorTexto().withValues(alpha: 0.7))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA RESPIRACIÓN GUIADA ---
  void _iniciarRespiracion() {
    timerRespiracion?.cancel();
    setState(() {
      segundosRespiracion = 4;
      estadoRespiracion = 'Inhala profundamente';
      ciclosCompletados = 0;
      respiracionPausada = false;
    });
    leerTexto("Inhala profundamente");
    _activarTimerRespiracion();
  }

  void _activarTimerRespiracion() {
    timerRespiracion?.cancel();
    timerRespiracion = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (respiracionPausada) return;
      setState(() {
        segundosRespiracion--;
        if (segundosRespiracion <= 0) {
          if (estadoRespiracion.contains('Inhala')) {
            estadoRespiracion = 'Manten el aire';
            segundosRespiracion = 2;
            leerTexto("Manten el aire");
          } else if (estadoRespiracion.contains('Manten')) {
            estadoRespiracion = 'Exhala suavemente';
            segundosRespiracion = 4;
            leerTexto("Exhala suavemente");
          } else {
            ciclosCompletados++;
            estadoRespiracion = 'Inhala profundamente';
            segundosRespiracion = 4;
            leerTexto("Inhala nuevamente");
          }
        }
      });
    });
  }

  void _pausarOContinuarRespiracion() {
    setState(() {
      respiracionPausada = !respiracionPausada;
    });
    if (respiracionPausada) {
      timerRespiracion?.cancel();
      leerTexto("Pausa");
    } else {
      leerTexto("Continuar");
      _activarTimerRespiracion();
    }
  }

  // ==========================================
  // VISTAS DE LA APLICACIÓN
  // ==========================================
  Widget vistaInicioApp() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/Escuela.png',
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 80, color: Colors.blueAccent),
          ),
          const SizedBox(height: 20),
          Text("Bienvenidos", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
          const SizedBox(height: 10),
          const Text("¿Quién va a ingresar?", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tarjetaRol("Maestra", "$nombreMaestra $apellidoMaestra", Icons.admin_panel_settings, Colors.purple, () => setState(() => vistaActual = 'pin_maestra')),
              const SizedBox(width: 30),
              _tarjetaRol("Alumno", "Aprender y jugar", Icons.face, Colors.green, () => setState(() => vistaActual = 'select_alumno')),
            ],
          )
        ],
      ),
    );
  }

  Widget _tarjetaRol(String titulo, String subtitulo, IconData icono, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 250, padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: _obtenerColorTarjeta(), borderRadius: BorderRadius.circular(20), border: Border.all(color: color, width: 3), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
        child: Column(
          children: [Icon(icono, size: 70, color: color), const SizedBox(height: 15), Text(titulo, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 10), Text(subtitulo, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _obtenerColorTexto()))],
        ),
      ),
    );
  }

  Widget vistaPinMaestra() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [IconButton(icon: Icon(Icons.arrow_back, size: 30, color: _obtenerColorTexto()), onPressed: () => setState(() { vistaActual = 'inicio_app'; pinIngresado = ''; })), const Spacer()]),
          const Icon(Icons.lock, size: 60, color: Colors.purple), const SizedBox(height: 10), 
          Text("PIN de Acceso Docente", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
          const SizedBox(height: 20),
          Text(pinIngresado.padRight(4, '_').split('').join(' '), style: const TextStyle(fontSize: 50, letterSpacing: 10, color: Colors.purple)),
          const SizedBox(height: 40),
          Wrap(
            spacing: 15, runSpacing: 15, alignment: WrapAlignment.center,
            children: List.generate(9, (index) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _obtenerColorTarjeta(), padding: const EdgeInsets.all(25), shape: const CircleBorder()),
              onPressed: () {
                setState(() {
                  if (pinIngresado.length < 4) pinIngresado += (index + 1).toString();
                  if (pinIngresado == pinCorrecto) { vistaActual = 'panel_maestra'; pinIngresado = ''; }
                  // ignore: curly_braces_in_flow_control_structures
                  else if (pinIngresado.length == 4) pinIngresado = ''; 
                });
              },
              child: Text("${index + 1}", style: TextStyle(fontSize: 28, color: _obtenerColorTexto())),
            )),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PANEL DOCENTE
  // ==========================================
  Widget vistaMaestra() {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            color: Colors.purple,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.white,
                  title: Text("Panel: $nombreMaestra $apellidoMaestra"),
                  leading: IconButton(icon: const Icon(Icons.logout), onPressed: () => setState(() => vistaActual = 'inicio_app')),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
                      tooltip: "Créditos",
                      onPressed: () => _mostrarCreditos(context),
                    )
                  ],
                ),
                const TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.white, labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), labelColor: Colors.white, unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(icon: Icon(Icons.add_task), text: "Asignar"),
                    Tab(icon: Icon(Icons.list_alt), text: "Creadas"),
                    Tab(icon: Icon(Icons.fact_check), text: "Corregir"),
                    Tab(icon: Icon(Icons.people), text: "Alumnos"),
                    Tab(icon: Icon(Icons.settings), text: "Perfil y PIN"),
                  ]
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _tabCrearTarea(),
                _tabVerActividadesCreadas(),
                _tabCorregirTareas(),
                _tabGestionAlumnos(),
                _tabPerfilYPin(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabCrearTarea() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: _obtenerColorTarjeta(), elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. Elegir Alumno", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
              DropdownButton(
                isExpanded: true, value: alumnoSeleccionado,
                items: listaAlumnos.map((a) => DropdownMenuItem(value: a.toString(), child: Text(a.toString()))).toList(),
                onChanged: (v) => setState(() => alumnoSeleccionado = v.toString()),
              ),
              const SizedBox(height: 20),
              Text("2. Elegir Materia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
              Row(
                children: [
                  // ignore: deprecated_member_use
                  Expanded(child: RadioListTile(title: Text("Lengua", style: TextStyle(color: _obtenerColorTexto())), value: "Lengua", groupValue: materiaSeleccionada, onChanged: (v) => setState(() { materiaSeleccionada = v.toString(); tipoActividad = 'Letras Faltantes'; }))),
                  // ignore: deprecated_member_use
                  Expanded(child: RadioListTile(title: Text("Matemáticas", style: TextStyle(color: _obtenerColorTexto())), value: "Matemáticas", groupValue: materiaSeleccionada, onChanged: (v) => setState(() { materiaSeleccionada = v.toString(); tipoActividad = 'Ecuación'; }))),
                ],
              ),
              const Divider(height: 30, thickness: 2),
              Text("3. Tipo de Actividad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
              if (materiaSeleccionada == 'Lengua') ...[
                DropdownButton(
                  isExpanded: true, value: tipoActividad,
                  items: ['Letras Faltantes', 'Unir con Flechas', 'Escribir Pictograma'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => tipoActividad = v.toString()),
                ),
                const SizedBox(height: 10),
                if (tipoActividad == 'Letras Faltantes') ...[
                  // Menú de dificultad agregado
                  Text("Nivel de Dificultad", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
                  DropdownButton(
                    isExpanded: true, value: nivelDificultad,
                    items: ['Fácil', 'Medio', 'Difícil'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                    onChanged: (v) => setState(() => nivelDificultad = v.toString()),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: ctrlPregunta, decoration: const InputDecoration(labelText: "Palabra con huecos (Ej: M _ N Z _ N A)")),
                  TextField(controller: ctrlCorrecta, decoration: const InputDecoration(labelText: "Letras Correctas separadas por coma (Ej: A, A)")),
                  TextField(controller: ctrlOpcionesFalsas, decoration: const InputDecoration(labelText: "Opciones Falsas (Ej: E, O)")),
                ] else if (tipoActividad == 'Unir con Flechas') ...[
                  TextField(controller: ctrlPregunta, decoration: const InputDecoration(labelText: "Palabra Inicial (Ej: Perro)")),
                  TextField(controller: ctrlCorrecta, decoration: const InputDecoration(labelText: "Pareja Correcta (Ej: Ladra)")),
                  TextField(controller: ctrlOpcionesFalsas, decoration: const InputDecoration(labelText: "Opciones Incorrectas (Ej: Maulla, Vuela)")),
                ] else if (tipoActividad == 'Escribir Pictograma') ...[
                  DropdownButton(
                    value: iconoPictogramaSeleccionado,
                    items: ['🍎', '🐶', '🐱', '🚗', '☀️', '⚽', '📚'].map((p) => DropdownMenuItem(value: p, child: Text("Pictograma: $p", style: const TextStyle(fontSize: 20)))).toList(),
                    onChanged: (v) => setState(() => iconoPictogramaSeleccionado = v.toString()),
                  ),
                  TextField(controller: ctrlCorrecta, decoration: const InputDecoration(labelText: "Nombre del objeto en el pictograma (Ej: Manzana)")),
                ]
              ] else ...[
                DropdownButton(
                  isExpanded: true, value: tipoActividad,
                  items: ['Ecuación', 'Contar Pictogramas', 'Orden Cronológico', 'Tablas Multiplicar'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => tipoActividad = v.toString()),
                ),
                const SizedBox(height: 10),
                if (tipoActividad == 'Contar Pictogramas') ...[
                  TextField(controller: ctrlPregunta, decoration: const InputDecoration(labelText: "Elementos a contar (Ej: 🍎🍎🍎🍎)")),
                  TextField(controller: ctrlCorrecta, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cantidad Correcta (Ej: 4)")),
                  TextField(controller: ctrlOpcionesFalsas, decoration: const InputDecoration(labelText: "Opciones Falsas (Ej: 2, 3, 5)")),
                ] else if (tipoActividad == 'Orden Cronológico') ...[
                  TextField(controller: ctrlPregunta, decoration: const InputDecoration(labelText: "Instrucción (Ej: ¿Qué se hace primero?)")),
                  TextField(controller: ctrlCorrecta, decoration: const InputDecoration(labelText: "Paso 1 Correcto (Ej: 1. Cocinar)")),
                  TextField(controller: ctrlOpcionesFalsas, decoration: const InputDecoration(labelText: "Pasos Siguientes (Ej: 2. Comer, 3. Lavar plato)")),
                ] else if (tipoActividad == 'Tablas Multiplicar') ...[
                  TextField(controller: ctrlPregunta, decoration: const InputDecoration(labelText: "Multiplicación (Ej: 3 x 4 = ?)")),
                  TextField(controller: ctrlCorrecta, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Resultado Correcto (Ej: 12)")),
                  TextField(controller: ctrlOpcionesFalsas, decoration: const InputDecoration(labelText: "Opciones Falsas (Ej: 10, 14, 15)")),
                ]
              ],

              if (materiaSeleccionada == 'Matemáticas' && tipoActividad == 'Ecuación') ...[
                const SizedBox(height: 20),
                Text("4. Crear Ecuación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
                const SizedBox(height: 8),
                TextField(controller: eqPregController, decoration: const InputDecoration(labelText: "Ecuación (ej: x + 3 = 7)")),
                TextField(controller: eqRespController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor de X Correcto")),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar Ecuación"),
                  onPressed: () {
                    if (eqPregController.text.isNotEmpty && eqRespController.text.isNotEmpty) {
                      setState(() {
                        ecuacionesMatematicas.add({
                          'id': ecuacionesMatematicas.length + 1,
                          'pregunta': eqPregController.text,
                          'respuestaCorrecta': eqRespController.text,
                        });
                        
                        var opciones = ['1', '2', '3', '4', '5'];
                        if (!opciones.contains(eqRespController.text)) opciones[0] = eqRespController.text;
                        opciones.shuffle();

                        listaTareas.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'alumno': alumnoSeleccionado,
                          'materia': 'Matemáticas',
                          'tipo': 'Ecuación',
                          'pregunta': "Resuelve: ${eqPregController.text}",
                          'correcta': eqRespController.text.trim(),
                          'opciones': opciones,
                          'dificultad': (tipoActividad == 'Letras Faltantes') ? nivelDificultad : 'Normal',
                          'estado': 'Pendiente',
                          'fechaCreacion': DateTime.now().toString(),
                          'notaMaestra': 'Sin calificar'
                        });

                        eqPregController.clear(); eqRespController.clear();
                      });
                      _sincronizar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ecuación guardada"), backgroundColor: Colors.green));
                    }
                  },
                ),
              ],
              
              if (!(materiaSeleccionada == 'Matemáticas' && tipoActividad == 'Ecuación')) ...[
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                    icon: const Icon(Icons.save, color: Colors.white), label: const Text("ASIGNAR TAREA", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      String preguntaFinal = tipoActividad == 'Escribir Pictograma' ? iconoPictogramaSeleccionado : ctrlPregunta.text;
                      if (preguntaFinal.isEmpty || ctrlCorrecta.text.isEmpty) return;
                      var opciones = ctrlOpcionesFalsas.text.split(',').map((e) => e.trim()).toList();
                      opciones.add(ctrlCorrecta.text.trim()); opciones.shuffle();

                      setState(() {
                        listaTareas.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'alumno': alumnoSeleccionado,
                          'materia': materiaSeleccionada,
                          'tipo': tipoActividad,
                          'pregunta': preguntaFinal,
                          'correcta': ctrlCorrecta.text.trim(),
                          'opciones': opciones,
                          'estado': 'Pendiente',
                          'fechaCreacion': DateTime.now().toString(),
                          'notaMaestra': 'Sin calificar'
                        });
                        ctrlPregunta.clear(); ctrlCorrecta.clear(); ctrlOpcionesFalsas.clear();
                      });
                      _sincronizar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tarea asignada a $alumnoSeleccionado"), backgroundColor: Colors.green));
                    },
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabVerActividadesCreadas() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text("Total de actividades creadas: ${listaTareas.length}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
        ),
        Expanded(
          child: listaTareas.isEmpty ? Center(child: Text("No se han creado actividades todavía.", style: TextStyle(color: _obtenerColorTexto()))) : ListView.builder(
            itemCount: listaTareas.length,
            itemBuilder: (context, index) {
              var t = listaTareas[index];
              return Card(
                color: _obtenerColorTarjeta(),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.purple.shade100, child: Text("${index + 1}")),
                  title: Text("${t['alumno']} - ${t['materia']} (${t['tipo']})", style: TextStyle(fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
                  subtitle: Text("Pregunta/Icono: ${t['pregunta']}\nRespuesta esperada: ${t['correcta']} | Estado: ${t['estado']}", style: TextStyle(color: _obtenerColorTexto())),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => listaTareas.removeAt(index));
                      _sincronizar();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tabCorregirTareas() {
    var completadas = listaTareas.where((t) => t['estado'] == 'Completado').toList();
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(15), child: Text("Tareas entregadas por alumnos:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto()))),
        Expanded(
          child: completadas.isEmpty ? Center(child: Text("No hay entregas pendientes.", style: TextStyle(color: _obtenerColorTexto()))) : ListView.builder(
            itemCount: completadas.length,
            itemBuilder: (context, index) {
              var t = completadas[index];
              return Card(
                color: _obtenerColorTarjeta(),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.assignment_turned_in, color: Colors.blue, size: 35),
                  title: Text("${t['alumno']} - ${t['materia']}", style: TextStyle(fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
                  subtitle: Text("Actividad: ${t['pregunta']} \nRespuesta: ${t['respuestaAlumno']}\nHora de entrega: ${t['horaCompletado'] ?? 'No registrada'}", style: TextStyle(color: _obtenerColorTexto())),
                  trailing: DropdownButton(
                    value: t['notaMaestra'] == 'Sin calificar' ? null : t['notaMaestra'], hint: const Text("Calificar"),
                    items: ['Excelente', 'Bien', 'Rehacer'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                    onChanged: (v) { setState(() { t['notaMaestra'] = v.toString(); if (v == 'Rehacer') t['estado'] = 'Pendiente'; }); _sincronizar(); },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tabGestionAlumnos() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: ctrlNuevoAlumno, decoration: const InputDecoration(hintText: "Nombre del Alumno"))),
              IconButton(icon: const Icon(Icons.person_add, color: Colors.green, size: 35), onPressed: () {
                if (ctrlNuevoAlumno.text.isNotEmpty) { setState(() { listaAlumnos.add(ctrlNuevoAlumno.text); ctrlNuevoAlumno.clear(); }); _sincronizar(); }
              })
            ],
          ),
          const SizedBox(height: 30),
          Text("Alumnos Registrados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
          Expanded(
            child: ListView.builder(
              itemCount: listaAlumnos.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.face, color: Colors.blue),
                title: Text(listaAlumnos[index].toString(), style: TextStyle(fontSize: 18, color: _obtenerColorTexto())),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                      tooltip: "Generar Reporte PDF",
                      onPressed: () => _generarReportePDF(listaAlumnos[index].toString()),
                    ),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () { setState(() => listaAlumnos.removeAt(index)); _sincronizar(); }),
                  ],
                ),
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _tabPerfilYPin() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Perfil de la Maestra", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
            const SizedBox(height: 10),
            TextField(controller: ctrlNombreMaestra, decoration: InputDecoration(labelText: "Nombre actual: $nombreMaestra")),
            TextField(controller: ctrlApellidoMaestra, decoration: InputDecoration(labelText: "Apellido actual: $apellidoMaestra")),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.save), label: const Text("Guardar Nombre"),
              onPressed: () {
                if (ctrlNombreMaestra.text.isNotEmpty) nombreMaestra = ctrlNombreMaestra.text;
                if (ctrlApellidoMaestra.text.isNotEmpty) apellidoMaestra = ctrlApellidoMaestra.text;
                ctrlNombreMaestra.clear(); ctrlApellidoMaestra.clear();
                _sincronizar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil actualizado"), backgroundColor: Colors.green));
              },
            ),
            const Divider(height: 40, thickness: 2),
            Text("Cambiar PIN de Acceso", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
            const SizedBox(height: 10),
            TextField(controller: ctrlNuevoPin, keyboardType: TextInputType.number, maxLength: 4, decoration: const InputDecoration(labelText: "Nuevo PIN (4 dígitos)")),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              icon: const Icon(Icons.lock_reset, color: Colors.white), label: const Text("Actualizar PIN", style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (ctrlNuevoPin.text.length == 4) {
                  setState(() => pinCorrecto = ctrlNuevoPin.text);
                  ctrlNuevoPin.clear();
                  _sincronizar();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN actualizado con éxito"), backgroundColor: Colors.green));
                }
              },
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DASHBOARD DEL ALUMNO
  // ==========================================
  Widget vistaSeleccionAlumno() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [IconButton(icon: Icon(Icons.arrow_back, size: 30, color: _obtenerColorTexto()), onPressed: () => setState(() => vistaActual = 'inicio_app')), const Spacer()]),
          const Icon(Icons.face, size: 80, color: Colors.green), const SizedBox(height: 20),
          Text("¿Quién va a estudiar hoy?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _obtenerColorTexto())), const SizedBox(height: 30),
          Wrap(
            spacing: 20, runSpacing: 20, alignment: WrapAlignment.center,
            children: listaAlumnos.map((nombre) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _obtenerColorTarjeta(), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.green, width: 3))),
                onPressed: () { setState(() { alumnoActual = nombre.toString(); vistaActual = 'dashboard'; }); leerTexto("Hola, $nombre"); },
                child: Text(nombre.toString(), style: TextStyle(fontSize: 24, color: _obtenerColorTexto(), fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget vistaDashboard() {
    var misPendientes = listaTareas.where((t) => t['alumno'] == alumnoActual && t['estado'] == 'Pendiente').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.all(20), child: Text("¡Hola, $alumnoActual!", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent))),
        if (misPendientes.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange, width: 2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Icon(Icons.notification_important, color: Colors.deepOrange), const SizedBox(width: 10), Text("Tienes ${misPendientes.length} tareas pendientes", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange))]),
                const SizedBox(height: 10),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, itemCount: misPendientes.length,
                    itemBuilder: (context, index) {
                      var t = misPendientes[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 10), width: 220,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          icon: Icon(t['materia'] == 'Lengua' ? Icons.spellcheck : Icons.calculate, color: t['materia'] == 'Lengua' ? Colors.purple : Colors.blue),
                          label: Text("Retomar ${t['materia']}\n${t['pregunta']}", maxLines: 2, overflow: TextOverflow.ellipsis),
                          onPressed: () { setState(() { tareaActiva = t; respuestaTemporal = ''; ctrlRespuestaTexto.clear(); vistaActual = 'resolver_tarea'; }); },
                        ),
                      );
                    }
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        Expanded(
          child: GridView.count(
            crossAxisCount: 2, childAspectRatio: 1.3, padding: const EdgeInsets.symmetric(horizontal: 20), crossAxisSpacing: 15, mainAxisSpacing: 15,
            children: [
              _tarjetaMenu('Rutinas', Icons.schedule, const Color(0xFFFFB74D), () => setState(() => vistaActual = 'rutinas')),
              _tarjetaMenu('Comunicación', Icons.record_voice_over, const Color(0xFF81C784), () => setState(() => vistaActual = 'comunicacion')),
              _tarjetaMenu('Pausa de Respiración', Icons.self_improvement, Colors.teal, () { _iniciarRespiracion(); setState(() => vistaActual = 'pausa_respiracion'); }),
              _tarjetaMenu('Tablas Multiplicar', Icons.grid_on, Colors.indigo, () => setState(() => vistaActual = 'tablas_multiplicar')),
              _tarjetaMenu('Matemáticas', Icons.calculate, const Color(0xFF4A90E2), () {
                var mats = misPendientes.where((t) => t['materia'] == 'Matemáticas').toList();
                if(mats.isNotEmpty) {
                  setState(() { tareaActiva = mats.first; respuestaTemporal = ''; vistaActual = 'resolver_tarea'; });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No tienes tareas pendientes")));
                }
              }),
              _tarjetaMenu('Lengua', Icons.spellcheck, Colors.purple.shade300, () {
                var lens = misPendientes.where((t) => t['materia'] == 'Lengua').toList();
                if(lens.isNotEmpty) {
                  setState(() { tareaActiva = lens.first; respuestaTemporal = ''; ctrlRespuestaTexto.clear(); vistaActual = 'resolver_tarea'; });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No tienes tareas pendientes")));
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tarjetaMenu(String titulo, IconData icono, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Container(decoration: BoxDecoration(color: _obtenerColorTarjeta(), borderRadius: BorderRadius.circular(20), border: Border.all(color: color, width: 3), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icono, size: 45, color: color), const SizedBox(height: 8), Text(titulo, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto()))])),
    );
  }

  // --- VISTA PAUSA DE RESPIRACIÓN (CON BOTÓN DE PAUSAR / CONTINUAR) ---
  Widget vistaPausaRespiracion() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [IconButton(icon: Icon(Icons.arrow_back, size: 30, color: _obtenerColorTexto()), onPressed: () { timerRespiracion?.cancel(); setState(() => vistaActual = 'dashboard'); })]),
          Text("Pausa de Calma", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
          const SizedBox(height: 30),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            width: estadoRespiracion.contains('Inhala') ? 220 : (estadoRespiracion.contains('Manten') ? 220 : 140),
            height: estadoRespiracion.contains('Inhala') ? 220 : (estadoRespiracion.contains('Manten') ? 220 : 140),
            decoration: BoxDecoration(
              color: Colors.teal.shade200, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.teal.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 10)]
            ),
            child: Center(
              child: Text("$segundosRespiracion", style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 30),
          Text(estadoRespiracion, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 20),
          
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: respiracionPausada ? Colors.green : Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            icon: Icon(respiracionPausada ? Icons.play_arrow : Icons.pause, color: Colors.white, size: 28),
            label: Text(
              respiracionPausada ? "Continuar" : "Pausar",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            onPressed: _pausarOContinuarRespiracion,
          ),
          
          const SizedBox(height: 20),
          Text("Ciclos de calma: $ciclosCompletados", style: TextStyle(fontSize: 18, color: _obtenerColorTexto())),
        ],
      ),
    );
  }

  Widget vistaResolverTarea() {
    if (tareaActiva == null) return vistaDashboard();
    var opciones = List.from(tareaActiva['opciones']);
    bool esEscribirPictograma = tareaActiva['tipo'] == 'Escribir Pictograma';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${tareaActiva['materia']} - ${tareaActiva['tipo'] ?? ''}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), icon: const Icon(Icons.save, color: Colors.white), label: const Text("Guardar", style: TextStyle(color: Colors.white)),
                  onPressed: () { leerTexto("Tarea guardada."); setState(() { tareaActiva = null; vistaActual = 'dashboard'; }); },
                )
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: _obtenerColorTarjeta(), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent, width: 3)),
              child: Column(children: [
                Text(esEscribirPictograma ? "¿Qué es este pictograma?" : "Completa la actividad:", style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 15),
                Text(tareaActiva['pregunta'].toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: esEscribirPictograma ? 80 : 34, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
              ]),
            ),
            const SizedBox(height: 30),

            if (esEscribirPictograma) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: ctrlRespuestaTexto,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _obtenerColorTexto()),
                  decoration: const InputDecoration(hintText: "Escribe la palabra aquí..."),
                  onChanged: (v) => setState(() => respuestaTemporal = v.trim()),
                ),
              ),
            ] else ...[
              Wrap(
                spacing: 20, runSpacing: 20, alignment: WrapAlignment.center,
                children: opciones.map((opc) {
                  bool sel = respuestaTemporal == opc.toString();
                  return InkWell(onTap: () { setState(() { respuestaTemporal = opc.toString(); }); leerTexto(opc.toString()); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15), decoration: BoxDecoration(color: sel ? Colors.blue.shade100 : _obtenerColorTarjeta(), borderRadius: BorderRadius.circular(15), border: Border.all(color: sel ? Colors.blue : Colors.grey, width: 3)), child: Text(opc.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _obtenerColorTexto()))));
                }).toList(),
              ),
            ],

            const SizedBox(height: 40),
            if (respuestaTemporal.isNotEmpty)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18)),
                icon: const Icon(Icons.send, color: Colors.white, size: 30), label: const Text("¡Terminar!", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  DateTime ahora = DateTime.now();
                  String horaFormateada = "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')} - ${ahora.day}/${ahora.month}";

                  if (respuestaTemporal.toLowerCase() == tareaActiva['correcta'].toString().toLowerCase()) {
                    leerTexto("¡Excelente trabajo!");
                  } else {
                    leerTexto("Enviado a la maestra");
                  }
                  setState(() {
                    tareaActiva['estado'] = 'Completado';
                    tareaActiva['respuestaAlumno'] = respuestaTemporal;
                    tareaActiva['horaCompletado'] = horaFormateada;
                    tareaActiva = null;
                    vistaActual = 'dashboard';
                  }); 
                  _sincronizar();
                },
              )
          ],
        ),
      ),
    );
  }

  Widget vistaTablasMultiplicar() {
    return Column(
      children: [
        Row(children: [IconButton(icon: Icon(Icons.arrow_back, size: 30, color: _obtenerColorTexto()), onPressed: () => setState(() => vistaActual = 'dashboard'))]),
        const Text("TABLAS DE MULTIPLICAR", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(10, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text("Tabla del ${i + 1}"),
                selected: tablaSeleccionadaVer == (i + 1),
                onSelected: (val) { setState(() => tablaSeleccionadaVer = i + 1); leerTexto("Tabla del ${i + 1}"); },
              ),
            )),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _obtenerColorTarjeta(), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.indigo, width: 3)),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, idx) {
                int mult = idx + 1;
                int res = tablaSeleccionadaVer * mult;
                return ListTile(
                  title: Text("$tablaSeleccionadaVer x $mult = $res", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _obtenerColorTexto())),
                  trailing: IconButton(icon: const Icon(Icons.volume_up, color: Colors.indigo), onPressed: () => leerTexto("$tablaSeleccionadaVer por $mult es $res")),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  Widget vistaRutinas() {
    int completadas = rutinas.where((r) => r['completada'] == true).length; 
    double progreso = rutinas.isEmpty ? 0 : completadas / rutinas.length;
    return Column(
      children: [
        Row(children: [IconButton(icon: Icon(Icons.arrow_back, size: 30, color: _obtenerColorTexto()), onPressed: () => setState(() => vistaActual = 'dashboard'))]),
        Container(padding: const EdgeInsets.all(16), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Progreso del día', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _obtenerColorTexto())), Text('$completadas de ${rutinas.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFB74D)))]), const SizedBox(height: 8), LinearProgressIndicator(value: progreso, minHeight: 12, borderRadius: BorderRadius.circular(6), backgroundColor: Colors.grey.shade300, color: const Color(0xFF81C784))])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: rutinas.length, itemBuilder: (context, index) { final rutina = rutinas[index]; bool lista = rutina['completada'] == true; return GestureDetector(onTap: () { setState(() => rutina['completada'] = !lista); if (!lista) leerTexto("Bien hecho"); _sincronizar(); }, child: Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: lista ? Colors.green.withValues(alpha: 0.1) : _obtenerColorTarjeta(), borderRadius: BorderRadius.circular(16), border: Border.all(color: lista ? Colors.green : Colors.grey.shade300, width: 2)), child: ListTile(leading: Icon(rutina['icono'] as IconData, size: 32, color: rutina['color'] as Color), title: Text(rutina['titulo'].toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: lista ? TextDecoration.lineThrough : null, color: lista ? Colors.grey : _obtenerColorTexto())), trailing: Icon(Icons.check, color: lista ? Colors.green : Colors.grey.shade300, size: 28)))); })),
      ],
    );
  }

  Widget vistaComunicacion() {
    return Column(
      children: [
        Row(children: [IconButton(icon: Icon(Icons.arrow_back, size: 30, color: _obtenerColorTexto()), onPressed: () => setState(() => vistaActual = 'dashboard'))]),
        Container(padding: const EdgeInsets.all(10), margin: const EdgeInsets.all(16), height: 100, decoration: BoxDecoration(color: _obtenerColorTarjeta(), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300, width: 2)), child: Row(children: [Expanded(child: fraseActual.isEmpty ? const Center(child: Text('Toca las tarjetas para hablar', style: TextStyle(color: Colors.grey, fontSize: 18))) : ListView.builder(scrollDirection: Axis.horizontal, itemCount: fraseActual.length, itemBuilder: (context, index) { final item = fraseActual[index]; return Padding(padding: const EdgeInsets.only(right: 8.0), child: Chip(avatar: Icon(item['icono'] as IconData, color: item['color'] as Color), label: Text(item['titulo'].toString(), style: const TextStyle(fontSize: 18)), backgroundColor: (item['color'] as Color).withValues(alpha: 0.15))); })), if (fraseActual.isNotEmpty) IconButton(icon: const Icon(Icons.backspace, color: Colors.redAccent, size: 28), onPressed: () => setState(() => fraseActual.clear()))])),
        if (fraseActual.isNotEmpty) ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)), icon: const Icon(Icons.record_voice_over, color: Colors.white), label: const Text("Hablar", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), onPressed: () { String textoFrase = fraseActual.map((i) => i['titulo'].toString()).join(" "); leerTexto(textoFrase); }),
        Expanded(child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.4, crossAxisSpacing: 16, mainAxisSpacing: 16), itemCount: pictogramas.length, itemBuilder: (context, index) { final pic = pictogramas[index]; return _tarjetaMenu(pic['titulo'].toString(), pic['icono'] as IconData, pic['color'] as Color, () { setState(() => fraseActual.add(pic)); leerTexto(pic['titulo'].toString()); }); })),
      ],
    );
  }

  Widget _construirVista() {
    switch (vistaActual) {
      case 'inicio_app': return vistaInicioApp();
      case 'pin_maestra': return vistaPinMaestra();
      case 'panel_maestra': return vistaMaestra();
      case 'select_alumno': return vistaSeleccionAlumno();
      case 'dashboard': return vistaDashboard();
      case 'resolver_tarea': return vistaResolverTarea();
      case 'tablas_multiplicar': return vistaTablasMultiplicar();
      case 'pausa_respiracion': return vistaPausaRespiracion();
      case 'rutinas': return vistaRutinas();
      case 'comunicacion': return vistaComunicacion();
      default: return vistaInicioApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _obtenerColorFondo(),
      appBar: (vistaActual != 'inicio_app' && vistaActual != 'pin_maestra' && vistaActual != 'panel_maestra' && vistaActual != 'select_alumno') ? AppBar(
        backgroundColor: _obtenerColorTarjeta(), elevation: 0,
        title: Row(
          children: [
            IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: () => setState(() { alumnoActual = null; vistaActual = 'inicio_app'; })),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blueAccent, size: 28),
              tooltip: "Créditos",
              onPressed: () => _mostrarCreditos(context),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: const Icon(Icons.self_improvement, color: Colors.teal, size: 30),
              tooltip: "Pausa de Respiración",
              onPressed: () {
                _iniciarRespiracion();
                setState(() => vistaActual = 'pausa_respiracion');
              },
            ),
            const SizedBox(width: 5),
            DropdownButton<String>(
              value: modoIluminacion,
              underline: const SizedBox(),
              items: ['Calma', 'Activo', 'Oscuro'].map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: _obtenerColorTexto())))).toList(),
              onChanged: (v) {
                setState(() => modoIluminacion = v.toString());
                _sincronizar();
              },
            ),
            const SizedBox(width: 10),
            IconButton(icon: Icon(sonidoActivado ? Icons.volume_up : Icons.volume_off, color: Colors.blueAccent, size: 30), onPressed: () { setState(() => sonidoActivado = !sonidoActivado); _sincronizar(); })
          ]
        )
      ) : null,
      body: SafeArea(child: _construirVista()),
    );
  }
}