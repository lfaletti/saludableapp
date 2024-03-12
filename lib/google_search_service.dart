import 'dart:convert';
import 'package:http/http.dart' as http;


class GoogleSearchService {
  static const String apiKey = 'AIzaSyAlBbRHuU1iCxAm5YLXzl9dEE6eBcu7Xbc';
  static const String cx = 'e0ac7cb0523f34486';
  static const String language = 'es'; // Define the language of the search

  Future<String> search(String term) async {
    var response = await http.get(
      Uri.parse('https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&language=$language&q=definicion%20of%20$term'),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      var data = jsonDecode(response.body);
      
      // Return the snippet from the first item.
      return data['items'][0]['snippet'];
    } else {
      // If the server returns an error response, throw an exception.
      throw Exception('Failed to load definition');
    }
  }
}