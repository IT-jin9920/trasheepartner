import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlanService {

  Future<List<dynamic>?> fetchPlans() async {

    try {
      var url = 'https://syntaxium.in/DUSTBIN_API/shopkeeper_plans.php';

      debugPrint("Fetching plans from URL: $url");

      var response = await http.get(Uri.parse(url));

      debugPrint("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        debugPrint("Response Data: $data");

        // Check if the key 'plan_details' exists in the response and has valid data
        if (data.containsKey('plan_details')) {
          var plans = data['plan_details'];
          debugPrint("Fetched Plans: $plans");
          return plans;
        } else {
          debugPrint("No 'plan_details' found in response.");
          return null;
        }
      } else {
        debugPrint("Failed to fetch plans. Status code: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      debugPrint("Network error: $error");
      return null;
    }
  }
}
