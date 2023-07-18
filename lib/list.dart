import 'package:flutter/material.dart';
import 'top_bar.dart';
import 'bottom_bar.dart';

class Item {
  final String title;
  bool checked;

  Item(this.title, this.checked);
}

class CheckList {
  final String title;
  final List<Item> items;

  CheckList(this.title, this.items);
}

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State_List createState() => State_List();
}

class State_List extends State<ListPage> {
  final List<CheckList> _checkLists = [];
  final _newCheckListController = TextEditingController();

  void _addCheckList() {
    final String title = _newCheckListController.text.trim();
    if (title.isNotEmpty) {
      setState(() {
        _checkLists.add(CheckList(title, []));
        _newCheckListController.clear();
      });
    }
  }

  void _deleteCheckList(CheckList checkList) {
    setState(() => _checkLists.remove(checkList));
  }

  void _addItem(CheckList checkList) {
    final String title = _newCheckListController.text.trim();
    if (title.isNotEmpty) {
      setState(() {
        checkList.items.add(Item(title, false));
        _newCheckListController.clear();
      });
    }
  }

  void _toggleItem(Item item) {
    setState(() => item.checked = !item.checked);
  }

  void _deleteItem(CheckList checkList, Item item) {
    setState(() => checkList.items.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topBar(title: 'Your Lists'), // Page Title
      body: ListView.builder(
        itemCount: _checkLists.length,
        itemBuilder: (context, index) => _buildCheckList(_checkLists[index]),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showCheckListDialog,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: const bottomBar(
        selectedIndex: 2, // Sets the selected index of the bottom navigation bar to 2
      ),
    );
  }

  Widget _buildCheckList(CheckList checkList) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(checkList.title),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deleteCheckList(checkList),
        ),

        children: <Widget>[
          _buildItemsList(checkList),
          _buildAddItemField(checkList),
        ],
      ),
    );
  }

  Widget _buildItemsList(CheckList checkList) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: checkList.items.length,
      itemBuilder: (context, index) {
        final item = checkList.items[index];
        return ListTile(
          leading: Checkbox(
            value: item.checked,
            onChanged: (bool? newValue) => newValue != null ? _toggleItem(item) : null,
          ),

          title: Text(
            item.title,
            style: TextStyle(decoration: item.checked ? TextDecoration.lineThrough : null),
          ),

          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteItem(checkList, item),
          ),
        );
      },
    );
  }

  Widget _buildAddItemField(CheckList checkList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onSubmitted: (value) => _addItem(checkList),
        decoration: InputDecoration(
          hintText: 'Add item',
          suffixIcon: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addItem(checkList),
          ),
        ),

        controller: _newCheckListController,
      ),
    );
  }

  void _showCheckListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add new check list"),
        content: TextField(
          controller: _newCheckListController,
          decoration: const InputDecoration(hintText: "Enter check list title"),
        ),

        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
              _newCheckListController.clear();
            },
          ),

          TextButton(
            child: const Text("Add"),
            onPressed: () {
              _addCheckList();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Lists',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ListPage(),
    );
  }
}


void main() {
  runApp(const MyApp());
}
