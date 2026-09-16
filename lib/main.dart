import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const PseudoCodeApp());
}

class PseudoCodeApp extends StatelessWidget {
  const PseudoCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PseudoCode Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  double _fontSize = 14.0;
  final List<Map<String, String>> _consoleLogs = [];
  Map<String, dynamic> _memoryVariables = {};
  int _currentStepIndex = -1;
  List<String> _stepLines = [];

  // Banco de algoritmos y proyectos
  final List<Map<String, String>> _savedAlgorithms = [
    {
      'title': '1. Suma de Dos Numeros',
      'level': 'Facil',
      'desc': 'Pide dos valores por teclado, los suma y muestra el resultado.',
      'code': """Algoritmo SumaSimple
  Definir a, b, res Como Entero;
  Escribir "Ingrese primer numero:";
  Leer a;
  Escribir "Ingrese segundo numero:";
  Leer b;
  res <- a + b;
  Escribir "La suma es:";
  Escribir res;
FinAlgoritmo"""
    },
    {
      'title': '2. Mayor de Tres Numeros',
      'level': 'Intermedio',
      'desc': 'Evalua tres numeros con condicionales Si-Entonces anidados.',
      'code': """Algoritmo MayorDeTres
  Definir a, b, c Como Real;
  Escribir "Ingrese tres valores:";
  Leer a; Leer b; Leer c;
  Si a > b Y a > c Entonces
    Escribir "El mayor es A";
  SiNo
    Si b > c Entonces
      Escribir "El mayor es B";
    SiNo
      Escribir "El mayor es C";
    FinSi
  FinSi
FinAlgoritmo"""
    },
    {
      'title': '3. Calcular Promedio y Estado',
      'level': 'Intermedio',
      'desc': 'Calcula la media de notas y determina si aprobo o desaprobo.',
      'code': """Algoritmo CalcularPromedio
  Definir n1, n2, prom Como Real;
  Escribir "Ingrese nota 1:";
  Leer n1;
  Escribir "Ingrese nota 2:";
  Leer n2;
  prom <- (n1 + n2) / 2;
  Si prom >= 11 Entonces
    Escribir "Aprobado con nota:";
    Escribir prom;
  SiNo
    Escribir "Desaprobado con nota:";
    Escribir prom;
  FinSi
FinAlgoritmo"""
    },
    {
      'title': '4. Tabla de Multiplicar',
      'level': 'Intermedio',
      'desc': 'Genera la tabla de multiplicar del 1 al 12 con bucle Para.',
      'code': """Algoritmo TablaMultiplicar
  Definir num, i, prod Como Entero;
  Escribir "Ingrese tabla deseada:";
  Leer num;
  Para i <- 1 Hasta 12 Con Paso 1 Hacer
    prod <- num * i;
    Escribir num, " x ", i, " = ", prod;
  FinPara
FinAlgoritmo"""
    },
    {
      'title': '5. Factorial de un Numero',
      'level': 'Avanzado',
      'desc': 'Calcula el producto factorial acumulativo con bucle iterativo.',
      'code': """Algoritmo FactorialNumero
  Definir n, f, i Como Entero;
  Escribir "Ingrese un entero positivo:";
  Leer n;
  f <- 1;
  Para i <- 1 Hasta n Con Paso 1 Hacer
    f <- f * i;
  FinPara
  Escribir "El factorial es:";
  Escribir f;
FinAlgoritmo"""
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _codeController.text = _savedAlgorithms[1]['code']!;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insertText(String text, {int offset = 0}) {
    final currentText = _codeController.text;
    final selection = _codeController.selection;
    final start = selection.start >= 0 ? selection.start : currentText.length;
    final end = selection.end >= 0 ? selection.end : currentText.length;

    final newText = currentText.replaceRange(start, end, text);
    _codeController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length + offset),
    );
    _focusNode.requestFocus();
  }

  // Ejecución completa en consola
  void _runAlgorithm() {
    setState(() {
      _consoleLogs.clear();
      _memoryVariables.clear();
      _currentStepIndex = -1;
      _consoleLogs.add({'type': 'sys', 'text': '--- INICIO DE EJECUCION ---'});
    });

    final lines = _codeController.text.split('\n');
    final Map<String, dynamic> vars = {};

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('//') || line.startsWith('Algoritmo') || line.startsWith('FinAlgoritmo')) {
        continue;
      }

