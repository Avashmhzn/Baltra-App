
import 'package:html/parser.dart';

List<String> extractSpecifications(String? htmlContent) {
  if (htmlContent == null || htmlContent.isEmpty) {
    return [];
  }

  // Parse the HTML content
  final document = parse(htmlContent);

  // Extract the text inside each <li> tag
  final List<String> specifications = [];
  document.querySelectorAll('li').forEach((element) {
    specifications.add(element.text);
  });

  return specifications;
}
