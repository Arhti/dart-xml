/// XML pretty printer and highlighter.
library xml.example.xml_pp;

import 'dart:io';

import 'package:args/args.dart' as args;
import 'package:xml/xml.dart' as xml;

const entityMapping = xml.XmlDefaultEntityMapping.xml();

const String ansiReset = '\u001b[0m';
const String ansiRed = '\u001b[31m';
const String ansiGreen = '\u001b[32m';
const String ansiYellow = '\u001b[33m';
const String ansiBlue = '\u001b[34m';
const String ansiMagenta = '\u001b[35m';
const String ansiCyan = '\u001b[36m';

const String attributeStyle = ansiBlue;
const String cdataStyle = ansiYellow;
const String commentStyle = ansiGreen;
const String declarationStyle = ansiCyan;
const String doctypeStyle = ansiCyan;
const String documentStyle = ansiReset;
const String documentFragmentStyle = ansiCyan;
const String elementStyle = ansiMagenta;
const String nameStyle = ansiRed;
const String processingStyle = ansiCyan;
const String textStyle = ansiReset;

final args.ArgParser argumentParser = args.ArgParser()
  ..addFlag(
    'color',
    abbr: 'c',
    help: 'Colorizes the output.',
    defaultsTo: stdout.supportsAnsiEscapes,
  )
  ..addOption(
    'indent',
    abbr: 'i',
    help: 'Customizes the indention when pretty printing.',
    defaultsTo: '  ',
  )
  ..addOption(
    'newline',
    abbr: 'n',
    help: 'Changes the newline character when pretty printing.',
    defaultsTo: '\n',
  )
  ..addFlag(
    'pretty',
    abbr: 'p',
    help: 'Reformats the output to be pretty.',
    defaultsTo: true,
  );

void printUsage() {
  stdout.writeln('Usage: xml_pp [options] {files}');
  stdout.writeln();
  stdout.writeln(argumentParser.usage);
  exit(1);
}

void main(List<String> arguments) {
  final files = <File>[];
  final results = argumentParser.parse(arguments);
  final color = results['color'];
  final indent = results['indent'];
  final newLine = results['newline'];
  final pretty = results['pretty'];

  for (final argument in results.rest) {
    final file = File(argument);
    if (file.existsSync()) {
      files.add(file);
    } else {
      stderr.writeln('File not found: $file');
      exit(2);
    }
  }
  if (files.isEmpty) {
    printUsage();
  }

  // Select the appropriate printing visitor. For simpler use-cases one would
  // just call `document.toXmlString(pretty: true, indent: '  ')`.
  final visitor = pretty
      ? (color
          ? XmlColoredPrettyWriter(stdout,
              entityMapping: entityMapping, indent: indent, newLine: newLine)
          : xml.XmlPrettyWriter(stdout,
              entityMapping: entityMapping, indent: indent, newLine: newLine))
      : (color
          ? XmlColoredWriter(stdout, entityMapping: entityMapping)
          : xml.XmlWriter(stdout, entityMapping: entityMapping));
  for (final file in files) {
    visitor.visit(xml.parse(file.readAsStringSync()));
  }
}

mixin ColoredWriter {
  StringSink get buffer;

  List<String> get styles;

  void style(String style, void Function() callback) {
    styles.add(style);
    buffer.write(style);
    callback();
    styles.removeLast();
    buffer.write(styles.isEmpty ? ansiReset : styles.last);
  }
}

class XmlColoredWriter extends xml.XmlWriter with ColoredWriter {
  XmlColoredWriter(StringSink buffer, {xml.XmlEntityMapping entityMapping})
      : super(buffer, entityMapping: entityMapping);

  @override
  final List<String> styles = [];

  @override
  void visitAttribute(xml.XmlAttribute node) =>
      style(attributeStyle, () => super.visitAttribute(node));

  @override
  void visitCDATA(xml.XmlCDATA node) =>
      style(cdataStyle, () => super.visitCDATA(node));

  @override
  void visitComment(xml.XmlComment node) =>
      style(commentStyle, () => super.visitComment(node));

  @override
  void visitDeclaration(xml.XmlDeclaration node) =>
      style(declarationStyle, () => super.visitDeclaration(node));

  @override
  void visitDocument(xml.XmlDocument node) =>
      style(documentStyle, () => super.visitDocument(node));

  @override
  void visitDocumentFragment(xml.XmlDocumentFragment node) =>
      style(documentFragmentStyle, () => super.visitDocumentFragment(node));

  @override
  void visitDoctype(xml.XmlDoctype node) =>
      style(doctypeStyle, () => super.visitDoctype(node));

  @override
  void visitElement(xml.XmlElement node) =>
      style(elementStyle, () => super.visitElement(node));

  @override
  void visitName(xml.XmlName name) =>
      style(nameStyle, () => super.visitName(name));

  @override
  void visitProcessing(xml.XmlProcessing node) =>
      style(processingStyle, () => super.visitProcessing(node));

  @override
  void visitText(xml.XmlText node) =>
      style(textStyle, () => super.visitText(node));
}

class XmlColoredPrettyWriter extends xml.XmlPrettyWriter with ColoredWriter {
  XmlColoredPrettyWriter(StringSink buffer,
      {xml.XmlEntityMapping entityMapping, String indent, String newLine})
      : super(buffer,
            entityMapping: entityMapping, indent: indent, newLine: newLine);
  @override
  final List<String> styles = [];

  @override
  void visitAttribute(xml.XmlAttribute node) =>
      style(attributeStyle, () => super.visitAttribute(node));

  @override
  void visitCDATA(xml.XmlCDATA node) =>
      style(cdataStyle, () => super.visitCDATA(node));

  @override
  void visitComment(xml.XmlComment node) =>
      style(commentStyle, () => super.visitComment(node));

  @override
  void visitDeclaration(xml.XmlDeclaration node) =>
      style(declarationStyle, () => super.visitDeclaration(node));

  @override
  void visitDocument(xml.XmlDocument node) =>
      style(documentStyle, () => super.visitDocument(node));

  @override
  void visitDocumentFragment(xml.XmlDocumentFragment node) =>
      style(documentFragmentStyle, () => super.visitDocumentFragment(node));

  @override
  void visitDoctype(xml.XmlDoctype node) =>
      style(doctypeStyle, () => super.visitDoctype(node));

  @override
  void visitElement(xml.XmlElement node) =>
      style(elementStyle, () => super.visitElement(node));

  @override
  void visitName(xml.XmlName name) =>
      style(nameStyle, () => super.visitName(name));

  @override
  void visitProcessing(xml.XmlProcessing node) =>
      style(processingStyle, () => super.visitProcessing(node));

  @override
  void visitText(xml.XmlText node) =>
      style(textStyle, () => super.visitText(node));
}
