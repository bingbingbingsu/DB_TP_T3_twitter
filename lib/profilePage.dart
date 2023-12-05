import 'package:database_team/writePage.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:database_team/profileEdit.dart';

String my_id = "1"; // 현재 접속죽인 유저 id
String p_id = "1"; //보려는 프로필의 유저 id

String name = ""; //p_id의 이름
String follow = ""; //p_id의 팔로우 표시용
String path = ""; //p_id의 프사
List<List<String>> Profilepost_list = []; //name, contet담는 2차원 배열

int n_Profilepost = 0;
List<List<String>> follower_list = []; //p_id의 팔로워 이름, path담는 2차원 배열
int n_follower = 0;
List<List<String>> following_list = []; //p_id가 팔로우 하는 사람 이름, path담는 2차원 배열
int n_following = 0;

String content = ""; // 글쓰기 할 때 저장용


Future<void> RunProfile(String tp_id, String tmy_id) async {
  my_id = tmy_id;
  p_id = tp_id;

  Profilepost_list = []; 
  //post_list = List.filled(20, "", growable: true); //p_id의 포스트들
  n_Profilepost = 0;
  follower_list = []; //p_id의 팔로워 이름, path담는 2차원 배열
  n_follower = 0;
  following_list = []; //p_id가 팔로우 하는 사람 이름, path담는 2차원 배열
  n_following = 0;
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


  String follower = "";
  String following = "";

  ////////name
  var result = await conn.execute("SELECT name FROM user where user_id = $p_id");
  for (final row in result.rows) {
    print(row.colAt(0).toString());
    name = row.colAt(0).toString();
  }
  ////////
  ////////follower
  var r_follower = await conn.execute("SELECT count(follower_id) FROM following where follower_id = $p_id");
  for (final row in r_follower.rows) {
    print(row.colAt(0).toString());
    follower = row.colAt(0).toString();
  }
  ////////
  ////////follower
  var r_following = await conn.execute("SELECT count(followee_id) FROM following where followee_id = $p_id");
  for (final row in r_following.rows) {
    print(row.colAt(0).toString());
    following = row.colAt(0).toString();
  }
  follow = follower + " 팔로워 " + following + " 팔로잉";
  ////////
  ////////image path
  var r_path = await conn.execute("SELECT file_path FROM media where media_id in (select media_id from user where user_id = $p_id)");
  for (final row in r_path.rows) {
    print(row.colAt(0).toString());
    path = row.colAt(0).toString();
  }
  ////////

  //////// post
  var r_post = await conn.execute("SELECT user.name, post.content, media.file_path FROM post, user, media where post.user_id = $p_id and user.user_id = post.writer_id and user.media_id = media.media_id order by post.created_time desc");
  for (final row in r_post.rows) {
    // print(row.colAt(0).toString());
    Profilepost_list.add([row.colAt(0).toString(), row.colAt(1).toString(), row.colAt(2).toString()]); //name이 0, content가 1, file_path가 2
    n_Profilepost++;
    // post.add(row.colAt(0).toString());
    //print(post_list[0][0]);
  }
  ////////
  //////// follower 
  var r_follower_list = await conn.execute("SELECT user.name, media.media_id FROM user, media where media.media_id = user.media_id and user_id in (select followee_id from following where follower_id = $p_id)");
  for (final row in r_follower_list.rows) {
    // print(row.colAt(0).toString());
    follower_list.add([row.colAt(0).toString(), row.colAt(1).toString()]); //name이 0, file_path가 1
    n_follower++;
    // post.add(row.colAt(0).toString());
    print(follower_list[0]);
  }
  ////////
  ///
  //////// following
  var r_following_list = await conn.execute("SELECT user.name, media.media_id FROM user, media where media.media_id = user.media_id and user.user_id in (select follower_id from following where followee_id = $p_id)");
  for (final row in r_following_list.rows) {
    // print(row.colAt(0).toString());
    following_list.add([row.colAt(0).toString(), row.colAt(1).toString()]); //name이 0, file_path가 1
    n_following++;
    // post.add(row.colAt(0).toString());
    print(following_list[0]);
  }
  ////////

  ///
  // if(p_id == my_id){
  //   runApp(MyProfile());
  // }
  // else{
  //   runApp(OtherProfile());
  // }

  // 종료 대기
  await conn.close();
}

Future<int> Follow() async {

  
  
  print("Connecting to mysql server...");
  int check = 0;
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
  //우선 이미 팔로우 되어있는지 체크, p_id의 follower중 my_id가 있는지
  var result = await conn.execute("SELECT follower_id from following where follower_id = $p_id and followee_id = $my_id");
  //print(result.length);
  for (final row in result.rows) {//이 포문을 들어오면 이미 팔로우 중인것
    check = 1;
    print(row.colAt(0).toString());
  }
  if(check == 1){ //이미 팔로우 중인 상황
    print("이미 팔로우");
    await conn.execute("DELETE from following where follower_id = $p_id and followee_id = $my_id");

    await RunProfile(p_id, my_id);
    await conn.close();

    return 0;
  }
  else{ //팔로우 안하고 있음
    await conn.execute("INSERT into following(follower_id, followee_id) values($p_id, $my_id)");
    print("팔로우 완료");
    await RunProfile(p_id, my_id);
    await conn.close();

    return 1;
  }


  // 종료 대기
}



