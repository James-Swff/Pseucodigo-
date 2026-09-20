import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
  List<String> _syntaxErrors = [];

  String _studentName = 'Estudiante';
  String _courseName = 'Algoritmos y Programacion';
  String _sectionCode = 'Facultad de Ingenieria';
  String _geminiApiKey = '';

  final List<Map<String, String>> _savedAlgorithms = [
    {
      'unit': 'Unidad 1: Secuencial (Sem. 1-6)',
      'title': '1. Conversión de Temperatura',
      'level': 'U1 - Básico',
      'desc': 'Conversión directa de Celsius a Fahrenheit y Kelvin sin condicionales.',
      'code': """Algoritmo ConversionTemperatura
  Definir celsius, fahrenheit, kelvin Como Real;
  Escribir "=== SISTEMA DE CONVERSION TERMICA ===";
  Escribir "Ingrese temperatura en grados Celsius:";
  Leer celsius;
  fahrenheit <- (celsius * 9 / 5) + 32;
  kelvin <- celsius + 273.15;
  Escribir "Temperatura en Fahrenheit:";
  Escribir fahrenheit;
  Escribir "Temperatura en Kelvin:";
  Escribir kelvin;
FinAlgoritmo"""
    },
    {
      'unit': 'Unidad 1: Secuencial (Sem. 1-6)',
      'title': '2. Desglose de Pago y Cambio',
      'level': 'U1 - Aplicación',
      'desc': 'Cálculo de cambio exacto dividiendo monedas y billetes secuencialmente.',
      'code': """Algoritmo DesgloseVenta
  Definir totalConsumo, montoPagado, vuelto Como Real;
  Escribir "Ingrese el monto total de la cuenta:";
  Leer totalConsumo;
  Escribir "Ingrese el dinero entregado por el cliente:";
  Leer montoPagado;
  vuelto <- montoPagado - totalConsumo;
  Escribir "El cambio a devolver es:";
  Escribir vuelto;
FinAlgoritmo"""
    },
    {
      'unit': 'Unidad 2: Condicionales (Sem. 7-12)',
      'title': '3. Planilla con Horas Extras (Si-Entonces)',
      'level': 'U2 - Condicional Doble',
      'desc': 'Aplica recargo del 150% en horas extras y descuento de ley del 9%.',
      'code': """Algoritmo CalcularPlanilla
  Definir horasTrabajadas Como Entero;
  Definir pagoPorHora, sueldoBruto, horasExtras, pagoExtras Como Real;
  Definir descuentoSalud, bonificacion, sueldoNeto Como Real;

  Escribir "Ingrese horas trabajadas:";
  Leer horasTrabajadas;
  Escribir "Ingrese tarifa por hora:";
  Leer pagoPorHora;

  Si horasTrabajadas > 40 Entonces
    horasExtras <- horasTrabajadas - 40;
    pagoExtras <- horasExtras * (pagoPorHora * 1.5);
    sueldoBruto <- (40 * pagoPorHora) + pagoExtras;
  SiNo
    horasExtras <- 0;
    pagoExtras <- 0;
    sueldoBruto <- horasTrabajadas * pagoPorHora;
  FinSi

  descuentoSalud <- sueldoBruto * 0.09;

  Si sueldoBruto < 1200 Entonces
    bonificacion <- 100;
  SiNo
    bonificacion <- 50;
  FinSi

  sueldoNeto <- (sueldoBruto - descuentoSalud) + bonificacion;

  Escribir "Sueldo Bruto:";
  Escribir sueldoBruto;
  Escribir "Descuento Salud (9%):";
  Escribir descuentoSalud;
  Escribir "Bonificacion:";
  Escribir bonificacion;
  Escribir "Sueldo Neto a Pagar:";
  Escribir sueldoNeto;
FinAlgoritmo"""
    },
    {
      'unit': 'Unidad 2: Condicionales (Sem. 7-12)',
      'title': '4. Menú de Opciones (Segun)',
      'level': 'U2 - Condicional Múltiple',
      'desc': 'Estructura Segun para seleccionar operaciones aritméticas por opción.',
      'code': """Algoritmo MenuOperaciones
  Definir opcion Como Entero;
  Definir n1, n2, resultado Como Real;
  Escribir "1: Sumar | 2: Multiplicar | 3: Potencia";
  Leer opcion;
  Escribir "Ingrese primer valor:";
  Leer n1;
  Escribir "Ingrese segundo valor:";
  Leer n2;
  Segun opcion Hacer
    1:
      resultado <- n1 + n2;
      Escribir "Resultado Suma:";
      Escribir resultado;
    2:
      resultado <- n1 * n2;
      Escribir "Resultado Multiplicacion:";
      Escribir resultado;
    De Otro Modo:
      resultado <- n1 * n1;
      Escribir "Cuadrado del primero:";
      Escribir resultado;
  FinSegun
FinAlgoritmo"""
    },
    {
      'unit': 'Unidad 3: Repetitivas (Sem. 13-18)',
      'title': '5. Tabla de Multiplicar (Para)',
      'level': 'U3 - Bucle Contador',
      'desc': 'Ciclo Para con contador incremental de 1 a 12.',
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
      'unit': 'Unidad 3: Repetitivas (Sem. 13-18)',
      'title': '6. Validación de Nota (Repetir - Hasta Que)',
      'level': 'U3 - Condición Final',
      'desc': 'Bucle con condición al final para forzar calificaciones válidas de 0 a 20.',
      'code': """Algoritmo ValidarNotaRepetir
  Definir nota Como Real;
  Repetir
    Escribir "Ingrese calificacion valida (0 a 20):";
    Leer nota;
  Hasta Que nota >= 0 Y nota <= 20
  Escribir "Nota universitaria registrada:";
  Escribir nota;
FinAlgoritmo"""
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _codeController.text = _savedAlgorithms[0]['code']!;
    _validateSyntax();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateSyntax() {
    final lines = _codeController.text.split('\n');
    final List<String> errors = [];
    int openSi = 0;
    int openPara = 0;
    int openMientras = 0;
    int openSegun = 0;
    int openRepetir = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('//')) continue;

      if (line.startsWith('Si ') && line.contains('Entonces')) openSi++;
      if (line.startsWith('FinSi')) openSi--;

      if (line.startsWith('Para ') && line.contains('Hacer')) openPara++;
      if (line.startsWith('FinPara')) openPara--;

      if (line.startsWith('Mientras ') && line.contains('Hacer')) openMientras++;
      if (line.startsWith('FinMientras')) openMientras--;

      if (line.startsWith('Segun ') && line.contains('Hacer')) openSegun++;
      if (line.startsWith('FinSegun')) openSegun--;

      if (line.startsWith('Repetir')) openRepetir++;
      if (line.startsWith('Hasta Que')) openRepetir--;

      if ((line.startsWith('Definir') || line.startsWith('Leer') || line.startsWith('Escribir') || line.contains('<-')) && !line.endsWith(';')) {
        errors.add('Línea ${i + 1}: Falta ";" al final.');
      }
    }

    if (openSi > 0) errors.add('Unidad 2: Falta cerrar bloque "Si" con "FinSi".');
    if (openSegun > 0) errors.add('Unidad 2: Falta cerrar condicional múltiple con "FinSegun".');
    if (openPara > 0) errors.add('Unidad 3: Falta cerrar bucle "Para" con "FinPara".');
    if (openMientras > 0) errors.add('Unidad 3: Falta cerrar bucle "Mientras" con "FinMientras".');
    if (openRepetir > 0) errors.add('Unidad 3: Falta cerrar bloque "Repetir" con "Hasta Que".');

    setState(() {
      _syntaxErrors = errors;
    });
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
    _validateSyntax();
    _focusNode.requestFocus();
  }

  double _evalMath(String expr, Map<String, dynamic> vars) {
    return FormulaParser.calculate(expr, vars);
  }

  bool _evalCondition(String cond, Map<String, dynamic> vars) {
    String c = cond.trim();
    for (String op in ['>=', '<=', '==', '!=', '>', '<']) {
      if (c.contains(op)) {
        final parts = c.split(op);
        final left = _evalMath(parts[0], vars);
        final right = _evalMath(parts[1], vars);
        switch (op) {
          case '>=': return left >= right;
          case '<=': return left <= right;
          case '==': return left == right;
          case '!=': return left != right;
          case '>': return left > right;
          case '<': return left < right;
        }
      }
    }
    return true;
  }

  void _runAlgorithm() {
    _validateSyntax();
    setState(() {
      _consoleLogs.clear();
      _memoryVariables.clear();
      _currentStepIndex = -1;
      _consoleLogs.add({'type': 'sys', 'text': '--- INICIO DE EJECUCION ---'});
    });

    final lines = _codeController.text.split('\n');
    final Map<String, dynamic> vars = {};

    Map<String, double> sampleInputs = {
      'celsius': 30.0,
      'totalconsumo': 120.0,
      'montopagado': 150.0,
      'horastrabajadas': 48.0,
      'pagoporhora': 25.0,
      'opcion': 1.0,
      'n1': 20.0,
      'n2': 10.0,
      'num': 7.0,
      'nota': 17.0,
      'a': 25.0,
      'b': 15.0,
    };

    bool skipBranch = false;
    List<bool> conditionStack = [];

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('//') || line.startsWith('Algoritmo') || line.startsWith('FinAlgoritmo')) {
        continue;
      }

      if (line.startsWith('Si ') && line.contains('Entonces')) {
        String condText = line.substring(3, line.indexOf('Entonces')).trim();
        bool condResult = _evalCondition(condText, vars);
        conditionStack.add(condResult);
        skipBranch = !condResult;
        continue;
      }

      if (line.startsWith('SiNo')) {
        if (conditionStack.isNotEmpty) {
          skipBranch = conditionStack.last;
        }
        continue;
      }

      if (line.startsWith('FinSi')) {
        if (conditionStack.isNotEmpty) conditionStack.removeLast();
        skipBranch = conditionStack.isNotEmpty ? !conditionStack.last : false;
        continue;
      }

      if (skipBranch) continue;

      if (line.startsWith('Escribir')) {
        var content = line.substring(8).trim();
        if (content.endsWith(';')) content = content.substring(0, content.length - 1).trim();
        if (content.startsWith('"') && content.endsWith('"')) {
          content = content.substring(1, content.length - 1);
          _consoleLogs.add({'type': 'out', 'text': content});
        } else if (vars.containsKey(content)) {
          var val = vars[content];
          String printVal = (val is double && val == val.roundToDouble()) ? '${val.toInt()}' : '$val';
          _consoleLogs.add({'type': 'out', 'text': printVal});
        } else {
          double calc = _evalMath(content, vars);
          String printVal = (calc == calc.roundToDouble()) ? '${calc.toInt()}' : '$calc';
          _consoleLogs.add({'type': 'out', 'text': printVal});
        }
      } else if (line.startsWith('Leer')) {
        var varName = line.substring(4).trim();
        if (varName.endsWith(';')) varName = varName.substring(0, varName.length - 1).trim();
        double val = sampleInputs[varName.toLowerCase()] ?? 15.0;
        vars[varName] = val;
        String printVal = (val == val.roundToDouble()) ? '${val.toInt()}' : '$val';
        _consoleLogs.add({'type': 'in', 'text': '-> [$varName] = $printVal (Dato leido)'});
      } else if (line.contains('<-')) {
        final parts = line.split('<-');
        final varName = parts[0].trim();
        final expr = parts[1].trim();
        double result = _evalMath(expr, vars);
        vars[varName] = (result == result.roundToDouble()) ? result.toInt() : double.parse(result.toStringAsFixed(2));
      }
    }

    setState(() {
      _memoryVariables = vars;
      _consoleLogs.add({'type': 'sys', 'text': '--- EJECUCION COMPLETADA CON EXITO ---'});
      _tabController.animateTo(2);
    });
  }

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
        _memoryVariables[v] = 20;
        _consoleLogs.add({'type': 'in', 'text': 'Leido [$v] <- 20'});
      } else if (line.contains('<-')) {
        final parts = line.split('<-');
        final v = parts[0].trim();
        double res = _evalMath(parts[1], _memoryVariables);
        _memoryVariables[v] = (res == res.roundToDouble()) ? res.toInt() : double.parse(res.toStringAsFixed(2));
      }
    });
  }

  String _translateCode(String lang) {
    final lines = _codeController.text.split('\n');
    final buffer = StringBuffer();

    if (lang == 'Python') {
      buffer.writeln('# Traducido a Python 3');
      for (var l in lines) {
        var line = l.trim();
        if (line.startsWith('Algoritmo')) buffer.writeln('def main():');
        else if (line.startsWith('FinAlgoritmo')) buffer.writeln('\nif __name__ == "__main__":\n    main()');
        else if (line.startsWith('Escribir')) buffer.writeln('    print(${line.substring(8).replaceAll(';', '').trim()})');
        else if (line.startsWith('Leer')) buffer.writeln('    ${line.substring(4).replaceAll(';', '').trim()} = float(input())');
        else if (line.contains('<-')) {
          var p = line.split('<-');
          buffer.writeln('    ${p[0].trim()} = ${p[1].replaceAll(";", "").trim()}');
        }
      }
    } else if (lang == 'C++') {
      buffer.writeln('#include <iostream>\nusing namespace std;\n\nint main() {');
      for (var l in lines) {
        var line = l.trim();
        if (line.startsWith('Escribir')) buffer.writeln('    cout << ${line.substring(8).replaceAll(';', '').trim()} << endl;');
        else if (line.startsWith('Leer')) buffer.writeln('    cin >> ${line.substring(4).replaceAll(';', '').trim()};');
        else if (line.contains('<-')) {
          var p = line.split('<-');
          buffer.writeln('    ${p[0].trim()} = ${p[1].replaceAll(";", "").trim()};');
        }
      }
      buffer.writeln('    return 0;\n}');
    } else if (lang == 'Java') {
      buffer.writeln('import java.util.Scanner;\n\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);');
      for (var l in lines) {
        var line = l.trim();
        if (line.startsWith('Escribir')) buffer.writeln('        System.out.println(${line.substring(8).replaceAll(';', '').trim()});');
        else if (line.startsWith('Leer')) buffer.writeln('        double ${line.substring(4).replaceAll(';', '').trim()} = sc.nextDouble();');
        else if (line.contains('<-')) {
          var p = line.split('<-');
          buffer.writeln('        ${p[0].trim()} = ${p[1].replaceAll(";", "").trim()};');
        }
      }
      buffer.writeln('    }\n}');
    }
    return buffer.toString();
  }

  Future<void> _showAiTutorDialog() async {
    final keyController = TextEditingController(text: _geminiApiKey);
    final promptController = TextEditingController();
    String aiResponse = '';
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> callGemini(String instruction, {String? customInput}) async {
              final key = keyController.text.trim();
              if (key.isEmpty) {
                setModalState(() {
                  aiResponse = '⚠️ Ingrese su API Key gratuita de Gemini para activar el tutor.';
                });
                return;
              }
              _geminiApiKey = key;

              setModalState(() {
                isLoading = true;
                aiResponse = '';
              });

              final currentCode = _codeController.text;
              final fullPrompt = """
Eres el Tutor IA de PseudoCode Studio Pro para estudiantes universitarios.
Instrucción: $instruction
${customInput != null && customInput.isNotEmpty ? "Detalle: $customInput" : ""}
Código actual:
$currentCode
""";

              try {
                final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key');
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    "contents": [
                      {
                        "parts": [
                          {"text": fullPrompt}
                        ]
                      }
                    ]
                  }),
                );

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
                  setModalState(() {
                    aiResponse = text;
                    isLoading = false;
                  });
                } else {
                  setModalState(() {
                    aiResponse = '❌ Error (${response.statusCode}): ${response.body}';
                    isLoading = false;
                  });
                }
              } catch (e) {
                setModalState(() {
                  aiResponse = '❌ Error de conexión: $e';
                  isLoading = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tutor IA - by aethell_labs',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: keyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Gemini API Key',
                        hintText: 'Pega tu clave gratuita...',
                        isDense: true,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key, size: 18, color: Colors.purpleAccent),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.psychology, size: 16, color: Colors.lightBlueAccent),
                          label: const Text('Explicar Algoritmo', style: TextStyle(fontSize: 11)),
                          onPressed: isLoading ? null : () => callGemini('Explica este algoritmo detalladamente paso a paso.'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.bug_report, size: 16, color: Colors.orangeAccent),
                          label: const Text('Buscar Errores', style: TextStyle(fontSize: 11)),
                          onPressed: isLoading ? null : () => callGemini('Identifica errores en este pseudocódigo PSeInt.'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.bolt, size: 16, color: Colors.greenAccent),
                          label: const Text('Optimizar', style: TextStyle(fontSize: 11)),
                          onPressed: isLoading ? null : () => callGemini('Optimiza este algoritmo PSeInt según buenas prácticas.'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promptController,
                            decoration: const InputDecoration(
                              hintText: 'Pregunta lo que quieras...',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  final input = promptController.text.trim();
                                  if (input.isNotEmpty) {
                                    callGemini('Consulta del usuario', customInput: input);
                                  }
                                },
                          child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: Colors.purpleAccent),
                        ),
                      ),
                    if (aiResponse.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1117),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                        ),
                        child: SelectableText(
                          aiResponse,
                          style: const TextStyle(fontSize: 12, height: 1.45, color: Color(0xFFC9D1D9)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copiar'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: aiResponse));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copiado al portapapeles.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  pw.Widget _buildPdfPseintShape(String text) {
    const double width = 260;
    const double height = 36;

    if (text.startsWith('Algoritmo') || text.startsWith('FinAlgoritmo')) {
      return pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.CustomPaint(
            size: const PdfPoint(width, height),
            painter: (canvas, size) {
              canvas.setFillColor(PdfColors.blue100);
              canvas.setStrokeColor(PdfColors.blue900);
              canvas.setLineWidth(1.3);
              canvas.drawRRect(0, 0, width, height, height / 2, height / 2);
              canvas.fillAndStrokePath();
            },
          ),
          pw.Container(
            width: width,
            height: height,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Text(text, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          ),
        ],
      );
    } else if (text.startsWith('Leer')) {
      const double slant = 18;
      return pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.CustomPaint(
            size: const PdfPoint(width, height),
            painter: (canvas, size) {
              canvas.setFillColor(PdfColors.teal50);
              canvas.setStrokeColor(PdfColors.teal800);
              canvas.setLineWidth(1.3);
              canvas.moveTo(slant, height);
              canvas.lineTo(width, height);
              canvas.lineTo(width - slant, 0);
              canvas.lineTo(0, 0);
              canvas.closePath();
              canvas.fillAndStrokePath();
            },
          ),
          pw.Container(
            width: width,
            height: height,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 25),
            child: pw.Text('[Entrada] $text', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
          ),
        ],
      );
    } else if (text.startsWith('Escribir')) {
      const double slant = 18;
      return pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.CustomPaint(
            size: const PdfPoint(width, height),
            painter: (canvas, size) {
              canvas.setFillColor(PdfColors.amber50);
              canvas.setStrokeColor(PdfColors.amber800);
              canvas.setLineWidth(1.3);
              canvas.moveTo(0, height);
              canvas.lineTo(width, height);
              canvas.lineTo(width - slant, 0);
              canvas.lineTo(slant, 0);
              canvas.closePath();
              canvas.fillAndStrokePath();
            },
          ),
          pw.Container(
            width: width,
            height: height,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 25),
            child: pw.Text('[Salida] $text', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900)),
          ),
        ],
      );
    } else if (text.startsWith('Si') || text.startsWith('Mientras') || text.startsWith('Segun') || text.startsWith('Hasta Que')) {
      const double rHeight = 44;
      return pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.CustomPaint(
            size: const PdfPoint(width, rHeight),
            painter: (canvas, size) {
              canvas.setFillColor(PdfColors.red50);
              canvas.setStrokeColor(PdfColors.red800);
              canvas.setLineWidth(1.3);
              canvas.moveTo(width / 2, rHeight);
              canvas.lineTo(width, rHeight / 2);
              canvas.lineTo(width / 2, 0);
              canvas.lineTo(0, rHeight / 2);
              canvas.closePath();
              canvas.fillAndStrokePath();
            },
          ),
          pw.Container(
            width: width,
            height: rHeight,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 35),
            child: pw.Text(text, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
          ),
        ],
      );
    } else {
      return pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.CustomPaint(
            size: const PdfPoint(width, height),
            painter: (canvas, size) {
              canvas.setFillColor(PdfColors.blueGrey50);
              canvas.setStrokeColor(PdfColors.blue700);
              canvas.setLineWidth(1.3);
              canvas.drawRect(0, 0, width, height);
              canvas.fillAndStrokePath();
            },
          ),
          pw.Container(
            width: width,
            height: height,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 15),
            child: pw.Text(text, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
          ),
        ],
      );
    }
  }

  Future<pw.Document> _buildAcademicPdf() async {
    final pdf = pw.Document();
    final code = _codeController.text;
    final steps = code.split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('//'))
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(26),
        build: (pw.Context context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue800, width: 1.5),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColors.blue50,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pw.Text('REPORTE ACADEMICO DE ALGORITMOS',
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.SizedBox(height: 3),
                      pw.Text('Alumno: $_studentName', style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                      pw.Text('Curso: $_courseName', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800)),
                      pw.Text('Detalle: $_sectionCode', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('PseudoCode Pro', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.Text('by aethell_labs', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.teal900)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text('1. Pseudocodigo Fuente:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Text(
                code,
                style: pw.TextStyle(font: pw.Font.courier(), fontSize: 9.5),
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Text('2. Diagrama de Flujo Oficial (Norma Visual PSeInt):',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final text = entry.value;
                final isLast = idx == steps.length - 1;

                return pw.Center(
                  child: pw.Column(
                    children: [
                      _buildPdfPseintShape(text),
                      if (!isLast)
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                          child: pw.Text('|\nv', style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue700)),
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
    return pdf;
  }

  void _showStudentHeaderDialog({required bool isShare}) {
    final nameCtrl = TextEditingController(text: _studentName);
    final courseCtrl = TextEditingController(text: _courseName);
    final sectionCtrl = TextEditingController(text: _sectionCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2028),
        title: const Text('Datos para el Membrete'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Alumno'),
              ),
              TextField(
                controller: courseCtrl,
                decoration: const InputDecoration(labelText: 'Curso / Taller'),
              ),
              TextField(
                controller: sectionCtrl,
                decoration: const InputDecoration(labelText: 'Sección / Grupo / Universidad'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
            onPressed: () async {
              setState(() {
                _studentName = nameCtrl.text.trim();
                _courseName = courseCtrl.text.trim();
                _sectionCode = sectionCtrl.text.trim();
              });
              Navigator.pop(context);

              final pdf = await _buildAcademicPdf();
              if (isShare) {
                final bytes = await pdf.save();
                await Printing.sharePdf(bytes: bytes, filename: 'Algoritmo_PSeInt_aethell_labs.pdf');
              } else {
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => pdf.save(),
                  name: 'Algoritmo_PSeInt_aethell_labs.pdf',
                );
              }
            },
            child: Text(isShare ? 'Compartir' : 'Generar PDF'),
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
            tooltip: 'Tutor IA (Gemini)',
            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.purpleAccent, size: 22),
            onPressed: _showAiTutorDialog,
          ),
          IconButton(
            tooltip: 'Compartir',
            icon: const Icon(Icons.share_rounded, color: Colors.greenAccent),
            onPressed: () => _showStudentHeaderDialog(isShare: true),
          ),
          IconButton(
            tooltip: 'Exportar PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.orangeAccent),
            onPressed: () => _showStudentHeaderDialog(isShare: false),
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
          tabs: [
            Tab(
              icon: Badge(
                isLabelVisible: _syntaxErrors.isNotEmpty,
                label: Text('${_syntaxErrors.length}'),
                child: const Icon(Icons.code),
              ),
              text: 'Editor',
            ),
            const Tab(icon: Icon(Icons.schema_rounded), text: 'Diagrama PSeInt'),
            const Tab(icon: Icon(Icons.dvr_rounded), text: 'Consola / Memoria'),
            const Tab(icon: Icon(Icons.transform_rounded), text: 'Traducir'),
            const Tab(icon: Icon(Icons.folder_open_rounded), text: 'Retos Sílabo'),
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
          _buildChallengesTab(),
        ],
      ),
    );
  }

  Widget _buildEditorTab() {
    final linesCount = _codeController.text.split('\n').length;
    final lineNumbersText = List.generate(linesCount, (i) => '${i + 1}').join('\n');

    return Column(
      children: [
        if (_syntaxErrors.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: Colors.amber.shade900.withOpacity(0.4),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _syntaxErrors.first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.amberAccent),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            color: const Color(0xFF14181E),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: TextField(
                      controller: _codeController,
                      focusNode: _focusNode,
                      maxLines: null,
                      expands: true,
                      onChanged: (v) => _validateSyntax(),
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

  Widget _buildKeyboardToolbar() {
    return Container(
      color: const Color(0xFF1A1F26),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _shortcutButton('Si', () => _insertText('Si  Entonces\n\t\nFinSi', offset: -16)),
                _shortcutButton('Segun', () => _insertText('Segun opcion Hacer\n\t1:\n\t\t\n\tDe Otro Modo:\n\t\t\nFinSegun', offset: -45)),
                _shortcutButton('Para', () => _insertText('Para i <- 1 Hasta  Con Paso 1 Hacer\n\t\nFinPara', offset: -26)),
                _shortcutButton('Mientras', () => _insertText('Mientras  Hacer\n\t\nFinMientras', offset: -21)),
                _shortcutButton('Repetir', () => _insertText('Repetir\n\t\nHasta Que ', offset: -11)),
                _shortcutButton('Escribir', () => _insertText('Escribir "";', offset: -2)),
                _shortcutButton('Leer', () => _insertText('Leer ;', offset: -1)),
                _shortcutButton('Definir', () => _insertText('Definir  Como Real;', offset: -12)),
              ],
            ),
          ),
          const Divider(height: 6, color: Colors.white10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _symbolButton('<-', () => _insertText(' <- ')),
                _symbolButton(';', () => _insertText(';')),
                _symbolButton('//', () => _insertText('// ')),
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

  Widget _renderPseintShape(String text) {
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

    if (text.startsWith('Si') || text.startsWith('Mientras') || text.startsWith('Segun') || text.startsWith('Hasta Que')) {
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
      child: Stack(
        children: [
          SingleChildScrollView(
            child: SelectableText(
              translatedCode,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF79C0FF), height: 1.45),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: FloatingActionButton.small(
              backgroundColor: const Color(0xFF1E88E5),
              child: const Icon(Icons.copy_rounded, size: 18, color: Colors.white),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: translatedCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado al portapapeles.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _savedAlgorithms.length,
      itemBuilder: (context, i) {
        final item = _savedAlgorithms[i];
        final unit = item['unit'] ?? 'Unidad';

        return Card(
          color: const Color(0xFF181D24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    unit,
                    style: const TextStyle(fontSize: 10, color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                    Chip(
                      label: Text(item['level']!, style: const TextStyle(fontSize: 10)),
                      backgroundColor: const Color(0xFF28303B),
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
                      _validateSyntax();
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

class FormulaParser {
  static double calculate(String expr, Map<String, dynamic> vars) {
    String clean = expr.trim();
    if (clean.endsWith(';')) clean = clean.substring(0, clean.length - 1).trim();

    final sortedKeys = vars.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    for (final key in sortedKeys) {
      clean = clean.replaceAll(RegExp('\\b' + RegExp.escape(key) + '\\b'), vars[key].toString());
    }

    try {
      return EvaluatorEngine(clean).run();
    } catch (e) {
      return double.tryParse(clean) ?? 0.0;
    }
  }
}

class EvaluatorEngine {
  final List<String> tokens = [];
  int pos = 0;

  EvaluatorEngine(String str) {
    String current = '';
    for (int i = 0; i < str.length; i++) {
      String c = str[i];
      if ('+-*/()'.contains(c)) {
        if (current.trim().isNotEmpty) tokens.add(current.trim());
        tokens.add(c);
        current = '';
      } else {
        current += c;
      }
    }
    if (current.trim().isNotEmpty) tokens.add(current.trim());
  }

  double run() => evalTerms();

  double evalPrimary() {
    if (pos >= tokens.length) return 0.0;
    String tok = tokens[pos++];
    if (tok == '(') {
      double val = evalTerms();
      if (pos < tokens.length && tokens[pos] == ')') pos++;
      return val;
    } else if (tok == '-') {
      return -evalPrimary();
    }
    return double.tryParse(tok) ?? 0.0;
  }

  double evalFactors() {
    double left = evalPrimary();
    while (pos < tokens.length && (tokens[pos] == '*' || tokens[pos] == '/')) {
      String op = tokens[pos++];
      double right = evalPrimary();
      if (op == '*') left *= right;
      else if (op == '/') left = right != 0 ? left / right : 0.0;
    }
    return left;
  }

  double evalTerms() {
    double left = evalFactors();
    while (pos < tokens.length && (tokens[pos] == '+' || tokens[pos] == '-')) {
      String op = tokens[pos++];
      double right = evalFactors();
      if (op == '+') left += right;
      else if (op == '-') left -= right;
    }
    return left;
  }
}

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
      queries:
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}

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
