import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokecard_dex/pokemon_cards/bloc/pokemon_card_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';

class MockPokemonCardRepository extends Mock implements PokemonCardRepository {}

void main() {
  group('PokemonCardBloc', () {
    late MockPokemonCardRepository pokemonCardRepository;

    setUp(() {
      pokemonCardRepository = MockPokemonCardRepository();
    });

    test('initial state is correct', () {
      final pokemonCardBloc = PokemonCardBloc(
        pokemonCardRepository: pokemonCardRepository,
      );
      expect(pokemonCardBloc.state, const PokemonCardState());
    });

    group('CardsFetched', () {
      blocTest<PokemonCardBloc, PokemonCardState>(
        'emits [success] when getCards is successful',
        build: () {
          when(() => pokemonCardRepository.getCards(page: 1)).thenAnswer(
            (_) async => [
              const PokemonCard(id: '1', name: 'Bulbasaur', imageUrl: ''),
            ],
          );
          return PokemonCardBloc(pokemonCardRepository: pokemonCardRepository);
        },
        act: (bloc) => bloc.add(CardsFetched()),
        expect: () => [
          const PokemonCardState(
            status: PokemonCardStatus.success,
            cards: [
              PokemonCard(id: '1', name: 'Bulbasaur', imageUrl: ''),
            ],
          ),
        ],
      );

      blocTest<PokemonCardBloc, PokemonCardState>(
        'emits [failure] when getCards throws an exception',
        build: () {
          when(() => pokemonCardRepository.getCards(page: 1))
              .thenThrow(Exception('Failed to fetch cards'));
          return PokemonCardBloc(pokemonCardRepository: pokemonCardRepository);
        },
        act: (bloc) => bloc.add(CardsFetched()),
        expect: () => [
          const PokemonCardState(status: PokemonCardStatus.failure),
        ],
      );
    });
  });
}
