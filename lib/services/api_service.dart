import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "http://<IP_BACKEND_KAMU>:8080";

  static Future<String> submitAttendance({
    required String studentId,
    required File imageFile,
    required double latitude,
    required double longitude,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      "student_id": studentId,
      "image_base64": base64Image,
      "latitude": latitude,
      "longitude": longitude,
    });

    final response = await http.post(
      Uri.parse("$_baseUrl/api/absen"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      return "Absensi berhasil!";
    } else {
      throw Exception("Gagal: ${response.body}");
    }
  }
}
