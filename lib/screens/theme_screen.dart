import 'package:flutter/material.dart';
import '../theme_notifier.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('테마'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  '테마를 선택하면 즉시 적용됩니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ThemeOption(
                      icon: Icons.brightness_auto_outlined,
                      label: '시스템 설정',
                      subtitle: '기기 설정에 따라 자동으로 변경',
                      mode: ThemeMode.system,
                      currentMode: currentMode,
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      icon: Icons.light_mode_outlined,
                      label: '라이트 모드',
                      subtitle: '항상 밝은 테마 사용',
                      mode: ThemeMode.light,
                      currentMode: currentMode,
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      icon: Icons.dark_mode_outlined,
                      label: '다크 모드',
                      subtitle: '항상 어두운 테마 사용',
                      mode: ThemeMode.dark,
                      currentMode: currentMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _ThemePreview(currentMode: currentMode),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final ThemeMode mode;
  final ThemeMode currentMode;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.mode,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : Icon(Icons.radio_button_unchecked, color: theme.colorScheme.outline),
      onTap: () => themeNotifier.value = mode,
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final ThemeMode currentMode;

  const _ThemePreview({required this.currentMode});

  String get _modeLabel {
    switch (currentMode) {
      case ThemeMode.system:
        return '시스템 설정';
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '현재 적용 중',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  currentMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : currentMode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  _modeLabel,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
