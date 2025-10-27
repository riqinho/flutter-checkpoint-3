import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:checkpoint_3/routes.dart';

// ---------- Paleta do tema claro “gregório” ----------
class AppMagicColors {
  static const primary = Color(0xFF8B5CF6); // roxo arcano
  static const gold = Color(0xFFE3B341); // dourado leve
  static const bg = Color(0xFFFAF8F5); // pergaminho
  static const card = Color(0xFFF2EEE9); // marfim
  static const text = Color(0xFF1E1E1E); // texto principal
  static const text2 = Color(0xFF5E5E5E); // texto secundário
  static const success = Color(0xFF3BB273);
  static const error = Color(0xFFC94E4E);
}

// ------------------ MODEL ------------------
class Password {
  final String password;
  Password({required this.password});
  factory Password.fromJson(Map<String, dynamic> json) =>
      Password(password: json['password'] as String);
}

// ------------------ SERVICE ------------------
class ApiService {
  static const String _baseUrl =
      'https://safekey-api-a1bd9aa97953.herokuapp.com';

  static Future<Password> generatePassword({
    required int length,
    required bool includeLowercase,
    required bool includeUppercase,
    required bool includeNumbers,
    required bool includeSymbols,
  }) async {
    final uri = Uri.parse('$_baseUrl/generate');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'length': length,
        'includeLowercase': includeLowercase,
        'includeUppercase': includeUppercase,
        'includeNumbers': includeNumbers,
        'includeSymbols': includeSymbols,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Erro ${resp.statusCode}: ${resp.body}');
    }

    final data = json.decode(resp.body) as Map<String, dynamic>;
    return Password.fromJson(data);
  }
}

// ------------------ UI ------------------
class NewpasswordScreen extends StatefulWidget {
  const NewpasswordScreen({super.key});
  @override
  State<NewpasswordScreen> createState() => _NewpasswordScreenState();
}

class _NewpasswordScreenState extends State<NewpasswordScreen> {
  String? _password;
  double _length = 12;
  bool _lower = true;
  bool _upper = true;
  bool _numbers = true;
  bool _symbols = false;
  bool _expanded = true;
  bool _loading = false;

  bool get _hasAnyCategory => _lower || _upper || _numbers || _symbols;

