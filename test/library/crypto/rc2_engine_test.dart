import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/src/CryptoUtils.dart';
import 'package:basic_utils/src/StringUtils.dart';
import 'package:basic_utils/src/library/crypto/rc2_engine.dart';
import 'package:basic_utils/src/library/crypto/rc2_parameters.dart';
import 'package:basic_utils/src/model/asn1/pkcs5s1_parameter_generator.dart';
import 'package:pointycastle/export.dart';

import 'package:test/test.dart';

void main() {
  test('test process()', () {
    var engine = RC2Engine();
    var actual = Uint8List(0);

    var params =
        RC2Parameters(StringUtils.hexToUint8List("0000000000000000"), bits: 63);
    var input = StringUtils.hexToUint8List("0000000000000000");
    var output = StringUtils.hexToUint8List("EBB773F993278EFF");

    engine.init(true, params);
    actual = engine.process(input);
    expect(actual, output);

    params =
        RC2Parameters(StringUtils.hexToUint8List("ffffffffffffffff"), bits: 64);
    input = StringUtils.hexToUint8List("ffffffffffffffff");
    output = StringUtils.hexToUint8List("278b27e42e2f0d49");

    engine.init(true, params);
    actual = engine.process(input);
    expect(actual, output);

    params =
        RC2Parameters(StringUtils.hexToUint8List("3000000000000000"), bits: 64);
    input = StringUtils.hexToUint8List("1000000000000001");
    output = StringUtils.hexToUint8List("30649edf9be7d2c2");

    engine.init(true, params);
    actual = engine.process(input);
    expect(actual, output);

    params = RC2Parameters(StringUtils.hexToUint8List("88"), bits: 64);
    input = StringUtils.hexToUint8List("0000000000000000");
    output = StringUtils.hexToUint8List("61a8a244adacccf0");

    engine.init(true, params);
    actual = engine.process(input);
    expect(actual, output);

    params =
        RC2Parameters(StringUtils.hexToUint8List("88bca90e90875a"), bits: 64);
    input = StringUtils.hexToUint8List("0000000000000000");
    output = StringUtils.hexToUint8List("6ccf4308974c267f");

    engine.init(true, params);
    actual = engine.process(input);
    expect(actual, output);

    params = RC2Parameters(
        StringUtils.hexToUint8List("88bca90e90875a7f0f79c384627bafb2"),
        bits: 64);
    input = StringUtils.hexToUint8List("0000000000000000");
    output = StringUtils.hexToUint8List("1a807d272bbe5db1");

    engine.init(true, params);
    actual = engine.process(input);
    expect(actual, output);

    params = RC2Parameters(
        StringUtils.hexToUint8List("88bca90e90875a7f0f79c384627bafb2"),
        bits: 128);
    input = StringUtils.hexToUint8List("0000000000000000");
    output = StringUtils.hexToUint8List("2269552ab0f85ca6");

    engine.init(true, params);
    actual = engine.process(input);
    expect(actual, output);

    params = RC2Parameters(
        StringUtils.hexToUint8List(
            "88bca90e90875a7f0f79c384627bafb216f80a6f85920584c42fceb0be255daf1e"),
        bits: 129);
    input = StringUtils.hexToUint8List("0000000000000000");
    output = StringUtils.hexToUint8List("5b78d3a43dfff1f1");

    engine.init(true, params);
    actual = engine.process(input);
    expect(actual, output);
  });

  test('test openssl rc2-40-cbc', () {
    // CMD = openssl enc -e -rc2-40-cbc -a -p -nosalt -iv c7d90059b29e97f7 -v
    // Password = test
    // Input = helloworld
    var engine = CBCBlockCipher(RC2Engine());
    engine.reset();

    var derivator = PKCS5S1ParameterGenerator(Digest('SHA-1'));
    var deriveParams = Pbkdf2Parameters(
        StringUtils.hexToUint8List('C7D90059B29E97F7'), 100000, 5);

    //derivator.init(deriveParams);
    //var d = derivator.process(Uint8List.fromList("test".codeUnits));
    //print(StringUtils.uint8ListToHex(d));
    //print("098F6BCD46");
    var params = ParametersWithIV(
      RC2Parameters(
        StringUtils.hexToUint8List("098F6BCD46"),
        bits: 40,
      ),
      StringUtils.hexToUint8List('C7D90059B29E97F7'),
    );
    var input = StringUtils.hexToUint8List('68656c6c6f776f726c64');
    var output = '3MN/S1ipU7V7lOHQGmGW6g==';

    engine.init(true, params);

    var padded = CryptoUtils.addPKCS7Padding(input, 8);
    final cipherText = Uint8List(padded.length);

    var offset = 0;
    while (offset < padded.length) {
      offset += engine.processBlock(padded, offset, cipherText, offset);
    }

    var out = base64.decode(output);
    expect(cipherText, out);
  });
}