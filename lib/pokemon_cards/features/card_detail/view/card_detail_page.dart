import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/data/repositories/pokemon_card_repository_impl.dart';
import 'package:pokecard_dex/pokemon_cards/features/card_detail/cubit/card_detail_cubit.dart';

class CardDetailPage extends StatelessWidget {
  const CardDetailPage({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CardDetailCubit(
        pokemonCardRepository: PokemonCardRepositoryImpl(),
        cardId: cardId,
      ),
      child: const CardDetailView(),
    );
  }
}

class CardDetailView extends StatelessWidget {
  const CardDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Detail')),
      body: BlocBuilder<CardDetailCubit, CardDetailState>(
        builder: (context, state) {
          switch (state.status) {
            case CardDetailStatus.initial:
            case CardDetailStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case CardDetailStatus.failure:
              return const Center(child: Text('Failed to load card details'));
            case CardDetailStatus.success:
              final card = state.card!;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(card.imageUrl),
                    const SizedBox(height: 16),
                    Text(card.name, style: Theme.of(context).textTheme.headlineSmall),
                    Text('HP: ${card.hp ?? 'N/A'}'),
                    Text('Supertype: ${card.supertype ?? 'N/A'}'),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