//글쓰기 버튼
Future<void> WritePost() async {

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



  //db에 저장
  await conn.execute("INSERT into post(user_id, content, writer_id) values(:user_id,:content,:writer_id)",
  {
    'user_id' : p_id,
    'content': content, 
    'writer_id':my_id,
  });
  //다시 RunProfile
  RunProfile(p_id, my_id);

  // 종료 대기
  await conn.close();
}

// void main() {
//   RunProfile();
// }


class Top extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        color: Colors.blue,
      ),
    );
  }
}


class MyMiddle extends StatefulWidget {
  const MyMiddle({super.key});

  @override
  State<MyMiddle> createState() => MyMiddleState();
}

class MyMiddleState extends State<MyMiddle> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(path), //수정 path에 저장되어 있음
                    ),
                    SizedBox(height: 16),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      follow,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // background
                  onPrimary: Colors.white, // foreground
                  ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileEditScreen(userId: int.parse(my_id),),)// NextPage는 이동할 다음 페이지의 위젯입니다.
                  );
                 },
                child: Text('프로필 수정'),
              )
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // background
                  onPrimary: Colors.white, // foreground
                  ),
                onPressed: () async { //무조건 myprofile이니깐 돌아갈 때 my profile로 가록록
                print("kkkkkk");
                print(my_id);
                print(p_id);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WriteScreen(userId:int.parse(my_id), writer_id: int.parse(my_id)),)); // int.parse(id),
                  // TextEditorWidget();
                 },
                child: Text('글쓰기'),
              )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => BottomState();
}

class BottomState extends State<Bottom> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 12,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: TabBar(
            indicatorColor: Colors.blue, // 선택된거 아래 색
            labelColor: Colors.white, //이건 글자 색
              tabs: [
                Tab(text: '게시글'),
                Tab(text: '팔로워'),
                Tab(text: '팔로잉'),
              ],
            ),
          body: TabBarView(
            children: [
              //Middle(),
              ProfilePost(itemCount: n_Profilepost,),
              Follower(itemCount: n_follower),
              Following(itemCount: n_following),
            ],
          ),
        ),
      ),
    );
  }
}




/////////////////////////////////////////////////////////////////////////////////////////////
class ProfilePost extends StatefulWidget {
  final int itemCount;

  const ProfilePost({Key? key, required this.itemCount}) : super(key: key);

  @override
  State<ProfilePost> createState() => _ProfilePostState();
}

class _ProfilePostState extends State<ProfilePost> {
  List<ProfilePostData> Profileposts = [];

  @override
  void initState() {
    super.initState();
    Profileposts = generateProfilePosts(widget.itemCount);
  }

