import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:pokecard_dex/pokemon_cards/domain/entities/pokemon_card.dart';
import 'package:pokecard_dex/pokemon_cards/domain/repositories/pokemon_card_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'pokemon_card_event.dart';
part 'pokemon_card_state.dart';

const _throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PokemonCardBloc extends Bloc<PokemonCardEvent, PokemonCardState> {
  PokemonCardBloc({required PokemonCardRepository pokemonCardRepository})
      : _pokemonCardRepository = pokemonCardRepository,
        super(const PokemonCardState()) {
    on<CardsFetched>(
      _onCardsFetched,
      transformer: throttleDroppable(_throttleDuration),
    );
    on<CardsRefreshed>(_onCardsRefreshed);
    on<CardsSearched>(_onCardsSearched);
    on<FilterChanged>(_onFilterChanged);
  }

  final PokemonCardRepository _pokemonCardRepository;
  int _currentPage = 1;

  Future<void> _onFilterChanged(
    FilterChanged event,
    Emitter<PokemonCardState> emit,
  ) async {
    emit(state.copyWith(activeFilters: event.newFilters));
    _currentPage = 1;
    try {
      final cards = await _pokemonCardRepository.getCards(
        page: _currentPage,
        types: event.newFilters,
      );
      _currentPage++;
      emit(state.copyWith(
        status: PokemonCardStatus.success,
        cards: cards,
        hasReachedMax: false,
      ));
    } catch (_) {
      emit(state.copyWith(status: PokemonCardStatus.failure));
    }
  }

  Future<void> _onCardsSearched(
    CardsSearched event,
    Emitter<PokemonCardState> emit,
  ) async {
    emit(state.copyWith(isSearching: true, searchQuery: event.query));
    _currentPage = 1;
    try {
      final cards = await _pokemonCardRepository.searchCards(
        query: event.query,
        page: _currentPage,
        types: state.activeFilters,
      );
      _currentPage++;
      emit(state.copyWith(
        status: PokemonCardStatus.success,
        cards: cards,
        hasReachedMax: false,
        isSearching: false,
      ));
    } catch (_) {
      emit(state.copyWith(status: PokemonCardStatus.failure, isSearching: false));
    }
  }

  Future<void> _onCardsRefreshed(
    CardsRefreshed event,
    Emitter<PokemonCardState> emit,
  ) async {
    _currentPage = 1;
    emit(const PokemonCardState());
    await _onCardsFetched(CardsFetched(), emit);
  }

  Future<void> _onCardsFetched(
    CardsFetched event,
    Emitter<PokemonCardState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PokemonCardStatus.initial) {
        final cards = state.isSearching
            ? await _pokemonCardRepository.searchCards(
                query: state.searchQuery,
                page: _currentPage,
                types: state.activeFilters,
              )
            : await _pokemonCardRepository.getCards(
                page: _currentPage,
                types: state.activeFilters,
              );
        _currentPage++;
        return emit(state.copyWith(
          status: PokemonCardStatus.success,
          cards: cards,
          hasReachedMax: false,
        ));
      }

      final cards = state.isSearching
          ? await _pokemonCardRepository.searchCards(
              query: state.searchQuery,
              page: _currentPage,
              types: state.activeFilters,
            )
          : await _pokemonCardRepository.getCards(
              page: _currentPage,
              types: state.activeFilters,
            );
      _currentPage++;
      if (cards.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(state.copyWith(
          status: PokemonCardStatus.success,
          cards: List.of(state.cards)..addAll(cards),
          hasReachedMax: false,
        ));
      }
    } catch (_) {
      emit(state.copyWith(status: PokemonCardStatus.failure));
    }
  }
}
