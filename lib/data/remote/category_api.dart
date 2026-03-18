import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/models/category.dart';

class CategoryApi {
  final ApiClient _client;

  CategoryApi(this._client);

  Future<List<Category>> getCategories({String? type}) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;

    final response = await _client.get(
      ApiEndpoints.categories,
      queryParameters: queryParams,
    );
    final items = response['categories'] as List<dynamic>;
    return items
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Category> createCategory({
    required String name,
    required String icon,
    required String color,
    required String type,
  }) async {
    final response = await _client.post(
      ApiEndpoints.categories,
      data: {'name': name, 'icon': icon, 'color': color, 'type': type},
    );
    return Category.fromJson(response['category'] as Map<String, dynamic>);
  }

  Future<Category> updateCategory(
    String id, {
    String? name,
    String? icon,
    String? color,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (icon != null) data['icon'] = icon;
    if (color != null) data['color'] = color;

    final response = await _client.put(
      '${ApiEndpoints.categories}/$id',
      data: data,
    );
    return Category.fromJson(response['category'] as Map<String, dynamic>);
  }

  Future<void> deleteCategory(String id) async {
    await _client.delete('${ApiEndpoints.categories}/$id');
  }
}
