import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:aimoov_spotify/core/errors/failure.dart';
import 'package:aimoov_spotify/core/services/base_api_service.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import 'app_exceptions.dart';

class NetworkApiService extends BaseApiService {
  @override
  Future<Either<Failure, T>> getResponse<T>(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      if (response.statusCode == 200) {
        return right(json.decode(response.body) as T);
      } else {
        return left(ServerFailure(message: response.body));
      }
    } on SocketException {
      return left(ServerFailure(message: 'No Internet connection'));
    }
  }

  @override
  Future deleteResponse(
      {required String url,
      Map<String, String>? headers,
      bool showToast = true}) {
    // TODO: implement deleteResponse
    throw UnimplementedError();
  }

  @override
  Future postResponse(
      String url, Map<String, dynamic> body, Map<String, String>? headers) {
    // TODO: implement postResponse
    throw UnimplementedError();
  }

  @override
  Future putResponse(
      String url, Map<String, dynamic> body, Map<String, String>? headers) {
    // TODO: implement putResponse
    throw UnimplementedError();
  }
}




//   @override
//   Future<ApiResult?> postResponse(
//       String url, dynamic body, Map<String, String>? headers) async {
//     dynamic responseJson;
//     try {
//       final response = await http.post(Uri.parse(url),
//           body: jsonEncode(body),
//           headers: {...?headers, 'connection': 'keep-alive'});
//       log('response: ${response.body}');
//       responseJson = returnResponse(response);

//       // if (responseJson['status'] == 'error') {
//       //   throw FetchDataException(responseJson['message']);
//       // }

//     } on SocketException {
//       responseJson = null;
//       Fluttertoast.showToast(
//         msg: 'No Internet connection',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: waterColor,
//         textColor: jacartaColor,
//         fontSize: 16.0,
//       );
//       // throw FetchDataException('No Internet connection');
//     } catch (e) {
//       responseJson = null;
//       log('error: $e +> url: $url');

//       Fluttertoast.showToast(
//         msg: e.toString(),
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: waterColor,
//         textColor: jacartaColor,
//         fontSize: 16.0,
//       );
//       throw FetchDataException(e.toString());
//     }

//     debugPrint("rslt= ${responseJson}");

//     return responseJson;
//   }

//   @override
//   Future<ApiResult?> deleteResponse(
//       {required String url,
//       Map<String, String>? headers,
//       bool showToast = true}) async {
//     ApiResult? responseJson;
//     try {
//       final response = await http.delete(Uri.parse(url), headers: headers);
//       // log('response: ${response.body}');
//       responseJson = returnResponse(response);

//       return responseJson;
//     } on SocketException {
//       responseJson = null;
//       if (showToast) {
//         Fluttertoast.showToast(
//           msg: 'No Internet connection',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           backgroundColor: waterColor,
//           textColor: jacartaColor,
//           fontSize: 16.0,
//         );
//       }
//     } catch (e) {
//       responseJson = null;

//       if (showToast) {
//         Fluttertoast.showToast(
//           msg: e.toString(),
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           backgroundColor: waterColor,
//           textColor: jacartaColor,
//           fontSize: 16.0,
//         );
//       }
//     }
//     return responseJson;
//   }

//   @override
//   Future<ApiResult?> putResponse(String url, Map<String, dynamic> body,
//       Map<String, String>? headers) async {
//     ApiResult? responseJson;
//     try {
//       final response = await http.put(Uri.parse(url),
//           body: jsonEncode(body), headers: headers);
//       // log('response: ${response.body}');
//       responseJson = returnResponse(response);
//       // if (responseJson['status'] == 'error') {
//       //   throw FetchDataException(responseJson['message']);
//       // }

//       return responseJson;
//     } on SocketException {
//       responseJson = null;
//       Fluttertoast.showToast(
//         msg: 'No Internet connection',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: waterColor,
//         textColor: jacartaColor,
//         fontSize: 16.0,
//       );
//     } catch (e) {
//       responseJson = null;

//       Fluttertoast.showToast(
//         msg: e.toString(),
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: waterColor,
//         textColor: jacartaColor,
//         fontSize: 16.0,
//       );
//       // throw FetchDataException(e.toString());
//     }
//   }

//   Future uploadFile({
//     required String url,
//     Map<String, dynamic>? data,
//     required String filePath,
//     // required List<int> bytes,
//   }) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(url));

//       if (data != null) {
//         for (var key in data.keys) {
//           // log('key: $key, value: ${data[key]}');
//           request.fields[key] = "${data[key]}";
//         }
//       }

//       final fileName = filePath.split('/').last;
//       log('fileName: $fileName');

//       request.files.add(await http.MultipartFile.fromPath(
//         'file', filePath,
//         filename: fileName,
//         // contentType: ('image', 'png', 'pdf', 'docx'),
//       ));
//       Map<String, String> headers = {"Content-type": "multipart/form-data"};
//       request.headers.addAll(headers);
//       request.send().then((response) {
//         log('status: ${response.statusCode}');
//       }).catchError((error) {
//         log('Error )>' + error.toString());
//       });
//     } catch (e) {
//       log(e.toString());
//     }
//   }

//   ApiResult returnResponse(http.Response response) {
//     // log('status code => ${response.statusCode}');
//     dynamic responseJson = jsonDecode(response.body);
//     switch (response.statusCode) {
//       case 200:
//         return ApiResult.success(data: responseJson);
//       case 400:
//         throw BadRequestException();
//       case 401:
//       case 403:
//         throw UnauthorizedException(response.body.toString());
//       case 404:
//         throw UnauthorizedException(response.body.toString());
//       case 500:
//       default:
//         throw FetchDataException(
//             'Error occurred while communication with server' +
//                 ' with status code : ${response.statusCode}');
//     }
//   }
// }
