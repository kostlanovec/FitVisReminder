import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  String _enteredPin = '';
  String? _error;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(appLockSettingsProvider);
      if (!settings.enabled || !settings.hasPin) {
        ref.read(appLockSessionProvider.notifier).unlock();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = ref.read(appLockSessionProvider.notifier);
    final settings = ref.read(appLockSettingsProvider);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      session.markBackgrounded();
    }
    if (state == AppLifecycleState.resumed) {
      session.markResumed(settings.timeoutMinutes);
    }
  }

  void _onKeyPress(String key) {
    if (_enteredPin.length >= 6) return;
    setState(() {
      _enteredPin += key;
      _error = null;
    });
    if (_enteredPin.length >= 4) {
      final settings = ref.read(appLockSettingsProvider);
      // If we have 4 digits and settings says 4, or we wait for 6... 
      // Actually, let's just use the verify logic.
      if (ref.read(appLockSettingsProvider.notifier).verifyPin(_enteredPin)) {
        _unlock();
      } else if (_enteredPin.length == 6 || (settings.hasPin && _enteredPin.length >= 4)) {
         // Auto-check for 4-digit pins too if they match
         // But the verifyPin handles it. If it's wrong at 4 and could be 6, we wait.
         if (_enteredPin.length >= 6) _handleWrongPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
  }

  void _handleWrongPin() {
    setState(() {
      _error = AppLocalizations.of(context)!.appLockInvalidPin;
      _isShaking = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() {
        _enteredPin = '';
        _isShaking = false;
      });
    });
  }

  void _unlock() {
    ref.read(appLockSessionProvider.notifier).unlock();
    setState(() => _enteredPin = '');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appLockSettingsProvider);
    final unlocked = ref.watch(appLockSessionProvider);
    final isProtected = settings.enabled && settings.hasPin;
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isProtected || unlocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            
            // Icon & Title
            Icon(
              Icons.lock_person_rounded,
              size: 64,
              color: isDark ? AppColors.primary : AppColors.primary,
            ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
            const SizedBox(height: 24),
            Text(
              l.appLockTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'Outfit',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.appLockSubtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 40),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _enteredPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled 
                      ? AppColors.primary 
                      : (isDark ? Colors.white10 : const Color(0x0D000000)),
                    border: Border.all(
                      color: filled ? AppColors.primary : (isDark ? Colors.white24 : Colors.black12),
                      width: 1.5,
                    ),
                    boxShadow: filled ? [
                      BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
                    ] : null,
                  ),
                );
              }),
            ).animate(target: _isShaking ? 1 : 0).shake(hz: 8, curve: Curves.easeInOut),
            
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ).animate().fadeIn(),

            const Spacer(flex: 1),
            
            // Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 1; i <= 9; i++) _KeyButton(label: '$i', onTap: () => _onKeyPress('$i')),
                  const SizedBox.shrink(),
                  _KeyButton(label: '0', onTap: () => _onKeyPress('0')),
                  IconButton(
                    onPressed: _onBackspace,
                    icon: const Icon(Icons.backspace_outlined),
                    iconSize: 24,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 2),
            
            TextButton(
              onPressed: () {
                // Potential emergency exit or hint
              },
              child: Text(
                l.appLockForgotPin,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
          ),
        ),
      ),
    );
  }
}