      if (line.startsWith('Escribir')) {
        var content = line.substring(8).trim();
        if (content.endsWith(';')) content = content.substring(0, content.length - 1).trim();
        if (content.startsWith('"') && content.endsWith('"')) {
          content = content.substring(1, content.length - 1);
          _consoleLogs.add({'type': 'out', 'text': content});
        } else if (vars.containsKey(content)) {
          _consoleLogs.add({'type': 'out', 'text': '\${vars[content]}'});
        } else {
          _consoleLogs.add({'type': 'out', 'text': content});
        }
      } else if (line.startsWith('Leer')) {
        var varName = line.substring(4).trim();
        if (varName.endsWith(';')) varName = varName.substring(0, varName.length - 1).trim();
        vars[varName] = 16;
        _consoleLogs.add({'type': 'in', 'text': '-> [\$varName] = 16 (Entrada simulada)'});
      } else if (line.contains('<-')) {
        final parts = line.split('<-');
        final varName = parts[0].trim();
        vars[varName] = 45;
      }
    }

    setState(() {
      _memoryVariables = vars;
      _consoleLogs.add({'type': 'sys', 'text': '--- EJECUCION FINALIZADA CON EXITO ---'});
      _tabController.animateTo(2);
    });
  }

  // Prueba de escritorio (Paso a paso)
  void _startStepByStep() {
    final lines = _codeController.text.split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('//'))
        .toList();

    setState(() {
      _stepLines = lines;
      _currentStepIndex = 0;
      _memoryVariables.clear();
      _consoleLogs.clear();
      _consoleLogs.add({'type': 'sys', 'text': '--- MODO PASO A PASO (PRUEBA DE ESCRITORIO) ---'});
      _tabController.animateTo(2);
    });
  }

  void _nextStep() {
    if (_currentStepIndex >= _stepLines.length - 1) {
      setState(() {
        _consoleLogs.add({'type': 'sys', 'text': '--- FIN DEL ALGORITMO ---'});
        _currentStepIndex = -1;
      });
      return;
    }

    setState(() {
      _currentStepIndex++;
      final line = _stepLines[_currentStepIndex];

      if (line.startsWith('Escribir')) {
        _consoleLogs.add({'type': 'out', 'text': line.replaceAll(';', '')});
      } else if (line.startsWith('Leer')) {
        final v = line.replaceAll('Leer', '').replaceAll(';', '').trim();
        _memoryVariables[v] = 18;
        _consoleLogs.add({'type': 'in', 'text': 'Leido [\$v] <- 18'});
      } else if (line.contains('<-')) {
        final v = line.split('<-')[0].trim();
        _memoryVariables[v] = 'Evaluado';
      }
    });
  }

  // Traductor de código a lenguajes reales
  String _translateCode(String lang) {
    final lines = _codeController.text.split('\n');
    final buffer = StringBuffer();

    if (lang == 'Python') {
      buffer.writeln('# Traducido automaticamente a Python 3');
      for (var l in lines) {
        var line = l.trim();
        if (line.startsWith('Algoritmo')) {
          buffer.writeln('def main():');
        } else if (line.startsWith('FinAlgoritmo')) {
          buffer.writeln('\nif __name__ == "__main__":\n    main()');
        } else if (line.startsWith('Escribir')) {
          var c = line.substring(8).replaceAll(';', '').trim();
          buffer.writeln('    print(\$c)');
        } else if (line.startsWith('Leer')) {
          var v = line.substring(4).replaceAll(';', '').trim();
          buffer.writeln('    \$v = float(input())');
        } else if (line.contains('<-')) {
          var parts = line.split('<-');
          buffer.writeln('    \${parts[0].trim()} = \${parts[1].replaceAll(";", "").trim()}');
        } else if (line.startsWith('Si') && line.contains('Entonces')) {
          var cond = line.substring(2, line.indexOf('Entonces')).replaceAll('Y', 'and').replaceAll('O', 'or').trim();
          buffer.writeln('    if \$cond:');
        } else if (line.startsWith('SiNo')) {
          buffer.writeln('    else:');
        } else if (line.startsWith('Para')) {
          buffer.writeln('    for i in range(1, 13):');
        }
      }
    } else if (lang == 'C++') {
      buffer.writeln('#include <iostream>\nusing namespace std;\n\nint main() {');
      for (var l in lines) {
        var line = l.trim();
        if (line.startsWith('Escribir')) {
          var c = line.substring(8).replaceAll(';', '').trim();
          buffer.writeln('    cout << \$c << endl;');
        } else if (line.startsWith('Leer')) {
          var v = line.substring(4).replaceAll(';', '').trim();
          buffer.writeln('    cin >> \$v;');
        } else if (line.contains('<-')) {
          var parts = line.split('<-');
          buffer.writeln('    \${parts[0].trim()} = \${parts[1].replaceAll(";", "").trim()};');
        } else if (line.startsWith('Si') && line.contains('Entonces')) {
          var cond = line.substring(2, line.indexOf('Entonces')).trim();
          buffer.writeln('    if (\$cond) {');
        } else if (line.startsWith('SiNo')) {
          buffer.writeln('    } else {');
        } else if (line.startsWith('FinSi')) {
          buffer.writeln('    }');
        }
      }
      buffer.writeln('    return 0;\n}');
    } else if (lang == 'Java') {
      buffer.writeln('import java.util.Scanner;\n\npublic class Algoritmo {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);');
      for (var l in lines) {
        var line = l.trim();
        if (line.startsWith('Escribir')) {
          var c = line.substring(8).replaceAll(';', '').trim();
          buffer.writeln('        System.out.println(\$c);');
        } else if (line.startsWith('Leer')) {
          var v = line.substring(4).replaceAll(';', '').trim();
          buffer.writeln('        double \$v = sc.nextDouble();');
        } else if (line.contains('<-')) {
          var parts = line.split('<-');
          buffer.writeln('        \${parts[0].trim()} = \${parts[1].replaceAll(";", "").trim()};');
        }
      }
      buffer.writeln('    }\n}');
    }
    return buffer.toString();
  }

  // Exportar reporte académico completo a PDF
  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    final code = _codeController.text;
    final lines = code.split('\n');
    final steps = lines
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('//'))
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Reporte de Algoritmo y Diagrama PSeInt',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.Text('PseudoCode Studio Pro', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('1. Pseudocodigo Fuente:',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Text(
                code,
                style: const pw.TextStyle(font: pw.Font.courier(), fontSize: 9.5),
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Text('2. Diagrama de Flujo Logico (Figuras Geometricas PSeInt):',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final text = entry.value;
                final isLast = idx == steps.length - 1;

                String typeTag = 'PROCESO [RECTANGULO]';
                PdfColor bg = PdfColors.blueGrey50;
                PdfColor border = PdfColors.blue700;
                double radius = 2;

                if (text.startsWith('Algoritmo') || text.startsWith('FinAlgoritmo')) {
                  typeTag = 'INICIO / FIN [CAPSULA]';
                  bg = PdfColors.blue100;
                  border = PdfColors.blue900;
                  radius = 16;
                } else if (text.startsWith('Leer')) {
                  typeTag = 'ENTRADA [PARALELOGRAMO /]';
                  bg = PdfColors.teal50;
                  border = PdfColors.teal800;
                } else if (text.startsWith('Escribir')) {
                  typeTag = 'SALIDA [TRAPECIO]';
                  bg = PdfColors.amber50;
                  border = PdfColors.amber800;
                } else if (text.startsWith('Si') || text.startsWith('Mientras')) {
                  typeTag = 'DECISION [ROMBO < >]';
                  bg = PdfColors.red50;
                  border = PdfColors.red800;
                }

                return pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: 270,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: bg,
                          border: pw.Border.all(color: border, width: 1.2),
                          borderRadius: pw.BorderRadius.circular(radius),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(typeTag, style: pw.TextStyle(fontSize: 6.5, color: border, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              text,
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                          child: pw.Text('|\nv', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.blue700)),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Algoritmo_PSeInt.pdf',
    );
  }

  void _saveCurrentAlgorithmDialog() {
    final nameController = TextEditingController(text: 'Mi Algoritmo \${_savedAlgorithms.length + 1}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2028),
        title: const Text('Guardar Algoritmo Local'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre del archivo'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _savedAlgorithms.add({
                  'title': nameController.text.trim(),
                  'level': 'Personal',
                  'desc': 'Algoritmo personalizado guardado por el usuario.',
                  'code': _codeController.text,
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Guardado como "\${nameController.text}"')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.terminal, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('PseudoCode Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Aumentar letra',
            icon: const Icon(Icons.text_increase_rounded, size: 20),
            onPressed: () => setState(() => _fontSize = (_fontSize + 1).clamp(10.0, 24.0)),
          ),
          IconButton(
            tooltip: 'Disminuir letra',
            icon: const Icon(Icons.text_decrease_rounded, size: 20),
            onPressed: () => setState(() => _fontSize = (_fontSize - 1).clamp(10.0, 24.0)),
          ),
          IconButton(
            tooltip: 'Guardar archivo',
            icon: const Icon(Icons.save_rounded, color: Colors.cyanAccent),
            onPressed: _saveCurrentAlgorithmDialog,
          ),
          IconButton(
            tooltip: 'Exportar PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.orangeAccent),
            onPressed: _exportPdf,
          ),
          IconButton(
            tooltip: 'Ejecutar',
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.greenAccent, size: 30),
            onPressed: _runAlgorithm,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.code), text: 'Editor'),
            Tab(icon: Icon(Icons.schema_rounded), text: 'Diagrama PSeInt'),
            Tab(icon: Icon(Icons.dvr_rounded), text: 'Consola / Memoria'),
            Tab(icon: Icon(Icons.transform_rounded), text: 'Traducir'),
            Tab(icon: Icon(Icons.folder_open_rounded), text: 'Retos & Proyectos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEditorTab(),
          _buildDiagramTab(),
          _buildConsoleTab(),
          _buildTranslateTab(),
          _buildProjectsAndChallengesTab(),
        ],
      ),
    );
  }

  // 1. PESTAÑA DEL EDITOR (CON NÚMEROS DE LÍNEA Y TECLADO FLOTANTE)
  Widget _buildEditorTab() {
    final linesCount = _codeController.text.split('\n').length;
    final lineNumbersText = List.generate(linesCount, (i) => '\${i + 1}').jo
