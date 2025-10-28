import 'package:checkpoint_3/data/settings_repository.dart';
import 'package:checkpoint_3/main.dart';
import 'package:checkpoint_3/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  SettingsRepository? _settingsRepository;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    final repo = await SettingsRepository.create();
    setState(() => _settingsRepository = repo);
  }

  final List<Map<String, String>> _pages = const [
    {
      'title': 'Descubra Seus Encantamentos',
      'description':
          'Aprenda a criar e guardar seus feitiços digitais com estilo e segurança.',
      'image': 'assets/lottie/intro1.json',
    },
    {
      'title': 'Crie Senhas Poderosas',
      'description': 'Gere combinações únicas com o toque da magia moderna.',
      'image': 'assets/lottie/intro2.json',
    },
    {
      'title': 'Proteja Seu Grimório',
      'description':
          'Guarde suas senhas encantadas com total segurança no Firebase.',
      'image': 'assets/lottie/intro3.json',
    },
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finishIntro();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishIntro() async {
    await _settingsRepository?.setShowIntro(!_dontShowAgain);
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: AppMagicColors.text,
      fontWeight: FontWeight.w800,
      letterSpacing: .2,
    );

    final descStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: AppMagicColors.text2, height: 1.35);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // leve “aura” mística no fundo
          child: Column(
            children: [
              // conteúdo
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Column(
                        children: [
                          // Lottie – você coloca os arquivos depois
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Lottie.asset(
                                page['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            page['title']!,
                            style: titleStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              page['description']!,
                              style: descStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // indicadores (dots)
                          _Dots(length: _pages.length, index: _currentPage),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // checkbox na última página
              if (isLastPage)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: AppMagicColors.primary,
                        value: _dontShowAgain,
                        onChanged: (val) =>
                            setState(() => _dontShowAgain = val ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'Não mostrar essa introdução novamente',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppMagicColors.text2),
                        ),
                      ),
                    ],
                  ),
                ),

              // navegação
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    // Voltar (só aparece após a 1ª página)
                    if (_currentPage > 0)
                      OutlinedButton.icon(
                        onPressed: _onBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppMagicColors.primary,
                        ),
                        label: const Text(
                          'Voltar',
                          style: TextStyle(color: AppMagicColors.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppMagicColors.gold,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 96),

                    const Spacer(),

                    // Avançar / Concluir
                    ElevatedButton.icon(
                      onPressed: _onNext,
                      icon: Icon(
                        isLastPage
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(isLastPage ? 'Concluir' : 'Avançar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppMagicColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dots indicativos de página (com animação suave)
class _Dots extends StatelessWidget {
  final int length;
  final int index;
  const _Dots({required this.length, required this.index});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(length, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          width: active ? 26 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active
                ? AppMagicColors.primary
                : AppMagicColors.gold.withOpacity(.55),
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppMagicColors.primary.withOpacity(.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}
