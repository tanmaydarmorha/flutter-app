import 'package:dio/dio.dart';
import 'package:fluvidmobile/modals/folder.dart';

import '../constants.dart';
import 'networking.dart';
import 'package:http_parser/http_parser.dart';

class UpdateService {
  static Future<String> updateFavoriteVideo({videoId, isFavorite}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/videos/favourite/');

    var response = await networkHelper.putData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: '{"favourite":$isFavorite,"videoIds":["$videoId"]}',
    );

    if (response['status'] == 1) {
      return (isFavorite).toString();
    }

    return null;
  }

  static Future<bool> updatePrivacyOption({videoId, urlBody}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url:
            'https://api.fluvid.com/api/v1/videos/privacySettings/$videoId');

    var response = await networkHelper.putData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: urlBody,
    );

    if (response['status'] == 1) {
      return true;
    }
    return false;
  }

  static Future<bool> setPasswordOption({videoId, urlBody}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/videos/password/$videoId');

    var response = await networkHelper.putData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: urlBody,
    );

    if (response['status'] == 1) {
      return true;
    }
    return false;
  }

  static Future<bool> updateThumbnail({videoId, filename, imagePath}) async {
    Response response;
    try {
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'thumbnail': await MultipartFile.fromFile(imagePath,
            filename: filename, contentType: MediaType('image', 'png')),
        'type': 'image/png'
      });

      response = await dio.post(
        'https://api.fluvid.com/api/v1/videos/thumbnail/$videoId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentUserToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } catch (e) {
      print('Error --------------------------------------------- $e');
      return false;
    }

    if (response.statusCode == 200) {
      if (response.data['status'] == 1) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> updateFolderName({folderId, urlBody}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/folders/$folderId');

    var response = await networkHelper.putData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: urlBody,
    );

    if (response['status'] == 1) {
      return true;
    }

    return false;
  }

  static Future<bool> addFolderToTrash({folderId}) async {
    Response response;
    try {
      Dio dio = Dio();
      response = await dio.delete(
        'https://api.fluvid.com/api/v1/folders/archive/',
        data: '{"restore":false,"folderIds":["$folderId"]}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentUserToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error --------------------------------------------- $e');
      return false;
    }

    if (response.statusCode == 200) {
      if (response.data['status'] == 1) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> addFolderToFavorites({folderId, isFavorite}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/folders/favourite/');

    var response = await networkHelper.putData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: '{"favourite":$isFavorite,"folderIds":["$folderId"]}',
    );

    if (response['status'] == 1) {
      return true;
    }

    return false;
  }

  static Future<Folder> addNewFolder(
      {parentFolderId, folderName, favourite}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url:
            'https://api.fluvid.com/api/v1/folders/$parentFolderId?favourite=$favourite');

    var response = await networkHelper.postData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: '{"title":"$folderName"}',
    );

    if (response['status'] == 1) {
      return Folder(
        isFavorite: response['data']['favourite'],
        folderId: response['data']['folder_id'],
        folderTitle: response['data']['title'],
      );
    }

    return null;
  }

  static Future<bool> updateDescription({videoId, title, description}) async {
    NetworkHelper networkHelper =
        NetworkHelper(url: 'https://api.fluvid.com/api/v1/videos/$videoId');

    print('{"title":"$title","tags":"","meta":"","description":$description}');
    var response = await networkHelper.putData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: '{"title":"$title","tags":"","meta":"","description":$description}',
    );

    print(response);

    if (response['status'] == 1) {
      return true;
    }

    return false;
  }

  static Future<bool> updateTitle({videoId, title}) async {
    NetworkHelper networkHelper =
        NetworkHelper(url: 'https://api.fluvid.com/api/v1/videos/$videoId');

    var response = await networkHelper.putData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: '{"title":"$title","tags":"","meta":"","description":""}',
    );

    if (response['status'] == 1) {
      return true;
    }

    return false;
  }

  static Future<bool> addVideoToTrash({videoId}) async {
    Response response;
    try {
      Dio dio = Dio();
      response = await dio.delete(
        'https://api.fluvid.com/api/v1/videos/archive/',
        data: '{"restore":false,"videoIds":["$videoId"]}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentUserToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error --------------------------------------------- $e');
      return false;
    }

    if (response.statusCode == 200) {
      if (response.data['status'] == 1) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> removeVideoFromTrash({videoId}) async {
    Response response;
    try {
      Dio dio = Dio();
      response = await dio.delete(
        'https://api.fluvid.com/api/v1/videos/archive/',
        data: '{"restore":true,"videoIds":["$videoId"]}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentUserToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error --------------------------------------------- $e');
      return false;
    }

    if (response.statusCode == 200) {
      if (response.data['status'] == 1) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> deleteTag({videoId, tag}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/videos/tags/$videoId?name=$tag');

    var response = await networkHelper.deleteData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
    );

    if (response['status'] == 1) {
      return true;
    }

    return false;
  }

  static Future<bool> addTag({videoId, tag}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/videos/tags/$videoId');

    var response = await networkHelper.postData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: '{"name":"$tag"}',
    );

    if (response['status'] == 1) {
      return true;
    }
    return false;
  }

  static Future<bool> deleteFolderPermanently({folderId}) async {
    Response response;
    try {
      Dio dio = Dio();
      response = await dio.delete(
        'https://api.fluvid.com/api/v1/folders/delete',
        data: '{"folderIds":["$folderId"]}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentUserToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error --------------------------------------------- $e');
      return false;
    }

    if (response.statusCode == 200) {
      if (response.data['status'] == 1) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> deleteVideoPermanently({videoId}) async {
    Response response;
    try {
      Dio dio = Dio();
      response = await dio.delete(
        'https://api.fluvid.com/api/v1/videos/delete',
        data: '{"videoIds":["$videoId"]}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentUserToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error --------------------------------------------- $e');
      return false;
    }

    if (response.statusCode == 200) {
      if (response.data['status'] == 1) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> restoreFolder({folderId}) async {
    Response response;
    try {
      Dio dio = Dio();
      response = await dio.delete(
        'https://api.fluvid.com/api/v1/folders/archive/',
        data: '{"restore":true,"folderIds":["$folderId"]}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentUserToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error --------------------------------------------- $e');
      return false;
    }

    if (response.statusCode == 200) {
      if (response.data['status'] == 1) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> addComment({videoId, comment}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/videoInfo/comments/$videoId/');

    var response = await networkHelper.postData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: '{"message":$comment}',
    );

    if (response['status'] == 1) {
      return true;
    }

    return false;
  }

  static Future<bool> updateVideoSettings({videoId, settingsBody}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/videos/settings/$videoId');

    var response = await networkHelper.putData(
      header: {
        'Authorization': 'Bearer $currentUserToken',
        'Content-Type': 'application/json',
      },
      body: settingsBody,
    );

    if (response['status'] == 1) {
      return true;
    }

    return false;
  }

  static Future<bool> resetPassword({email}) async {
    NetworkHelper networkHelper = NetworkHelper(
        url: 'https://api.fluvid.com/api/v1/auth/forgotPassword');

    var response = await networkHelper.putData(
      header: {
        'Content-Type': 'application/json',
      },
      body: '{"email":"$email"}',
    );

    if (response['status'] == 1) {
      return true;
    }

    return false;
  }

  static Future<bool> registerNewUser({email}) async {
    NetworkHelper networkHelper =
        NetworkHelper(url: 'https://api.fluvid.com/api/v1/auth/register');

    var response = await networkHelper.putData(
      header: {
        'Content-Type': 'application/json',
      },
      body:
          '{"email":"$email","reSend":"","g-recaptcha-response":"android042020byaditya"}',
    );

    if (response['data']['status'] == 1) {
      return true;
    } else {
      return false;
    }
  }
}
