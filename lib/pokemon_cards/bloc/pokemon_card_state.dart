part of 'pokemon_card_bloc.dart';

enum PokemonCardStatus { initial, success, failure }

final class PokemonCardState extends Equatable {
  const PokemonCardState({
    this.status = PokemonCardStatus.initial,
    this.cards = const <PokemonCard>[],
    this.hasReachedMax = false,
    this.isSearching = false,
    this.searchQuery = '',
    this.activeFilters = const {},
  });

  final PokemonCardStatus status;
  final List<PokemonCard> cards;
  final bool hasReachedMax;
  final bool isSearching;
  final String searchQuery;
  final Set<String> activeFilters;

  PokemonCardState copyWith({
    PokemonCardStatus? status,
    List<PokemonCard>? cards,
    bool? hasReachedMax,
    bool? isSearching,
    String? searchQuery,
    Set<String>? activeFilters,
  }) {
    return PokemonCardState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }

  @override
  List<Object> get props => [
    status,
    cards,
    hasReachedMax,
    isSearching,
    searchQuery,
    activeFilters,
  ];
}
