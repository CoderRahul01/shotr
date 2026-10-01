import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/viewfinder_frame.dart';
import '../../services/purchases_service.dart';

/// Paywall: shotr Pro, $19/month, cancel anytime (SPEC decisions log).
/// Triggers: free makes run out, a locked action, or Settings.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.reason});

  final String? reason;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Package? _package;
  bool _loading = true;
  bool _buying = false;
  bool _pending = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _package = await ref.read(purchasesProvider).monthly();
    } catch (_) {
      _message = "Couldn't load the price. Check your connection.";
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _buy() async {
    final pkg = _package;
    if (pkg == null) return;
    setState(() {
      _buying = true;
      _message = null;
    });
    final r = await ref.read(purchasesProvider).buy(pkg);
    if (!mounted) return;
    setState(() => _buying = false);
    switch (r) {
      case PurchaseState.purchased:
        await ref.read(accountProvider.notifier).refresh();
        if (mounted) _close();
      case PurchaseState.pending:
        setState(() => _pending = true);
        ref.read(purchasesProvider).onChange((isPro) async {
          if (isPro) {
            await ref.read(accountProvider.notifier).refresh();
            if (mounted) _close();
          }
        });
      case PurchaseState.cancelled:
        break;
      case PurchaseState.failed:
        setState(() => _message = "The purchase didn't go through. You weren't charged.");
    }
  }

  Future<void> _restore() async {
    setState(() => _message = null);
    final ok = await ref.read(purchasesProvider).restore();
    if (!mounted) return;
    if (ok) {
      await ref.read(accountProvider.notifier).refresh();
      if (mounted) _close();
    } else {
      setState(() => _message = 'No active Pro subscription found on this account.');
    }
  }

  void _close() => context.canPop() ? context.pop() : context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    if (_pending) return _PendingView(onClose: _close);
    final price = _package?.storeProduct.priceString ?? r'$19';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Close', icon: const Icon(Icons.close_rounded), onPressed: _close),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    if (widget.reason == 'free_used') const MonoLabel("You've used your 5 free makes"),
                    if (widget.reason == 'fair_use') const MonoLabel("You've reached this month's makes"),
                    const SizedBox(height: 14),
                    const RiseIn(child: Text('shotr Pro', style: ShotrText.display)),
                    const SizedBox(height: 18),
                    RiseIn(
                      index: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(price, style: ShotrText.display.copyWith(fontSize: 56, letterSpacing: -2.2)),
                          const SizedBox(width: 8),
                          const Text('/ month · cancel anytime', style: ShotrText.quiet),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    for (final (i, f) in const [
                      'All shot types: posts, emails, build notes, takeaways',
                      'Drafts in your voice',
                      'Reads image-only screenshots too',
                      'Weekly witness',
                      'Monthly fair-use makes',
                      'Every new feature',
                    ].indexed)
                      RiseIn(
                        index: 2 + i,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: ShotrColors.raised)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_rounded, size: 18, color: ShotrColors.text),
                              const SizedBox(width: 12),
                              Expanded(child: Text(f, style: ShotrText.body)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    const Text('Saving, reading, sorting and search stay free and unlimited.', style: ShotrText.small),
                  ],
                ),
              ),
              if (_message != null) ...[
                Text(
                  _message!,
                  style: ShotrText.small.copyWith(color: ShotrColors.text),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
              PrimaryButton(label: _loading ? 'Loading…' : 'Start Pro · $price/month', busy: _buying, onPressed: _loading || _package == null ? null : _buy),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _restore,
                child: Text('Restore purchase', style: ShotrText.small.copyWith(color: ShotrColors.textSoft, fontSize: 13)),
              ),
              const Text('Renews monthly until you cancel in your store account.', style: ShotrText.small, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// SPEC edge case: purchase pending (UPI, slow cards).
class _PendingView extends StatelessWidget {
  const _PendingView({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Close', icon: const Icon(Icons.close_rounded), onPressed: onClose),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ViewfinderFrame(
                focused: true,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Center(
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ShotrColors.text)),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Payment pending', style: ShotrText.h1),
              const SizedBox(height: 14),
              Text(
                'UPI and some cards take a moment. Pro unlocks as soon as it confirms. You can keep saving shots meanwhile.',
                style: ShotrText.body.copyWith(color: ShotrColors.textMuted),
              ),
              const SizedBox(height: 16),
              const ShotBadge('Pending'),
              const Spacer(),
              GhostButton(label: 'Back to shotr', onPressed: onClose),
            ],
          ),
        ),
      ),
    );
  }
}