  void _snack(
    String msg, {
    Color color = AppMagicColors.primary,
    IconData icon = Icons.auto_awesome,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePassword() async {
    if (!_hasAnyCategory) {
      _snack(
        'Selecione ao menos um tipo de caractere para conjurar ✨',
        color: AppMagicColors.error,
        icon: Icons.error_outline,
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.generatePassword(
        length: _length.round(),
        includeLowercase: _lower,
        includeUppercase: _upper,
        includeNumbers: _numbers,
        includeSymbols: _symbols,
      );
      setState(() => _password = res.password);
      _snack(
        'Senha conjurada com sucesso! 🔮',
        color: AppMagicColors.success,
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      _snack(
        'Falha ao conjurar senha: $e',
        color: AppMagicColors.error,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyPassword() {
    final p = _password;
    if (p == null) return;
    Clipboard.setData(ClipboardData(text: p));
    _snack('Senha copiada para a área mágica ✨');
  }

  Future<void> _savePassword() async {
    if (_password == null) {
      _snack(
        'Conjure uma senha antes de selá-la no grimório.',
        color: AppMagicColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    // Diálogo com validação de título (não fecha se vazio)
    final title = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final c = TextEditingController();
        String? errorText;
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              backgroundColor: AppMagicColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Selar feitiço',
                style: TextStyle(
                  color: AppMagicColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: c,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Título do feitiço',
                      hintText: 'Ex.: Cofre do trabalho',
                      errorText: errorText,
                      prefixIcon: const Icon(
                        Icons.menu_book_outlined,
                        color: AppMagicColors.primary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppMagicColors.gold.withOpacity(.6),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppMagicColors.gold.withOpacity(.6),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: AppMagicColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dê um nome para identificar sua senha no grimório.',
                    style: TextStyle(color: AppMagicColors.text2, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppMagicColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final t = c.text.trim();
                    if (t.isEmpty) {
                      setLocal(
                        () => errorText = 'Dê um título ao seu feitiço ✍️',
                      );
                      return; // não fecha
                    }
                    Navigator.pop(ctx, t);
                  },
                  child: const Text('Selar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (title == null) return;

    try {
      await FirebaseFirestore.instance.collection('passwords').add({
        'title': title,
        'password': _password,
      });

      _snack(
        'Feitiço selado no grimório! 🧿',
        color: AppMagicColors.success,
        icon: Icons.check_circle_outline,
      );

      // (2) Redirecionar automaticamente para Home
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } catch (e) {
      _snack(
        'Erro ao selar no grimório: $e',
        color: AppMagicColors.error,
        icon: Icons.error_outline,
      );
    }
  }

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppMagicColors.text,
    );
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppMagicColors.text2);

    return Scaffold(
      backgroundColor: AppMagicColors.bg,
      appBar: AppBar(
        backgroundColor: AppMagicColors.bg,
        elevation: 0,
        title: const Text(
          'Conjurar Feitiço',
          style: TextStyle(
            color: AppMagicColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppMagicColors.primary),
            tooltip: 'Sobre o gerador',
            onPressed: () {
              _snack(
                'Gere sua senha, ajuste os runas (opções) e sele-a no grimório.',
                icon: Icons.menu_book_outlined,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // senha gerada
            Card(
              color: AppMagicColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppMagicColors.gold.withOpacity(.5)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.auto_fix_high_outlined,
                  color: AppMagicColors.primary,
                ),
                title: Text(
                  _password ?? 'Nenhum feitiço conjurado',
                  style: titleStyle,
                ),
                subtitle: Text(
                  _password == null
                      ? 'Toque em “Conjurar Senha” para gerar seu encantamento.'
                      : 'Toque para copiar para o pergaminho do sistema.',
                  style: bodyStyle,
                ),
                onTap: _password == null ? null : _copyPassword,
                trailing: IconButton(
                  icon: const Icon(Icons.copy, color: AppMagicColors.primary),
                  tooltip: 'Copiar senha',
                  onPressed: _password == null ? null : _copyPassword,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // opções (expansível)
            Card(
              color: AppMagicColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppMagicColors.gold.withOpacity(.5)),
              ),
              child: AnimatedCrossFade(
                crossFadeState: _expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
                firstChild: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune, color: AppMagicColors.primary),
                          const SizedBox(width: 8),
                          Text('Ajustes do Encantamento', style: titleStyle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tamanho da senha: ${_length.round()}',
                        style: bodyStyle?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        value: _length,
                        min: 6,
                        max: 32,
                        divisions: 26,
                        label: _length.round().toString(),
                        activeColor: AppMagicColors.primary,
                        onChanged: (v) => setState(() => _length = v),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Incluir letras minúsculas'),
                        value: _lower,
                        activeColor: AppMagicColors.primary,
                        onChanged: (v) => setState(() => _lower = v),
                      ),
                      SwitchListTile(
                        title: const Text('Incluir letras maiúsculas'),
                        value: _upper,
                        activeColor: AppMagicColors.primary,
                        onChanged: (v) => setState(() => _upper = v),
                      ),
                      SwitchListTile(
                        title: const Text('Incluir números'),
                        value: _numbers,
                        activeColor: AppMagicColors.primary,
                        onChanged: (v) => setState(() => _numbers = v),
                      ),
                      SwitchListTile(
                        title: const Text('Incluir símbolos'),
                        value: _symbols,
                        activeColor: AppMagicColors.primary,
                        onChanged: (v) => setState(() => _symbols = v),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _toggleExpanded,
                          child: const Text('Ocultar runas'),
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: ListTile(
                  title: const Text('Mostrar runas do encantamento'),
                  trailing: const Icon(
                    Icons.expand_more,
                    color: AppMagicColors.primary,
                  ),
                  onTap: _toggleExpanded,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // botão gerar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppMagicColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loading ? null : _generatePassword,
                label: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Conjurar Senha'),
              ),
            ),
          ],
        ),
      ),

      // salvar
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppMagicColors.primary,
        foregroundColor: Colors.white,
        onPressed: _password == null ? null : _savePassword,
        child: const Icon(Icons.check),
        tooltip: "Selar no Grimório",
      ),
    );
  }
}
