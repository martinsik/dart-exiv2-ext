part of exiv2;

_all(String filename) native "GetAllExifRecords";
_get(String filename, String tag) native "GetExifRecord";


class Exiv2File {

  File _file;

  Exiv2File(this._file);

  Exiv2File.fromString(String filePath): this._file = new File(filePath);


  Map<String, String> getAll() {
    return _all(_file.path);
  }
}