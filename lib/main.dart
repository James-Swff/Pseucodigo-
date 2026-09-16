import 'package:flutter/material.dart';

void main() {
  runApp(const PseudoCodeApp());
}

class PseudoCodeApp extends StatelessWidget {
  const PseudoCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PseudoCode Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121418),
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
  final List<Map<String, String>> _consoleLogs = [];

  final String _initialCode = '''Algoritmo CalcularPromedio
  Definir n1, n2, prom Como Real;
  Escribir "Ingrese nota 1:";
  Leer n1;
  Escribir "Ingrese nota 2:";
  Leer n2;
  prom <- (n1 + n2) / 2;
  Si prom >= 11 Entonces
    Escribir "Aprobado con:";
    Escribir prom;
  SiNo
    Escribir "Desaprobado con:";
    Escribir prom;
  FinSi
FinAlgoritmo''';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _codeController.text = _initialCode;
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

  void _runAlgorithm() {
    setState(() {
      _consoleLogs.clear();
      _consoleLogs.add({'type': 'sys', 'text': '--- INICIO DE EJECUCION ---'});
    });

    final lines = _codeController.text.split('\n');
    final Map<String, dynamic> variables = {};

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
        } else if (variables.containsKey(content)) {
          _consoleLogs.add({'type': 'out', 'text': '${variables[content]}'});
        } else {
          _consoleLogs.add({'type': 'out', 'text': content});
        }
      } else if (line.startsWith('Leer')) {
        var varName = line.substring(4).trim();
        if (varName.endsWith(';')) varName = varName.substring(0, varName.length - 1).trim();
        variables[varName] = 16;
        _consoleLogs.add({'type': 'in', 'text': '-> [$varName] = 16 (Entrada simulada)'});
      } else if (line.contains('<-')) {
        final parts = line.split('<-');
        final varName = parts[0].trim();
        variables[varName] = 'Calculado';
      }
    }

    setState(() {
      _consoleLogs.add({'type': 'sys', 'text': '--- EJECUCION FINALIZADA CON EXITO ---'});
      _tabController.animateTo(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.terminal, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('PseudoCode Studio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ejecutar',
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.greenAccent, size: 28),
            onPressed: _runAlgorithm,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(icon: Icon(Icons.code), text: 'Editor'),
            Tab(icon: Icon(Icons.schema_rounded), text: 'Diagrama'),
            Tab(icon: Icon(Icons.dvr_rounded), text: 'Consola'),
            Tab(icon: Icon(Icons.school_rounded), text: 'Retos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEditorTab(),
          _buildDiagramTab(),
          _buildConsoleTab(),
          _buildChallengesTab(),
        ],
      ),
    );
  }

  Widget _buildEditorTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF161A22),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _codeController,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Color(0xFFE6EDF3),
                height: 1.4,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Escribe tu pseudocodigo aqui...',
              ),
            ),
          ),
        ),
        _buildKeyboardToolbar(),
      ],
    );
  }

  Widget _buildKeyboardToolbar() {
    return Container(
      color: const Color(0xFF21262D),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
          const Divider(height: 6, color: Colors.white12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF30363D),
          foregroundColor: Colors.lightBlueAccent,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          minimumSize: const Size(40, 32),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minimumSize: const Size(36, 32),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDiagramTab() {
    final lines = _codeController.text.split('\n');
    final steps = lines
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('//'))
        .toList();

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final text = entry.value;
              final isLast = idx == steps.length - 1;

              return Column(
                children: [
                  _flowchartNode(text),
                  if (!isLast)
                    const Column(
                      children: [
                        SizedBox(height: 4),
                        Icon(Icons.arrow_downward_rounded, size: 20, color: Colors.blueAccent),
                        SizedBox(height: 4),
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

  Widget _flowchartNode(String text) {
    Color bg = const Color(0xFF21262D);
    Color border = Colors.blueAccent;
    BorderRadius? radius = BorderRadius.circular(8);

    if (text.startsWith('Algoritmo') || text.startsWith('FinAlgoritmo')) {
      bg = const Color(0xFF1E3A5F);
      border = Colors.blueAccent;
      radius = BorderRadius.circular(24);
    } else if (text.startsWith('Leer') || text.startsWith('Escribir')) {
      bg = const Color(0xFF332B00);
      border = Colors.amberAccent;
    } else if (text.startsWith('Si') || text.startsWith('Mientras')) {
      bg = const Color(0xFF3D1E28);
      border = Colors.redAccent;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: border, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildConsoleTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF1F242C),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, size: 12, color: Colors.greenAccent),
                  SizedBox(width: 8),
                  Text('Terminal Movil', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
                onPressed: () => setState(() => _consoleLogs.clear()),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSys
                        ? Colors.transparent
                        : isInput
                            ? const Color(0xFF1565C0)
                            : const Color(0xFF282E38),
                    borderRadius: BorderRadius.circular(8),
                    border: isSys ? Border.all(color: Colors.white12) : null,
                  ),
                  child: Text(
                    log['text']!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isSys ? Colors.white54 : Colors.white,
                      fontSize: 13,
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

  Widget _buildChallengesTab() {
    final challenges = [
      {
        'title': '1. Suma de Dos Numeros',
        'level': 'Facil',
        'desc': 'Pide al usuario ingresar 2 numeros y muestra la suma.',
        'code': '''Algoritmo SumaSimple
  Definir a, b, res Como Entero;
  Escribir "Ingrese primer numero:";
  Leer a;
  Escribir "Ingrese segundo numero:";
  Leer b;
  res <- a + b;
  Escribir "La suma es:";
  Escribir res;
FinAlgoritmo'''
      },
      {
        'title': '2. Mayor de Tres Numeros',
        'level': 'Intermedio',
        'desc': 'Determina el mayor de tres numeros usando Si-Entonces.',
        'code': '''Algoritmo MayorDeTres
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
FinAlgoritmo'''
      },
      {
        'title': '3. Tabla de Multiplicar',
        'level': 'Intermedio',
        'desc': 'Genera la tabla de un numero del 1 al 12.',
        'code': '''Algoritmo TablaMultiplicar
  Definir num, i, prod Como Entero;
  Escribir "Ingrese tabla deseada:";
  Leer num;
  Para i <- 1 Hasta 12 Con Paso 1 Hacer
    prod <- num * i;
    Escribir num, " x ", i, " = ", prod;
  FinPara
FinAlgoritmo'''
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: challenges.length,
      itemBuilder: (context, i) {
        final item = challenges[i];
        final isEasy = item['level'] == 'Facil';
        return Card(
          color: const Color(0xFF1B2028),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Chip(
                      label: Text(item['level']!, style: const TextStyle(fontSize: 11)),
                      backgroundColor: isEasy ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(item['desc']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Cargar al Editor'),
                    onPressed: () {
                      setState(() {
                        _codeController.text = item['code']!;
                        _tabController.animateTo(0);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reto cargado al editor')),
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
