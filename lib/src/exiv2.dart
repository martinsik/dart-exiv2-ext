part of exiv2;

_all(String filename) native "GetAllExifRecords";
_get(String filename, String key) native "GetExifRecord";


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
//    print(exifTagToString(tag));
    var val = _get(file, exifTagToString(tag));
//    print(val);
    return _get(file, exifTagToString(tag));
  }

}

