library exiv2.test;

import 'package:test/test.dart';
import 'dart:io';
import 'package:system_info/system_info.dart';
//import 'dart-ext:exiv2_wrapper';
import 'package:dart-exiv2-ext/exiv2.dart';

void main() {

  var dir = Directory.current;
//  var dartExec = new File(Platform.executable).resolveSymbolicLinksSync();
//  var dartSdkDir = new File(dartExec).parent.parent;


  test("Get all EXIF metadata", () {
    var img1file = new File(dir.path + Platform.pathSeparator + 'img1_with_exif.jpg');

    var exivTest1 = new Exiv2File(img1file);
    print(exivTest1.getAll());
  });

}
