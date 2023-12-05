import 'package:database_team/SignUpPage.dart';
import 'package:database_team/postPage.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';


class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 페이지'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 10), //View같은 역할 중간에 띄는 역할
            Center( //Center <- Listview
              child: InkWell( //InkWell을 사용
                child: Text(
                  '처음이신가요? 이메일 계정 만들기',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()), // NextPage는 이동할 다음 페이지의 위젯입니다.
                  );
                },
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // 로그인 버튼 눌렀을 때
                dbConnector(context);
                
              },
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> dbConnector(BuildContext context) async {
  print("Connecting to mysql server...");

  // MySQL 접속 설정
  final conn = await MySQLConnection.createConnection(
    host: '------',
    port: 1111,
    userName: "------",
    password: '------',
    databaseName: '------', // optional
    secure: false,
  );

  await conn.connect();

  print("Connected");

  final email = emailController.text;
  final password = passwordController.text;
  // String email = "example1@example.com";
  // String password = "password1";

  var result = await conn.execute(
    "SELECT * FROM account WHERE email = :email AND password = :password",
      {
        "email":email,
        "password":password,
      });
  for (final row in result.rows) {
    print(row.colAt(0).toString());
    print(row.colAt(1).toString());
  }

  if (result.rows.isNotEmpty) {
    // 로그인 성공 - 사용자 정보를 찾음
    // 여기에 로그인 성공 시의 동작을 추가하세요 (예: 다음 페이지로 이동)
    print("Login successful!");
    var id;
    for (final row in result.rows) {
      id = row.colAt(0);
    }
    
    print(id);
    my_id = id.toString();
    await RunMain();
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage(id:int.parse(id))),); // int.parse(id),
  }
  else {
    // 로그인 실패 - 사용자 정보를 찾을 수 없음
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid email or password'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  await conn.close();
}
