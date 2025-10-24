import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';

abstract class PokemonCardRepository {
  Future<List<PokemonCard>> getCards({
    required int page,
    int pageSize = 20,
    Set<String> types = const {},
  });
  Future<PokemonCard> getCard({required String id});
  Future<List<PokemonCard>> searchCards({
    required String query,
    required int page,
    Set<String> types = const {},
  });
}
