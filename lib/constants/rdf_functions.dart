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

class AclResource {
  String aclResStr = '';

  AclResource(String aclResStr) {
    this.aclResStr = aclResStr;
  }

  // ignore: long-method
  List divideAclData() {
    Map<String, String> userNameMap = {};
    Map<String, List> userPermMap = {};

    RegExp prefixRegExp = new RegExp(
      r"@prefix ([a-zA-Z0-9: <>#].*)",
      caseSensitive: false,
      multiLine: false,
    );

    RegExp accessGroupRegExp = new RegExp(
      r"(?<=^:[a-zA-Z]+\n)(?:^\s+.*;$\n)*(?:^\s+.*\.\n?)",
      caseSensitive: false,
      multiLine: true,
    );

    Iterable<RegExpMatch> accessGroupList =
        accessGroupRegExp.allMatches(aclResStr);
    Iterable<RegExpMatch> prefixList = prefixRegExp.allMatches(aclResStr);

    for (final prefixItem in prefixList) {
      String prefixLine = prefixItem[0].toString();
      if (prefixLine.contains('/card#>')) {
        var itemList = prefixLine.split(' ');
        userNameMap[itemList[1]] =
            itemList[2].substring(0, itemList[2].length - 1);
      }
    }

    for (final accessGroup in accessGroupList) {
      String accessGroupStr = accessGroup[0].toString();

      RegExp accessRegExp = new RegExp(
        r"acl:access[T|t]o (?<resource><[a-zA-Z0-9_-]*.[a-z]*>)",
        caseSensitive: false,
        multiLine: false,
      );

      RegExp modeRegExp = new RegExp(
        r"acl:mode ([^.]*)",
        caseSensitive: false,
        multiLine: false,
      );

      RegExp agentRegExp = new RegExp(
        r"acl:agent[a-zA-Z]*? ([^;]*);",
        caseSensitive: false,
        multiLine: false,
      );

      Iterable<RegExpMatch> accessPers = agentRegExp.allMatches(accessGroupStr);
      Iterable<RegExpMatch> accessRes = accessRegExp.allMatches(accessGroupStr);
      Iterable<RegExpMatch> accessModes = modeRegExp.allMatches(accessGroupStr);

      for (final accessModesItem in accessModes) {
        List accessList = accessModesItem[1].toString().split(',');
        List accessItemList = [];
        Set accessItemSet = {};
        for (String accessItem in accessList) {
          accessItemList.add(accessItem.replaceAll('acl:', '').trim());
          accessItemSet.add((accessItem).trim());
        }
        accessItemList.sort();
        String accessStr = accessItemList.join('');

        Set accessResItemSet = {};
        for (final accessResItem in accessRes) {
          List accessResList = accessResItem[1].toString().split(',');
          for (String accessItem in accessResList) {
            accessResItemSet.add(accessItem.trim());
          }
        }

        Set accessPersItemSet = {};
        for (final accessPersItem in accessPers) {
          List accessPersList = accessPersItem[1].toString().split(',');
          for (String accessItem in accessPersList) {
            accessPersItemSet.add(accessItem.replaceAll('me', '').trim());
          }
        }
        userPermMap[accessStr] = [
          accessResItemSet,
          accessPersItemSet,
          accessItemSet,
        ];
      }
    }

    return [userNameMap, userPermMap];
  }

  List<List<String>> divideRdfData(String aclResStr) {
    List<String> rdfDataList = [];

    var aclDataList = aclResStr.split('\n');

    for (var i = 0; i < aclDataList.length; i++) {
      String dataItem = aclDataList[i];
      if (dataItem.contains(';')) {
        var itemList = dataItem.split(';');
        for (var j = 0; j < itemList.length; j++) {
          String item = itemList[j];
          rdfDataList.add(item);
        }
      } else {
        rdfDataList.add(dataItem);
      }
    }

    return [rdfDataList];
  }
}
