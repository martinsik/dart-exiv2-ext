part of exiv2;

_all(String filename) native "GetAllExifRecords";
_get(String filename, String key) native "GetExifRecord";
_set(String filename, Map exifTags) native "SetExifRecords";
_remove(String filename, List tags) native "RemoveExifRecord";
_removeAll(String filename) native "RemoveAllExifRecords";

String exifTagToString(ExifTag tag) {
  return tag.toString().split('.')[1].replaceAll('_', '.');
}

ExifTag stringToExifTag(String str) {
  var normStr = str.replaceAll('.', '_');
  return ExifTag.values.firstWhere((ExifTag tag) => tag.toString().split('.')[1] == normStr);
}

class Exiv2 {

  // @todo: Maybe this class should also be able to convert tags into labels.

  static String _verifiedFilePath(var file) {
    String path = _getFilePath(file);
    if (!(new File(path).existsSync())) {
      throw new Exception("This file doesn't exist");
    }
    return path;
  }

  static String _getFilePath(var file) {
    if (file is File) {
      return (file as File).path;
    } else if (file is String) {
      return file;
    } else {
      throw new Exception("Use String or File objects only");
    }
  }

  static Map<ExifTag, String> getAll(var file) {
    var response = {};
    _all(_verifiedFilePath(file)).forEach((String tag, String value) {
      response[stringToExifTag(tag)] = value;
    });
    return response;
  }

  static String getTag(var file, ExifTag tag) {
    return _get(_verifiedFilePath(file), exifTagToString(tag));
  }

  static void setMap(var file, Map<ExifTag, dynamic> exifTags) {
    // Force string keys and values
    var normalizedMap = {};
    exifTags.forEach((ExifTag tag, var value) {
      normalizedMap[exifTagToString(tag)] = value.toString();
    });
    _set(_verifiedFilePath(file), normalizedMap);
  }

  static void setTag(var file, ExifTag tag, var value) {
    setMap(_verifiedFilePath(file), {tag: value});
  }

  static bool remove(var file, var tags) {
    if (!(tags is List)) {
      tags = [tags];
    }
    return _remove(_verifiedFilePath(file), tags.map((ExifTag tag) => exifTagToString(tag)).toList());
  }

  static void removeAll(var file) {
    _removeAll(_verifiedFilePath(file));
  }
}
