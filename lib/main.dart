import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

import 'models/app_models.dart';
import 'screens/admin.dart';
import 'screens/home.dart';
import 'screens/matches.dart';
import 'screens/notifications.dart';
import 'screens/profile.dart';
import 'screens/rankings.dart';
import 'screens/referee.dart';
import 'screens/team.dart';
import 'screens/welcome_page.dart';
import 'screens/profile_selection.dart';
import 'screens/player_registration/player_registration_page.dart';
import 'services/data_service.dart';
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
  NoventaApp(data: data),
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

   // ================================================================
   // PRIMERA PANTALLA
   // ================================================================

   home: AppShell(data: data),
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
 late UserRole role;

 String tab = 'home';

 bool started = false;

 late Player player;

 @override
 void initState() {
  super.initState();

  role = UserRole.player;

  player = widget.data.players.first;
 }

 // ======================================================================
 // INICIAR APP
 // ======================================================================

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

 // ======================================================================
 // CONTENIDO
 // ======================================================================

 Widget content() {
  switch (role) {
  // ================================================================
  // PLAYER
  // ================================================================

   case UserRole.player:
    return switch (tab) {
     'home' => PlayerHome(
      data: widget.data,
      player: player,
      notifications: () => showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       backgroundColor: Colors.transparent,
       builder: (_) => const NotificationsSheet(),
      ),
      navigate: (x) {
       setState(() {
        tab = x;
       });
      },
     ),

     'matches' => MatchesScreen(
      matches: widget.data.matches,
     ),

     'rankings' => RankingsScreen(
      players: widget.data.players,
      standings: widget.data.standings,
     ),

     'team' => TeamScreen(
      data: widget.data,
     ),

     'profile' => ProfileScreen(
      data: widget.data,
      player: player,
      logout: () {
       setState(() {
        started = false;
       });
      },
     ),

     _ => const SizedBox(),
    };

  // ================================================================
  // MANAGER
  // ================================================================

   case UserRole.managerTeam:
    return switch (tab) {
     'manager_home' => TeamScreen(
      data: widget.data,
     ),

     'manager_tactical' => TeamScreen(
      data: widget.data,
     ),

     'manager_schedule' => MatchesScreen(
      matches: widget.data.matches,
     ),

     'profile' => ProfileScreen(
      data: widget.data,
      player: player,
      logout: () {
       setState(() {
        started = false;
       });
      },
     ),

     _ => const SizedBox(),
    };

  // ================================================================
  // REFEREE
  // ================================================================

   case UserRole.referee:
    return switch (tab) {
     'ref_control' => RefereeScreen(
      data: widget.data,
     ),

     'ref_matches' => MatchesScreen(
      matches: widget.data.matches,
     ),

     'profile' => ProfileScreen(
      data: widget.data,
      player: player,
      logout: () {
       setState(() {
        started = false;
       });
      },
     ),

     _ => const SizedBox(),
    };

  // ================================================================
  // ADMIN
  // ================================================================

   case UserRole.adminField:
    return switch (tab) {
     'admin_overview' => AdminScreen(
      data: widget.data,
     ),

     'admin_teams' => AdminScreen(
      data: widget.data,
     ),

     'admin_referees' => AdminScreen(
      data: widget.data,
     ),

     'profile' => ProfileScreen(
      data: widget.data,
      player: player,
      logout: () {
       setState(() {
        started = false;
       });
      },
     ),

     _ => const SizedBox(),
    };
  }
 }

 // ======================================================================
 // BUILD
 // ======================================================================

 @override
 Widget build(BuildContext context) {
  // ================================================================
  // WELCOME PAGE
  // ================================================================

  if (!started) {
   return WelcomePage(
    onStart: () {
     Navigator.push(
      context,
      MaterialPageRoute(
       builder: (_) => ProfileSelectionPage(
        onPlayerAccessGranted: (_) {
         Navigator.pop(context);

         Navigator.push(
          context,
          MaterialPageRoute(
           builder: (_) => const PlayerRegistrationPage(),
          ),
         );
        },

        onProfileSelected: (profile) {
         Navigator.pop(context);

         switch (profile) {
          case ProfileType.player:
           start(UserRole.player);
           break;

          case ProfileType.manager:
           start(UserRole.managerTeam);
           break;

          case ProfileType.referee:
           start(UserRole.referee);
           break;

          case ProfileType.admin:
           start(UserRole.adminField);
           break;
         }
        },
       ),
      ),
     );
    },

    onLogin: () {
     // Login se implementará en la siguiente etapa.
    },
   );
  }

  // ================================================================
  // APP PRINCIPAL
  // ================================================================

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
         padding: const EdgeInsets.fromLTRB(
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