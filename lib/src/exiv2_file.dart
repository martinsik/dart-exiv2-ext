part of exiv2;

_all(String filename) native "GetAllExifRecords";
_get(String filename, String key) native "GetExifRecord";


class Exiv2File {

  static Map<ExifTag, String> getAll(String file) {
    return _all(file);
  }

  static String get(String file, ExifTag tag) {
    return stringToExifTag(_get(file, exifTagToString(tag)));
  }

}