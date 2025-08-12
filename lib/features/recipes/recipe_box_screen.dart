part of app;

Widget recipeBoxScreen(BuildContext context, String Function(String) t) {
    String query = '';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setInner) {
        List<RecipeModel> list = recipes
            .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
        list.sort((a, b) {
          final int fa = _favorites.contains(a.id) ? 0 : 1;
          final int fb = _favorites.contains(b.id) ? 0 : 1;
          final int byFav = fa.compareTo(fb);
          if (byFav != 0) return byFav;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: t('search'),
                ),
                onChanged: (String v) => setInner(() {
                  query = v;
                }),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int i) {
                    final RecipeModel r = list[i];
                    final bool fav = _favorites.contains(r.id);
                    return Card(
                      child: ListTile(
                        title: Text(r.title),
                        subtitle: Text(
                          '${r.ingredients.length} ingredients · ${r.steps.length} steps',
                        ),
                        trailing: IconButton(
                          tooltip: fav ? t('unfavorite') : t('favorite'),
                          icon: Icon(fav ? Icons.star : Icons.star_border),
                          onPressed: () => setState(() {
                            if (fav) {
                              _favorites.remove(r.id);
                            } else {
                              _favorites.add(r.id);
                            }
                          }),
                        ),
                        onTap: () {
                          _showRecipeSummary(r, t);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _recipesInPlannerTab(
    BuildContext context,
    String Function(String) t,
    Set<String> usedIds,
  ) {
    final List<RecipeModel> list =
        recipes.where((r) => usedIds.contains(r.id)).toList()..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            );
    if (list.isEmpty) return Center(child: Text(t('no_meals')));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (BuildContext context, int i) {
        final RecipeModel r = list[i];
        final bool fav = _favorites.contains(r.id);
        return Card(
          child: ListTile(
            title: Text(r.title),
            trailing: IconButton(
              tooltip: fav ? t('unfavorite') : t('favorite'),
              icon: Icon(fav ? Icons.star : Icons.star_border),
              onPressed: () => setState(() {
                if (fav) {
                  _favorites.remove(r.id);
                } else {
                  _favorites.add(r.id);
                }
              }),
            ),
            onTap: () {
              _showRecipeSummary(r, t);
            },
          ),
        );
      },
    );
  }


    }

    }

      switch (unit) {
      case 'g':
        return 'oz';
      case 'kg':
        return 'lb';
      case 'ml':
        return 'fl oz';
      case 'l':
        return 'pt';
      case 'tsp':
        return 'tsp';
      case 'tbsp':
        return 'tbsp';
      case 'cup':
        return 'cup';
      case 'unit':
        return 'unit';
      default:
        return unit;
    }
  }

  }
