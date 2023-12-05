import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:database_team/profilePage.dart';

// void main() {
//   runApp(SearchTab());
// }

String search_key = "";
List<List<String>> Search_list = []; //name, email, path담는 2차원 배열

class SearchTab extends StatefulWidget {
  final String userId;
  const SearchTab({Key? key, required this.userId}) : super(key: key);
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String inputText = ''; // 입력된 텍스트를 저장할 변수
  List<SearchData> searchResults = [];

  Future<void> Search() async {
    List<List<String>> tempList = []; // 임시로 검색 결과를 저장할 리스트
    // MySQL 접속 설정
    final conn = await MySQLConnection.createConnection(
      host: "------",
      port: 1111,
      userName: "------",
      password: "------",
      databaseName: '------', // optional
      secure: false,
    );

    // 연결 대기
    await conn.connect();
    print("Connected");

    // 검색 쿼리 실행
    var result = await conn.execute(
        "SELECT u.name, a.email, u.user_id FROM user u JOIN account a ON u.user_id = a.id WHERE u.name LIKE '%$inputText%' OR a.email LIKE '%$inputText%'");

    // 검색 결과를 tempList에 저장
    for (final row in result.rows) {
      tempList.add([row.colAt(0).toString(), row.colAt(1).toString(), row.colAt(2).toString()]); //name, email, id
    }

    await conn.close();

    // 검색 결과를 상태에 반영
    setState(() {
      searchResults = tempList
          .map((item) => SearchData(name: item[0], email: item[1], id: item[2]))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('사용자 검색'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    inputText = text;
                  });
                },
                decoration: InputDecoration(
                  labelText: '이름 또는 이메일 검색',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: Search,
                  ),
                ),
              ),
            ),
            Expanded(
  child: ListView.builder(
    itemCount: searchResults.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(searchResults[index].name),
        subtitle: Text(searchResults[index].email),
        onTap: () async {
          // 다른 사람의 프로필 정보를 가져옵니다.
          await RunProfile(searchResults[index].id, widget.userId);
          // OtherProfile 페이지로 이동하면서 필요한 정보를 전달합니다.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherProfile(pId: searchResults[index].id),
            ),
          );
        },
      );
    },
  ),
),
          ],
        ),
      ),
    );
  }
}



class SearchData {
  final String name;
  final String email;
  final String id;

  SearchData({required this.name, required this.email, required this.id});
}
