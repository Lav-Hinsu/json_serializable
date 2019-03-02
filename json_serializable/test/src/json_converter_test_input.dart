// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '_json_serializable_test_input.dart';

@ShouldGenerate(
  r'''
JsonConverterNamedCtor<E> _$JsonConverterNamedCtorFromJson<E>(
    Map<String, dynamic> json) {
  return JsonConverterNamedCtor<E>()
    ..value = json['value'] == null
        ? null
        : const _DurationMillisecondConverter.named()
            .fromJson(json['value'] as int)
    ..genericValue = json['genericValue'] == null
        ? null
        : _GenericConverter<E>.named().fromJson(json['genericValue'] as int)
    ..keyAnnotationFirst = json['keyAnnotationFirst'] == null
        ? null
        : JsonConverterNamedCtor._fromJson(json['keyAnnotationFirst'] as int);
}

Map<String, dynamic> _$JsonConverterNamedCtorToJson<E>(
        JsonConverterNamedCtor<E> instance) =>
    <String, dynamic>{
      'value': instance.value == null
          ? null
          : const _DurationMillisecondConverter.named().toJson(instance.value),
      'genericValue': instance.genericValue == null
          ? null
          : _GenericConverter<E>.named().toJson(instance.genericValue),
      'keyAnnotationFirst': instance.keyAnnotationFirst == null
          ? null
          : JsonConverterNamedCtor._toJson(instance.keyAnnotationFirst)
    };
''',
  configurations: ['default'],
)
@JsonSerializable()
@_DurationMillisecondConverter.named()
@_GenericConverter.named()
class JsonConverterNamedCtor<E> {
  Duration value;
  E genericValue;

  // Field annotations have precedence over class annotations
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  Duration keyAnnotationFirst;

  static Duration _fromJson(int value) => null;

  static int _toJson(Duration object) => 42;
}

@ShouldGenerate(
  r'''
JsonConvertOnField<E> _$JsonConvertOnFieldFromJson<E>(
    Map<String, dynamic> json) {
  return JsonConvertOnField<E>()
    ..annotatedField = json['annotatedField'] == null
        ? null
        : const _DurationMillisecondConverter()
            .fromJson(json['annotatedField'] as int)
    ..annotatedWithNamedCtor = json['annotatedWithNamedCtor'] == null
        ? null
        : const _DurationMillisecondConverter.named()
            .fromJson(json['annotatedWithNamedCtor'] as int)
    ..classAnnotatedWithField = json['classAnnotatedWithField'] == null
        ? null
        : _durationConverter.fromJson(json['classAnnotatedWithField'] as int)
    ..genericValue = json['genericValue'] == null
        ? null
        : _GenericConverter<E>().fromJson(json['genericValue'] as int);
}

Map<String, dynamic> _$JsonConvertOnFieldToJson<E>(
        JsonConvertOnField<E> instance) =>
    <String, dynamic>{
      'annotatedField': instance.annotatedField == null
          ? null
          : const _DurationMillisecondConverter()
              .toJson(instance.annotatedField),
      'annotatedWithNamedCtor': instance.annotatedWithNamedCtor == null
          ? null
          : const _DurationMillisecondConverter.named()
              .toJson(instance.annotatedWithNamedCtor),
      'classAnnotatedWithField': instance.classAnnotatedWithField == null
          ? null
          : _durationConverter.toJson(instance.classAnnotatedWithField),
      'genericValue': instance.genericValue == null
          ? null
          : _GenericConverter<E>().toJson(instance.genericValue)
    };
''',
  configurations: ['default'],
)
@JsonSerializable()
@_durationConverter
class JsonConvertOnField<E> {
  @_DurationMillisecondConverter()
  Duration annotatedField;

  @_DurationMillisecondConverter.named()
  Duration annotatedWithNamedCtor;

  Duration classAnnotatedWithField;

  @_GenericConverter()
  E genericValue;
}

class _GenericConverter<T> implements JsonConverter<T, int> {
  const _GenericConverter();

  const _GenericConverter.named();

  @override
  T fromJson(int json) => null;

  @override
  int toJson(T object) => 0;
}

@ShouldThrow('`JsonConverter` implementations can have no more than one type '
    'argument. `_BadConverter` has 2.')
@JsonSerializable()
@_BadConverter()
class JsonConverterWithBadTypeArg<T> {
  T value;
}

class _BadConverter<T, S> implements JsonConverter<S, int> {
  const _BadConverter();

  @override
  S fromJson(int json) => null;

  @override
  int toJson(S object) => 0;
}

@ShouldThrow('Found more than one matching converter for `Duration`.')
@JsonSerializable()
@_durationConverter
@_DurationMillisecondConverter()
class JsonConverterDuplicateAnnotations {
  Duration value;
}

const _durationConverter = _DurationMillisecondConverter();

class _DurationMillisecondConverter implements JsonConverter<Duration, int> {
  const _DurationMillisecondConverter();

  const _DurationMillisecondConverter.named();

  @override
  Duration fromJson(int json) =>
      json == null ? null : Duration(milliseconds: json);

  @override
  int toJson(Duration object) => object?.inMilliseconds;
}

@ShouldThrow('Generators with constructor arguments are not supported.')
@JsonSerializable()
@_ConverterWithCtorParams(42)
class JsonConverterCtorParams {
  Duration value;
}

class _ConverterWithCtorParams implements JsonConverter<Duration, int> {
  final int param;

  const _ConverterWithCtorParams(this.param);

  @override
  Duration fromJson(int json) => null;

  @override
  int toJson(Duration object) => 0;
}
