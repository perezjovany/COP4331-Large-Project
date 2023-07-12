import 'package:http/http.dart' as http;
import 'dart:convert';

class CardsData {

  static Future<String> getJson(String url, String outgoing) async
  {
    String ret = "";

    try
    {
      http.Response response = await http.post(url as Uri,
          body: utf8.encode(outgoing),
          headers:
          {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          encoding: Encoding.getByName("utf-8")
      );
      ret = response.body;
    }
    catch (e)
    {
      print(e.toString());
    }

    return ret;
  }

}
