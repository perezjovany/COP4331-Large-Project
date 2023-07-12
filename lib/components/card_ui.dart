import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_app/components/path.dart' show buildPath;

class CardUI extends StatefulWidget {
  const CardUI({Key? key}) : super(key: key);

  @override
  _CardUIState createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> {
  var card = '';
  var search = '';
  var message = '';
  var searchResults = '';
  var cardList = '';

  @override
  Widget build(BuildContext context) {
    Future<void> addCard() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var _ud = prefs.getString('user_data');
      var ud = json.decode(_ud!);
      var userId = ud['userId'];

      var path = await buildPath('api/addcard');
      var url = Uri.parse(path); // Use buildPath from path.dart
      var headers = {'Content-Type': 'application/json'};
      var body = jsonEncode({
        'userId': userId,
        'card': card,
      });

      try {
        var response = await http.post(url, headers: headers, body: body);
        var res = jsonDecode(response.body);

        if (res['error'].length > 0) {
          setState(() {
            message = "API Error: ${res['error']}";
          });
        } else {
          setState(() {
            message = 'Card has been added';
          });
        }
      } catch (e) {
        setState(() {
          message = e.toString();
        });
      }
    }

    Future<void> searchCard() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var _ud = prefs.getString('user_data');
      var ud = json.decode(_ud!);
      var userId = ud['userId'];

      var path = await buildPath('api/searchcards');
      var url = Uri.parse(path);// Use buildPath from path.dart
      var headers = {'Content-Type': 'application/json'};
      var body = jsonEncode({
        'userId': userId,
        'search': search,
      });

      try {
        var response = await http.post(url, headers: headers, body: body);
        var txt = response.body;
        var res = jsonDecode(txt);
        var results = res['results'];
        var resultText = '';
        for (var i = 0; i < results.length; i++) {
          resultText += results[i];
          if (i < results.length - 1) {
            resultText += ', ';
          }
        }
        setState(() {
          searchResults = 'Card(s) have been retrieved';
          cardList = resultText;
        });
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        setState(() {
          searchResults = e.toString();
        });
      }
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Card To Search For',
            ),
            onChanged: (value) {
              setState(() {
                search = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: searchCard,
            child: const Text('Search Card'),
          ),
          const SizedBox(height: 10),
          Text(searchResults),
          const SizedBox(height: 10),
          Text(cardList),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Card To Add',
            ),
            onChanged: (value) {
              setState(() {
                card = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: addCard,
            child: const Text('Add Card'),
          ),
          const SizedBox(height: 10),
          Text(message),
        ],
      ),
    );
  }
}