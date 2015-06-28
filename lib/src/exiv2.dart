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

  static Map<ExifTag, String> getAll(String file) {
    return _all(file);
  }

  static String get(String file, ExifTag tag) {
    return _get(file, exifTagToString(tag));
  }

  static bool setMap(String file, Map<ExifTag, dynamic> exifTags) {
    // Force string values
    var normalizedMap = {};
    exifTags.forEach((ExifTag tag, dynamic value) {
      normalizedMap[exifTagToString(tag)] = value.toString();
    });
    return _set(file, normalizedMap);
  }

}

