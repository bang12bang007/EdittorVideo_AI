import 'dart:io';
import 'package:edit_video_app/presentation/pages/service/service_flashAPI.dart'
    show restoreImage;
import 'package:flutter/material.dart';
import 'package:edit_video_app/assets/colors.dart';

class ImagePreviewPage extends StatefulWidget {
  final File file;

  const ImagePreviewPage({
    super.key,
    required this.file,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late File file;
  bool isRestored = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    const Color colorEdittor = UtilColors.color_edittor;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorEdittor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Image Editor",
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: colorEdittor,
          ),
        ),
        actions: [
          IconButton(
              style: ButtonStyle(iconSize: MaterialStateProperty.all(30)),
              icon: Icon(
                Icons.file_upload_outlined,
                color: colorEdittor,
              ),
              onPressed: () {
                null;
              }),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Image.file(
              file,
              fit: BoxFit.contain,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.face),
                  onPressed: isRestored || isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          File? restoredImage = await restoreImage(widget.file);
                          if (restoredImage != null) {
                            setState(() {
                              file = restoredImage;
                              isRestored = true;
                            });
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                ),
              ],
            ),
            if (isLoading) ...[
              SizedBox(
                width: 10,
              ),
              Text(
                "Restoring ...",
                style: TextStyle(
                  color: colorEdittor,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorEdittor),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
