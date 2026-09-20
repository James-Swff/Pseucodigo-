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
      if (line.isEmpty || line.startsWith('//')) continue;
      if (line.startsWith('Algoritmo') || line.startsWith('FinAlgoritmo')) continue;

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
        _consoleLogs.add({'type': 'in', 'text': '-> [$varName] =$printVal (Dato leido)'});
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
          buffer.writeln('    ${p[0].trim()} =${p[1].replaceAll(";", "").trim()}');
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
          buffer.writeln('    ${p[0].trim()} =${p[1].replaceAll(";", "").trim()};');
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
          buffer.writeln('        ${p[0].trim()} =${p[1].replaceAll(";", "").trim()};');
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
                  aiResponse = '⚠️ Ingrese su API Key gratuita de Gemini (Google AI Studio) para activar el tutor.';
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
Eres el Tutor IA oficial de PseudoCode Studio Pro (desarrollado por aethell_labs) para estudiantes de ingeniería.
Tu rol es explicar conceptos de PSeInt, corregir algoritmos o crearlos siguiendo el estándar universitario estricto de PSeInt.

INSTRUCCION DEL USUARIO: $instruction
${customInput != null && customInput.isNotEmpty ? "DETALLE ADICIONAL: $customInput" : ""}
CODIGO FUENTE ACTUAL EN EL EDITOR:
```text
$currentCode
