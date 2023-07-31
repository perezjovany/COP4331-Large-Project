import 'package:flutter/material.dart';
import 'top_bar.dart';
import 'bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/components/path.dart' show buildPath;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Item {
  final String? itemId;
  String title;
  bool checked;
  final String? listId;

  bool? isEditing;
  TextEditingController? editingController;

  Item(this.itemId, this.title, this.checked, this.listId) {
    isEditing = false;
    editingController = TextEditingController(text: title);
  }
}

class CheckList {
  String? listId;
  String title;
  List<Item> items;
  String? userId;

  bool? isEditing;
  TextEditingController? editingController;

  CheckList(this.listId, this.title, this.items, this.userId) {
    isEditing = false;
    editingController = TextEditingController(text: title);
  }
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
        'Authorization': '$token'
      };
      var body = jsonEncode({'userId': userId, 'label': title});

      try {
        var response = await http.post(url, headers: headers, body: body);
        var res = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            _checkLists.add(CheckList(res['listId'], title, [], res['userId']));
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
      var path = await buildPath('api/create_list_item');
      var url = Uri.parse(path);
      var token = await getToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': '$token'
      };
      var body = jsonEncode({'listId': checkList.listId, 'label': title});

      try {
        var response = await http.post(url, headers: headers, body: body);
        var res = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            checkList.items.add(Item(res['listItemId'], title, false, checkList.listId));
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
  
  Future<void> _editCheckList(CheckList checkList, String newTitle) async {
    var path = await buildPath('api/update_list');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token',
    };
    var body = jsonEncode({'listId': checkList.listId, 'label': newTitle});

    try {
      var response = await http.put(url, headers: headers, body: body);
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          // Update the title of the checkList
          checkList.title = newTitle;
        });
      } else {
        _showErrorDialog(res['error']);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _deleteCheckList(CheckList checkList) async {
    var path = await buildPath('api/delete_list');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token'
    };
    var body = jsonEncode({'listId': checkList.listId});

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
    var path = await buildPath('api/update_list_item');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token'
    };
    var body = jsonEncode(
        {'listItemId': item.itemId, 'isChecked': (!item.checked).toString()});

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

  Future<void> _editItem(Item itemToUpdate, String newTitle) async {
    final String itemId = itemToUpdate.itemId!;
    var path = await buildPath('api/update_list_item');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token'
    };
    var body = jsonEncode({
      'listItemId': itemId,
      'label': newTitle,
    });

    try {
      var response = await http.put(url, headers: headers, body: body);
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          itemToUpdate.title = newTitle;
        });
      } else {
        _showErrorDialog(res['error']);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _deleteItem(CheckList checkList, Item item) async {
    var path = await buildPath('api/delete_list_item');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token'
    };
    var body = jsonEncode({'listItemId': item.itemId});

    try {
      var response = await http.delete(url, headers: headers, body: body);
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
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      var userId = userData['userId'].toString();

      var path = await buildPath('api/get_all_lists/$userId');
      var url = Uri.parse(path);

      var token = await getToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': '$token'
      };

      var response = await http.get(url, headers: headers);
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (var listData in res) {
          var listItemsPath =
              await buildPath('api/get_list_items/${listData['_id']}');
          var listItemsUrl = Uri.parse(listItemsPath);

          var listItemsResponse =
              await http.get(listItemsUrl, headers: headers);
          var listItemsRes = jsonDecode(listItemsResponse.body);

          List<Item> items = [];
          if (listItemsResponse.statusCode == 200 && listItemsRes != null) {
            for (var listItemData in listItemsRes) {
              var itemId = listItemData['_id'] ?? 'Unknown Item ID';
              var title = listItemData['label'] ?? 'Unknown Title';
              var checked = listItemData['isChecked'] ?? false;
              var listId = listItemData['listId'] ?? 'Unknown List';
              items.add(Item(itemId, title, checked, listId));
            }
          }

          CheckList checkList =
              CheckList(listData['_id'], listData['label'], items, listData['listId']);
          setState(() {
            _checkLists.add(checkList);
          });
        }
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
    bool isEditing = checkList.isEditing ?? false; // Initialize with false
    TextEditingController controller =
        checkList.editingController ?? TextEditingController();

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: isEditing
            ? TextField(
                controller: controller,
                onSubmitted: (value) {
                  _saveCheckListTitle(checkList, value);
                },
              )
            : Text(checkList.title),
        trailing: isEditing
            ? IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  _saveCheckListTitle(checkList, controller.text);
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _startEditCheckList(checkList, controller);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteCheckList(checkList),
                  ),
                ],
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
        bool isEditing = item.isEditing ?? false; // Initialize with false
        TextEditingController controller =
            item.editingController ?? TextEditingController();

        return ListTile(
          leading: Checkbox(
            value: item.checked,
            onChanged: (bool? newValue) =>
                newValue != null ? _toggleItem(item) : null,
          ),
          title: isEditing
              ? TextField(
                  controller: controller,
                  onSubmitted: (value) {
                    _saveItemTitle(item, value);
                  },
                )
              : Text(
                  item.title,
                  style: TextStyle(
                    decoration: item.checked ? TextDecoration.lineThrough : null,
                  ),
                ),
          trailing: isEditing
              ? IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    _saveItemTitle(item, controller.text);
                  },
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _startEditItem(item, controller);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteItem(checkList, item),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _startEditCheckList(CheckList checkList, TextEditingController controller) {
    setState(() {
      checkList.isEditing = true;
      checkList.editingController = controller;
    });
  }

  void _saveCheckListTitle(CheckList checkList, String newTitle) {
    setState(() {
      checkList.isEditing = false;
      checkList.title = newTitle;
    });
    _editCheckList(checkList, newTitle); // Save the changes to the server
    FocusScope.of(context).unfocus();
  }

  void _startEditItem(Item item, TextEditingController controller) {
    setState(() {
      item.isEditing = true;
      item.editingController = controller;
    });
  }

  void _saveItemTitle(Item item, String newTitle) {
    setState(() {
      item.isEditing = false;
      item.title = newTitle;
    });
    _editItem(item, newTitle); // Save the changes to the server
    FocusScope.of(context).unfocus();
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
