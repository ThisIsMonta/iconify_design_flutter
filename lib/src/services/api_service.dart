import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iconify_design/src/shared/constants.dart';

class ClientService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: '$api/',
      receiveTimeout: DEFAULT_TIMEOUT,
    ),
  );

  ClientService();

  Future<Either<DioException, Response>> getRequest(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(
          DioException(
            message: "Error",
            requestOptions: RequestOptions(),
          ),
        );
      }
    } on DioException catch (e) {
      return Left(
        DioException(
          message: "Error",
          requestOptions: e.requestOptions,
        ),
      );
    } catch (e) {
      return Left(
        DioException(
          message: "Error",
          requestOptions: RequestOptions(),
        ),
      );
    }
  }
}
