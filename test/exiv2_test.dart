library exiv2.test.wrapper;

import 'dart:io';
import 'package:test/test.dart';
import 'package:exiv2/exiv2.dart';

void main() {

  var testDir = Directory.current.path + Platform.pathSeparator + 'test';
//  var dartExec = new File(Platform.executable).resolveSymbolicLinksSync();
//  var dartSdkDir = new File(dartExec).parent.parent;

  test("Exception for non-existing file", () {
    expect(() => Exiv2.getTag('/foo/bar', ExifTag.Exif_Image_Model), throwsException);
    expect(() => Exiv2.getTag(123, ExifTag.Exif_Image_Model), throwsException);
  });

  test("Get EXIF metadata", () {
    // http://www.exiv2.org/tags.html
    var img1file = testDir + Platform.pathSeparator + 'img1_with_exif.jpg';

    var exifData = Exiv2.getAll(new File(img1file));

    expect(exifData, containsPair(ExifTag.Exif_Image_DateTime, '2011:09:10 15:26:42'));
    expect(exifData, containsPair(ExifTag.Exif_Photo_ApertureValue, '29/8'));
    expect(exifData, containsPair(ExifTag.Exif_Photo_ISOSpeedRatings, '100'));
    expect(exifData, containsPair(ExifTag.Exif_Photo_ExposureTime, '1/500'));

    expect(Exiv2.getTag(img1file, ExifTag.Exif_Photo_FNumber), equals('7/2'));
    // Missing record
    expect(Exiv2.getTag(img1file, ExifTag.Exif_GPSInfo_GPSDestLatitudeRef), isNull);
  });

  test("Image with no EXIF metadata", () {
    var img1file = testDir + Platform.pathSeparator + 'img1_no_exif.jpg';

    expect(Exiv2.getAll(img1file), isEmpty);
  });

  group("Modify test files: ", () {
    var img1file = testDir + Platform.pathSeparator + 'img1_no_exif.jpg';
    var testImg = testDir + Platform.pathSeparator + '_test_img1_no_exif.jpg';

    setUp(() {
      new File(img1file).copySync(testImg);
    });

    tearDown(() {
      new File(testImg).deleteSync();
    });

    group('Modifying tags: ', () {

      test("Non-existing tag EXIF metadata", () {
        expect(() => Exiv2.setTag(new File(testImg), ExifTag.Exif_Image_JPEGTables, 'undefined'), throwsStateError);
      });

      test("Setting and removing multiple EXIF metadata", () {
        var testTags1 = {
          ExifTag.Exif_Image_DotRange: 6, // Byte
          ExifTag.Exif_Image_Orientation: 2, // Short
          ExifTag.Exif_Image_XClipPathUnits: -4, // SShort
          ExifTag.Exif_Image_ImageLength: 2048 // Long
        };
        var testTags2 = {
          ExifTag.Exif_Image_ImageWidth: 8192, // Long
          ExifTag.Exif_Image_Model: 'Camera model', // Ascii
          ExifTag.Exif_Image_YResolution: "2/3", // Rational
          ExifTag.Exif_Image_WhitePoint: "-4/7" // Rational
        };

        Exiv2.setMap(testImg, testTags1);
        Exiv2.setMap(testImg, testTags2);

        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_DotRange), equals('6'));
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_Orientation), equals('2'));
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_XClipPathUnits), equals('-4'));
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_ImageLength), equals('2048'));
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_ImageWidth), equals('8192'));
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_Model), equals('Camera model'));
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_YResolution), equals('2/3'));
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_WhitePoint), equals('-4/7'));

        // Remove single tag
        expect(Exiv2.remove(testImg, ExifTag.Exif_Image_DotRange), isTrue);
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_DotRange), isNull);

        // Remove all tags
        Exiv2.removeAll(testImg);
        expect(Exiv2.getAll(testImg), isEmpty);
      });

      test("Single EXIF metadata", () {
        Exiv2.setTag(testImg, ExifTag.Exif_Image_Model, 'Camera model');
        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_Model), equals('Camera model'));
      });

      test("Rewrite same EXIF tag multiple times", () {
        Exiv2.setTag(testImg, ExifTag.Exif_Image_Model, 'Camera model #1');
        Exiv2.setTag(testImg, ExifTag.Exif_Image_Model, 'Camera model #2');
        Exiv2.setTag(testImg, ExifTag.Exif_Image_Model, 'Camera model #3');

        expect(Exiv2.getTag(testImg, ExifTag.Exif_Image_Model), equals('Camera model #3'));
      });

    });
  });

}
