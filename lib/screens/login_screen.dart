import 'package:checkpoint_3/main.dart';
import 'package:checkpoint_3/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // chave do formulário
  final _formKey = GlobalKey<FormState>();

  // controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // visibilidade da senha
  bool _isObscure = true;

  // loading
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---- helpers de UI ----
  void _showSnack(String text, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color ?? AppMagicColors.primary,
        content: Row(
          children: [
            Icon(icon ?? Icons.auto_awesome, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  String _friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'E-mail inválido no grimório 🪶';
        case 'user-not-found':
          return 'Nenhum mago encontrado com esse e-mail 🪄';
        case 'wrong-password':
          return 'Palavra-chave do feitiço incorreta 🔒';
        case 'email-already-in-use':
          return 'Este e-mail já está selado em outro grimório ✉️';
        case 'weak-password':
          return 'Senha fraca — conjure um feitiço mais poderoso 💥';
        default:
          return 'O feitiço falhou por aqui… (${e.code})';
      }
    }
    return 'Algo quebrou o círculo mágico. Tente novamente ✨';
  }

  // ---- ações ----
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        _showSnack(
          'Portais abertos. Bem-vindo ao grimório! ✨',
          color: AppMagicColors.success,
          icon: Icons.check_circle_outline,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        _showSnack(
          _friendlyError(e),
          color: AppMagicColors.error,
          icon: Icons.error_outline,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        _showSnack(
          'Grimório criado com sucesso! 🧿',
          color: AppMagicColors.success,
          icon: Icons.auto_awesome,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        _showSnack(
          _friendlyError(e),
          color: AppMagicColors.error,
          icon: Icons.error_outline,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ---- build ----
  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: AppMagicColors.text,
      letterSpacing: 0.2,
    );
    final body = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppMagicColors.text2);

    return Scaffold(
      backgroundColor: AppMagicColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppMagicColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppMagicColors.gold.withOpacity(.45)),
                boxShadow: [
                  BoxShadow(
                    color: AppMagicColors.primary.withOpacity(.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // “selo mágico” simples (halo + ícone)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppMagicColors.primary.withOpacity(.35),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x33E3B341), // dourado translúcido
                              Color(0x338B5CF6), // roxo translúcido
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.auto_fix_high_outlined,
                          size: 64,
                          color: AppMagicColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Bem-vindo ao Grimório', style: headline),
                      const SizedBox(height: 6),
                      Text(
                        'Conecte-se para conjurar e guardar seus feitiços digitais.',
                        textAlign: TextAlign.center,
                        style: body,
                      ),
                      const SizedBox(height: 24),

                      // E-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppMagicColors.text),
                        decoration: _inputDecoration(
                          label: 'E-mail do mago',
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Insira um e-mail do seu grimório 🪶'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Senha
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        style: const TextStyle(color: AppMagicColors.text),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Digite a palavra-chave do feitiço 🔐'
                            : null,
                        decoration: _inputDecoration(
                          label: 'Palavra-chave',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _isObscure = !_isObscure),
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppMagicColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(
                                color: AppMagicColors.primary,
                              ),
                            )
                          : Column(
                              children: [
                                // Entrar
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppMagicColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: _signIn,
                                    child: const Text(
                                      'Entrar no Grimório',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Registrar
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppMagicColors.primary,
                                      side: const BorderSide(
                                        color: AppMagicColors.gold,
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    onPressed: _signUp,
                                    child: const Text('Criar meu Grimório'),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppMagicColors.text2),
      prefixIcon: Icon(icon, color: AppMagicColors.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppMagicColors.gold.withOpacity(.55)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppMagicColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppMagicColors.error, width: 1.8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppMagicColors.error, width: 2),
      ),
    );
  }
}
