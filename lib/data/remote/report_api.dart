import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class ReportApi {
  final ApiClient _client;

  ReportApi(this._client);

  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    return await _client.get(ApiEndpoints.monthlyReport(year, month));
  }

  Future<Map<String, dynamic>> getCategoryBreakdown({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await _client.get(
      ApiEndpoints.categoryBreakdown,
      queryParameters: queryParams,
    );
  }

  Future<Map<String, dynamic>> getTrends({int months = 6}) async {
    return await _client.get(
      ApiEndpoints.trends,
      queryParameters: {'months': months},
    );
  }
}
