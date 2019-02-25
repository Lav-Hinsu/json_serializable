// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_gen/source_gen.dart';
import 'package:source_gen_test/source_gen_test.dart';
import 'package:test/test.dart';

import '../annotations.dart';
import 'build_log_tracking.dart';
import 'expectation_element.dart';
import 'generate_for_element.dart';

/// If [shouldThrowDefaults] is not provided or `null`, the keys from
/// [generators] are used.
///
/// Tests registered by this function assume [initializeBuildLogTracking] has
/// been called.
///
/// If [expectedAnnotatedTests] is provided, it should contain the names of the
/// members in [libraryReader] that are annotated for testing. If the same
/// element is annotated for multiple tests, it should appear in the list
/// the same number of times.
void testAnnotatedClasses(
  LibraryReader libraryReader,
  Map<String, GeneratorForAnnotation> generators, {
  Iterable<String> expectedAnnotatedTests,
  List<String> shouldThrowDefaults,
}) {
  // TODO: test shouldThrowDefaults empty (should throw)
  // TODO: test shouldThrowDefaults contains values != generators (should throw)

  shouldThrowDefaults ??= generators.keys.toList();
  final annotatedElements =
      genAnnotatedElements(libraryReader, shouldThrowDefaults);

  if (expectedAnnotatedTests != null) {
    test('[Found all expected test elements]', () {
      final expectedList = expectedAnnotatedTests.toList();

      final missing = <String>[];

      for (var elementName in annotatedElements.map((e) => e.elementName)) {
        if (!expectedList.remove(elementName)) {
          missing.add(elementName);
        }
      }

      expect(expectedList, isEmpty,
          reason: 'There are unknown items in `expectedAnnotatedTests`.');
      expect(missing, isEmpty,
          reason: 'There are items missing in `expectedAnnotatedTests`.');
    });
  }

  for (final entry in annotatedElements) {
    _testAnnotatedClass(libraryReader, entry, generators);
  }
}

void _testAnnotatedClass(
  LibraryReader libraryReader,
  ExpectationElement annotatedElement,
  Map<String, GeneratorForAnnotation> generators,
) {
  if (annotatedElement.expectation is ShouldThrow) {
    _testShouldThrow(libraryReader,
        annotatedElement as ExpectationElement<ShouldThrow>, generators);
  } else if (annotatedElement.expectation is ShouldGenerate) {
    _testShouldGenerate(libraryReader,
        annotatedElement as ExpectationElement<ShouldGenerate>, generators);
  } else {
    throw UnsupportedError('Should never get here!');
  }
}

void _testShouldThrow(
  LibraryReader _library,
  ExpectationElement<ShouldThrow> annotatedElement,
  Map<String, GeneratorForAnnotation> generators,
) {
  final elementName = annotatedElement.elementName;

  for (var configuration in annotatedElement.expectation.configurations) {
    var generator = generators[configuration];

    if (generator == null) {
      test('unsupported - $configuration', () {
        fail('`$configuration` is not supported');
      });
      return;
    }

    var testName = elementName;

    if (configuration != defaultConfigurationName) {
      testName += ' ($configuration)';
    }

    test(testName, () {
      expect(() => generateForElement(generator, _library, elementName),
          annotatedElement.matcher);
    });
  }
}

void _testShouldGenerate(
  LibraryReader libraryReader,
  ExpectationElement<ShouldGenerate> annotatedElement,
  Map<String, GeneratorForAnnotation> generators,
) {
  final elementName = annotatedElement.elementName;

  final expectedLogItems = annotatedElement.expectation.expectedLogItems;

  for (var configuration in annotatedElement.expectation.configurations) {
    var generator = generators[configuration];

    if (generator == null) {
      test('unsupported - $configuration', () {
        fail('`$configuration` is not supported');
      });
      return;
    }

    var testName = elementName;

    if (configuration != defaultConfigurationName) {
      testName += ' ($configuration)';
    }

    test(testName, () {
      final output = generateForElement(generator, libraryReader, elementName);

      try {
        expect(output, annotatedElement.matcher);
      } on TestFailure {
        printOnFailure("ACTUAL CONTENT:\nr'''\n$output'''");
        rethrow;
      }

      expect(buildLogItems, expectedLogItems);
      clearBuildLog();
    });
  }
}
