import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/visa_models.dart';

class VisaRemoteDatasource {
  const VisaRemoteDatasource(this._dio);
  final Dio _dio;

  Future<bool> submitApplication(VisaApplicationState state) async {
    try {
      final formData = FormData.fromMap({
        'fullName': state.fullName,
        'passportNo': state.passportNo,
        'dateOfBirth': state.dateOfBirth,
        'nationality': state.nationality,
        'email': state.email,
        'phone': state.phone,
        'country': state.country,
        'visaType': state.visaType,
        'travelDate': state.travelDate,
        'returnDate': state.returnDate,
        'purpose': state.purpose,
        for (final doc in state.documents)
          if (doc.file != null)
            doc.fieldName: await MultipartFile.fromFile(
              doc.file!.path,
              filename: doc.file!.path.split('/').last,
            ),
      });

      final response = await _dio.post(
        ApiEndpoints.visaSubmit,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
