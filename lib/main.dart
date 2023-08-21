import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'i0enIS8nNDpJDT1a5BuePyUd4lNAmI1xgvsJEEJF';
  final keyClientKey = 'djsvsZTGx2h8wjlqpCIDHAL49fBEFfnGhddqWWLE';

  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    title: 'Flutter - Storage File',
    debugShowCheckedModeBanner: false,
    home: SavePage(),
  ));
}

class SavePage extends StatefulWidget {
  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  PickedFile? pickedFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            GestureDetector(
              child: pickedFile != null
                  ? Container(
                width: 250,
                height: 250,
                decoration:
                BoxDecoration(border: Border.all(color: Colors.deepOrange)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: VideoPlayer(
                    VideoPlayerController.file(File(pickedFile!.path)),
                  ),
                ),
              )
                  : Container(
                width: 250,
                height: 250,
                decoration:
                BoxDecoration(border: Border.all(color: Colors.deepOrangeAccent)),
                child: Center(
                  child: Text('Click here to pick a video from Gallery'),
                ),
              ),
              onTap: () async {
                final pickedVideo = await ImagePicker().getVideo(source: ImageSource.gallery);

                if (pickedVideo != null) {
                  setState(() {
                    pickedFile = PickedFile(pickedVideo.path);
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Container(
                height: 50,
                child: ElevatedButton(
                  child: Text('Upload Video'),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  onPressed: isLoading || pickedFile == null
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });

                    final parseFile = ParseFile(File(pickedFile!.path));
                    await parseFile.save();

                    final videoObject = ParseObject('Video')
                      ..set('file', parseFile);
                    await videoObject.save();

                    setState(() {
                      isLoading = false;
                      pickedFile = null;
                    });

                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                          'Video uploaded successfully!',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.orange,
                      ));
                  },
                ))
          ],
        ),
      ),
    );
  }
}
