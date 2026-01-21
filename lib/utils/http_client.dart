import 'package:dio/dio.dart';
import 'api_config.dart';
import 'error_handler.dart';

/// HTTP客户端封装
/// 作用：统一处理网络请求、添加token、错误处理等
/// 
/// ⚠️ 注意：这是预留文件，后端接口完成后才使用
/// 目前使用 MockService 进行开发
/// 
/// 为什么需要这个？
/// - 统一添加请求头（如token）
/// - 统一处理错误
/// - 统一处理加载状态
/// - 统一处理超时
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late Dio _dio;

  /// 初始化HTTP客户端
  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器（统一处理）
    _dio.interceptors.add(
      InterceptorsWrapper(
        // 请求拦截器：添加token等
        onRequest: (options, handler) {
          // TODO: 从本地存储获取token
          // final token = SharedPreferences.getInstance()
          //     .then((prefs) => prefs.getString('token'));
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        // 响应拦截器：统一处理响应
        onResponse: (response, handler) {
          handler.next(response);
        },
        // 错误拦截器：统一处理错误
        onError: (error, handler) {
          // 统一处理错误
          final errorMessage = ErrorHandler.handleError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: errorMessage,
            ),
          );
        },
      ),
    );
  }

  /// GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// POST请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// PUT请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// DELETE请求
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// 上传文件
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (data != null) ...data,
        fileKey: await MultipartFile.fromFile(filePath),
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}





