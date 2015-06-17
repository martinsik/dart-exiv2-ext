library exiv2.test;

import 'package:test/test.dart';
import 'dart:io';
import 'package:dart-exiv2-ext/exiv2.dart';

void main() {

  var testDir = Directory.current.path + Platform.pathSeparator + 'test';
//  var dartExec = new File(Platform.executable).resolveSymbolicLinksSync();
//  var dartSdkDir = new File(dartExec).parent.parent;


  test("Get EXIF metadata", () {
    // http://www.exiv2.org/tags.html
    var img1file = new File(testDir + Platform.pathSeparator + 'img1_with_exif.jpg');

    var exiv2Test1 = new Exiv2File(img1file);
    var exifData = exiv2Test1.getAll();

    expect(exifData, containsPair('Exif.Image.DateTime', '2011:09:10 15:26:42'));
    expect(exifData, containsPair('Exif.Photo.ApertureValue', '29/8'));
    expect(exifData, containsPair('Exif.Photo.ISOSpeedRatings', '100'));
    expect(exifData, containsPair('Exif.Photo.ExposureTime', '1/500'));

    expect(exiv2Test1.get('Exif.Photo.FNumber'), equals('7/2'));
    expect(exiv2Test1.get('Exif.Photo.Foo'), isNull);
  });

  test("Image with no EXIF metadata", () {
    var img1file = new File(testDir + Platform.pathSeparator + 'img1_no_exif.jpg');
    var exiv2Test1 = new Exiv2File.fromString(img1file.path);

    expect(exiv2Test1.getAll(), isEmpty);
  });

}
