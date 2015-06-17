part of exiv2;

_all(String filename) native "GetAllExifRecords";
_get(String filename, String key) native "GetExifRecord";


class Exiv2File {

  File _file;

  Exiv2File(this._file);

  Exiv2File.fromString(String filePath): this._file = new File(filePath);


  Map<String, String> getAll() {
    return _all(_file.path);
  }

  String get(String key) {
    return _get(_file.path, key);
  }
}