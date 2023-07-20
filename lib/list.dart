import 'package:flutter/material.dart';
import 'top_bar.dart';
import 'bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/components/path.dart' show buildPath;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Item {
  final String title;
  final String userId;
  bool checked;

  Item(this.title, this.checked, this.userId);
}

class CheckList {
  final String title;
  final String userId;
  final List<Item> items;

  CheckList(this.title, this.items, this.userId);
}

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State_List createState() => State_List();
}

class State_List extends State<ListPage> {
  final List<CheckList> _checkLists = [];
  final _newCheckListController = TextEditingController();

  Future<String> getToken() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');
    return token ?? '';
  }

  Future<void> _addCheckList() async {
    final String title = _newCheckListController.text.trim();
    if (title.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      var userId = userData['userId'];

      var path = await buildPath('api/create_list');
      var url = Uri.parse(path);
      var token = await getToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var body = jsonEncode({'userId': userId, 'label': title});

      try {
        var response = await http.post(url, headers: headers, body: body);
        var res = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            _checkLists.add(CheckList(title, [], res['listId'].toString()));
            _newCheckListController.clear();
          });
        } else {
          _showErrorDialog(res['error']);
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      }
    }
  }

  Future<void> _addItem(CheckList checkList) async {
    final String title = _newCheckListController.text.trim();
    if (title.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      var userId = userData['userId'];

      var path = await buildPath('api/create_list_item');
      var url = Uri.parse(path);
      var token = await getToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var body = jsonEncode({'listId': userId, 'label': title});

      try {
        var response = await http.post(url, headers: headers, body: body);
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        var res = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            checkList.items.add(Item(title, false, res['listItemId'].toString()));
            _newCheckListController.clear();
          });
        } else {
          _showErrorDialog(res['error']);
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      }
    }
  }

  Future<void> _deleteCheckList(CheckList checkList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
    var userId = userData['userId'];

    var path = await buildPath('api/delete_list');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode({'listId': userId});

    try {
      var response = await http.delete(url, headers: headers, body: body);
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _checkLists.remove(checkList);
        });
      } else {
        _showErrorDialog(res['error']);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _toggleItem(Item item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
    var userId = userData['userId'];

    var path = await buildPath('api/update_list_item');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode(
        {'listItemId': userId, 'isChecked': (!item.checked).toString()});

    try {
      var response = await http.put(url, headers: headers, body: body);
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          item.checked = !item.checked;
        });
      } else {
        _showErrorDialog(res['error']);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _deleteItem(CheckList checkList, Item item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
    var userId = userData['userId'];

    var path = await buildPath('api/delete_list_item');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = jsonEncode({'listItemId': userId});

    try {
      var response = await http.delete(url, headers: headers, body: body);
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          checkList.items.remove(item);
        });
      } else {
        _showErrorDialog(res['error']);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
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
        selectedIndex:
            2, // Sets the selected index of the bottom navigation bar to 2
      ),
    );
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
            onChanged: (bool? newValue) =>
                newValue != null ? _toggleItem(item) : null,
          ),
          title: Text(
            item.title,
            style: TextStyle(
                decoration: item.checked ? TextDecoration.lineThrough : null),
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
