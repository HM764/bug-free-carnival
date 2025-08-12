part of app;

Widget recipesInPlannerScreen(
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
