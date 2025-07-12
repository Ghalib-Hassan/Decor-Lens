import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<bool> uploadImageToCloudinary(FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    print('No file selected');
    customSnackbar(
      title: 'Error',
      message: 'No file selected',
      titleColor: red,
    );
    return false;
  }

  File file = File(filePickerResult.files.first.path!);

  final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
  var request = http.MultipartRequest('POST', uri);

  //Read the file content as bytes
  var fileBytes = await file.readAsBytes();
  var multipartFile = http.MultipartFile.fromBytes(
    'file', // The name of the form field
    fileBytes,
    filename: file.path.split('/').last, // The original file name
  );

  //Add the file path to the request
  request.files.add(multipartFile);
  request.fields['upload_preset'] = "admin_upload_preset";
  request.fields['resource_type'] = "raw";

  //Send the request
  var response = await request.send();

  //Get the response as text
  var responseBody = await response.stream.bytesToString();

  print(responseBody);

  if (response.statusCode == 200) {
    // Parse the response
    var jsonResponse = jsonDecode(responseBody);
    String? secureUrl = jsonResponse['secure_url'];

    if (secureUrl != null) {
      print('Image uploaded successfully: $secureUrl');
      customSnackbar(
        title: 'Success',
        message: 'Image uploaded successfully',
        titleColor: green,
      );
      return true;
    } else {
      print('Error: No secure URL returned');
      customSnackbar(
        title: 'Error',
        message: 'No secure URL returned',
        titleColor: red,
      );
      return false;
    }
  } else {
    print('Error uploading image: ${response.statusCode}');
    customSnackbar(
      title: 'Error',
      message: 'Error uploading image',
      titleColor: red,
    );
    return false;
  }
}
