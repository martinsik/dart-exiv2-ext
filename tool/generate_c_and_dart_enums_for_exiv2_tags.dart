library exiv2.tools.enum_generator;

import 'dart:io';
import 'package:simple_requests/simple_requests.dart';
import 'package:xml/xml.dart';


var packageRootDir = (new Directory.fromUri(Platform.script).parent.parent).path;
var templateDir = packageRootDir + Platform.pathSeparator + 'tool' + Platform.pathSeparator + 'templates';
var targetCFile = packageRootDir + Platform.pathSeparator + 'native' + Platform.pathSeparator + 'exiv2_enums.h';
var targetDartFile = packageRootDir + Platform.pathSeparator + 'lib' + Platform.pathSeparator + 'src' + Platform.pathSeparator + 'exiv2_enums.dart';


main() async {
  var urls = [
    'http://www.exiv2.org/tags.html',
    'http://www.exiv2.org/tags-canon.html',
    'http://www.exiv2.org/tags-fujifilm.html',
    'http://www.exiv2.org/tags-minolta.html',
    'http://www.exiv2.org/tags-nikon.html',
    'http://www.exiv2.org/tags-olympus.html',
    'http://www.exiv2.org/tags-panasonic.html',
    'http://www.exiv2.org/tags-pentax.html',
    'http://www.exiv2.org/tags-samsung.html',
    'http://www.exiv2.org/tags-sigma.html',
    'http://www.exiv2.org/tags-sony.html',
  ];

  var tags = {};

  for (var url in urls) {
    var response = await request(Uri.parse(url));
    print("Parsing ${url}");

    RegExp exp = new RegExp(r'<table class="ReportTable" [\s\S]*?<\/table>');
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

    tags.addAll(exif);
  }

  // C header with exif tag.
  var headerFile = new File(targetCFile);
  var cEnumsHeaderTemplate = await new File(templateDir + Platform.pathSeparator + 'exiv2_enums.h.template').readAsString();

  // Generate enum of all tags.
  var tagsEnumContent = tags.keys.map((String key) => '    ExifTag_' + key.replaceAll('.', '_'));

  // Generate enum of all data types.
  var dataTypeEnumContent = new Set.from(tags.values).map((String key) => '    ExifData_' + key.replaceAll('.', '_'));

  // Generate list of tag => type pairs.
  var tagsDefinitionContent = tags.keys.map((String key) => '    {"${key}", ExifTag_${key.replaceAll('.', '_')}, ExifData_${tags[key]}}');

  cEnumsHeaderTemplate = cEnumsHeaderTemplate.replaceAll("// EXIF_TAGS_GO_HERE", tagsEnumContent.join(',\n'));
  cEnumsHeaderTemplate = cEnumsHeaderTemplate.replaceAll("// EXIF_DEFINITIONS_GO_HERE", tagsDefinitionContent.join(',\n') + ',');
  cEnumsHeaderTemplate = cEnumsHeaderTemplate.replaceAll("// EXIF_DATA_TYPES_GO_HERE", dataTypeEnumContent.join(',\n'));

  // Save to the target file
  headerFile.writeAsString(cEnumsHeaderTemplate);
  print("Saved to: ${headerFile.path}");

  // Generate Dart enums.
  var dartFile = new File(targetDartFile);
  var dartTagsEnumContent = tags.keys.map((String key) => '    ' + key.replaceAll('.', '_'));
  var dartEnumsTemplate = await new File(templateDir + Platform.pathSeparator + 'exiv2_enums.dart.template').readAsString();
  dartEnumsTemplate = dartEnumsTemplate.replaceAll("// EXIF_TAGS_GO_HERE", dartTagsEnumContent.join(',\n'));

  // Save to the target file
  dartFile.writeAsString(dartEnumsTemplate);
  print("Saved to: ${dartFile.path}");
}