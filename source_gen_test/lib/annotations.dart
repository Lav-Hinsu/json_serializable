// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Non-public, implementation base class of  [ShouldGenerate] and
/// [ShouldThrow].
abstract class TestExpectation {
  final List<String> configurations;

  const TestExpectation._(this.configurations);
}

const defaultConfigurationName = 'default';

class ShouldGenerate extends TestExpectation {
  final String expectedOutput;
  final bool contains;
  final List<String> expectedLogItems;

  const ShouldGenerate(
    this.expectedOutput, {
    List<String> configurations,
    this.contains = false,
    this.expectedLogItems = const [],
  }) : super._(configurations);
}

class ShouldThrow extends TestExpectation {
  final String errorMessage;
  final String todo;

  const ShouldThrow(
    this.errorMessage, {
    this.todo,
    List<String> configurations,
  }) : super._(configurations);
}
