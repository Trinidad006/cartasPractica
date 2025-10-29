import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/bloc/pokemon_card_bloc.dart';
import 'package:pokecard_dex/pokemon_cards/widgets/bottom_loader.dart';
import 'package:pokecard_dex/pokemon_cards/widgets/card_list_item.dart';

class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by name',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              context.read<PokemonCardBloc>().add(CardsSearched(value));
            });
          },
        ),
      ),
      drawer: Drawer(
        child: BlocBuilder<PokemonCardBloc, PokemonCardState>(
          builder: (context, state) {
            final availableTypes = [
              'Colorless',
              'Darkness',
              'Dragon',
              'Fairy',
              'Fighting',
              'Fire',
              'Grass',
              'Lightning',
              'Metal',
              'Psychic',
              'Water',
            ];

            return ListView(
              children: availableTypes.map((type) {
                return CheckboxListTile(
                  title: Text(type),
                  value: state.activeFilters.contains(type),
                  onChanged: (bool? value) {
                    final newFilters = Set<String>.from(state.activeFilters);
                    if (value == true) {
                      newFilters.add(type);
                    } else {
                      newFilters.remove(type);
                    }
                    context.read<PokemonCardBloc>().add(FilterChanged(newFilters));
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<PokemonCardBloc>().add(CardsRefreshed()),
        child: BlocBuilder<PokemonCardBloc, PokemonCardState>(
          builder: (context, state) {
            if (state.isSearching && state.status == PokemonCardStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            switch (state.status) {
              case PokemonCardStatus.failure:
                return const Center(child: Text('Fallo al obtener las cartas'));
              case PokemonCardStatus.success:
                if (state.cards.isEmpty) {
                  return Center(
                    child: Text(
                      state.isSearching || state.searchQuery.isNotEmpty
                          ? 'No se encontraron cartas para "${state.searchQuery}"'
                          : 'No se encontraron cartas',
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: state.hasReachedMax
                      ? state.cards.length
                      : state.cards.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    return index >= state.cards.length
                        ? const BottomLoader()
                        : CardListItem(card: state.cards[index]);
                  },
                );
              case PokemonCardStatus.initial:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<PokemonCardBloc>().add(CardsFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }
}
