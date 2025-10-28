import 'package:checkpoint_3/main.dart';
import 'package:flutter/material.dart';

class PasswordResultCard extends StatelessWidget {
  final String? password;
  final VoidCallback onCopy;

  const PasswordResultCard({
    super.key,
    required this.password,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
          password ?? 'Nenhum feitiço conjurado',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppMagicColors.text,
          ),
        ),
        subtitle: Text(
          password == null
              ? 'Toque em “Conjurar Senha” para gerar seu encantamento.'
              : 'Toque para copiar para o pergaminho do sistema.',
          style: const TextStyle(color: AppMagicColors.text2),
        ),
        onTap: password == null ? null : onCopy,
        trailing: IconButton(
          icon: const Icon(Icons.copy, color: AppMagicColors.primary),
          tooltip: 'Copiar senha',
          onPressed: password == null ? null : onCopy,
        ),
      ),
    );
  }
}
