import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';

class CardListItem extends StatelessWidget {
  const CardListItem({required this.card, super.key});

  final PokemonCard card;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.network(
          card.imageUrl,
          width: 50,
          fit: BoxFit.contain,
          // Añadir un loading builder para una mejor experiencia de usuario
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 50,
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          // Añadir un error builder para fallos de red
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error),
        ),
        title: Text(card.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HP: ${card.hp ?? 'N/A'}'),
            Text(card.supertype ?? ''),
          ],
        ),
        dense: true,
        onTap: () => context.go('/card/${card.id}'),
      ),
    );
  }
}
