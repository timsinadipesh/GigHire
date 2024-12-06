import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ImageUploadService {
  // Imgur API credentials
  final String clientId = '498e458aa95667b';

  // Upload image to Imgur and return the uploaded image URL
  Future<String> uploadImageToImgur(dynamic imageSource) async {
    try {
      // Prepare image data
      List<int> imageBytes;
      if (kIsWeb) {
        // For Web: Ensure the source is a Uint8List
        if (imageSource == null || imageSource is! Uint8List) {
          throw Exception("Invalid image source for web.");
        }
        imageBytes = imageSource;
      } else {
        // For Mobile/Desktop: Ensure the source is a File
        if (imageSource == null || imageSource is! File) {
          throw Exception("Invalid image source for mobile/desktop.");
        }
        imageBytes = await imageSource.readAsBytes();
      }

      // Convert image to Base64
      String base64Image = base64Encode(imageBytes);

      // Prepare Imgur API request
      var url = Uri.parse('https://api.imgur.com/3/image');
      var headers = {
        'Authorization': 'Client-ID $clientId',
      };
      var body = {'image': base64Image};

      // Send POST request to Imgur
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Parse response and return image URL
        var jsonResponse = jsonDecode(response.body);
        String imageUrl = jsonResponse['data']['link'];
        print("Image uploaded to Imgur successfully. URL: $imageUrl");
        return imageUrl;
      } else {
        throw Exception("Imgur API call failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading image to Imgur: ${e.runtimeType} - ${e.toString()}");
      throw e;
    }
  }
}
