import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokecard_dex/pokemon_cards/features/card_detail/view/card_detail_page.dart';
import 'package:pokecard_dex/pokemon_cards/view/cards_page.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const CardsPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'card/:id',
          builder: (BuildContext context, GoRouterState state) {
            final cardId = state.pathParameters['id']!;
            return CardDetailPage(cardId: cardId);
          },
        ),
      ],
    ),
  ],
);
