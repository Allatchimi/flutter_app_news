import 'package:xml/xml.dart' as xml;

extension XmlIterableExtension on Iterable<xml.XmlElement> {
  xml.XmlElement? get firstOrNull => isEmpty ? null : first;
}
