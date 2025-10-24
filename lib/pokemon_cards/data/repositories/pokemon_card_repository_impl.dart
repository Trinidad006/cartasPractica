import 'package:dio/dio.dart';
import 'package:pokecard_dex/pokemon_cards/data/models/pokemon_card_model.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';

class PokemonCardRepositoryImpl implements PokemonCardRepository {
  PokemonCardRepositoryImpl({Dio? dio}) : _dio = dio?? Dio();

  final Dio _dio;
  final String _baseUrl = 'https://api.pokemontcg.io/v2';

  @override
  Future<List<PokemonCard>> getCards({
    required int page,
    int pageSize = 20,
    Set<String> types = const {},
  }) async {
    try {
      final queryParameters = {
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'name',
      };
      if (types.isNotEmpty) {
        queryParameters['q'] = 'types:(${types.join(' OR ')})';
      }

      final response = await _dio.get(
        '$_baseUrl/cards',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['data'] as List;
        final cards = results
            .map((cardData) =>
                PokemonCardModel.fromJson(cardData as Map<String, dynamic>)
                    .toEntity())
            .toList();
        return cards;
      } else {
        throw Exception('Failed to load Pokémon cards');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load Pokémon cards: ${e.message}');
    }
  }

  @override
  Future<PokemonCard> getCard({required String id}) async {
    try {
      final response = await _dio.get('$_baseUrl/cards/$id');

      if (response.statusCode == 200 && response.data != null) {
        final result = response.data['data'] as Map<String, dynamic>;
        final card = PokemonCardModel.fromJson(result).toEntity();
        return card;
      } else {
        throw Exception('Failed to load Pokémon card');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load Pokémon card: ${e.message}');
    }
  }

  @override
  Future<List<PokemonCard>> searchCards({
    required String query,
    required int page,
    Set<String> types = const {},
  }) async {
    try {
      final queryParameters = {
        'q': 'name:$query*',
        'page': page,
        'pageSize': 20,
        'orderBy': 'name',
      };
      if (types.isNotEmpty) {
        queryParameters['q'] = '${queryParameters['q']} types:(${types.join(' OR ')})';
      }

      final response = await _dio.get(
        '$_baseUrl/cards',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['data'] as List;
        final cards = results
            .map((cardData) =>
                PokemonCardModel.fromJson(cardData as Map<String, dynamic>)
                    .toEntity())
            .toList();
        return cards;
      } else {
        throw Exception('Failed to load Pokémon cards');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load Pokémon cards: ${e.message}');
    }
  }
}
