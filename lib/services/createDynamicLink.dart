import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class createDynamicLink {
  ///Build a dynamic link firebase
  static Future<String> buildDynamicLink(id) async {
    String url = "https://pocketodo.page.link";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.parse('$url/taskpage/$id'),
      androidParameters: AndroidParameters(
        packageName: "com.example.pocketodo",
        minimumVersion: 0,
      ),
      iosParameters: IosParameters(
        bundleId: "com.example.pocketodo",
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          description: "Pocketodo will help you to use your time efficiently",
          imageUrl:
          Uri.parse("https://photos.app.goo.gl/UHnhTAkFgCKiH2D99"),
          title: "Pocketodo Application"),
    );
    final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
    return dynamicUrl.shortUrl.toString();
  }
}