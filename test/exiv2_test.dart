library exiv2.test.wrapper;

import 'dart:io';
import 'package:test/test.dart';
import 'package:dart-exiv2-ext/exiv2.dart';

void main() {

  var testDir = Directory.current.path + Platform.pathSeparator + 'test';
//  var dartExec = new File(Platform.executable).resolveSymbolicLinksSync();
//  var dartSdkDir = new File(dartExec).parent.parent;

  test("Get EXIF metadata", () {
    // http://www.exiv2.org/tags.html
    var img1file = testDir + Platform.pathSeparator + 'img1_with_exif.jpg';

    var exifData = Exiv2.getAll(img1file);

    expect(exifData, containsPair('Exif.Image.DateTime', '2011:09:10 15:26:42'));
    expect(exifData, containsPair('Exif.Photo.ApertureValue', '29/8'));
    expect(exifData, containsPair('Exif.Photo.ISOSpeedRatings', '100'));
    expect(exifData, containsPair('Exif.Photo.ExposureTime', '1/500'));

    expect(Exiv2.get(img1file, ExifTag.Exif_Photo_FNumber), equals('7/2'));
    expect(Exiv2.get(img1file, ExifTag.Exif_GPSInfo_GPSDestLatitudeRef), isNull);
  });

  test("Image with no EXIF metadata", () {
    var img1file = testDir + Platform.pathSeparator + 'img1_no_exif.jpg';

    expect(Exiv2.getAll(img1file), isEmpty);
  });

  test("Setting EXIF metadata", () {
    var img1file = testDir + Platform.pathSeparator + 'img1_no_exif.jpg';
    var testImg = testDir + Platform.pathSeparator + '_test_img1_no_exif.jpg';

    var orig = new File(img1file);
    orig.copySync(testImg);

    var testTags = {
      ExifTag.Exif_Image_Orientation: 2,
      ExifTag.Exif_Image_ImageLength: 2048,
      ExifTag.Exif_Image_TargetPrinter: "Test Printer 123",
      ExifTag.Exif_Image_WhitePoint: "2/3"
    };

    Exiv2.setMap(testImg, testTags);

    new File(testImg).deleteSync();
  });

}
