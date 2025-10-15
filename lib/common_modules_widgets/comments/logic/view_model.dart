
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cpanal/models/get_comment_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../constants/app_strings.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/dio.dart';
import '../record_service.dart';

class CommentProvider extends ChangeNotifier{
  bool isGetCommentLoading = false;
  bool isGetCommentSuccess = false;
  bool isAddCommentLoading = false;
  bool isAddCommentSuccess = false;
  int pageNumber = 1;
  Set<int> commentIds = {};
  bool hasMore = true;
  List comments = [];
  List newComments = [];
  GetCommentModel? getCommentModel;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  XFile? XImageFileAttachmentPersonal;
  File? attachmentPersonalImage;
  List listAttachmentPersonalImage = [];
  List<XFile> listXAttachmentPersonalImage = [];
  final picker = ImagePicker();
  String? errorAddCommentMessage;
  String? getRequestCommentErrorMessage;
  AudioRecorder? _recorder;
  bool _isRecording = false;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;

  Duration get elapsedTime => _elapsedTime;
  bool get isRecording => _isRecording;

  Future<void> start() async {
    if (kIsWeb) {
      // الويب هيبدأ من خلال كود مخصص في واجهة المستخدم
      return;
    }

    _recorder = AudioRecorder();

    if (await _recorder!.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder!.start(
        RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      _isRecording = true;
      _elapsedTime = Duration.zero;

      // ✅ شغّل عداد الوقت
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        _elapsedTime += Duration(seconds: 1);
        notifyListeners(); // عشان الـ UI يتحدث
      });

      notifyListeners();
    }
  }

  Future<RecordingResult?> stop() async {
    if (!_isRecording) return null;

    _timer?.cancel();
    _isRecording = false;
    notifyListeners();

    if (kIsWeb) {
      return null;
    } else {
      final path = await _recorder?.stop();
      if (path == null) return null;
      return RecordingResult(path: path);
    }
  }

  Future<void> disposeRecorder() async {
    _timer?.cancel();
    await _recorder?.dispose();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
  Future<void> addComment(BuildContext context, {
    required String id,
    List<XFile>? images,
    String? voicePath,
    Uint8List? voiceBytes, // ✅ أضف دي
    slug,
  }) async {
    if (images == null && voicePath == null && voiceBytes == null && contentController.text.isEmpty) {
      return;
    }
    isAddCommentLoading = true;
    notifyListeners();

    try {
      var response;
      print("Voice Path: $voicePath");

      if (images != null || voicePath != null || voiceBytes != null) {
        print("Uploading media...");

        FormData formData = FormData.fromMap({
          if (contentController.text.isNotEmpty) "content": contentController.text,
          if (images != null && images.isNotEmpty)
            "images[]": await Future.wait(images.map((file) async {
              final bytes = await file.readAsBytes();
              return MultipartFile.fromBytes(bytes, filename: file.name);
            })),
          if (voicePath != null && File(voicePath).existsSync())
            "sounds": await MultipartFile.fromFile(voicePath, filename: "recorded_audio.m4a"),
          if (voiceBytes != null)
            "sounds": MultipartFile.fromBytes(voiceBytes, filename: "recorded_audio_web.m4a"), // ✅ للويب
        });

        response = await DioHelper.postFormData(
          url: "/$slug/entities-operations/$id/comments",
          context: context,
          formdata: formData,
        );
      } else {
        response = await DioHelper.postData(
          url: "/$slug/entities-operations/$id/comments",
          context: context,
          data: {
            if (contentController.text.isNotEmpty) "content": contentController.text,
          },
        );
      }

      if (response.data['status'] == false) {
        Fluttertoast.showToast(
          msg: response.data['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        isAddCommentSuccess = true;
        Fluttertoast.showToast(
          msg: response.data['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        contentController.clear();

        getCommentModel = null;
      }
      notifyListeners();
    } catch (error) {
      errorAddCommentMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();

      Fluttertoast.showToast(
        msg: errorAddCommentMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      isAddCommentLoading = false;
      notifyListeners();
    }
  }
  Future<void> getComment(BuildContext context, slug, id, {pages, bool? isNewPage}) async {
    if (pages != null) {
      pageNumber = pages;
    }
    isGetCommentLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/$slug/entities-operations/$id/comments",
        context: context,
        query: {
          "page": pages ?? pageNumber,
          "order_dir": "desc",
        },
      );

      newComments = response.data['comments'] ?? [];

      if (pages == 1) {
        comments.clear(); // Clear only when loading the first page
      }

      if (newComments.isNotEmpty) {
        comments.addAll(newComments);

        // ✅ إزالة التكرار بناءً على الـ id
        final ids = <dynamic>{};
        comments = comments.where((e) => ids.add(e['id'])).toList();

        print("COMMENTS LENGTH --> ${comments.length}");
        hasMore = true;
        pageNumber++;
        print("PAGE NUMBER --> $pageNumber");
        print("HAS MORE --> $hasMore");
      } else {
        hasMore = false;
      }

      isGetCommentLoading = false;
      isGetCommentSuccess = true;
      notifyListeners();
    } catch (error) {
      getRequestCommentErrorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
    } finally {
      isGetCommentLoading = false;
      notifyListeners();
    }
  }
  Future<File?> _compressImage(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 1600,
      minHeight: 1600,
    );
    return result != null ? File(result.path) : null;
  }
  Future<void> getProfileImageByGallery() async {
    final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFileProfile == null) return;

    if (kIsWeb) {
      Uint8List bytes = await imageFileProfile.readAsBytes();
      listXAttachmentPersonalImage.add(imageFileProfile);
      listAttachmentPersonalImage.add({
        "preview": bytes,     // 🖥️ للعرض
        "upload": bytes,      // 🖥️ للرفع برضه
      });
    } else {
      File originalFile = File(imageFileProfile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        listAttachmentPersonalImage.add({
          "preview": compressedFile,   // 📱 للعرض
          "upload": compressedFile,    // 📱 للرفع
        });
      }
    }


    notifyListeners();
  }

  Future<void> getProfileImageByCam() async {
    final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.camera);
    if (imageFileProfile == null) return;

    if (kIsWeb) {
      Uint8List bytes = await imageFileProfile.readAsBytes();
      listXAttachmentPersonalImage.add(imageFileProfile);
      listAttachmentPersonalImage.add({
        "preview": bytes,     // 🖥️ للعرض
        "upload": bytes,      // 🖥️ للرفع برضه
      });
    } else {
      File originalFile = File(imageFileProfile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        listAttachmentPersonalImage.add({
          "preview": compressedFile,   // 📱 للعرض
          "upload": compressedFile,    // 📱 للرفع
        });
      }
    }


    notifyListeners();
  }

  Future<void> getImage(context,{image1, image2, list, bool one = true, list2}) =>
      showModalBottomSheet<void>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      AppStrings.selectPhoto.tr(),
                      style: TextStyle(
                          fontSize: 20, color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () async {
                                await getProfileImageByGallery();
                                await image2 == null
                                    ? null
                                    : Image.asset("assets/images/profileImage.png");
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.image,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              AppStrings.gallery.tr(),
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                await getProfileImageByCam();
                                print(image1);
                                print(image2);
                                await image2 == null
                                    ? null
                                    : Image.asset(
                                    "assets/images/profileImage.png");
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              AppStrings.camera.tr(),
                              style: TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
}