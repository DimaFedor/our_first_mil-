import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../progress/services/xp_system.dart';
import '../models/xp_rewards_models.dart';
import '../providers/xp_rewards_provider.dart';

class XPRewardsScreen extends ConsumerStatefulWidget {
  const XPRewardsScreen({super.key});

  @override
  ConsumerState<XPRewardsScreen> createState() => _XPRewardsScreenState();
}

class _XPRewardsScreenState extends ConsumerState<XPRewardsScreen> {
  bool _isClaimingDaily = false;
  String? _purchasingItemId;
  String? _errorMessage;
  String? _successMessage;

  bool get _isUkr => Localizations.localeOf(context).languageCode == 'uk';

  String _tr({required String en, required String uk}) => _isUkr ? uk : en;

  void _openRewardsFeedback() {
    final subject = _tr(en: 'Idea for EXP Rewards', uk: 'Ідея для EXP бонусів');
    final message = _tr(
      en: 'Describe your idea: what should be added or changed in Rewards, and why it would help learners.',
      uk: 'Опиши свою ідею: що саме варто додати або змінити в Rewards і чому це допоможе учням.',
    );

    final uri = Uri(
      path: '/support',
      queryParameters: <String, String>{
        'category': 'feedback',
        'subject': subject,
        'message': message,
      },
    );
    context.push(uri.toString());
  }

