part of exiv2;

_all(String filename) native "GetAllExifRecords";
_get(String filename, String key) native "GetExifRecord";
_set(String filename, Map exifTags) native "SetExifRecords";


String exifTagToString(ExifTag tag) {
  return tag.toString().split('.')[1].replaceAll('_', '.');
}

ExifTag stringToExifTag(String str) {
  var normStr = str.replaceAll('.', '_');
  return ExifTag.values.firstWhere((ExifTag tag) => tag.toString().split('.')[1] == normStr);
}


class Exiv2 {

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
    return _all(_verifiedFilePath(file));
  }

  static String get(var file, ExifTag tag) {
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
    setMap(file, {tag: value});
  }

}
