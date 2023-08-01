import 'package:flutter/material.dart';



class SearchFood extends SearchDelegate<String> {
  
  //example list, need to connect to db
  List<String> foodItems;

  SearchFood({required this.foodItems});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, query);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> allItems = foodItems
        .where(
          (item) => item.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();

    return ListView.builder(
      itemCount: allItems.length,
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Text(allItems[index]),
        onTap: (){
          query = allItems[index];
          close(context, query);
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> foodSuggestions = foodItems
        .where(
          (itemsuggestion) => itemsuggestion.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();

    return ListView.builder(
      itemCount: foodSuggestions.length,
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Text(foodSuggestions[index]),
        onTap: (){
          query = foodSuggestions[index];
          close(context, query);
        },
      ),
    );
  }
}
