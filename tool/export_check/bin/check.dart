import 'dart:io';

import 'package:export_check/export_check.dart';

/// A workspace member; its package config resolves every package in this
/// repository, every `dart:` library, and Flutter.
const _workspace = '../../flutter_falconx';

const List<LibraryRef> _subjects = [
  (uri: 'package:flutter_falconx/flutter_falconx.dart', root: _workspace),
  (uri: 'package:flutter_falconnect/flutter_falconnect.dart', root: _workspace),
  (uri: 'package:flutter_falmodel/flutter_falmodel.dart', root: _workspace),
  (uri: 'package:flutter_falstore/flutter_falstore.dart', root: _workspace),
  (uri: 'package:flutter_faltool/flutter_faltool.dart', root: _workspace),
];

const List<LibraryRef> _targets = [
  (uri: 'dart:async', root: _workspace),
  (uri: 'dart:collection', root: _workspace),
  (uri: 'dart:convert', root: _workspace),
  (uri: 'dart:core', root: _workspace),
  (uri: 'dart:developer', root: _workspace),
  (uri: 'dart:ffi', root: _workspace),
  (uri: 'dart:io', root: _workspace),
  (uri: 'dart:isolate', root: _workspace),
  (uri: 'dart:js_interop', root: _workspace),
  (uri: 'dart:js_interop_unsafe', root: _workspace),
  (uri: 'dart:math', root: _workspace),
  (uri: 'dart:typed_data', root: _workspace),
  (uri: 'dart:ui', root: _workspace),
  (uri: 'package:flutter/cupertino.dart', root: _workspace),
  (uri: 'package:flutter/foundation.dart', root: _workspace),
  (uri: 'package:flutter/material.dart', root: _workspace),
  (uri: 'package:flutter/services.dart', root: _workspace),
];

/// Flutter owns these declarations; their collisions with `dart:` libraries,
/// such as the `Flow` widget against `dart:developer`, are Flutter's.
const _frameworkOwned = ['package:flutter/', 'dart:ui'];

const _retrofitHttpResponse =
    "Retrofit's HttpResponse; code that Retrofit generates for a method "
    'returning HttpResponse<T> needs it.';
const _convertCodec =
    "dart:convert's Codec; apps reach dart:ui's image Codec through "
    'instantiateImageCodec without naming it, and switching would break '
    'apps that name the encoding Codec.';
const _singlePackageName =
    'This single-package barrel imports no Flutter library; the '
    'flutter-falconx-package skill tells apps to hide the name when they '
    'import the barrel next to material.';

const Map<AllowlistKey, String> _allowlist = {
  (
    subject: 'package:flutter_falconx/flutter_falconx.dart',
    name: 'HttpResponse',
  ): _retrofitHttpResponse,
  (
    subject: 'package:flutter_falconnect/flutter_falconnect.dart',
    name: 'HttpResponse',
  ): _retrofitHttpResponse,
  (subject: 'package:flutter_falconx/flutter_falconx.dart', name: 'Codec'):
      _convertCodec,
  (subject: 'package:flutter_faltool/flutter_faltool.dart', name: 'Codec'):
      _convertCodec,
  (
    subject: 'package:flutter_faltool/flutter_faltool.dart',
    name: 'TextDirection',
  ): _singlePackageName,
  (subject: 'package:flutter_falconnect/flutter_falconnect.dart', name: 'Path'):
      _singlePackageName,
};

Future<void> main() async {
  exitCode = await runCheck(
    subjects: _subjects,
    targets: _targets,
    allowlist: _allowlist,
    frameworkOwned: _frameworkOwned,
  );
}
