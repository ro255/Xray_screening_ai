import 'package:diesease_ai_app/core/app_language.dart';
import 'package:diesease_ai_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _kPrimary = AppColors.primary;
const _kInk = AppColors.ink;
const _kMuted = AppColors.muted;
const _kBorder = AppColors.border;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final language = context.watch<AppLanguageController>().value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.settings
          ),
          centerTitle: true,
          ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                strings.languageLabel,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kInk,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                strings.chooseLanguage,
                style: const TextStyle(color: _kMuted, fontSize: 14),
              ),
              const SizedBox(height: 20),
              _LanguageCard(
                flag: '🇬🇧',
                name: 'English',
                native: 'English',
                selected: language == AppLanguage.english,
                onTap: () => context
                    .read<AppLanguageController>()
                    .setLanguage(AppLanguage.english),
              ),
              const SizedBox(height: 12),
              _LanguageCard(
                flag: '🇹🇿',
                name: 'Swahili',
                native: 'Kiswahili',
                selected: language == AppLanguage.swahili,
                onTap: () => context
                    .read<AppLanguageController>()
                    .setLanguage(AppLanguage.swahili),
              ),
              const SizedBox(height: 24),
              _AboutCard(strings: strings),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String name;
  final String native;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.name,
    required this.native,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.soft : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kPrimary : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: selected
                    ? _kPrimary.withValues(alpha: 0.1)
                    : AppColors.canvas,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: _kInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    native,
                    style: const TextStyle(
                      color: _kMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? Container(
                      key: const ValueKey('check'),
                      height: 28,
                      width: 28,
                      decoration: const BoxDecoration(
                        color: _kPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    )
                  : Container(
                      key: const ValueKey('empty'),
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _kBorder, width: 1.4),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final AppStrings strings;
  const _AboutCard({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.shield_rounded, color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strings.screeningDisclaimer,
              style: const TextStyle(
                color: Color(0xFF4D625B),
                height: 1.5,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
