part of exiv2;

List<String> _all(String filename) native "GetAllExifRecords";
String _get(String filename, String tag) native "GetExifRecord";


class Exiv2File {

  File _file;

  Exiv2File(this._file);

  Exiv2File.fromString(String filePath): this._file = new File(filePath);


  getAll() {
    return _all(_file.path);
  }
}