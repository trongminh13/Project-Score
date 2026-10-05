import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_score/src/config/app_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';

import '../cubit/predictor_round_cubit.dart';
import '../cubit/predictor_round_state.dart';
import '../widgets/prediction_match_card.dart';
import '../widgets/prediction_code_ticket.dart';

class PredictorPredictView extends StatefulWidget {
  const PredictorPredictView({super.key});

  @override
  State<PredictorPredictView> createState() => _PredictorPredictViewState();
}

class _PredictorPredictViewState extends State<PredictorPredictView> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];
  final Set<String> _firstTimePicks = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToNext(int currentIndex) {
    if (currentIndex + 1 >= _itemKeys.length) return;
    
    final key = _itemKeys[currentIndex + 1];
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: 0.1, // Scroll next item to near-top
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PredictorRoundCubit, PredictorRoundState>(
      listenWhen: (previous, current) {
        if (previous is PredictorRoundLoaded && current is PredictorRoundLoaded) {
          return (!previous.round.isSubmitted && current.round.isSubmitted) || 
                 previous.submitError != current.submitError;
        }
        return false;
      },
      listener: (context, state) {
        if (state is PredictorRoundLoaded) {
          if (state.submitError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.submitError!),
                backgroundColor: context.colors.error,
                action: SnackBarAction(
                  label: 'Thử lại',
                  textColor: context.colors.onError,
                  onPressed: () => context.read<PredictorRoundCubit>().submitRound(),
                ),
              ),
            );
          } else if (state.round.isSubmitted) {
            context.push(Routes.predictorSuccess);
          }
        }
      },
      builder: (context, state) {
        if (state is PredictorRoundLoading || state is PredictorRoundInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is PredictorRoundNoActive) {
          return const Center(child: Text('Hiện không có vòng đấu nào diễn ra.'));
        }
        
        if (state is PredictorRoundError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }

        if (state is! PredictorRoundLoaded) {
          return const SizedBox();
        }

        final round = state.round;
        final matches = round.matches;
        final hasFailedSync = state.syncStatuses.values.any((s) => s == SyncStatus.failed);

        final allPicked = round.userPicks.length == matches.length;

        if (_itemKeys.length != matches.length) {
          _itemKeys.clear();
          _itemKeys.addAll(List.generate(matches.length, (i) => GlobalKey()));
        }

        return Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                if (round.prizeName != null || round.prizeDescription != null)
                  _PrizeBanner(
                    title: round.prizeName ?? 'Phần thưởng vòng đấu',
                    description: round.prizeDescription ?? '',
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          round.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          if (hasFailedSync)
                            IconButton(
                              icon: Icon(Icons.sync_problem, color: context.colors.error),
                              tooltip: 'Thử lại đồng bộ',
                              onPressed: () => context.read<PredictorRoundCubit>().retryFailedPicks(),
                            ),
                          if (round.isSubmitted)
                            Text(
                              '✅ Đã chốt thành công',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            Text(
                              '${round.userPicks.length}/${matches.length} đã chọn',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PredictionCodeTicket(
                  matches: matches,
                  userPicks: round.userPicks,
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: AppSpacing.m,
                      right: AppSpacing.m,
                      bottom: 240, // Increased to account for higher button + nav bar
                    ),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      return PredictionMatchCard(
                        key: _itemKeys[index],
                        match: match,
                        selectedPick: round.userPicks[match.id],
                        syncStatus: state.syncStatuses[match.id],
                        isLocked: round.isSubmitted || match.isLocked(DateTime.now().add(round.serverTimeOffset)),
                        onPick: (pick) {
                          context.read<PredictorRoundCubit>().selectPick(match.id, pick);
                          if (!_firstTimePicks.contains(match.id) && index < matches.length - 1) {
                            _firstTimePicks.add(match.id);
                            _scrollToNext(index);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            ), // Close Positioned.fill
            // Sticky submit button at bottom - visible only when all picked
            if (allPicked && !round.isSubmitted)
              Positioned(
                left: 0,
                right: 0,
                bottom: 100, // Move up to avoid bottom navigation bar
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.m, AppSpacing.xl, AppSpacing.xl),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PredictorRoundCubit>().submitRound();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Chốt dự đoán 🎯',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PrizeBanner extends StatelessWidget {
  final String title;
  final String description;
  const _PrizeBanner({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, 0),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
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
