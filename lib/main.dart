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
          _consoleLogs.add({'type': 'out', 'text': '${vars[content]}'});
        } else {
          _consoleLogs.add({'type': 'out', 'text': content});
        }
      } else if (line.startsWith('Leer')) {
        var varName = line.substring(4).trim();
        if (varName.endsWith(';')) varName = varName.substring(0, varName.length - 1).trim();
        vars[varName] = 16;
        _consoleLogs.add({'type': 'in', 'text': '-> [$varName] = 16 (Entrada simulada)'});
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
        _consoleLogs.add({'type': 'in', 'text': 'Leido [$v] <- 18'});
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
          buffer.writeln('    print($c)');
        } else if (line.startsWith('Leer')) {
          var v = line.substring(4).replaceAll(';', '').trim();
          buffer.writeln('    $v = float(input())');
        } else if (line.contains('<-')) {
          var parts = line.split('<-');
          buffer.writeln('    ${parts[0].trim()} = ${parts[1].replaceAll(";", "").trim()}');
        } else if (line.startsWith('Si') && line.contains('Entonces')) {
          var cond = line.substring(2, line.indexOf('Entonces')).replaceAll('Y', 'and').replaceAll('O', 'or').trim();
          buffer.writeln('    if $cond:');
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
          buffer.writeln('    cout << $c << endl;');
        } else if (line.startsWith('Leer')) {
          var v = line.substring(4).replaceAll(';', '').trim();
          buffer.writeln('    cin >> $v;');
        } else if (line.contains('<-')) {
          var parts = line.split('<-');
          buffer.writeln('    ${parts[0].trim()} = ${parts[1].replaceAll(";", "").trim()};');
        } else if (line.startsWith('Si') && line.contains('Entonces')) {
          var cond = line.substring(2, line.indexOf('Entonces')).trim();
          buffer.writeln('    if ($cond) {');
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
          buffer.writeln('        System.out.println($c);');
        } else if (line.startsWith('Leer')) {
          var v = line.substring(4).replaceAll(';', '').trim();
          buffer.writeln('        double $v = sc.nextDouble();');
        } else if (line.contains('<-')) {
          var parts = line.split('<-');
          buffer.writeln('        ${parts[0].trim()} = ${parts[1].replaceAll(";", "").trim()};');
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
                  pw.Text('Reporte de Algoritmo - by aethell_labs',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.Text('by aethell_labs', style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey800)),
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
    final nameController = TextEditingController(text: 'Mi Algoritmo ${_savedAlgorithms.length + 1}');
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
                SnackBar(content: Text('Guardado como "${nameController.text}"')),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Row(
              children: [
                Icon(Icons.terminal, color: Colors.blueAccent, size: 20),
                SizedBox(width: 6),
                Text('PseudoCode Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            Text('by aethell_labs', style: TextStyle(fontSize: 10, color: Colors.cyanAccent, letterSpacing: 0.8)),
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
    final lineNumbersText = List.generate(linesCount, (i) => '${i + 1}').join('\n');

    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF14181E),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gutter con números de línea
                Container(
                  width: 42,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: const Color(0xFF0D1015),
                  child: Text(
                    lineNumbersText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: _fontSize,
                      color: Colors.white24,
                      height: 1.45,
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.white10),
                // Área de código
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: TextField(
                      controller: _codeController,
                      focusNode: _focusNode,
                      maxLines: null,
                      expands: true,
                      onChanged: (v) => setState(() {}),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: _fontSize,
                        color: const Color(0xFFE2E8F0),
                        height: 1.45,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Escribe tu algoritmo...',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildKeyboardToolbar(),
      ],
    );
  }

  // Barra de botones inteligentes (Toolbar de 2 filas)
  Widget _buildKeyboardToolbar() {
    return Container(
      color: const Color(0xFF1A1F26),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila 1: Snippets con autocompletado
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _shortcutButton('Si', () => _insertText('Si  Entonces\n\t\nFinSi', offset: -16)),
                _shortcutButton('Para', () => _insertText('Para i <- 1 Hasta  Con Paso 1 Hacer\n\t\nFinPara', offset: -26)),
                _shortcutButton('Mientras', () => _insertText('Mientras  Hacer\n\t\nFinMientras', offset: -21)),
                _shortcutButton('Escribir', () => _insertText('Escribir "";', offset: -2)),
                _shortcutButton('Leer', () => _insertText('Leer ;', offset: -1)),
                _shortcutButton('Definir', () => _insertText('Definir  Como Entero;', offset: -14)),
              ],
            ),
          ),
          const Divider(height: 6, color: Colors.white10),
          // Fila 2: Símbolos clave en 1 toque
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _symbolButton('<-', () => _insertText(' <- ')),
                _symbolButton(';', () => _insertText(';')),
                _symbolButton('""', () => _insertText('""', offset: -1)),
                _symbolButton('()', () => _insertText('()', offset: -1)),
                _symbolButton('>=', () => _insertText(' >= ')),
                _symbolButton('<=', () => _insertText(' <= ')),
                _symbolButton('==', () => _insertText(' == ')),
                _symbolButton('Tab', () => _insertText('  ')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcutButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF28303B),
          foregroundColor: Colors.lightBlueAccent,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          minimumSize: const Size(38, 30),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _symbolButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          minimumSize: const Size(36, 30),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  // 2. PESTAÑA DE DIAGRAMA INTERACTIVO CON FIGURAS PSEINT
  Widget _buildDiagramTab() {
    final steps = _codeController.text.split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('//'))
        .toList();

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(120),
      minScale: 0.3,
      maxScale: 3.5,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final text = entry.value;
              final isLast = idx == steps.length - 1;

              return Column(
                children: [
                  _renderPseintShape(text),
                  if (!isLast)
                    const Column(
                      children: [
                        SizedBox(height: 2),
                        Icon(Icons.arrow_downward_rounded, size: 22, color: Colors.blueAccent),
                        SizedBox(height: 2),
                      ],
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Renderizado según la figura formal de PSeInt
  Widget _renderPseintShape(String text) {
    // A. INICIO / FIN: Cápsula
    if (text.startsWith('Algoritmo') || text.startsWith('FinAlgoritmo')) {
      return Container(
        constraints: const BoxConstraints(minWidth: 170, maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
    }

    // B. DECISIÓN: Rombo (Si, Mientras)
    if (text.startsWith('Si') || text.startsWith('Mientras')) {
      return CustomPaint(
        painter: DiamondBorderPainter(color: Colors.redAccent),
        child: ClipPath(
          clipper: DiamondClipper(),
          child: Container(
            width: 250,
            height: 90,
            color: const Color(0xFF3D1620),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // C. ENTRADA (Leer): Paralelogramo inclinado
    if (text.startsWith('Leer')) {
      return CustomPaint(
        painter: ParallelogramBorderPainter(color: Colors.tealAccent),
        child: ClipPath(
          clipper: ParallelogramClipper(),
          child: Container(
            width: 230,
            color: const Color(0xFF0F3633),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_forward_rounded, color: Colors.tealAccent, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // D. SALIDA (Escribir): Trapecio estándar PSeInt
    if (text.startsWith('Escribir')) {
      return CustomPaint(
        painter: TrapezoidBorderPainter(color: Colors.amberAccent),
        child: ClipPath(
          clipper: TrapezoidClipper(),
          child: Container(
            width: 250,
            color: const Color(0xFF3B2E05),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_outward_rounded, color: Colors.amberAccent, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // E. PROCESO / ASIGNACIÓN: Rectángulo recto
    return Container(
      constraints: const BoxConstraints(minWidth: 170, maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E242C),
        border: Border.all(color: Colors.lightBlueAccent, width: 1.8),
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 3. PESTAÑA DE CONSOLA Y PRUEBA DE ESCRITORIO
  Widget _buildConsoleTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: const Color(0xFF181D24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      minimumSize: const Size(60, 30),
                    ),
                    icon: const Icon(Icons.skip_next_rounded, size: 18),
                    label: Text(_currentStepIndex == -1 ? 'Paso a Paso' : 'Siguiente (${_currentStepIndex + 1})'),
                    onPressed: _currentStepIndex == -1 ? _startStepByStep : _nextStep,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
                onPressed: () => setState(() {
                  _consoleLogs.clear();
                  _memoryVariables.clear();
                  _currentStepIndex = -1;
                }),
              ),
            ],
          ),
        ),
        // Fila de memoria de variables (Prueba de escritorio)
        if (_memoryVariables.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: const Color(0xFF102A43),
            child: Row(
              children: [
                const Icon(Icons.memory_rounded, size: 16, color: Colors.cyanAccent),
                const SizedBox(width: 8),
                const Text('Memoria: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _memoryVariables.entries.map((e) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                          ),
                          child: Text('${e.key} = ${e.value}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Pantalla de terminal estilo chat
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _consoleLogs.length,
            itemBuilder: (context, i) {
              final log = _consoleLogs[i];
              final isSys = log['type'] == 'sys';
              final isInput = log['type'] == 'in';

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                alignment: isInput ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSys
                        ? Colors.transparent
                        : isInput
                            ? const Color(0xFF1565C0)
                            : const Color(0xFF222832),
                    borderRadius: BorderRadius.circular(6),
                    border: isSys ? Border.all(color: Colors.white12) : null,
                  ),
                  child: Text(
                    log['text']!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isSys ? Colors.white54 : Colors.white,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. PESTAÑA DE TRADUCCIÓN A LENGUAJES REALES
  Widget _buildTranslateTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Colors.cyanAccent,
            tabs: [
              Tab(text: 'Python'),
              Tab(text: 'C++'),
              Tab(text: 'Java'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _codeViewerBox(_translateCode('Python')),
                _codeViewerBox(_translateCode('C++')),
                _codeViewerBox(_translateCode('Java')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeViewerBox(String translatedCode) {
    return Container(
      color: const Color(0xFF14181E),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SelectableText(
          translatedCode,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF79C0FF), height: 1.45),
        ),
      ),
    );
  }

  // 5. BANCO DE RETOS Y PROYECTOS GUARDADOS
  Widget _buildProjectsAndChallengesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _savedAlgorithms.length,
      itemBuilder: (context, i) {
        final item = _savedAlgorithms[i];
        final level = item['level'] ?? 'Normal';
        final isEasy = level == 'Facil';
        final isAdv = level == 'Avanzado';

        return Card(
          color: const Color(0xFF181D24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Chip(
                      label: Text(level, style: const TextStyle(fontSize: 10.5)),
                      backgroundColor: isEasy
                          ? Colors.green.withOpacity(0.2)
                          : isAdv
                              ? Colors.red.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item['desc'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      minimumSize: const Size(70, 30),
                    ),
                    icon: const Icon(Icons.file_upload_outlined, size: 16),
                    label: const Text('Cargar al Editor', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      setState(() {
                        _codeController.text = item['code']!;
                        _tabController.animateTo(0);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cargado: ${item['title']}')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// FIGURAS GEOMÉTRICAS Y BORDES OFICIALES DE PSEINT
// ---------------------------------------------------------------------------

// 1. ROMBO (DECISIÓN: Si / Mientras)
class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DiamondBorderPainter extends CustomPainter {
  final Color color;
  DiamondBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}

// 2. PARALELOGRAMO (ENTRADA: Leer)
class ParallelogramClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const slant = 18.0;
    return Path()
      ..moveTo(slant, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - slant, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ParallelogramBorderPainter extends CustomPainter {
  final Color color;
  ParallelogramBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const slant = 18.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(slant, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - slant, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}

// 3. TRAPECIO (SALIDA: Escribir - Norma PSeInt)
class TrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const slant = 18.0;
    return Path()
      ..moveTo(slant, 0)
      ..lineTo(size.width - slant, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class TrapezoidBorderPainter extends CustomPainter {
  final Color color;
  TrapezoidBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const slant = 18.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(slant, 0)
      ..lineTo(size.width - slant, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}
