import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn0;
import 'package:googleapis/drive/v3.dart' as drive0;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Drive Test',
      theme: ThemeData.light(),
      home: SamplesScreen0(),
    );
  }
}

class SamplesScreen0 extends StatefulWidget {
  @override
  _SampleScreen0State createState() => _SampleScreen0State();
}

class _SampleScreen0State extends State<SamplesScreen0> {
  String savedFileName0 = "";

  late signIn0.GoogleSignIn _googleSignIn0;

  signIn0.GoogleSignInAccount? _account0;

  late var httpClient0;

  late drive0.DriveApi _googleDriveApi0;

  late drive0.FileList _fileList0;

  String signInStatus0 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("Google Drive バックアップ・インポートテスト"),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => _saveNewFile0(),
              child: Text(
                "①テキストファイルを作製し、端末内に保存",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () => _backUpToGoolgeDrive0(),
              child: Text(
                "②Googleドライブに全ファイルをバックアップ",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () => _getListFromGoogleDrive0(),
              child: Text(
                "③Googleドライブ内の全ファイル情報を取得",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () => _importFromGoogleDrive0(),
              child: Text(
                "④Googleドライブ内の全ファイルを端末内にインポート",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () => _deleteGoolgeDriveFiles0(),
              child: Text(
                "⑤Googleドライブ内の全ファイルを削除",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () => _signOutFromGoogle0(),
              child: Text(
                "⑥Googleアカウントからログアウト",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(signInStatus0),
          ],
        ),
      ),
    );
  }

  Future<bool> _googleSignInMethod0() async {
    _googleSignIn0 = signIn0.GoogleSignIn(
      scopes: [
        drive0.DriveApi.driveAppdataScope,
        'https://www.googleapis.com/auth/drive.file',
      ],
    );
    try {
      final checkSignInResult0 = await _googleSignIn0.isSignedIn();
      print("サインインしているか否か $checkSignInResult0");

      if (checkSignInResult0) {
        _account0 = await _googleSignIn0.signInSilently();

        if (_account0 == null) {
          print("認証情報を初期化する必要が生じたため、もう一度ボタンを押してください。");
          await _googleSignIn0.disconnect();
          throw Exception();
        }
      } else {
        _account0 = await _googleSignIn0.signIn();

        if (_account0 == null) {
          print("キャンセル");
          throw Exception();
        }
      }
      setState(() {
        signInStatus0 = "サインイン中";
      });
      return true;
    } catch (e) {
      setState(() {
        signInStatus0 = "サインインアウト中";
      });
      print("サインインできず $e")
      return false;
    }
  }

  _backUpToGoolgeDrive0() {}

  Future<void> _saveNewFile0() async {
    final String savedContent0 = "テスト用のテキストファイルです。";
    String savedPath0 = "";
    final savedDocumentDirectory0 = await getApplicationDocumentsDirectory();
    savedPath0 = savedDocumentDirectory0.path;

    savedFileName0 = "SaveTest_${(DateFormat("yyyyMMddHHmmss")).format(DateTime.now()).toString()}.txt";
    String savedFullpath0 = join(savedPath0,savedFileName0);
    
    try {
      File savedFile0 = File(savedFullpath0);
      
      await savedFile0.writeAsString(savedContent0);
    } catch (e) {
      print(e);
    }
  }

  _getListFromGoogleDrive0() {}

  _importFromGoogleDrive0() {}

  _signOutFromGoogle0() {}

  _deleteGoolgeDriveFiles0() {}
}
