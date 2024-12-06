import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadService {
  static const String _imgurClientId = '498e458aa95667b';

  Future<String?> uploadImageToImgur(dynamic imageSource) async {
    try {
      // Read the file as bytes
      List<int> imageBytes = await imageSource.readAsBytes();

      // Base64 encode the image
      String base64Image = base64Encode(imageBytes);

      // Imgur API endpoint
      final response = await http.post(
        Uri.parse('https://api.imgur.com/3/image'),
        headers: {
          'Authorization': 'Client-ID $_imgurClientId',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'image': base64Image,
          'type': 'base64',
        }),
      );

      // Check the response
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Return the direct link to the uploaded image
        return responseData['data']['link'];
      } else {
        // Handle upload failure
        print('Image upload failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      // Handle any errors during upload
      print('Error uploading image: $e');
      return null;
    }
  }
}