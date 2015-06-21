library exiv2.tools.enum_generator;

import 'dart:io';
import 'package:simple_requests/simple_requests.dart';
import 'package:xml/xml.dart';


var packageRootDir = (new Directory.fromUri(Platform.script).parent.parent).path;
var templateDir = packageRootDir + Platform.pathSeparator + 'tool' + Platform.pathSeparator + 'templates';
var targetCFile = packageRootDir + Platform.pathSeparator + 'native' + Platform.pathSeparator + 'exiv2_enums.h';
var targetDartFile = packageRootDir + Platform.pathSeparator + 'lib' + Platform.pathSeparator + 'src' + Platform.pathSeparator + 'exiv2_enums.dart';


main() async {
  var response = await request(Uri.parse('http://www.exiv2.org/tags.html'));

  RegExp exp = new RegExp(r'<table class="ReportTable" id="Exif"[\s\S]*?<\/table>');
  var table = exp.stringMatch(response.content);
  table = table.replaceAll(new RegExp(r'<colgroup>[\s\S]*?<\/colgroup>'), '');

  var document = parse(table);
  var rows = document.findAllElements('tr');
  var exif = {};

  for (var row in rows) {
    var nodes = row.findElements('td');
    if (nodes.length > 0) {
      exif[nodes.elementAt(3).text] = nodes.elementAt(4).text;
    }
  }

  var keys = exif.keys;

  // Generate C header with exif tag.
  var headerFile = new File(targetCFile);
  var cEnumsHeaderTemplate = await new File(templateDir + Platform.pathSeparator + 'exiv2_enums.h.template').readAsString();

  // Generate enum of all tags.
  var tagsEnumContent = keys.map((String key) => '    ExifTag_' + key.replaceAll('.', '_')).join(',\n');
  cEnumsHeaderTemplate = cEnumsHeaderTemplate.replaceAll("// EXIF_TAGS_GO_HERE", tagsEnumContent);

  // Generate enum of all data types.
  var typeEnumContent = new Set.from(exif.values.map((String key) => '    ExifData_' + key.replaceAll('.', '_'))).join(',\n');
  cEnumsHeaderTemplate = cEnumsHeaderTemplate.replaceAll("// EXIF_DATA_TYPES_GO_HERE", typeEnumContent);

  // Generate list of tag => type pairs.
  var tagsDefinitionContent = keys.map((String key) => '    {"${key}", ExifTag_${key.replaceAll('.', '_')}, ExifData_${exif[key]}}').join(',\n') + ',';
  cEnumsHeaderTemplate = cEnumsHeaderTemplate.replaceAll("// EXIF_DEFINITIONS_GO_HERE", tagsDefinitionContent);

  // Save to the target file
  headerFile.writeAsString(cEnumsHeaderTemplate);
  print("Saved to: ${headerFile.path}");


  // Generate Dart enums.
  var dartFile = new File(targetDartFile);

  var dartTtagsEnumContent = keys.map((String key) => '    ' + key.replaceAll('.', '_')).join(',\n');
  var dartEnumsTemplate = await new File(templateDir + Platform.pathSeparator + 'exiv2_enums.dart.template').readAsString();
  dartEnumsTemplate = dartEnumsTemplate.replaceAll("// EXIF_TAGS_GO_HERE", dartTtagsEnumContent);

  // Save to the target file
  dartFile.writeAsString(dartEnumsTemplate);
  print("Saved to: ${dartFile.path}");
}