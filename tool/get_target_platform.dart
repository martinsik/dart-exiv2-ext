library exiv2.tools.target_platform;

import 'dart:io';

main() {
  RegExp exp = new RegExp(r'"(.*)"');
  var match = exp.firstMatch(Platform.version);
  String build = match.group(1);

  print(build.indexOf("32") == -1 ? 64 : 32);
}