  List<ProfilePostData> generateProfilePosts(int count) {
    List<ProfilePostData> generatedProfilePosts = [];
    for (int i = 0; i < count; i++) {
      generatedProfilePosts.add(ProfilePostData(
        image: Profilepost_list[i][2], //수정해야돼 Profilepost_list[i][2]가 file path
        text: Profilepost_list[i][0] + " | " + Profilepost_list[i][1],
      ));
    }
    return generatedProfilePosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("SNS 포스트"),
      // ),
      body: ListView.separated(
        itemCount: Profileposts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ProfilePostItem(Profilepost: Profileposts[index]),
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

class ProfilePostData {
  final String image;
  final String text;

  ProfilePostData({required this.image, required this.text});
}

class ProfilePostItem extends StatelessWidget {
  final ProfilePostData Profilepost;

  const ProfilePostItem({Key? key, required this.Profilepost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(Profilepost.image),
        radius: 25.0, // 반지름 크기 조정
      ),
      title: Text(Profilepost.text),
      onTap: () {
        // 포스트 클릭 시 동작 정의
        // 원하는 동작을 구현해 주세요
      },
    );
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////
//Follower
class Follower extends StatefulWidget {
  final int itemCount;

  const Follower({Key? key, required this.itemCount}) : super(key: key);

  @override
  State<Follower> createState() => _FollowerState();
}

class _FollowerState extends State<Follower> {
  List<FollowerData> followers = [];

  @override
  void initState() {
    super.initState();
    followers = generateFollowers(widget.itemCount);
  }

  List<FollowerData> generateFollowers(int count) {
    List<FollowerData> generatedFollowers = [];
    for (int i = 0; i < count; i++) {
      generatedFollowers.add(FollowerData(
        image: Profilepost_list[i][2], //수정 : follower_list[i][1]에 path저장되어 있음
        text: follower_list[i][0],
      ));
    }
    return generatedFollowers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("SNS 포스트"),
      // ),
      body: ListView.separated(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FollowerItem(follower: followers[index]),
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

class FollowerData {
  final String image;
  final String text;

  FollowerData({required this.image, required this.text});
}

class FollowerItem extends StatelessWidget {
  final FollowerData follower;

  const FollowerItem({Key? key, required this.follower}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(follower.image),
        radius: 25.0, // 반지름 크기 조정
      ),
      title: Text(follower.text),
      onTap: () {
        // 포스트 클릭 시 동작 정의
        // 원하는 동작을 구현해 주세요
      },
    );
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////
//Following
class Following extends StatefulWidget {
  final int itemCount;

  const Following({Key? key, required this.itemCount}) : super(key: key);

  @override
  State<Following> createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  List<FollowingData> followings = [];

  @override
  void initState() {
    super.initState();
    followings = generateFollowings(widget.itemCount);
  }

  List<FollowingData> generateFollowings(int count) {
    List<FollowingData> generatedFollowings = [];
    for (int i = 0; i < count; i++) {
      generatedFollowings.add(FollowingData(
        image: Profilepost_list[i][2], //수정 : following_list[i][1]에 path 저장되어 있음
        text: following_list[i][0],
      ));
    }
    return generatedFollowings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("SNS 포스트"),
      // ),
      body: ListView.separated(
        itemCount: followings.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FollowingItem(following: followings[index]),
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

class FollowingData {
  final String image;
  final String text;

  FollowingData({required this.image, required this.text});
}

class FollowingItem extends StatelessWidget {
  final FollowingData following;

  const FollowingItem({Key? key, required this.following}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(following.image),
        radius: 25.0, // 반지름 크기 조정
      ),
      title: Text(following.text),
      onTap: () {
        // 포스트 클릭 시 동작 정의
        // 원하는 동작을 구현해 주세요
      },
    );
  }
}
///////////////////////////////////////////////////////////
//write page


// class TextEditorWidget extends StatefulWidget {
//   @override
//   _TextEditorWidgetState createState() => _TextEditorWidgetState();
// }

// class _TextEditorWidgetState extends State<TextEditorWidget> {
//   String inputText = ''; // 입력된 텍스트를 저장할 변수

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           actions: [
//             ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.red, // background
//                   onPrimary: Colors.white, // foreground
//                   ),
//                 onPressed: () async { 
//                   content = inputText;
//                   await WritePost(); //얘를 await 해서 db 업데이트하고
//                   runApp(TabPage(id: int.parse(my_id))); //id:int.parse(id))
//                   //여기서 TabPage로 가는 거 
//                 },
//                 child: Text('글 쓰기'),
//               ),
//           ],
//           title: Text('게시글 작성'),
//         ),
//         body: Directionality(
//           textDirection: TextDirection.ltr,
//           child: TextFormField(
//             textAlign: TextAlign.left,
//             decoration: InputDecoration(
//               labelText: '텍스트를 입력하세요',
//             ),
//             onChanged: (text) {
//               setState(() {
//                 inputText = text; // 입력된 텍스트를 변수에 저장
//               });
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }






////////////////////////////////////////////////////////////////////////////////////////////
//my profile
class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            //Top(),
            MyMiddle(),
            Bottom(),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////
//other profile
class OtherProfile extends StatefulWidget {
  final String pId;

  const OtherProfile({Key? key, required this.pId}) : super(key: key);


  @override
  State<OtherProfile> createState() => OtherProfileState();
}

class OtherProfileState extends State<OtherProfile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            //Top(),
            OtherMiddle(pId: widget.pId,),
            Bottom(),
          ],
        ),
      ),
    );
  }
}


class OtherMiddle extends StatefulWidget {
  final String pId;

  const OtherMiddle({Key? key, required this.pId}) : super(key: key);
  @override
  State<OtherMiddle> createState() => OtherMiddleState();
}

class OtherMiddleState extends State<OtherMiddle> {

  void showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(path), //수정 path 에 저장되어있음
                    ),
                    SizedBox(height: 16),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      follow,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // background
                  onPrimary: Colors.white, // foreground
                  ),
                onPressed: () async { 
                  if(await Follow() == 1){//팔로우 한 것
                    showAlertDialog('알림', '팔로우 완료');

                  }
                  else{//팔로우 취소
                    showAlertDialog('알림', '팔로우 취소');
                  }
                  Navigator.pushAndRemoveUntil(
                  context, 
                    MaterialPageRoute(builder: (context) => OtherProfile(pId: widget.pId,)),
                    (Route<dynamic> route) => false,
                  );
                 
                },
                child: Text('팔로우'),
              )
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // background
                  onPrimary: Colors.white, // foreground
                  ),
                onPressed: () { 
                  // runApp(TextEditorWidget());
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => TextEditorWidget()),); // int.parse(id),
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WriteScreen(userId:int.parse(widget.pId), writer_id: int.parse(my_id)),)); // int.parse(id),

                },
                child: Text('글쓰기'),
              )
              ),
            ],
          ),
        ),
      ),
    );
  }
}


