import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordVerifyingController = TextEditingController();

  Future<void> registerUser() async {
    if (userIdController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordVerifyingController.text.isEmpty) {
      showAlertDialog('알림', '모든 필드를 입력해주세요.');
      return;
    }

    final idCheck = await confirmIdCheck(userIdController.text);

    if (idCheck != '0') {
      showAlertDialog('알림', '입력한 아이디가 이미 존재합니다.');
    } else if (passwordController.text != passwordVerifyingController.text) {
      showAlertDialog('알림', '입력한 비밀번호가 같지 않습니다.');
    } else {
      await insertMember(userIdController.text, passwordController.text);
      showAlertDialog('알림', '아이디가 생성되었습니다.');
    }
  }

  Future<String> confirmIdCheck(String userId) async {
    // Perform your ID check logic here (e.g., querying the database)
    // Return '0' for no duplication, '1' for duplication (as per your implementation).
    return '0';
  }

  Future<void> insertMember(String userId, String password) async {
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

      await conn.execute(
        'INSERT INTO account (email, password) VALUE (:email, :password)',
        {
          'email': userId,
          'password': password,
        }
      );
      var result = await conn.execute(
      "SELECT * FROM account WHERE email = :email AND password = :password",
      {
        "email":userId,
        "password":password,
      });
      var id;
      for (final row in result.rows) {
        id = row.colAt(0);
      }
      await conn.execute("INSERT INTO user (user_id, name, birth, media_id) VALUE ($id,'yourName','2000-01-01',1)");

      await conn.close();
    } catch (e) {
      print('Error inserting member: $e');
      showAlertDialog('알림', '계정 생성 중 오류가 발생했습니다.');
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 가입'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: '이메일',
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
              ),
              TextField(
                controller: passwordVerifyingController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  registerUser();
                },
                child: Text('회원 가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: RegistrationPage(),
    ),
  );
}
