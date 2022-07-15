import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn0;
import 'package:googleapis/drive/v3.dart' as drive0;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
      print("サインインできず $e");
      return false;
    }
  }

  Future<void> _backUpToGoolgeDrive0() async {
    final savedFileDirecrory0 = await getApplicationDocumentsDirectory();

    List<FileSystemEntity> fileEntity0 =
        Directory(savedFileDirecrory0.path).listSync();

    fileEntity0.removeWhere((element0) => !element0.path.endsWith(".txt"));

    fileEntity0.forEach((element0) {
      print(element0.path);
    });

    if (fileEntity0.length == 0) {
      print("ファイルが存在しません。");
      return;
    }

    final signInResult0 = await _googleSignInMethod0();
    if (!signInResult0) {
      print("サインインできませんでした。");
      return;
    }

    httpClient0 = (await _googleSignIn0.authenticatedClient())!;

    _googleDriveApi0 = drive0.DriveApi(httpClient0);

    final uploadFile0 = drive0.File();

    uploadFile0.parents = ["appDataFolder"];

    for (int i0 = 0; i0 < fileEntity0.length; i0++) {
      final File file0 = File(fileEntity0[i0].path);
      uploadFile0.name = "googleDrive_${basename(fileEntity0[i0].path)}";

      await _googleDriveApi0.files.create(
        uploadFile0,
        uploadMedia: drive0.Media(file0.openRead(), file0.lengthSync()),
      );
      print("${i0 + 1}番目のファイルを保存");
    }
    print("Google Driveに全ファイルのバックアップ完了");
  }

  Future<void> _saveNewFile0() async {
    final String savedContent0 = "テスト用のテキストファイルです。";
    String savedPath0 = "";
    final savedDocumentDirectory0 = await getApplicationDocumentsDirectory();
    savedPath0 = savedDocumentDirectory0.path;

    savedFileName0 =
        "SaveTest_${(DateFormat("yyyyMMddHHmmss")).format(DateTime.now()).toString()}.txt";
    String savedFullpath0 = join(savedPath0, savedFileName0);

    try {
      File savedFile0 = File(savedFullpath0);

      await savedFile0.writeAsString(savedContent0);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getListFromGoogleDrive0() async {
    final signInResult0 = await _googleSignInMethod0();

    if (!signInResult0) {
      print("サインインできませんでした。");
      return;
    }

    httpClient0 = (await _googleSignIn0.authenticatedClient())!;

    _googleDriveApi0 = drive0.DriveApi(httpClient0);

    await _googleDriveApi0.files
        .list(spaces: 'appDataFolder', $fields: 'files(id, name, createdTime)')
        .then((value0) {
      _fileList0 = value0;

      if (_fileList0.files!.length != 0) {
        for (var i0 = 0; i0 < _fileList0.files!.length; i0++) {
          print(
              "Id: ${_fileList0.files![i0].id} File Name: ${_fileList0.files![i0].name} CreatedTime: ${_fileList0.files![i0].createdTime}");
        }
      } else {
        print("ファイルが存在しません。");
      }
    });
  }

  Future<void> _importFromGoogleDrive0() async {
    await _getListFromGoogleDrive0();

    final importDirectory0 = await getApplicationDocumentsDirectory();

    int importFileCount0 = 0;

    if (_fileList0.files!.length > 0) {
      for (var i0 = 0; i0 < _fileList0.files!.length; i0++) {
        final importFilePath0 =
            join(importDirectory0.path, _fileList0.files![i0].name);
        print("インポート先のファイルパス: $importFilePath0");
        final importFile0 = File(importFilePath0);
        drive0.Media? file0 = (await _googleDriveApi0.files.get(
                _fileList0.files![i0].id!,
                downloadOptions: drive0.DownloadOptions.fullMedia))
            as drive0.Media?;
        List<int> downLoadData0 = [];
        file0!.stream.listen((data0) {
          print("DataReceived: ${data0.length}");
          downLoadData0.insertAll(downLoadData0.length, data0);
        }, onDone: () async {
          importFileCount0++;
          print("forループのindex値 ${i0 + 1}");
          print("カウンター値 $importFileCount0");

          await importFile0.writeAsBytes(downLoadData0);

          if (importFileCount0 == _fileList0.files!.length) {
            print("インポート完了");
          }
        }, onError: (e) {
          print(e);
        });
      }
    } else {
      print("ファイルが存在しません。");
    }
  }

  Future<void> _signOutFromGoogle0() async {
    _googleSignIn0 = signIn0.GoogleSignIn(scopes: [
      drive0.DriveApi.driveAppdataScope,
    ]);

    try {
      await _googleSignIn0.signOut();
      setState(() {
        signInStatus0 = "サインインアウト中";
      });
    } catch (e) {
      print("サインアウトできませんでした。$e");
    }
  }

  Future<void> _deleteGoolgeDriveFiles0() async {
    await _getListFromGoogleDrive0();

    if (_fileList0.files!.length > 0) {
      for (var i0 = 0; i0 < _fileList0.files!.length; i0++) {
        await _googleDriveApi0.files.delete(_fileList0.files![i0].id!);
      }
      print("ファイルを全て削除しました。");
    }
  }
}
