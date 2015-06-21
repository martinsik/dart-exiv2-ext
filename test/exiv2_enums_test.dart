library exiv2.test.enums;

import 'dart:io';
import 'package:test/test.dart';
import 'package:dart-exiv2-ext/exiv2.dart';

void main() {
  test("Enum conversions to string", () {
    expect(exifTagToString(ExifTag.Exif_Image_JPEGPointTransforms), equals('Exif.Image.JPEGPointTransforms'));
    expect(exifTagToString(ExifTag.Exif_GPSInfo_GPSSpeed), equals('Exif.GPSInfo.GPSSpeed'));
  });

  test("Enum conversions from string", () {
    expect(stringToExifTag('Exif.Image.JPEGPointTransforms'), equals(ExifTag.Exif_Image_JPEGPointTransforms));
    expect(stringToExifTag('Exif.GPSInfo.GPSSpeed'), equals(ExifTag.Exif_GPSInfo_GPSSpeed));
  });
}