import 'dart:convert';
import 'package:http/http.dart' as http;
import '../BaseUrl.dart';
import 'Category.dart';
Future<List<Category>> fetchCategories() async {
  final url = Uri.parse(baseUrl);

  final response = await http.post(
    url,
    body: {
      'view': 'category',
      'lang': 'en',
      'catID': '',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<Category> categories = (data['data']['cat_list'] as List)
        .map((i) => Category.fromJson(i))
        .toList();
    return categories;
  } else {
    throw Exception('Failed to load categories');
  }
}

