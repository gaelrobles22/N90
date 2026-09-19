import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({
    FirebaseAuth? auth,
  }) : _auth =
      auth ?? FirebaseAuth.instance;

  User? get currentUser {
    return _auth.currentUser;
  }

  String? get currentUid {
    return _auth.currentUser?.uid;
  }

  bool get isAuthenticated {
    return _auth.currentUser != null;
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception(
        'El correo electrónico es obligatorio.',
      );
    }

    if (password.isEmpty) {
      throw Exception(
        'La contraseña es obligatoria.',
      );
    }

    print('AUTH: Iniciando creación de cuenta...');
    print('AUTH: Email: $normalizedEmail');

    try {
      print('AUTH: Llamando a Firebase...');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      print('AUTH: Firebase respondió correctamente.');
      print('AUTH: UID: ${credential.user?.uid}');
      print('AUTH: Email creado: ${credential.user?.email}');

      return credential;
    } on FirebaseAuthException catch (e) {
      print('AUTH ERROR: code=${e.code}');
      print('AUTH ERROR: message=${e.message}');

      throw Exception(
        _getAuthErrorMessage(e),
      );
    } catch (e) {
      print('AUTH ERROR GENERAL: $e');
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail =
    email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception(
        'El correo electrónico es obligatorio.',
      );
    }

    if (password.isEmpty) {
      throw Exception(
        'La contraseña es obligatoria.',
      );
    }

    try {
      return await _auth
          .signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e),
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getAuthErrorMessage(
      FirebaseAuthException e,
      ) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';

      case 'weak-password':
        return 'La contraseña es demasiado débil.';

      case 'user-not-found':
        return 'No existe una cuenta con este correo.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos.';

      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';

      case 'network-request-failed':
        return 'No hay conexión con Firebase.';

      case 'operation-not-allowed':
        return 'El método de autenticación no está habilitado.';

      default:
        return 'No fue posible completar la autenticación.';
    }
  }
}