  Future<void> _claimDaily({
    required String userId,
    required bool useLocalMode,
    required int currentStreak,
  }) async {
    if (_isClaimingDaily) return;

    setState(() {
      _isClaimingDaily = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await ref
        .read(xpRewardsServiceProvider)
        .claimDailyCheckIn(
          userId: userId,
          useLocalMode: useLocalMode,
          currentStreak: currentStreak,
        );

    if (!mounted) return;

    ref.invalidate(xpRewardsWalletProvider);
    ref.invalidate(xpRewardsTransactionsProvider);
    ref.invalidate(userDataProvider(userId));
    ref.invalidate(userXPProvider);
    ref.invalidate(levelInfoProvider);

    setState(() {
      _isClaimingDaily = false;
      if (!result.applied) {
        _errorMessage = _tr(
          en: 'Daily bonus already claimed today.',
          uk: 'Щоденний бонус на сьогодні вже отримано.',
        );
      } else if (!result.remoteSynced) {
        _successMessage = _tr(
          en: 'Bonus claimed locally: +${result.xpEarned} XP and +${result.creditsEarned} credits.',
          uk: 'Бонус зараховано локально: +${result.xpEarned} XP та +${result.creditsEarned} кредитів.',
        );
      } else {
        _successMessage = _tr(
          en: 'Daily bonus claimed: +${result.xpEarned} XP and +${result.creditsEarned} credits!',
          uk: 'Щоденний бонус отримано: +${result.xpEarned} XP та +${result.creditsEarned} кредитів!',
        );
      }
    });
  }

  Future<void> _purchaseItem({
    required String userId,
    required bool useLocalMode,
    required String itemId,
  }) async {
    if (_purchasingItemId != null) return;

    setState(() {
      _purchasingItemId = itemId;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await ref
        .read(xpRewardsServiceProvider)
        .purchaseItem(
          userId: userId,
          useLocalMode: useLocalMode,
          itemId: itemId,
        );

    if (!mounted) return;

    ref.invalidate(xpRewardsWalletProvider);
    ref.invalidate(xpRewardsTransactionsProvider);

    setState(() {
      _purchasingItemId = null;
      if (!result.success) {
        if (result.message == 'Not enough credits.') {
          _errorMessage = _tr(
            en: 'Not enough EXP credits for this purchase.',
            uk: 'Недостатньо EXP кредитів для цієї покупки.',
          );
        } else if (result.message == 'Item already owned.') {
          _errorMessage = _tr(
            en: 'You already own this item.',
            uk: 'Цей предмет уже є у твоєму інвентарі.',
          );
        } else {
          _errorMessage = _tr(
            en: 'Unable to complete purchase right now.',
            uk: 'Наразі не вдалося виконати покупку.',
          );
        }
      } else if (!result.remoteSynced) {
        _successMessage = _tr(
          en: 'Purchase saved locally.',
          uk: 'Покупку збережено локально.',
        );
      } else {
        _successMessage = _tr(
          en: 'Purchase completed successfully.',
          uk: 'Покупку успішно завершено.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserUidProvider);
    final useLocalMode = ref.watch(useLocalAuthProvider);
    final userDataAsync = userId == null
        ? const AsyncValue.data(null)
        : ref.watch(userDataProvider(userId));
    final walletAsync = ref.watch(xpRewardsWalletProvider);
    final transactionsAsync = ref.watch(xpRewardsTransactionsProvider);
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkTheme
                ? const [
                    Color(0xFF0A0E27),
                    Color(0xFF1A1F3A),
                    Color(0xFF0D1B3A),
                  ]
                : const [
                    Color(0xFFF8FAFF),
                    Color(0xFFEEF3FF),
                    Color(0xFFE6EEFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: userId == null
              ? Center(
                  child: Text(
                    _tr(
                      en: 'Sign in to use EXP rewards.',
                      uk: 'Увійди в акаунт, щоб користуватись EXP бонусами.',
                    ),
                    style: TextStyle(color: onSurface),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF0066FF),
                  onRefresh: () async {
                    ref.invalidate(xpRewardsWalletProvider);
                    ref.invalidate(xpRewardsTransactionsProvider);
                    ref.invalidate(userDataProvider(userId));
                    await Future<void>.delayed(
                      const Duration(milliseconds: 220),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(Icons.arrow_back, color: onSurface),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _tr(en: 'EXP Rewards', uk: 'EXP Бонуси'),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tr(
                          en: 'Earn EXP credits for consistency and spend them on boosters and perks.',
                          uk: 'Заробляй EXP кредити за стабільне навчання та витрачай їх на бустери й перки.',
                        ),
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.72),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRewardsFeedbackCard(onSurface: onSurface),
                      const SizedBox(height: 12),
                      walletAsync.when(
                        data: (wallet) {
                          final currentStreak =
                              (userDataAsync.valueOrNull?.currentStreak ?? 0);
                          final canClaimDaily = wallet.canClaimDaily(
                            _dayKey(DateTime.now()),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroCard(
                                wallet: wallet,
                                onSurface: onSurface,
                                isDarkTheme: isDarkTheme,
                              ),
                              const SizedBox(height: 12),
                              if (_errorMessage != null) ...[
                                _buildMessageCard(
                                  color: Colors.red,
                                  icon: Icons.error_outline,
                                  text: _errorMessage!,
                                ),
                                const SizedBox(height: 10),
                              ],
                              if (_successMessage != null) ...[
                                _buildMessageCard(
                                  color: Colors.green,
                                  icon: Icons.check_circle_outline,
                                  text: _successMessage!,
                                ),
                                const SizedBox(height: 10),
                              ],
                              _buildDailyCard(
                                onSurface: onSurface,
                                canClaimDaily: canClaimDaily,
                                isLoading: _isClaimingDaily,
                                onClaim: () => _claimDaily(
                                  userId: userId,
                                  useLocalMode: useLocalMode,
                                  currentStreak: currentStreak,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildEarningRulesCard(onSurface: onSurface),
                              const SizedBox(height: 18),
                              Text(
                                _tr(en: 'Reward Shop', uk: 'Магазин нагород'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildShopGrid(
                                wallet: wallet,
                                onSurface: onSurface,
                                onBuy: (itemId) => _purchaseItem(
                                  userId: userId,
                                  useLocalMode: useLocalMode,
                                  itemId: itemId,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _tr(
                                  en: 'Recent Activity',
                                  uk: 'Остання активність',
                                ),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              transactionsAsync.when(
                                data: (transactions) => _buildTransactionsCard(
                                  transactions: transactions,
                                  onSurface: onSurface,
                                ),
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (_, _) => _buildMessageCard(
                                  color: Colors.orange,
                                  icon: Icons.info_outline,
                                  text: _tr(
                                    en: 'Could not load transaction history.',
                                    uk: 'Не вдалося завантажити історію операцій.',
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (_, _) => _buildMessageCard(
                          color: Colors.red,
                          icon: Icons.error_outline,
                          text: _tr(
                            en: 'Failed to load rewards wallet.',
                            uk: 'Не вдалося завантажити бонусний гаманець.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({
    required RewardWallet wallet,
    required Color onSurface,
    required bool isDarkTheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(en: 'Balance', uk: 'Баланс'),
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${wallet.creditsBalance} ${_tr(en: 'credits', uk: 'кредитів')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badgeChip(
                icon: Icons.trending_up_rounded,
                text:
                    '${_tr(en: 'Earned', uk: 'Зароблено')}: ${wallet.totalCreditsEarned}',
              ),
              _badgeChip(
                icon: Icons.shopping_bag_outlined,
                text:
                    '${_tr(en: 'Spent', uk: 'Витрачено')}: ${wallet.totalCreditsSpent}',
              ),
              _badgeChip(
                icon: Icons.flash_on,
                text:
                    '${_tr(en: 'Boost', uk: 'Буст')}: ${wallet.xpBoostLessonsRemaining}',
              ),
              _badgeChip(
                icon: Icons.shield_outlined,
                text:
                    '${_tr(en: 'Shields', uk: 'Щити')}: ${wallet.streakShields}',
              ),
              _badgeChip(
                icon: Icons.lightbulb_outline,
                text:
                    '${_tr(en: 'Hints', uk: 'Підказки')}: ${wallet.hintTokens}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsFeedbackCard({required Color onSurface}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_outlined, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                _tr(en: 'Share your innovation', uk: 'Поділись інновацією'),
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _tr(
              en: 'Have an idea for better rewards or perks? Send it to us directly.',
              uk: 'Маєш ідею для кращих бонусів або перків? Надішли її нам напряму.',
            ),
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.72),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openRewardsFeedback,
              icon: const Icon(Icons.feedback_outlined),
              label: Text(_tr(en: 'Suggest an idea', uk: 'Запропонувати ідею')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard({
    required Color onSurface,
    required bool canClaimDaily,
    required bool isLoading,
    required VoidCallback onClaim,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Text(
                _tr(en: 'Daily Login Bonus', uk: 'Щоденний бонус за вхід'),
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _tr(
              en: 'Claim +15 XP and +20 credits once per day.',
              uk: 'Отримуй +15 XP та +20 кредитів раз на день.',
            ),
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.72),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canClaimDaily && !isLoading ? onClaim : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.card_giftcard),
              label: Text(
                canClaimDaily
                    ? _tr(en: 'Claim daily bonus', uk: 'Забрати щоденний бонус')
                    : _tr(
                        en: 'Already claimed today',
                        uk: 'Вже отримано сьогодні',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningRulesCard({required Color onSurface}) {
    final rules = [
      (
        icon: Icons.login_rounded,
        text: _tr(
          en: 'Daily check-in: +15 XP, +20 credits',
          uk: 'Щоденний вхід: +15 XP, +20 кредитів',
        ),
      ),
      (
        icon: Icons.task_alt_rounded,
        text: _tr(
          en: 'Lesson completion: +8 credits',
          uk: 'Завершення уроку: +8 кредитів',
        ),
      ),
      (
        icon: Icons.auto_awesome,
        text: _tr(
          en: 'Course completion: +60 XP, +50 credits',
          uk: 'Завершення курсу: +60 XP, +50 кредитів',
        ),
      ),
      (
        icon: Icons.local_fire_department,
        text: _tr(
          en: 'Streak milestones: extra XP + credits every 7/30 days',
          uk: 'Мільстоуни стріку: додатковий XP + кредити кожні 7/30 днів',
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(en: 'How to earn', uk: 'Як заробляти'),
            style: TextStyle(
              color: onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          for (final rule in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(rule.icon, size: 16, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule.text,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.76),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShopGrid({
    required RewardWallet wallet,
    required Color onSurface,
    required void Function(String itemId) onBuy,
  }) {
    final entries = [
      _ShopPresentation(
        item: RewardShopCatalog.xpBoosterPack,
        icon: Icons.flash_on,
        accent: const Color(0xFFF59E0B),
        title: _tr(en: 'XP Booster (x3)', uk: 'XP Бустер (x3)'),
        description: _tr(
          en: '+25% XP for next 3 lesson completions.',
          uk: '+25% XP для наступних 3 завершень уроків.',
        ),
      ),
      _ShopPresentation(
        item: RewardShopCatalog.streakShield,
        icon: Icons.shield_outlined,
        accent: const Color(0xFF0EA5E9),
        title: _tr(en: 'Streak Shield', uk: 'Щит стріку'),
        description: _tr(
          en: 'Protects one missed day and keeps your streak.',
          uk: 'Захищає один пропущений день і зберігає стрік.',
        ),
      ),
      _ShopPresentation(
        item: RewardShopCatalog.hintPack,
        icon: Icons.lightbulb_outline,
        accent: const Color(0xFF8B5CF6),
        title: _tr(en: 'Hint Pack', uk: 'Пак підказок'),
        description: _tr(
          en: 'Adds 5 hint tokens to your inventory.',
          uk: 'Додає 5 токенів підказок у твій інвентар.',
        ),
      ),
      _ShopPresentation(
        item: RewardShopCatalog.neonProfileFrame,
        icon: Icons.auto_awesome,
        accent: const Color(0xFF22C55E),
        title: _tr(en: 'Neon Profile Frame', uk: 'Неонова рамка профілю'),
        description: _tr(
          en: 'Unlocks a premium profile avatar frame.',
          uk: 'Відкриває преміум-рамку для аватара профілю.',
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final width =
            (constraints.maxWidth - ((columns - 1) * 12)).clamp(0, 2000) /
            columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: entries
              .map((entry) {
                final isOwned =
                    entry.item.cosmeticId != null &&
                    wallet.ownedCosmetics.contains(entry.item.cosmeticId);
                final canAfford =
                    wallet.creditsBalance >= entry.item.costCredits;
                final isBuying = _purchasingItemId == entry.item.id;

                return SizedBox(
                  width: width,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD6E2FF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: entry.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                entry.icon,
                                color: entry.accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.title,
                                style: TextStyle(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.description,
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.72),
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${entry.item.costCredits} ${_tr(en: 'credits', uk: 'кредитів')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: isBuying || isOwned || !canAfford
                                  ? null
                                  : () => onBuy(entry.item.id),
                              child: isBuying
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isOwned
                                          ? _tr(en: 'Owned', uk: 'Куплено')
                                          : _tr(en: 'Buy', uk: 'Купити'),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildTransactionsCard({
    required List<RewardTransaction> transactions,
    required Color onSurface,
  }) {
    if (transactions.isEmpty) {
      return _buildMessageCard(
        color: Colors.blueGrey,
        icon: Icons.history_toggle_off,
        text: _tr(
          en: 'No reward activity yet. Complete a lesson to start.',
          uk: 'Поки немає бонусної активності. Заверши урок, щоб почати.',
        ),
      );
    }

    final displayItems = transactions.take(8).toList(growable: false);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E2FF)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < displayItems.length; i++) ...[
            _transactionTile(displayItems[i], onSurface),
            if (i != displayItems.length - 1)
              const Divider(height: 1, indent: 12, endIndent: 12),
          ],
        ],
      ),
    );
  }

  Widget _transactionTile(RewardTransaction transaction, Color onSurface) {
    final isGain = !transaction.isSpend;
    final icon = switch (transaction.type) {
      RewardTransactionType.dailyCheckIn => Icons.calendar_today_rounded,
      RewardTransactionType.lessonCompletion => Icons.task_alt_rounded,
      RewardTransactionType.streakMilestone => Icons.local_fire_department,
      RewardTransactionType.courseCompletion => Icons.flag_rounded,
      RewardTransactionType.purchase => Icons.shopping_bag_outlined,
      RewardTransactionType.boosterXpBonus => Icons.flash_on,
    };

    final accent = isGain ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final creditsText = transaction.creditsDelta == 0
        ? ''
        : '${transaction.creditsDelta > 0 ? '+' : ''}${transaction.creditsDelta}';
    final xpText = transaction.xpDelta == 0
        ? ''
        : '${transaction.xpDelta > 0 ? '+' : ''}${transaction.xpDelta} XP';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: accent, size: 18),
      ),
      title: Text(
        transaction.title,
        style: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
        ),
      ),
      subtitle: Text(
        transaction.subtitle,
        style: TextStyle(
          color: onSurface.withValues(alpha: 0.64),
          fontSize: 12,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (creditsText.isNotEmpty)
            Text(
              creditsText,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          if (xpText.isNotEmpty)
            Text(
              xpText,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dayKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _ShopPresentation {
  final RewardShopItemDefinition item;
  final IconData icon;
  final Color accent;
  final String title;
  final String description;

  const _ShopPresentation({
    required this.item,
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });
}
