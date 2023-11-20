// Project import
import 'package:rdflib/rdflib.dart';

Map getFileContent(String fileInfo) {
  Graph g = Graph();
  g.parseTurtle(fileInfo);
  Map fileContentMap = {};
  List fileContentList = [];
  for (Triple t in g.triples) {
    /**
     * Use
     *  - t.sub -> Subject
     *  - t.pre -> Predicate
     *  - t.obj -> Object
     */
    String predicate = t.pre.value;
    if (predicate.contains('#')) {
      String subject = t.sub.value;
      String attributeName = predicate.split('#')[1];
      String attrVal = t.obj.value;
      if (attributeName != 'type') {
        fileContentList.add([subject, attributeName, attrVal]);
      }
      fileContentMap[attributeName] = [subject, attrVal];
    }
  }

  return fileContentMap;
}
