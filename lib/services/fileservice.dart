import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mondroid/services/popupservice.dart';
import 'package:mondroid/services/storageservice.dart';


class FileService {

  Future<String> getDiretoryPath() async {
    String? directory = await StorageService().read('directory');
    if (directory == null) {
      directory = await FilePicker.platform.getDirectoryPath();
      if (directory != null) {
        StorageService().write('directory', directory);
      }
    }
    return directory.toString();
  }

  Future<String> getNewDirectoryPath() async {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      StorageService().write('directory', directory);
    }
    return directory.toString();
  }

  Future<bool> saveAsCsv(List<Map<String, dynamic>> data, String directory,
      String fileName) async {
    try {
      List<List<dynamic>> rows = [];
      if (data.isNotEmpty) {
        rows.add(data.first.keys.toList());
        for (var map in data) {
          rows.add(map.values.toList());
        }
      }

      String csvData = const ListToCsvConverter().convert(rows);

      return saveFile(csvData, directory, '$fileName.csv');
    } catch (e) {
      PopupService.show('Error saving CSV file: $e');
    }

    return false;
  }

  Future<bool> saveAsJson(List<Map<String, dynamic>> data, String directory,
      String fileName) async {
    try {
      String jsonData = jsonEncode(data);
      return saveFile(jsonData, directory, '$fileName.json');
    } catch (e) {
      PopupService.show('Error saving JSON file: $e');
    }
    return false;
  }
}

Future<bool> saveFile(String content, String directory, String fileName) async {
  try {
    final uniqueFileName = await verifyUniqueFileName(directory, fileName);

    final file = File('$directory/$uniqueFileName');

    await file.writeAsString(content);
    return true;
  } catch (e) {
    PopupService.show('Error saving file: $e');
    return false;
  }
}

Future<String> verifyUniqueFileName(String directory, String fileName) async {
  String uniqueFileName = fileName;
  int count = 1;

  while (await File('$directory/$uniqueFileName').exists()) {
    uniqueFileName = '$fileName ($count)';
    count++;
  }

  return uniqueFileName;
}
