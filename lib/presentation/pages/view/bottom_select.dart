import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class BuildMidderSelection extends StatefulWidget {
  const BuildMidderSelection({
    super.key,
    required this.selectedItems,
    required this.onSelected,
  });

  final Set<String> selectedItems;
  final Function(dynamic item) onSelected;

  @override
  State<BuildMidderSelection> createState() => _BuildMidderSelectionState();
}

class _BuildMidderSelectionState extends State<BuildMidderSelection> {
  final List<AssetEntity> _videos = [];
  final List<Uint8List?> _thumbnails = [];
  Set<int> selectedIndexes = {};
  bool _isLoading = true;
  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadAssets();
  }

  Future<void> _requestPermissionAndLoadAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    debugPrint("Quyền truy cập: ${permission.isAuth}");
    if (!permission.isAuth) {
      setState(() {
        _permissionError =
            "Ứng dụng cần quyền truy cập thư viện để hiển thị video.";
        _isLoading = false;
      });
      PhotoManager.openSetting();
      return;
    }

    final albums = await PhotoManager.getAssetPathList(type: RequestType.all);
    if (albums.isEmpty) {
      setState(() {
        _permissionError = "Không tìm thấy album nào.";
        _isLoading = false;
      });
      debugPrint("Không có album nào");
      return;
    }
    debugPrint("Có ${albums.length} album");

    List<AssetEntity> allAssets = [];
    for (final album in albums) {
      final assets = await album.getAssetListRange(
        start: 0,
        end: await album.assetCountAsync,
      );
      allAssets.addAll(assets);
    }

    for (final asset in allAssets) {
      debugPrint("Asset: ${asset.id}, type: ${asset.type}");
      if (asset.type == AssetType.video) {
        _videos.add(asset);
        _thumbnails.add(null);
      }
    }

    setState(() {
      _isLoading = false;
    });

    for (int i = 0; i < _videos.length; i++) {
      final thumb = await _videos[i].thumbnailDataWithSize(
        const ThumbnailSize(200, 200),
      );
      if (mounted) {
        setState(() {
          _thumbnails[i] = thumb;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _permissionError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: PhotoManager.openSetting,
              child: const Text("Mở cài đặt"),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(child: Text("Không có video nào được tìm thấy."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        final isSelected = selectedIndexes.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedIndexes.remove(index);
                widget.selectedItems.remove(video.id);
              } else {
                selectedIndexes.add(index);
                widget.selectedItems.add(video.id);
              }
              widget.onSelected(video);
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hiển thị thumbnail hoặc progress indicator
              _thumbnails[index] != null
                  ? Image.memory(
                      _thumbnails[index]!,
                      fit: BoxFit.cover,
                    )
                  : const ColoredBox(
                      color: Colors.black12,
                      child: Center(child: CircularProgressIndicator()),
                    ),

              // Hiển thị icon khi được chọn
              if (isSelected)
                const Positioned(
                  top: 5,
                  right: 20,
                  child: Icon(Icons.check_circle, color: Colors.blue),
                ),
            ],
          ),
        );
      },
    );
  }
}
