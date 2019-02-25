import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_test/source_gen_test.dart';
import 'package:test/test.dart';

import '../annotations.dart';

List<ExpectationElement> genAnnotatedElements(
        LibraryReader libraryReader, List<String> shouldThrowDefaults) =>
    libraryReader.allElements
        .expand((e) => _expectationElements(e, shouldThrowDefaults))
        .toList();

Iterable<ExpectationElement> _expectationElements(
    Element element, List<String> shouldThrowDefaults) sync* {
  for (var expectation in const TypeChecker.fromRuntime(ShouldGenerate)
      .annotationsOfExact(element)
      .map(_shouldGenerate)) {
    yield ExpectationElement<ShouldGenerate>._(expectation, element.name);
  }
  for (var expectation in const TypeChecker.fromRuntime(ShouldThrow)
      .annotationsOfExact(element)
      .map((obj) => _shouldThrow(obj, shouldThrowDefaults))) {
    yield ExpectationElement<ShouldThrow>._(expectation, element.name);
  }
}

class ExpectationElement<T extends TestExpectation> {
  final T expectation;
  final String elementName;

  ExpectationElement._(this.expectation, this.elementName)
      : assert(expectation != null),
        assert(elementName != null);

  Matcher get matcher {
    var exp = expectation;
    if (exp is ShouldGenerate) {
      return exp.contains
          ? contains(exp.expectedOutput)
          : equals(exp.expectedOutput);
    } else if (exp is ShouldThrow) {
      final messageMatcher = exp.errorMessage;
      final todoMatcher = exp.todo ?? isEmpty;

      return throwsInvalidGenerationSourceError(messageMatcher, todoMatcher);
    }
    throw StateError('Should never get here...');
  }
}

ShouldGenerate _shouldGenerate(DartObject obj) {
  final reader = ConstantReader(obj);
  return ShouldGenerate(
    reader.read('expectedOutput').stringValue,
    contains: reader.read('contains').boolValue,
    expectedLogItems: reader
        .read('expectedLogItems')
        .listValue
        .map((obj) => obj.toStringValue())
        .toList(),
    configurations: _configurations(reader, const [defaultConfigurationName]),
  );
}

ShouldThrow _shouldThrow(DartObject obj, List<String> defaults) {
  final reader = ConstantReader(obj);
  return ShouldThrow(
    reader.read('errorMessage').stringValue,
    todo: reader.read('todo').literalValue as String,
    configurations: _configurations(reader, defaults),
  );
}

List<String> _configurations(ConstantReader reader, List<String> defaults) {
  final field = reader.read('configurations');
  if (field.isNull) {
    return defaults;
  }

  return field.listValue.map((obj) => obj.toStringValue()).toList();
}
