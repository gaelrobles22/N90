import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

import 'models/app_models.dart';
import 'models/team.dart';

import 'screens/admin.dart';
import 'screens/home.dart';
import 'screens/matches.dart';
import 'screens/notifications.dart';
import 'screens/profile.dart';
import 'screens/rankings.dart';
import 'screens/referee.dart';
import 'screens/welcome_page.dart';
import 'screens/profile_selection.dart';
import 'screens/team.dart';
import 'screens/player_registration/access_code_page.dart';
import 'screens/registration/registration_page.dart';
import 'screens/guest/guest_field_selection_page.dart';
import 'screens/login/login_page.dart';
import 'screens/login/role_selection_page.dart';
import 'screens/login/player_team_selection_page.dart';
import 'screens/login/field_assignment_page.dart';

import 'services/data_service.dart';
import 'services/player_registration_service.dart';

import 'widgets/common.dart';
import 'widgets/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final data = DataService();

  await data.init();

  runApp(
    NoventaApp(
      data: data,
    ),
  );
}

class NoventaApp extends StatelessWidget {
  final DataService data;

  const NoventaApp({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOVENTA',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lime,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Arial',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            color: Colors.white54,
          ),
        ),
      ),
      home: AppShell(
        data: data,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final DataService data;

  const AppShell({
    super.key,
    required this.data,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final PlayerRegistrationService
  _playerRegistrationService =
  PlayerRegistrationService();

  late UserRole role;

  String tab = 'home';

  bool started = false;

  late Player player;

  String? currentUid;

  Map<String, dynamic>? currentUserData;

  List<Map<String, dynamic>> currentFieldMembers = [];

  String? currentFieldId;
  String? currentFieldName;
  String? currentTeamId;

  @override
  void initState() {
    super.initState();

    role = UserRole.player;

    player = widget.data.players.first;
  }

  // ============================================================
  // INICIAR APP ANTIGUA / CONTEXTO LOCAL
  // ============================================================

  void start(UserRole r) {
    setState(() {
      role = r;
      started = true;

      tab = switch (r) {
        UserRole.player => 'home',
        UserRole.referee => 'ref_control',
        UserRole.managerTeam => 'manager_home',
        UserRole.adminField => 'admin_overview',
      };
    });
  }

  // ============================================================
  // CERRAR SESIÓN LOCAL
  // ============================================================

  void logout() {
    setState(() {
      started = false;
      currentUid = null;
      currentUserData = null;
      currentFieldMembers = [];
      currentFieldId = null;
      currentFieldName = null;
      currentTeamId = null;
      role = UserRole.player;
      tab = 'home';
    });
  }

  // ============================================================
  // OBTENER ROLES DEL USUARIO
  // ============================================================

  List<String> _getRolesFromMembers(
      List<Map<String, dynamic>> members,
      ) {
    final Set<String> roles = {};

    for (final member in members) {
      final status =
      member['status']?.toString();

      if (status != null &&
          status != 'active') {
        continue;
      }

      final rawRoles = member['roles'];

      if (rawRoles is List) {
        for (final value in rawRoles) {
          final roleName =
          value.toString().trim();

          if (roleName.isNotEmpty) {
            roles.add(roleName);
          }
        }
      }

      // Compatibilidad con documentos antiguos.
      final singleRole =
      member['role']?.toString().trim();

      if (singleRole != null &&
          singleRole.isNotEmpty) {
        roles.add(singleRole);
      }
    }

    return roles.toList();
  }

  // ============================================================
  // CONVERTIR STRING A USER ROLE
  // ============================================================

  UserRole? _userRoleFromString(
      String value,
      ) {
    switch (value) {
      case 'player':
        return UserRole.player;

      case 'managerTeam':
        return UserRole.managerTeam;

      case 'referee':
        return UserRole.referee;

      case 'adminField':
        return UserRole.adminField;

      default:
        return null;
    }
  }

  // ============================================================
  // OBTENER FIELD ID
  // ============================================================

  String? _getFieldId(
      List<Map<String, dynamic>> members,
      ) {
    for (final member in members) {
      final status =
      member['status']?.toString();

      if (status != null &&
          status != 'active') {
        continue;
      }

      final fieldId =
      member['fieldId']?.toString();

      if (fieldId != null &&
          fieldId.isNotEmpty) {
        return fieldId;
      }
    }

    return null;
  }

  // ============================================================
  // OBTENER FIELD NAME
  // ============================================================

  Future<String> _getFieldName(
      String fieldId,
      List<Map<String, dynamic>> members,
      ) async {
    for (final member in members) {
      final memberFieldId =
      member['fieldId']?.toString();

      if (memberFieldId == fieldId) {
        final fieldName =
        member['fieldName']?.toString();

        if (fieldName != null &&
            fieldName.isNotEmpty) {
          return fieldName;
        }
      }
    }

    try {
      final fieldDocument =
      await _firestore
          .collection('fields')
          .doc(fieldId)
          .get();

      if (fieldDocument.exists) {
        final data =
        fieldDocument.data();

        final name =
        data?['name']?.toString();

        if (name != null &&
            name.isNotEmpty) {
          return name;
        }
      }
    } catch (e) {
      debugPrint(
        'No fue posible obtener nombre del campo: $e',
      );
    }

    return 'Campo NOVENTA';
  }

  // ============================================================
  // LOGIN CORRECTO
  // ============================================================

  Future<void> _handleLoginSuccess(
      String uid,
      Map<String, dynamic> userData,
      List<Map<String, dynamic>> fieldMembers,
      ) async {
    if (!mounted) {
      return;
    }

    setState(() {
      currentUid = uid;
      currentUserData = userData;
      currentFieldMembers = fieldMembers;
    });

    final roles =
    _getRolesFromMembers(fieldMembers);

    debugPrint(
      '========================================',
    );
    debugPrint(
      'NOVENTA - LOGIN CONTEXTO',
    );
    debugPrint(
      'UID: $uid',
    );
    debugPrint(
      'ROLES: $roles',
    );
    debugPrint(
      '========================================',
    );

    if (roles.isEmpty) {
      _showError(
        'Tu cuenta todavía no tiene un rol asignado.',
      );
      return;
    }

    if (roles.length == 1) {
      await _enterRole(
        roles.first,
      );
      return;
    }

    await _openRoleSelection(
      roles,
    );
  }

  // ============================================================
  // USUARIO SIN CANCHA ASIGNADA
  // ============================================================

  Future<void> _handleFieldAssignmentRequired(
      String uid,
      Map<String, dynamic> userData,
      ) async {
    if (!mounted) {
      return;
    }

    debugPrint(
      '========================================',
    );
    debugPrint(
      'NOVENTA - USUARIO SIN CANCHA',
    );
    debugPrint(
      'NOVENTA - UID: $uid',
    );
    debugPrint(
      'NOVENTA - PREPARANDO ASIGNACIÓN DE CANCHA',
    );
    debugPrint(
      '========================================',
    );

    setState(() {
      currentUid = uid;
      currentUserData = userData;
      currentFieldMembers = [];
      currentFieldId = null;
      currentFieldName = null;
      currentTeamId = null;
    });

    final result =
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FieldAssignmentPage(
          uid: uid,
          userData: userData,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final fieldId =
    result['fieldId'] as String?;

    final fieldName =
    result['fieldName'] as String?;

    final accessCodeId =
    result['accessCodeId'] as String?;

    debugPrint(
      '========================================',
    );
    debugPrint(
      'NOVENTA - CANCHA ASIGNADA',
    );
    debugPrint(
      'NOVENTA - FIELD ID: $fieldId',
    );
    debugPrint(
      'NOVENTA - FIELD NAME: $fieldName',
    );
    debugPrint(
      'NOVENTA - ACCESS CODE ID: $accessCodeId',
    );
    debugPrint(
      '========================================',
    );

    if (fieldId == null ||
        fieldId.isEmpty) {
      _showError(
        'No se pudo obtener la cancha asignada.',
      );
      return;
    }

    // El usuario ya fue creado en Firebase Auth y users/{uid}
    // ya existe. Aquí actualizamos únicamente el estado local
    // de AppShell con la nueva membresía de cancha.

    setState(() {
      currentFieldId = fieldId;
      currentFieldName = fieldName;
      currentFieldMembers = [
        {
          'userId': uid,
          'fieldId': fieldId,
          'accessCodeId': accessCodeId,
          'roles': <String>['player'],
          'status': 'active',
        },
      ];
    });

    debugPrint(
      'NOVENTA - FIELD MEMBERS ACTUALIZADOS',
    );
    debugPrint(
      'NOVENTA - CURRENT FIELD: $currentFieldId',
    );
    debugPrint(
      'NOVENTA - CURRENT FIELD NAME: $currentFieldName',
    );

    // La asignación inicial siempre entra como player.
    await _enterPlayerContext();
  }

  // ============================================================
  // SELECCIÓN DE ROL
  // ============================================================

  Future<void> _openRoleSelection(
      List<String> roles,
      ) async {
    if (!mounted) {
      return;
    }

    final selectedRole =
    await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RoleSelectionPage(
              roles: roles,
              onRoleSelected: (role) {
                Navigator.pop(
                  context,
                  role,
                );
              },
            ),
      ),
    );

    if (!mounted ||
        selectedRole == null) {
      return;
    }

    await _enterRole(
      selectedRole,
    );
  }

  // ============================================================
  // ENTRAR CON UN ROL
  // ============================================================

  Future<void> _enterRole(
      String roleName,
      ) async {
    final selectedRole =
    _userRoleFromString(
      roleName,
    );

    if (selectedRole == null) {
      _showError(
        'El rol "$roleName" no es válido.',
      );
      return;
    }

    switch (selectedRole) {
      case UserRole.player:
        await _enterPlayerContext();
        break;

      case UserRole.managerTeam:
        _enterSimpleRole(
          UserRole.managerTeam,
        );
        break;

      case UserRole.referee:
        _enterSimpleRole(
          UserRole.referee,
        );
        break;

      case UserRole.adminField:
        _enterSimpleRole(
          UserRole.adminField,
        );
        break;
    }
  }

  // ============================================================
  // ENTRAR COMO PLAYER
  // ============================================================

  Future<void> _enterPlayerContext() async {
    final uid = currentUid;

    debugPrint(
      'NOVENTA - ENTRANDO A CONTEXTO PLAYER',
    );
    debugPrint(
      'UID: $uid',
    );

    if (uid == null || uid.isEmpty) {
      _showError(
        'No fue posible identificar tu cuenta.',
      );
      return;
    }

    final fieldId =
    _getFieldId(currentFieldMembers);

    debugPrint(
      'NOVENTA - FIELD ID: $fieldId',
    );
    debugPrint(
      'NOVENTA - FIELD MEMBERS: $currentFieldMembers',
    );

    if (fieldId == null ||
        fieldId.isEmpty) {
      _showError(
        'Tu cuenta no tiene un campo asignado.',
      );
      return;
    }

    final fieldName =
    await _getFieldName(
      fieldId,
      currentFieldMembers,
    );

    debugPrint(
      'NOVENTA - FIELD NAME: $fieldName',
    );

    if (!mounted) return;

    currentFieldId = fieldId;
    currentFieldName = fieldName;

    debugPrint(
      'NOVENTA - CONSULTANDO ENROLLMENTS',
    );

    final enrollments =
    await _playerRegistrationService
        .getActiveEnrollments(uid);

    debugPrint(
      'NOVENTA - ENROLLMENTS ENCONTRADOS: ${enrollments.length}',
    );

    if (!mounted) return;

    final matchingEnrollments =
    enrollments
        .where(
          (item) =>
      item.fieldId == fieldId &&
          item.isActive,
    )
        .toList();

    debugPrint(
      'NOVENTA - ENROLLMENTS DEL CAMPO: ${matchingEnrollments.length}',
    );

    final enrollment =
    matchingEnrollments.isEmpty
        ? null
        : matchingEnrollments.first;

    if (enrollment == null) {
      debugPrint(
        'NOVENTA - SIN EQUIPO, ABRIENDO SELECCION DE EQUIPO',
      );

      await _openPlayerTeamSelection(
        uid: uid,
        fieldId: fieldId,
        fieldName: fieldName,
      );

      return;
    }

    debugPrint(
      'NOVENTA - EQUIPO ENCONTRADO: ${enrollment.teamId}',
    );

    await _finishPlayerLogin(
      enrollment.teamId,
    );
  }

  // ============================================================
  // SELECCIÓN DE EQUIPO PARA USUARIO EXISTENTE
  // ============================================================

  Future<void> _openPlayerTeamSelection({
    required String uid,
    required String fieldId,
    required String fieldName,
  }) async {
    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PlayerTeamSelectionPage(
              uid: uid,
              fieldId: fieldId,
              fieldName: fieldName,
              onTeamAssigned:
                  (FieldTeam team) async {
                await _finishPlayerLogin(
                  team.id,
                );
              },
            ),
      ),
    );
  }

  // ============================================================
  // FINALIZAR LOGIN DEL PLAYER
  // ============================================================

  Future<void> _finishPlayerLogin(
      String teamId,
      ) async {
    debugPrint(
      'NOVENTA - FINALIZANDO LOGIN',
    );
    debugPrint(
      'NOVENTA - TEAM ID: $teamId',
    );

    if (!mounted) {
      debugPrint(
        'NOVENTA - WIDGET NO MOUNTED',
      );
      return;
    }

    final uid = currentUid;

    if (uid == null || uid.isEmpty) {
      _showError(
        'No fue posible identificar tu cuenta.',
      );
      return;
    }

    final userData =
        currentUserData;

    if (userData == null) {
      _showError(
        'No se encontraron los datos del jugador.',
      );
      return;
    }

    // ------------------------------------------------------------
    // NOMBRE DEL JUGADOR
    // ------------------------------------------------------------

    final fullName =
        userData['fullName']
            ?.toString()
            .trim() ??
            'Jugador NOVENTA';

    // ------------------------------------------------------------
    // NOMBRE DEL EQUIPO
    // ------------------------------------------------------------

    String teamName = '';

    try {
      final teamDocument =
      await _firestore
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamDocument.exists) {
        final teamData =
        teamDocument.data();

        teamName =
            teamData?['name']
                ?.toString() ??
                '';
      }
    } catch (e) {
      debugPrint(
        'NOVENTA - ERROR OBTENIENDO EQUIPO: $e',
      );
    }

    if (!mounted) return;

    // ------------------------------------------------------------
    // CREAR PLAYER DE SESIÓN
    // ------------------------------------------------------------

    player = Player(
      id: uid,
      fullName: fullName,
      position: Position.del,
      dorsal: 10,
      photoUrl:
      userData['profilePhotoUrl']
          ?.toString() ??
          '',
      overallRating: 0,
      verificationStatus:
      VerificationStatus.verified,
      teamId: teamId,
      teamName: teamName,
      stats: PlayerStats(),
    );

    currentTeamId = teamId;

    debugPrint(
      'NOVENTA - PLAYER CARGADO',
    );
    debugPrint(
      'NOVENTA - PLAYER ID: ${player.id}',
    );
    debugPrint(
      'NOVENTA - PLAYER NAME: ${player.fullName}',
    );
    debugPrint(
      'NOVENTA - TEAM ID: ${player.teamId}',
    );
    debugPrint(
      'NOVENTA - TEAM NAME: ${player.teamName}',
    );

    // ------------------------------------------------------------
    // ENTRAR A HOME
    // ------------------------------------------------------------

    debugPrint(
      'NOVENTA - CAMBIANDO ESTADO A HOME',
    );

    setState(() {
      role = UserRole.player;
      tab = 'home';
      started = true;
    });

    debugPrint(
      'NOVENTA - LOGIN TERMINADO',
    );
  }

  // ============================================================
  // ROLES NO PLAYER
  // ============================================================

  void _enterSimpleRole(
      UserRole selectedRole,
      ) {
    if (!mounted) {
      return;
    }

    setState(() {
      role = selectedRole;
      started = true;

      tab = switch (selectedRole) {
        UserRole.player => 'home',
        UserRole.referee => 'ref_control',
        UserRole.managerTeam => 'manager_home',
        UserRole.adminField => 'admin_overview',
      };
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Inicio de sesión correcto.',
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoginSuccess:
          _handleLoginSuccess,
          onFieldAssignmentRequired:
          _handleFieldAssignmentRequired,
        ),
      ),
    );
  }

  // ============================================================
  // REGISTRO
  // ============================================================

  void _openRegistration(
      RegistrationAccess access,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RegistrationPage(
              access: access,
            ),
      ),
    );
  }

  // ============================================================
  // GUEST
  // ============================================================

  void _openGuestMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GuestFieldSelectionPage(
              onFieldSelected:
                  (fieldId, fieldName) {
                // La pantalla pública del campo
                // se conectará en la siguiente etapa.
              },
            ),
      ),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget content() {
    switch (role) {
      case UserRole.player:
        return switch (tab) {
          'home' => PlayerHome(
            player: player,
            fieldId: currentFieldId ?? '',
            notifications:
                () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor:
              Colors.transparent,
              builder: (_) =>
              const NotificationsSheet(),
            ),
            navigate: (x) {
              setState(() {
                tab = x;
              });
            },
          ),

          'matches' => MatchesScreen(
            matches:
            widget.data.matches,
          ),

          'rankings' => RankingsScreen(
            players:
            widget.data.players,
            standings:
            widget.data.standings,
          ),

          'team' => TeamScreen(
            data: widget.data,
          ),

          'profile' => ProfileScreen(
            data: widget.data,
            player: player,
            logout: logout,
          ),

          _ => const SizedBox(),
        };

      case UserRole.managerTeam:
        return switch (tab) {
          'manager_home' =>
              TeamScreen(
                data: widget.data,
              ),

          'manager_tactical' =>
              TeamScreen(
                data: widget.data,
              ),

          'manager_schedule' =>
              MatchesScreen(
                matches:
                widget.data.matches,
              ),

          'profile' => ProfileScreen(
            data: widget.data,
            player: player,
            logout: logout,
          ),

          _ => const SizedBox(),
        };

      case UserRole.referee:
        return switch (tab) {
          'ref_control' =>
              RefereeScreen(
                data: widget.data,
              ),

          'ref_matches' =>
              MatchesScreen(
                matches:
                widget.data.matches,
              ),

          'profile' => ProfileScreen(
            data: widget.data,
            player: player,
            logout: logout,
          ),

          _ => const SizedBox(),
        };

      case UserRole.adminField:
        return switch (tab) {
          'admin_overview' =>
              AdminScreen(
                data: widget.data,
              ),

          'admin_teams' =>
              AdminScreen(
                data: widget.data,
              ),

          'admin_referees' =>
              AdminScreen(
                data: widget.data,
              ),

          'profile' => ProfileScreen(
            data: widget.data,
            player: player,
            logout: logout,
          ),

          _ => const SizedBox(),
        };
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '========================================',
    );
    debugPrint(
      'NOVENTA - APPSHELL BUILD',
    );
    debugPrint(
      'NOVENTA - STARTED: $started',
    );
    debugPrint(
      'NOVENTA - ROLE: $role',
    );
    debugPrint(
      'NOVENTA - TAB: $tab',
    );
    debugPrint(
      'NOVENTA - CURRENT UID: $currentUid',
    );
    debugPrint(
      'NOVENTA - CURRENT TEAM: $currentTeamId',
    );
    debugPrint(
      '========================================',
    );

    if (!started) {
      debugPrint(
        'NOVENTA - MOSTRANDO WELCOME PAGE',
      );

      return WelcomePage(
        onStart: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProfileSelectionPage(
                    onRegistrationAccessGranted:
                        (access) {
                      _openRegistration(
                        access,
                      );
                    },
                    onProfileSelected:
                        (profile) {
                      switch (profile) {
                        case ProfileType.register:
                          break;

                        case ProfileType.guest:
                          _openGuestMode();
                          break;

                        case ProfileType.login:
                          _openLogin();
                          break;
                      }
                    },
                  ),
            ),
          );
        },
      );
    }

    debugPrint(
      'NOVENTA - MOSTRANDO APP PRINCIPAL',
    );
    debugPrint(
      'NOVENTA - CONSTRUYENDO CONTENT',
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView(
                  padding:
                  const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    20,
                  ),
                  children: [
                    content(),
                  ],
                ),
              ),
            ),
            AppNavigation(
              role: role,
              tab: tab,
              onTab: (x) {
                setState(() {
                  tab = x;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}