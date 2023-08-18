import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_search_api/src/app/page/googleSearch/firebase.dart';
import 'package:google_search_api/src/app/page/googleSearch/googleSearch.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final FireBasePage firebase = FireBasePage();

  List<bool> _bookmarked = []; // 북마크 상태 리스트 생성
  late Future<List<Map<String, dynamic>>> _bookmarks;
  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  void initState() {
    super.initState();

    _bookmarks = firebase.getUserBookmarks(); // userId 전달
    print(_bookmarks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff0067C0),
        title: const Text(
          "저장된 링크",
          style: TextStyle(
            fontFamily: "SF Pro",
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 17 / 14,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookmarks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는데 실패했습니다.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length, // 아이템 개수는 북마크에 종속됩니다.
              itemBuilder: (BuildContext context, int index) {
                // 파이어베이스에서 받아온 데이터를 사용합니다.
                String title = snapshot.data![index]['title'];
                String keyword = snapshot.data![index]['keyword'];
                String? displayLink = snapshot.data![index]['displayLink'];
                String snippet = snapshot.data![index]['snippet'];
                String link = snapshot.data![index]['link'];
                String? cseThumbnail = snapshot.data![index]['cse_thumbnail'];
                return Container(
                  margin: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                  // margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // 배경색 없애기
                    border:
                        Border.all(color: Colors.grey.shade300), // 테두리 회색으로 변경
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      launchURL(link);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    cseThumbnail != null
                                        ? Image.network(
                                            cseThumbnail,
                                            width: 16,
                                            height: 16,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.public, size: 16),
                                    const SizedBox(width: 5),
                                    Text(
                                      displayLink ?? "",
                                      style: const TextStyle(
                                        fontFamily: "SF Pro",
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff333333),
                                        height: 12 / 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontFamily: "SF Pro",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff000000),
                                    height: 14 / 12,
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  snippet,
                                  style: const TextStyle(
                                    fontFamily: "SF Pro",
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff888888),
                                    height: 1,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (cseThumbnail != null) const SizedBox(width: 5),
                        if (cseThumbnail != null)
                          Image.network(
                            cseThumbnail,
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        // IconButton(
                        //   icon: Icon(
                        //     _bookmarked[index]
                        //         ? Icons.bookmark
                        //         : Icons.bookmark_border,
                        //   ),
                        //   onPressed: () async {
                        //     bool newBookmark = !_bookmarked[index];
                        //     Future<String?> bookmarkDocumentID =
                        //         firebase.updateBookmark(
                        //             _searchText,
                        //             _searchResults[index],
                        //             newBookmark); // 북마크 업데이트
                        //     setState(() {
                        //       _bookmarked[index] =
                        //           newBookmark; // 해당 카드의 북마크 상태를 토글한다.
                        //     });
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );

                Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: InkWell(
                    onTap: () {
                      launchURL(link);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    cseThumbnail != null
                                        ? Image.network(
                                            cseThumbnail,
                                            width: 16,
                                            height: 16,
                                            fit: BoxFit.cover,
                                          )
                                        : SizedBox(),
                                    SizedBox(width: 8),
                                    Text(
                                      displayLink ?? "",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  title,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  snippet,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (cseThumbnail != null) SizedBox(width: 5),
                        if (cseThumbnail != null)
                          Image.network(
                            cseThumbnail,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.bookmark,
                          ),
                          onPressed: () async {
                            print(link);
                            print(keyword);
                            String? bookmarkDocumentID = await firebase
                                .deleteBookmarkInBookmarkPage(keyword, link);

                            // 북마크 삭제 성공시 리스트 업데이트 및 화면 갱신
                            if (bookmarkDocumentID != null) {
                              setState(() {
                                _bookmarks = firebase
                                    .getUserBookmarks(); // Comment: userId 전달
                              });
                            } else {
                              // 오류 메시지 표시
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('북마크 삭제에 실패하였습니다. 다시 시도해 주세요.'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
