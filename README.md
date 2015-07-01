# dart-exiv2

Dart VM native extension wrapper for Exiv2 library ([exiv2.org](exiv2.org)).

## Prerequisites

This native extension links `libexiv2.[so,dylib,dll]` as a shared library, uses `cmake` to manage the compilation process, a C/C++ compiler compatible with `cmake` and `bash`. Therefore you need to install these by hand before compiling this extension.

On windows without Cygwin environment (and no `bash`) you can run cmake in `./native/build` directory by yourself with `cmake ../..` (it won't make mess with compilation files in directory with source files). 
 
## Installation
 
#### 1. Add dependency

Add to your `pubspec.yaml`:

```
dependencies:
    exiv2: "^0.1.0"
```

Then run `pub get`.

#### 2. Compile the native extension wrapper

```
$ pub run exiv2:compile
```

This uses `cmake` under the hood to compile the extension as so-called "out of source" build. Then also runs unit tests to check that the binary is valid.

The compiled extension is copied automatically to `lib/src/libexiv2_wrapper.[so,dylib,dll]`.

## Usage

EXIF manipulation is done via static methods in Exiv2 class.  
All Exif tag names are represented by `ExifTag` enum.

```dart
import 'package:exiv2/exiv2.dart';

String imagePath = '/path/to/image.jpg';
// You can also use an instance of File.
// File image = new File('/path/to/image.jpg');

// Get all EXIF records. All returned records are Dart Strings.
Map<ExifTag, String> allExifRecords = Exiv2.getAll(imagePath);

// Get a single record.
String singleRecord = Exiv2.getTag(imagePath, ExifTag.Exif_Image_Model);

// Set multiple records.
var records = {
    ExifTag.Exif_Image_Model: "Canon EOS 550D",
    ExifTag.Exif_Image_Orientation: 2,
    ExifTag.Exif_Image_ISOSpeedRatings: 100,
}
Exiv2.setMap(imagePath, records);

// Set a single record
Exiv2.setTag(imagePath, ExifTag.Exif_Image_Model, "Canon EOS 550D");

// Remove tag
Exiv2.remove(imagePath, ExifTag.Exif_Image_Model)

// Remove all tags
Exiv2.removeAll(imagePath);
```

## Development

C/C++ files are in `native` directory.

Since there are several hundred EXIF tags, enums used in both Dart `exiv2_enums.dart` and C `exiv2_enums.h` are generated automatically from [http://www.exiv2.org/metadata.html](http://www.exiv2.org/metadata.html). You can regenerate them with:

```
$ dart tool/generate_c_and_dart_enums_for_exiv2_tags.dart
```

To compile the extension you can use the default `bin/compile.dart` or maybe more easily manually by running `cmake`. There's a `bash` script called `native/build/refresh.sh` that removes all binaries, cmake, make and compilation files and re-runs `cmake .`.

```
cd native/build
$ ./refresh.sh
```

Note that you need to run `refresh.sh` from `native/build` directory to avoid messing source and compilation files together.

## License

dart-exiv2 is licensed under MIT license.

Exiv2 ([exiv2.org](http://www.exiv2.org/)) is licensed under GNU General Public License.
