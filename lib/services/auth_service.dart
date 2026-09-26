import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser {
    return _auth.currentUser;
  }

  String? get currentUid {
    return _auth.currentUser?.uid;
  }

  bool get isAuthenticated {
    return _auth.currentUser != null;
  }

  // ============================================================
  // CREAR CUENTA
  // ============================================================

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

    try {
      final credential =
      await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // INICIAR SESIÓN
  // ============================================================

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
      return await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException {
      // IMPORTANTE:
      //
      // Conservamos el FirebaseAuthException original.
      //
      // Esto permite que LoginPage pueda identificar
      // el código real:
      //
      // user-not-found
      // wrong-password
      // invalid-credential
      // invalid-email
      // etc.
      //
      // NO convertirlo en Exception personalizada aquí.
      rethrow;
    }
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ============================================================
  // RECUPERAR CONTRASEÑA
  // ============================================================


  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: email,
    );
  }

  // ============================================================
  // MENSAJES DE AUTENTICACIÓN
  // ============================================================
  //
  // Estos mensajes se utilizan principalmente para
  // creación de cuenta.
  //
  // signIn() conserva el error original para que
  // LoginPage pueda manejarlo.

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
        return 'La contraseña es incorrecta.';

      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos.';

      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde.';

      case 'network-request-failed':
        return 'No hay conexión con Firebase.';

      case 'operation-not-allowed':
        return 'El método de autenticación no está habilitado.';

      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';

      default:
        return 'No fue posible completar la autenticación.';
    }
  }
}