import 'dart:io';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

const String name = 'rougish';
final Directory docDir = Directory('doc');

void main(List<String> args) => grind(args);

@DefaultTask('lists tasks')
void usage() {
  log('grind ${context.grinder.tasks}');
}

@Task('lists TODOs')
void todo() {
  const token = 'TODO';
  if (Platform.isWindows) {
    run('findstr', arguments: ['/s', '/n', '\\/\\/${token}:', '*.dart']);
  } else {
    run('grep', arguments: ['//${token}:', '--recursive', '--line-number', '--include', '\\*.dart']);
  }
}

@Task('lists FIXMEs')
void fixme() {
  const token = 'FIXME';
  if (Platform.isWindows) {
    run('findstr', arguments: ['/s', '/n', '\\/\\/${token}:', '*.dart']);
  } else {
    run('grep', arguments: ['//${token}:', '--recursive', '--line-number', '--include', '\\*.dart']);
  }
}

@Task('formats code')
void format() {
  // DartFmt.format(existingSourceDirs, lineLength: 100);
  //   grind 0.9 is using deprecated dartfmt tool, needs to switch to dart format
  //   https://github.com/dart-lang/dart_style/issues/986
  run('dart', arguments: ['format', '--line-length', '100', '--fix', '--output', 'write', '.']);
}

@Task('analyzes code')
void analyze() {
  //Analyzer.analyze(existingSourceDirs, fatalWarnings: true);
  //  regular dart command has better defaults and output formatting
  run('dart', arguments: ['analyze']);
}

@Task('runs tests')
void test() {
  //TestRunner().test();
  //  grind-provided impl doesn't support randomization
  run('dart',
      arguments: ['test', '--test-randomize-ordering-seed=random', '--reporter', 'expanded']);
}

@Task('deletes build artifacts')
void clean() {
  log('running default clean..');
  defaultClean();
}

@Task('compiles executable')
@Depends(clean)
void compile() {
  String ext = Platform.isWindows ? '.exe' : '';
  String inPath = path.join(binDir.path, '${name}.dart');
  String outPath = path.join(binDir.path, '${name}${ext}');
  run('dart', arguments: ['compile', 'exe', '--output', outPath, inPath]);

  String prompt = Platform.isWindows ? '>' : '\$';
  print('\nto run the new binary:\n${prompt} ${outPath}');
}

@Task('generates api docs')
void document() {
  delete(docDir);
  run('dart', arguments: ['doc', '--validate-links', '.']);
}

@Task('prepares a release candidate')
@Depends(format, analyze, test, compile, document)
void build() {
  log('did all the things!');
}
