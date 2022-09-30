import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];

  String diplayErrorMessage();
}

// general failures
class ServerFailure extends Failure {
  String? message;

  ServerFailure({this.message});

  @override
  String diplayErrorMessage() {
    return message ?? "An error occured, try again later";
  }
}
