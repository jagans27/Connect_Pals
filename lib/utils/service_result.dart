enum Status { success, failure }

class ServiceResult<T> {
  Status status;
  T? data;
  String message;

  ServiceResult({
    required this.status,
    this.data,
    required this.message,
  });
}

