import 'package:database_team/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

class WriteScreen extends StatefulWidget {
  final int userId, writer_id;
  const WriteScreen({Key? key, required this.userId, required this.writer_id}) : super(key: key);

  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _formKey = GlobalKey<FormState>();
  String toContent = '';
  late TextEditingController _ContentController;

  @override
  void initState() {
    super.initState();
    _ContentController = TextEditingController(text: toContent);
  }



  Future<void> saveContent() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final conn = await MySQLConnection.createConnection(
        host: '------',
        port: 1111,
        userName: '------',
        password: '------',
        databaseName: '------',
        secure: false,
      );

      await conn.connect();

      var stmt = await conn.prepare(
        "INSERT into post(user_id, content, writer_id) values(?, ?, ?)", //user_id, content, writer_id
      );
      await stmt.execute([
        widget.userId,
        _ContentController.text,
        widget.writer_id,
      ]);
      print("ssssss");
      print(widget.writer_id);
      await RunProfile(widget.userId.toString() ,widget.writer_id.toString());

      await stmt.deallocate();
      await conn.close();
    } catch (e) {
      print('Error saving profile: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.0),
          children: <Widget>[
  
            TextFormField(
              controller: _ContentController,
              decoration: InputDecoration(
                labelText: '게시글 작성',
                hintText: '게시글을 입력해주세요.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '게시글을 입력해주세요.';
                }
                return null;
              },
            ),
            ElevatedButton(
              child: Text('save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await saveContent();
                  //추가한거
                  if(widget.userId == widget.writer_id){
                    Navigator.pushAndRemoveUntil(
                  context, 
                    MaterialPageRoute(builder: (context) => MyProfile()),
                    (Route<dynamic> route) => false,
                  );
                  }
                  else{
                    Navigator.pushAndRemoveUntil(
                  context, 
                    MaterialPageRoute(builder: (context) => OtherProfile(pId: widget.userId.toString())),
                    (Route<dynamic> route) => false,
                  );
                  }
                
                } 
              },
            ),
          ],
        ),
      ),
    );
  }
}
