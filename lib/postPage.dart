import 'package:database_team/profilePage.dart';
import 'package:database_team/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';


String my_id = "1";

List<List<String>> post_list = [];
int n_post = 0;

//
Future<void> RunMain() async {
  post_list = [];
  n_post = 0;

  print("Connecting to mysql server...");

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


  ////////name, path, content
  var result = await conn.execute("SELECT user.name, media.file_path, post.content FROM user, media, post where user.user_id = post.writer_id and media.media_id = user.media_id and post.writer_id in (select follower_id from following where followee_id = $my_id) order by post.created_time desc");
  // for (final row in result.rows) {
  //   // print(row.colAt(0).toString());
  //   post_list.add([row.colAt(0).toString(), row.colAt(1).toString(), row.colAt(2).toString()]);//username, filepath, content
  //   print("0 " + post_list[n_post][0]);
  //   print("1 " + post_list[n_post][1]);
  //   print("2 " + post_list[n_post][2]);
  //   n_post++;
  // }
  if(result.isNotEmpty){
    for (final row in result.rows) {
    // print(row.colAt(0).toString());
    post_list.add([row.colAt(0).toString(), row.colAt(1).toString(), row.colAt(2).toString()]);//username, filepath, content
    print("0 " + post_list[n_post][0]);
    print("1 " + post_list[n_post][1]);
    print("2 " + post_list[n_post][2]);
    n_post++;
  }
  }
  
  // 종료 대기
  await conn.close();
}

//
 
class TabPage extends StatefulWidget {
  final int id;

  // Constructor
  TabPage({required this.id});
  @override
  State<TabPage> createState() => TabPageState();
}
 
class TabPageState extends State<TabPage> {
  // @override
  // void initState() {
  //   super.initState();
  //   my_id = widget.id.toString();
  //   // Call dbConnector separately
  //   WidgetsBinding.instance?.addPostFrameCallback((_) async {
  //     await dbConnector();
  //     setState(() {});
  //   });
  // }

  
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold
  );
  
  final List<Widget> _widgetOptions = <Widget>[
    Post(itemCount: n_post),
    SearchTab(userId: my_id,),
    MyProfile(),
    //Navigator.push(context, route)

    
  ];
 
  Future<void> _onItemTapped(int index) async {
    if(index == 2){
      await RunProfile(my_id,my_id);
      //Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()),); // int.parse(id),
    }
    setState(()  {
      
      _selectedIndex = index;
    });
    
  }
 
  // 메인 위젯
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightGreen,
        onTap: _onItemTapped,
      ),
    );
  }
 
 
  @override
  void dispose() {
    super.dispose();
  }
    
}

////////////////////////////////////// post 
class Post extends StatefulWidget {
  final int itemCount;

  const Post({Key? key, required this.itemCount}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  List<PostData> posts = [];

  @override
  void initState() {
    super.initState();
    posts = generatePosts(widget.itemCount);
  }

  List<PostData> generatePosts(int count) {
    List<PostData> generatedPosts = [];
    for (int i = 0; i < count; i++) {
      generatedPosts.add(PostData(
        image: post_list[i][1], //수정: 이거도 post_list[i][1]로 path 설정
        text: post_list[i][0] + " | " + post_list[i][2],
      ));
    }
    return generatedPosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("SNS 포스트"),
      // ),
      body: ListView.separated(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: PostItem(post: posts[index]),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
            height: 1.0,
          );
        },
      ),
    );
  }
}

class PostData {
  final String image;
  final String text;

  PostData({required this.image, required this.text});
}

class PostItem extends StatelessWidget {
  final PostData post;

  const PostItem({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(post.image),
        radius: 25.0, // 반지름 크기 조정
      ),
      title: Text(post.text),
      onTap: () {
        // 포스트 클릭 시 동작 정의
        // 원하는 동작을 구현해 주세요
      },
    );
  }
}
/////////////////////////////////////
///
///




/////////////////////////////////////////////////////////////////////////여기부터
///
