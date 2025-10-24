import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';

part 'card_detail_state.dart';

class CardDetailCubit extends Cubit<CardDetailState> {
  CardDetailCubit({
    required this.pokemonCardRepository,
    required this.cardId,
  }) : super(const CardDetailState()) {
    fetchCard();
  }

  final PokemonCardRepository pokemonCardRepository;
  final String cardId;

  Future<void> fetchCard() async {
    emit(state.copyWith(status: CardDetailStatus.loading));
    try {
      final card = await pokemonCardRepository.getCard(id: cardId);
      emit(state.copyWith(status: CardDetailStatus.success, card: card));
    } catch (_) {
      emit(state.copyWith(status: CardDetailStatus.failure));
    }
  }
}
