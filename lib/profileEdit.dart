import 'dart:io';
import 'package:database_team/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  final int userId;
  const ProfileEditScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  var media_id;
  String real_name = '';
  String birth = '';
  String password = '';
  String? _imagePath;
  late TextEditingController _realNameController;
  late TextEditingController _birthdayController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _realNameController = TextEditingController(text: real_name);
    _birthdayController = TextEditingController(text: birth);
    _passwordController = TextEditingController(text: password);
    loadProfile();
  }

  Future<void> loadProfile() async {
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

      var result = await conn.execute(
        "SELECT user.name, user.birth, user.media_id, account.password FROM user, account WHERE user_id = :user_id and user.user_id = account.id",
        {'user_id': widget.userId},
      );

      if (result.numOfRows > 0) {
        var row = result.rows.first;
        setState(() {
          real_name = row.colAt(0) ?? '';
          birth = row.colAt(1) ?? '';
          media_id = int.tryParse(row.colAt(2) ?? '') ?? 0;
          password = row.colAt(3) ?? '';

          _realNameController.text = real_name;
          _birthdayController.text = birth;
          _passwordController.text = password;
        });
      }

      await conn.close();
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> saveProfile() async {
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
  "UPDATE user SET name = ?, birth = ? WHERE user_id = ?",
);
await stmt.execute([
  _realNameController.text,
  _birthdayController.text,
  widget.userId,
]);

var stmt2 = await conn.prepare(
  "UPDATE account SET password = ? WHERE id = ?", // Assuming 'id' is the correct column name in the 'account' table
);
await stmt2.execute([
  _passwordController.text,
  widget.userId,
]);
      await RunProfile(widget.userId.toString(),widget.userId.toString());
      await stmt.deallocate();
      await stmt2.deallocate();
      await conn.close();
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  Future<void> pickImage() async {
    var picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
        // image.saveTo("/");
      });
      uploadPath();
    }
  }
  Future<void> uploadPath() async {
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
  //        "INSERT into post(user_id, content, writer_id) values(?, ?, ?)", //user_id, content, writer_id

    await conn.execute("INSERT INTO media(title, type, file_path) VALUES ('test','jpeg','$_imagePath')");

    var result = await conn.execute(
        "SELECT * FROM media WHERE file_path = '$_imagePath'");
    var id;
    for (final row in result.rows) {
      id = row.colAt(0);
    }

    var stmt = await conn.prepare(
      "UPDATE user SET media_id = $id WHERE user_id = ?",
    );

    await stmt.execute([
      widget.userId,
    ]);
    await stmt.deallocate();
    await conn.close();
  } catch (e) {
    print('Error saving img: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.0),
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: _imagePath != null 
              ? FileImage(File(_imagePath!)) as ImageProvider<Object>
              : NetworkImage('https://via.placeholder.com/150') as ImageProvider<Object>,
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await pickImage();
                },
              ),
            ),

            SizedBox(height: 20),
            TextFormField(
              controller: _realNameController,
              decoration: InputDecoration(
                labelText: 'real name',
                hintText: 'Please enter your real name.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '실명을 입력해주세요.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _birthdayController,
              decoration: InputDecoration(
                labelText: 'birth',
                hintText: 'YYYY-MM-DD 형식으로 입력해주세요.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '생일을 입력해주세요.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration( 
                labelText: 'password',
                hintText: 'enter new password.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요.';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await saveProfile();
                }
                Navigator.pushAndRemoveUntil(
                  context, 
                    MaterialPageRoute(builder: (context) => MyProfile()),
                    (Route<dynamic> route) => false,
                );
                 
              },
            ),
          ],
        ),
      ),
    );
  }
}
