import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../soccer/presentation/widgets/fixture_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<FavoritesCubit>(); // Trigger lookup to catch errors early
    } catch (e) {
      return const Center(
        child: Text('Chưa thể kết nối được danh sách yêu thích. Vui lòng thử lại sau!'),
      );
    }
    
    return BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FavoritesLoaded) {
            if (state.favoriteMatches.isEmpty) {
              return const Center(child: Text('Bạn chưa yêu thích trận đấu nào.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: state.favoriteMatches.length,
              itemBuilder: (context, index) {
                final match = state.favoriteMatches[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to details if needed
                  },
                  child: FixtureCard(
                    soccerFixture: match,
                    showLeagueLogo: true,
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
  }
}
