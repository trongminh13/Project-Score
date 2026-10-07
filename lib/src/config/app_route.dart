import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/premium_upgrade_screen.dart';
import '../core/domain/entities/teams.dart';
import '../features/team/presentation/cubit/team_cubit.dart';
import '../features/team/presentation/screens/team_details_screen.dart';
import 'package:flutter/material.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/predictor/presentation/cubit/predictor_round_cubit.dart';
import '../features/predictor/presentation/screens/predictor_main_screen.dart';
import '../features/predictor/presentation/screens/fantasy_hub_screen.dart';
import '../features/predictor/presentation/screens/predictor_success_screen.dart';
import '../features/splash/presentation/screens/animated_splash_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_score/src/features/fixture/presentation/cubit/fixture/fixture_cubit.dart';
import 'package:live_score/src/features/fixture/presentation/cubit/statistics/statistics_cubit.dart';

import '../container_injector.dart';
import '../core/domain/entities/soccer_fixture.dart';
import '../core/l10n/app_l10n.dart';
import '../features/fixture/presentation/screens/fixture_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/soccer/presentation/cubit/leagues/leagues_cubit.dart';
import '../features/soccer/presentation/cubit/soccer/soccer_cubit.dart';
import '../features/soccer/presentation/screens/fixtures_screen.dart';
import '../features/soccer/presentation/screens/soccer_layout.dart';
import '../features/soccer/presentation/screens/soccer_screen.dart';
import '../features/soccer/presentation/screens/standings_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String soccer = '/soccer';
  static const String fixtures = '/fixtures';
  static const String standings = '/standings';
  static const String fixtureDetails = '/fixture_details';
  static const String settings = '/settings';
  static const String favorites = '/favorites';
  static const String predictor = '/predictor';
  static const String predictorGame = '/predictor/game';
  static const String predictorSuccess = '/predictor-success';
  static const String teamDetails = '/team_details/:id';
  static const String profile = '/profile';
  static const String premiumUpgrade = '/premium-upgrade';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: AnimatedSplashScreen());
        },
      ),
      ShellRoute(
        builder: (_, _, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => sl<LeaguesCubit>()..getLeagues(),
              ),
              BlocProvider(create: (context) => sl<SoccerCubit>()),
              BlocProvider(create: (context) => sl<FavoritesCubit>()..loadFavorites()),
              BlocProvider(create: (context) => sl<PredictorRoundCubit>()..loadCurrentRound()),
            ],
            child: SoccerLayout(child: child),
          );
        },
        routes: [
          GoRoute(
            path: Routes.soccer,
            pageBuilder: (context, _) {
              return const NoTransitionPage(child: SoccerScreen());
            },
          ),
          GoRoute(
            path: Routes.fixtures,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: FixturesScreen(competitionId: state.extra as int?),
              );
            },
          ),
          GoRoute(
            path: Routes.standings,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: StandingsScreen(competitionId: state.extra as int?),
              );
            },
          ),
          GoRoute(
            path: Routes.predictor,
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: FantasyHubScreen());
            },
          ),
          GoRoute(
            path: Routes.predictorGame,
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: PredictorMainScreen());
            },
          ),
          GoRoute(
            path: Routes.favorites,
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: FavoritesScreen());
            },
          ),
          GoRoute(
            path: Routes.teamDetails,
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id'] ?? '0');
              final team = state.extra as Team?;
              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => sl<TeamCubit>()..getTeamDetails(id),
                  child: TeamDetailsScreen(
                    team: team ?? Team(id: id, name: 'Team $id', logo: ''),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
              GoRoute(
        path: Routes.premiumUpgrade,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: PremiumUpgradeScreen());
        },
      ),
      GoRoute(
        path: Routes.profile,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: ProfileScreen());
        },
      ),
      GoRoute(
        path: Routes.fixtureDetails,
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<FixtureCubit>()),
                BlocProvider(create: (_) => sl<StatisticsCubit>()),
              ],
              child: FixtureScreen(soccerFixture: state.extra as SoccerFixture),
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.settings,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: SettingsScreen());
        },
      ),
      GoRoute(
        path: Routes.predictorSuccess,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: PredictorSuccessScreen());
        },
      ),
    ],
  );
}

class NoRouteFound extends StatelessWidget {
  const NoRouteFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(context.l10n.noRouteFound)));
  }
}
