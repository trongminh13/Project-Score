import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';

import '../../domain/entities/predictor_pick.dart';
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
  final Set<String> _firstTimePicks = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToNext(int currentIndex) {
    if (!_scrollController.hasClients) return;
    const double estimatedCardHeight = 220.0; 
    _scrollController.animateTo(
      (currentIndex + 1) * estimatedCardHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PredictorRoundCubit, PredictorRoundState>(
      listener: (context, state) {
        if (state is PredictorRoundLoaded && state.submitError != null) {
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    round.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      if (hasFailedSync)
                        IconButton(
                          icon: Icon(Icons.sync_problem, color: context.colors.error),
                          tooltip: 'Thử lại đồng bộ',
                          onPressed: () => context.read<PredictorRoundCubit>().retryFailedPicks(),
                        ),
                      Text(
                        '${round.userPicks.length}/${matches.length} đã chọn',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.colorsExt.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                itemCount: matches.length + 1, 
                itemBuilder: (context, index) {
                  if (index == matches.length) {
                    return _buildSubmitButton(context, state);
                  }

                  final match = matches[index];
                  return PredictionMatchCard(
                    match: match,
                    selectedPick: round.userPicks[match.id],
                    syncStatus: state.syncStatuses[match.id],
                    isLocked: match.isLocked(DateTime.now().add(round.serverTimeOffset)),
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
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, PredictorRoundLoaded state) {
    final allPicked = state.round.userPicks.length == state.round.matches.length;
    final isSubmitted = state.round.isSubmitted;
    
    return Column(
      children: [
        PredictionCodeTicket(
          matches: state.round.matches,
          userPicks: state.round.userPicks,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl, top: AppSpacing.m),
          child: ElevatedButton(
            onPressed: (allPicked && !isSubmitted) 
            ? () {
                context.read<PredictorRoundCubit>().submitRound();
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
          backgroundColor: isSubmitted ? context.colors.primary.withValues(alpha: 0.5) : context.colors.primary,
          foregroundColor: context.colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          isSubmitted 
              ? 'Đã chốt (${state.round.userPicks.length}/${state.round.matches.length})' 
              : (allPicked ? 'Chốt dự đoán' : 'Vui lòng dự đoán đủ các trận'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      ],
    );
  }
}
