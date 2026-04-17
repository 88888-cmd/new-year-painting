import 'package:app/models/response.dart';
import 'package:app/routes/routes.dart';
import 'package:app/store/config.dart';
import 'package:app/store/user.dart';
import 'package:app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as getx;
import 'package:mime/mime.dart' as mime;

class HttpService extends getx.GetxService {
  static HttpService get to => getx.Get.find();

  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();

    final options = BaseOptions(
      baseUrl: Constants.serverUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
      validateStatus: (status) => status == 200,
    );

    _dio = Dio(options);

    _dio.interceptors.add(_RequestInterceptors());

    // _dio.interceptors.add(LogInterceptor(requestBody: true, responseHeader: true));
  }

  Map<String, dynamic>? getHeaders({bool excludeToken = false}) {
    final headers = <String, dynamic>{
      'Accept-Language': ConfigStore.to.locale.toLanguageTag(),
    };
    if (UserStore.to.isLogin && !excludeToken) {
      headers['token'] = UserStore.to.token;
    }

    return headers;
  }

  Future<ResponseModel> get(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool excludeToken = false,
    bool showLoading = false,
  }) async {
    if (showLoading) EasyLoading.show(status: 'Loading...');

    try {
      Options requestOptions = options ?? Options();
      requestOptions.headers = getHeaders(excludeToken: excludeToken);
      final response = await _dio.get(
        url,
        queryParameters: params,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      if (showLoading) EasyLoading.dismiss();
      return ResponseModel.fromJson(response.data);
    } catch (error) {
      if (error is! DioException) EasyLoading.dismiss();
      rethrow;
    }
  }

  Future<ResponseModel> post(
    String url, {
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    bool excludeToken = false,
    bool showLoading = false,
  }) async {
    if (showLoading) EasyLoading.show(status: 'Loading...');

    try {
      final requestOptions = options ?? Options();
      requestOptions.headers = getHeaders(excludeToken: excludeToken);
      final response = await _dio.post(
        url,
        data: data,
        options: requestOptions,
        cancelToken: cancelToken,
      );
      if (showLoading) EasyLoading.dismiss();
      return ResponseModel.fromJson(response.data);
    } catch (error) {
      if (error is! DioException) EasyLoading.dismiss();
      rethrow;
    }
  }

  Future<ResponseModel> upload(
    String url, {
    required String path,
    Options? options,
    CancelToken? cancelToken,
    bool excludeToken = false,
    bool showLoading = false,
  }) async {
    if (showLoading) EasyLoading.show(status: 'Loading...');

    try {
      final requestOptions = options ?? Options();
      requestOptions.headers = getHeaders(excludeToken: excludeToken);
      final name = path.substring(path.lastIndexOf('/') + 1, path.length);

      // final ext = name.split('.').last.toLowerCase();
      // const allowedTypes = {
      //   'png': 'image/png',
      //   'jpg': 'image/jpeg',
      //   'jpeg': 'image/jpeg',
      //   'gif': 'image/gif',
      //   'mov': 'video/quicktime'
      // };

      final file = await MultipartFile.fromFile(
        path,
        filename: name,
        contentType: DioMediaType.parse(mime.lookupMimeType(path) ?? ''),
      );
      final formData = FormData.fromMap({'file': file});
      final response = await _dio.post(
        url,
        data: formData,
        options: requestOptions,
        cancelToken: cancelToken,
      );
      if (showLoading) EasyLoading.dismiss();
      return ResponseModel.fromJson(response.data);
    } catch (error) {
      if (error is! DioException) EasyLoading.dismiss();
      rethrow;
    }
  }
}

class _RequestInterceptors extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data['code'] != 0) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
        true,
      );
    } else {
      super.onResponse(response, handler);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        EasyLoading.showToast('Connection timeout');
        break;
      case DioExceptionType.sendTimeout:
        EasyLoading.showToast('Send timeout');
        break;
      case DioExceptionType.receiveTimeout:
        EasyLoading.showToast('Receive timeout');
        break;
      case DioExceptionType.badCertificate:
        EasyLoading.showToast('Certificate error');
        break;
      case DioExceptionType.badResponse:
        final response = err.response;
        final statusCode = response?.statusCode;

        switch (statusCode) {
          case 404:
            EasyLoading.showToast('$statusCode - Server not found');
            break;
          case 500:
            EasyLoading.showToast('$statusCode - Server error');
            break;
          case 502:
            EasyLoading.showToast('$statusCode - Bad gateway');
            break;
          default:
            if (response?.data['code'] == -1) {
              EasyLoading.showToast(response?.data['msg']);
              UserStore.to.logout();
              getx.Get.offAllNamed(Routes.login);
            } else {
              EasyLoading.showToast(
                response?.data['msg']?.toString() ?? 'Server Error',
              );
            }
            break;
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.connectionError:
        EasyLoading.showToast('Connection error');
        break;
      default:
        EasyLoading.showToast('Unknown error');
        break;
    }
    super.onError(err, handler);
  }
}
