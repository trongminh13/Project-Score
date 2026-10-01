import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<FavoritesCubit>(); // Trigger lookup to catch errors early
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yêu thích')),
        body: const Center(
          child: Text('Chưa thể kết nối được danh sách yêu thích. Vui lòng thử lại sau!'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu thích')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoaded) {
            if (state.favoriteMatchIds.isEmpty) {
              return const Center(child: Text('No favorites yet.'));
            }
            return ListView.builder(
              itemCount: state.favoriteMatchIds.length,
              itemBuilder: (context, index) {
                final id = state.favoriteMatchIds[index];
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text('Match ID: $id'),
                  subtitle: const Text('API lookup needed for details'),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
