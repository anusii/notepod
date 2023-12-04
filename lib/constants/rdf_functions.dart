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

Map getEncFileContent(String fileInfo) {
  Graph g = Graph();
  g.parseTurtle(fileInfo);
  Map fileContentMap = {};

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
      String fileName = subject.split('#')[1];
      String attributeName = predicate.split('#')[1];
      String attrVal = t.obj.value;
      if (attributeName != 'type') {
        if (fileContentMap.containsKey(fileName)) {
          fileContentMap[fileName][attributeName] = attrVal;
        } else {
          fileContentMap[fileName] = {attributeName: attrVal};
        }
      }
    }
  }

  return fileContentMap;
}

class PodProfile {
  String profileRdfStr = '';

  PodProfile(String profileRdfStr) {
    this.profileRdfStr = profileRdfStr;
  }

  // the method is for the new yarrabah server
  List divideFolderData() {
    List<String> rdfDataList = [];
    final Map prefixList = {};

    var profileDataList = profileRdfStr.split('\n');
    for (var i = 0; i < profileDataList.length; i++) {
      String dataItem = profileDataList[i];
      if (dataItem.contains('ldp:contains')) {
        var itemList = dataItem
            .replaceAll(new RegExp(r'[.</>]'), '')
            .replaceAll(' ', '')
            .replaceAll('ldp:contains', '')
            .split(',');
        rdfDataList = itemList;
      }
    }
    rdfDataList.remove('gurriny');

    return [rdfDataList, prefixList];
  }

  List dividePrvRdfData() {
    List<String> rdfDataList = [];
    final Map prefixList = {};

    var profileDataList = profileRdfStr.split('\n');
    for (var i = 0; i < profileDataList.length; i++) {
      String dataItem = profileDataList[i];
      if (dataItem.contains(';')) {
        var itemList = dataItem.split(';');
        for (var j = 0; j < itemList.length; j++) {
          String item = itemList[j];
          rdfDataList.add(item);
        }
      } else {
        rdfDataList.add(dataItem);
      }

      if (dataItem.contains('@prefix')) {
        var itemList = dataItem.split(' ');
        prefixList[itemList[1]] = itemList[2];
      }

      // if (dataItem.contains('<http://www.w3.org/ns/ldp#>')) {
      //   var itemList = dataItem.split(' ');
      //   prefixList['ldPlatform'] = itemList[1];
      // }

      // if (dataItem.contains('<http://www.w3.org/ns/posix/stat#>')) {
      //   var itemList = dataItem.split(' ');
      //   prefixList['stat'] = itemList[1];
      // }

      // if (dataItem.contains('<http://www.w3.org/2001/XMLSchema#>')) {
      //   var itemList = dataItem.split(' ');
      //   prefixList['xmlSchema'] = itemList[1];
      // }

      // if (dataItem.contains('<>')) {
      //   var itemList = dataItem.split(' ');
      //   prefixList['prv'] = itemList[1];
      // }
    }

    return [rdfDataList, prefixList];
  }

  List divideRdfData(String profileRdfStr) {
    List<String> rdfDataList = [];
    String vcardPrefix = '';
    String foafPrefix = '';

    var profileDataList = profileRdfStr.split('\n');
    for (var i = 0; i < profileDataList.length; i++) {
      String dataItem = profileDataList[i];
      if (dataItem.contains(';')) {
        var itemList = dataItem.split(';');
        for (var j = 0; j < itemList.length; j++) {
          String item = itemList[j];
          rdfDataList.add(item);
        }
      } else {
        rdfDataList.add(dataItem);
      }

      if (dataItem.contains('<http://www.w3.org/2006/vcard/ns#>')) {
        var itemList = dataItem.split(' ');
        vcardPrefix = itemList[1];
      }

      if (dataItem.contains('<http://xmlns.com/foaf/0.1/>')) {
        var itemList = dataItem.split(' ');
        foafPrefix = itemList[1];
      }
    }

    return [rdfDataList, vcardPrefix, foafPrefix];
  }

  String getAddressId(String infoLabel) {
    String personalInfo = '';
    var rdfRes = divideRdfData(profileRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String vcardPrefix = rdfRes[1];
    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(vcardPrefix + infoLabel)) {
        var itemList = dataItem.split(':');
        personalInfo = itemList[2];
      }
    }

    return personalInfo;
  }

  String getEncKeyHash() {
    String encKeyHash = '';

    if (profileRdfStr.contains('@prefix')) {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('sh-data:encKey')) {
          var itemList = dataItem.trim().split(' ');
          encKeyHash = itemList[1].trim().split('"')[1];
        }
      }
    } else {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('http://yarrabah.net/predicates/terms#encKey')) {
          var itemList = dataItem.trim().split(' ');
          encKeyHash = itemList[1].trim().split('"')[1];
        }
      }
    }

    return encKeyHash;
  }

  String getPersonalInfo(String infoLabel) {
    String personalInfo = '';
    var rdfRes = divideRdfData(profileRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String vcardPrefix = rdfRes[1];
    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(vcardPrefix + infoLabel)) {
        var itemList = dataItem.split('"');
        personalInfo = itemList[1];
      }
    }

    return personalInfo;
  }

  String getProfName() {
    String profName = '';
    var rdfRes = divideRdfData(profileRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String vcardPrefix = rdfRes[1];
    //String foafPrefix = rdfRes[2];
    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(vcardPrefix + 'fn')) {
        var itemList = dataItem.split('"');
        profName = itemList.length > 0 ? itemList[1] : itemList.first;
      }
      // else if (dataItem.contains(foafPrefix+'name')) {
      //   var itemList = dataItem.split('"');
      //   profName = itemList[1];
      // }
    }
    if (profName.isEmpty) {
      profName = 'John-Doe';
    }

    return profName;
  }

  String getProfPicture() {
    var rdfRes = divideRdfData(profileRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String vcardPrefix = rdfRes[1];
    String foafPrefix = rdfRes[2];
    String pictureUrl = '';
    String optionalPictureUrl = '';
    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(vcardPrefix + 'hasPhoto')) {
        var itemList = dataItem.split('<');
        pictureUrl = itemList[1].replaceAll('>', '');
      }
      if (dataItem.contains(foafPrefix + 'img')) {
        var itemList = dataItem.split('<');
        optionalPictureUrl = itemList[1].replaceAll('>', '');
      }
    }
    if (pictureUrl.isEmpty & optionalPictureUrl.isNotEmpty) {
      pictureUrl = optionalPictureUrl;
    }

    return pictureUrl;
  }
}
