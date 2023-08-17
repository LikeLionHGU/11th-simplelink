import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FireBasePage {

  //검색 세션 페이지 정보
  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    final result = await FirebaseFirestore.instance
        .collection('search_history')
        .where('userID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .get();

    print('User\'s search history: ${result.docs}');
    List<Map<String, dynamic>> searchHistory = [];
    for (var doc in result.docs) {
      searchHistory.add(doc.data() as Map<String, dynamic>);
    }

    return searchHistory;
  }




  // 유저별로 키워드 저장
  Future<void> saveKeywordAndUserIDToFirebase(String keyword) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('keywords').add({
        'userID': userID,
        'keyword': keyword,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving keyword and userID to Firebase: $e');
    }
  }

  Future<void> saveHistoryToFirebase(String keyword, dynamic searchResult) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final cseThumbnail = searchResult['pagemap']['cse_thumbnail'];
    final displayLink = searchResult['displayLink'];
    final title = searchResult['title'];
    final snippet = searchResult['snippet'];
    final link = searchResult['link'];

    try {
      await FirebaseFirestore.instance.collection('keywords').add({
        'userID': userID,
        'keyword': keyword,
        'cse_thumbnail': cseThumbnail,
        'display_link': displayLink,
        'title': title,
        'snippet': snippet,
        'link': link,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving keyword and userID to Firebase: $e');
    }
  }


  //유저별로 키워드 5개 가져오기
  Future<List<String>> getTop5KeywordsByUserID() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    List<String> result = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('keywords')
          .where('userID', isEqualTo: userID)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      for (var doc in querySnapshot.docs) {
        result.add(doc['keyword']);
      }
    } catch (e) {
      print('Error fetching top 5 keywords: $e');
    }

    return result;
  }

  //유저별로 키워드 전부 가져오기
  Future<List<String>> getAllKeywordsByUserID() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    List<String> result = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('keywords')
          .where('userID', isEqualTo: userID)
          .orderBy('createdAt', descending: true)
          .get();

      for (var doc in querySnapshot.docs) {
        result.add(doc['keyword']);

      }
      print(result);
    } catch (e) {
      print('Error fetching all keywords: $e');
    }

    return result;
  }

  Future<void> saveToFirebase(
      String keyword,
      List<Map<String, dynamic>> searchResults,
      ) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('search_history').add({
        'userID': userID,
        'keyword': keyword,
        'searchResults': searchResults,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving to Firebase: $e');
    }
  }



}