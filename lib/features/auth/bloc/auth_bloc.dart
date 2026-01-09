import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/auth/bloc/auth_event.dart';
import 'package:travel_planner/features/auth/bloc/auth_state.dart';
import 'package:travel_planner/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_planner/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_planner/core/config.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.forEach(
      _authRepository.user,
      onData: (user) {
        if (user != null) {
          _syncUserToFirestore(user);
          return AuthAuthenticated(user: user);
        } else {
          return AuthUnauthenticated();
        }
      },
    );
  }

  void _syncUserToFirestore(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userDoc.get();
    
    if (!doc.exists) {
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL ?? AppConfig.defaultProfilePic,
        bio: 'Wandering the world, one AI response at a time.',
        createdAt: DateTime.now(),
      );
      await userDoc.set(appUser.toMap());
      print("AuthBloc: Mirrored user ${user.email} to Firestore.");
    }
  }

  void _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logIn(email: event.email, password: event.password);
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  void _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(email: event.email, password: event.password);
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logOut();
  }

  void _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  void _onGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
