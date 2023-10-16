import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';

import 'authCubit.dart';

//State
@immutable
abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpProgress extends SignUpState {
  final AuthProvider authProvider;

  SignUpProgress(this.authProvider);
}

class SignUpSuccess extends SignUpState {}

class SignUpFailure extends SignUpState {
  final String errorMessage;
  final AuthProvider authProvider;

  SignUpFailure(this.errorMessage, this.authProvider);
}

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;

  SignUpCubit(this._authRepository) : super(SignUpInitial());

  //signUp user
  void signUpUser(
      {required AuthProvider authProvider,
      required String email,
      required String password,
      required String grade}) {
    //emitting signup progress state
    emit(SignUpProgress(authProvider));
    _authRepository.signUpUser(email: email,password:  password ,grade: grade).then((value) {

      emit(SignUpSuccess());

    }
        //success
        ).catchError((e) {
      //failure
      emit(SignUpFailure(e.toString(), authProvider));
    });
  }
}
