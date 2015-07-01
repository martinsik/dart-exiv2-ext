import 'dart:io';

main() async {
  Directory.current = 'native/build';

  var compilationResults = await Process.run('bash', ['refresh.sh']);
  print(compilationResults.stdout);
  print(compilationResults.stderr);

  Directory.current = '../..';

  if (new File('lib/src/libexiv2_wrapper.dylib').existsSync() ||
      new File('lib/src/libexiv2_wrapper.so').existsSync() ||
      new File('lib/src/libexiv2_wrapper.dll').existsSync()) {
    print('Congratulations! Binary compiled successfully!');
  } else {
    print('Some error occured! Try running cmake by yourself in ./native/build directory or add an issue ' +
        'to https://github.com/martinsik/dart-exiv2-ext/issues');
    return;
  }

  var testResults = await Process.run('pub', ['run', 'test', '.']);
  print(testResults.stdout);
  print(testResults.stderr);
}
