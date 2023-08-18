import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FireBasePage {
  //북마크 업데이트 함수
  Future<String?> deleteBookmarkInBookmarkPage(String keyword, String Link) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('bookmarks')
        .where("userID", isEqualTo: userID)
        .where("link", isEqualTo: Link)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(snapshot.docs[0].id)
          .delete();
    }

  }

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

 //북마크 업데이트 함수
  Future<String?> updateBookmark(String keyword, dynamic searchResult, bool isAdd) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot? existingBookmark;
    var image = searchResult['pagemap']['cse_thumbnail'];
    // 북마크가 이미 있는지 확인
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('bookmarks')
        .where("userID", isEqualTo: userID)
        .where("link", isEqualTo: searchResult['link'])
        .limit(1)
        .get();

    for (var document in result.docs) {
      existingBookmark = document;
    }

    if (isAdd && existingBookmark == null) {
      // 북마크 추가
      try {
        DocumentReference addedBookmark = await FirebaseFirestore.instance.collection('bookmarks').add({
          'userID': userID,
          'keyword': keyword,
          'cse_thumbnail': image[0]['src'],
          'displayLink': searchResult['displayLink'],
          'title': searchResult['title'],
          'snippet': searchResult['snippet'],
          'link': searchResult['link'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        return addedBookmark.id;
      } catch (e) {
        print('Error saving bookmark to Firebase: $e');
        return null;
      }
    } else if (!isAdd && existingBookmark != null) {
      // 북마크 삭제
      try {
        await FirebaseFirestore.instance.collection('bookmarks').doc(existingBookmark.id).delete();
        return null;
      } catch (e) {
        print('Error deleting bookmark from Firebase: $e');
        return null;
      }
    }
    return null;
  }

  // 사용자 ID로 북마크된 항목을 모두 가져오는 메서드
  Future<List<Map<String, dynamic>>> getUserBookmarks() async {
    String? userID = await FirebaseAuth.instance.currentUser?.uid;
    print(userID);
    List<Map<String, dynamic>> bookmarks = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bookmarks')
          .where('userID', isEqualTo: userID)
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // 데이터를 명시적으로 Map<String, dynamic>으로 변환합니다.
        bookmarks.add(data); // 수정된 데이터를 북마크 목록에 추가합니다.
      }
      print(bookmarks);
    } catch (e) {
      print('Error fetching all bookmarks: $e');
    }

    return bookmarks;
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

  Future<void> saveHistoryToFirebase(String keyword, List<Map<String, dynamic>> searchResults) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    // 결과 목록을 반복하면서 각 결과에 대해 Firestore에 저장합니다.
    for (final searchResult in searchResults) {
      final displayLink = searchResult['displayLink'];

      var cseThumbnail = searchResult['pagemap']['cse_thumbnail'];
      final title = searchResult['title'];
      final snippet = searchResult['snippet'];
      final link = searchResult['link'];

      try {
        await FirebaseFirestore.instance.collection('search_history').add({
          'userID': userID,
          'keyword': keyword,
          'cse_thumbnail': cseThumbnail[0]['src'],
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





}