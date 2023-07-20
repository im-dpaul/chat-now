import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(
      methodCount: 0, errorMethodCount: 10, colors: true, printEmojis: true, printTime: true, lineLength: 113),
      output: ConsoleOutput(),
);

final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];