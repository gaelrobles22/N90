# Noventa Pro ⚽

Aplicación Flutter para la administración y consulta de una liga/sede de fútbol.

El proyecto utiliza **Flutter + Firebase + Cloud Firestore** y actualmente cuenta con una interfaz inicial para jugadores, rankings, partidos y administración de sede.

---


flutter clean
flutter pub get
flutter run
flutter analyze

## 📌 Estado actual

### Completado

* [x] Proyecto Flutter funcionando.
* [x] Firebase configurado.
* [x] `firebase_options.dart` configurado.
* [x] `firebase_core` integrado.
* [x] `cloud_firestore` integrado.
* [x] `DataService` creado para trabajar con Firestore.
* [x] Interfaz inicial de Noventa Pro.
* [x] Navegación inferior:

    * Inicio
    * Rankings
    * Partidos
    * Sede / Admin
* [x] Diseño oscuro.
* [x] Aplicación ejecutando correctamente.

### Pendiente

Actualmente varias pantallas todavía utilizan datos estáticos.

Ejemplos:

* Alex Mendoza
* Titanes FC
* Real Baja
* Galácticos SC
* Resultados de partidos
* Posiciones
* Goleadores
* Nombre de la sede

El siguiente objetivo es sustituir estos datos por información real almacenada en **Cloud Firestore**.

---

# 🚀 Ejecución del proyecto

## Requisitos

Se necesita tener instalado:

* Flutter
* Dart
* Android Studio / Android SDK para Android
* Git
* Firebase configurado

Verificar Flutter:

```powershell
flutter --version
```

Verificar Dart:

```powershell
dart --version
```

Ver dispositivos disponibles:

```powershell
flutter devices
```

---

# 📂 Ubicación del proyecto

Actualmente el proyecto se encuentra en:

```text
E:\Proyecto N90\N90\flutter_code
```

Entrar al proyecto:

```powershell
cd "E:\Proyecto N90\N90\flutter_code"
```

---

# 📦 Instalar dependencias

Después de entrar al proyecto:

```powershell
flutter pub get
```

---

# ▶️ Ejecutar la aplicación

Ejecutar:

```powershell
flutter run
```

Para ver los dispositivos disponibles:

```powershell
flutter devices
```

También se puede ejecutar especificando un dispositivo:

```powershell
flutter run -d <DEVICE_ID>
```

---

# 🔥 Firebase

El proyecto utiliza Firebase para almacenar los datos de la aplicación.

Firebase se inicializa en:

```text
lib/main.dart
```

mediante:

```
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

La configuración de Firebase se encuentra en:

```text
lib/firebase_options.dart
```

No eliminar este archivo si se desea mantener la configuración actual de Firebase.

---

# 🗄️ Cloud Firestore

El proyecto utiliza:

```dart
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
```

La comunicación con Firestore se centraliza principalmente en:

```text
lib/services/data_service.dart
```

Para revisar los datos almacenados:

```text
Firebase Console
    ↓
Proyecto Noventa Pro
    ↓
Build
    ↓
Firestore Database
    ↓
Data
```

La región de Firebase no impide utilizar Firestore desde México. Lo importante es que la aplicación esté configurada con el proyecto Firebase correcto y que las reglas de Firestore permitan las operaciones necesarias.

---

# 📁 Estructura del proyecto

```text
flutter_code/
│
├── android/
├── ios/
│
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── models/
│   │   └── app_models.dart
│   │
│   └── services/
│       └── data_service.dart
│
├── pubspec.yaml
└── README.md
```

---

# 🧩 Componentes principales

## `main.dart`

Actualmente contiene la aplicación y las pantallas principales:

```text
PlayerHomeScreen
RankingsScreen
MatchesScreen
AdminDashboardScreen
```

También contiene la navegación inferior.

---

## `app_models.dart`

Ubicación:

```text
lib/models/app_models.dart
```

Aquí se encuentran los modelos que representan las entidades de la aplicación.

Entre ellas se contemplan conceptos como:

```text
Field
Team
Player
Match
```

Antes de modificar la estructura de Firestore se debe revisar este archivo.

---

## `data_service.dart`

Ubicación:

```text
lib/services/data_service.dart
```

Este servicio será responsable de centralizar las operaciones con Firestore.

La intención es manejar desde aquí operaciones como:

```text
Obtener sede
Obtener equipos
Crear equipo
Obtener jugadores
Obtener partidos
Obtener rankings
Actualizar información
```

---

# 🗄️ Estructura propuesta de Firestore

Una estructura inicial podría ser:

```text
fields
 └── field-1
      ├── name
      ├── logoUrl
      └── ...

teams
 ├── team-1
 │    ├── name
 │    ├── logoUrl
 │    └── fieldId
 │
 ├── team-2
 │    ├── name
 │    └── fieldId
 │
 └── ...

players
 ├── player-1
 │    ├── name
 │    ├── teamId
 │    ├── number
 │    ├── position
 │    └── goals
 │
 └── ...

matches
 ├── match-1
 │    ├── homeTeamId
 │    ├── awayTeamId
 │    ├── homeScore
 │    ├── awayScore
 │    ├── date
 │    └── status
 │
 └── ...
```

> Esta estructura es una propuesta. Antes de crear nuevas colecciones o documentos se debe revisar el `DataService` y los modelos existentes para evitar duplicar información.

---

# 🎯 Próximo trabajo

El siguiente objetivo es dejar de utilizar datos hardcodeados y comenzar a utilizar Firestore.

El orden recomendado es:

```text
Firestore
    ↓
DataService
    ↓
Modelos
    ↓
AdminDashboardScreen
```

## 1. Conectar la sede

Actualmente aparece:

```text
Complejo Deportivo Reforma
```

como texto estático.

Debe obtenerse desde Firestore.

Objetivo:

```text
Firestore
    ↓
DataService
    ↓
Field
    ↓
AdminDashboardScreen
```

---

## 2. Conectar equipos

Actualmente aparecen equipos como:

```text
Titanes FC
Real Baja
Galácticos SC
```

como datos estáticos.

La siguiente etapa será obtenerlos desde Firestore.

---

## 3. Registrar nuevo equipo

El botón:

```text
Registrar Nuevo Equipo
```

actualmente no realiza ninguna operación.

Debe convertirse en un flujo que permita:

```text
Registrar Nuevo Equipo
        ↓
Formulario
        ↓
Validación
        ↓
DataService
        ↓
Firestore
```

---

## 4. Conectar jugadores

Después de los equipos:

```text
Firestore
    ↓
Teams
    ↓
Players
```

Los jugadores deberán estar asociados a un equipo mediante `teamId`.

---

## 5. Conectar partidos

La pantalla:

```text
MatchesScreen
```

deberá dejar de utilizar resultados estáticos.

Los partidos deberán obtenerse desde Firestore.

---

## 6. Conectar rankings

Finalmente:

```text
RankingsScreen
```

deberá calcular o consultar información real de jugadores y partidos.

Ejemplo:

```text
Goles
Partidos jugados
Victorias
Derrotas
Empates
Puntos
```

---

# 🔍 Validar el proyecto

Después de realizar cambios:

```powershell
flutter analyze
```

Si no existen errores, ejecutar:

```powershell
flutter run
```

Los mensajes de tipo `info`, por ejemplo:

```text
prefer_const_constructors
```

son recomendaciones del analizador y no necesariamente impiden ejecutar la aplicación.

Los mensajes de tipo:

```text
error
```

sí deben corregirse.

---

# 🧹 Comandos útiles

## Limpiar proyecto

```powershell
flutter clean
```

## Descargar dependencias

```powershell
flutter pub get
```

## Analizar código

```powershell
flutter analyze
```

## Ejecutar

```powershell
flutter run
```

## Ver dispositivos

```powershell
flutter devices
```

---

# ⚠️ Problemas comunes

## Firebase no inicializa

Verificar que `main.dart` tenga:

```
WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

antes de:

```
runApp(...)
```

---

## Firestore no muestra datos

Revisar en Firebase Console:

```
Firestore Database
    ↓
Data
```

Comprobar:

* Nombre de la colección.
* ID del documento.
* Nombre de los campos.
* Tipo de los campos.
* Reglas de seguridad.
* Proyecto Firebase utilizado por la aplicación.

---

## Modifiqué Firebase pero la aplicación no cambia

Comprobar que la pantalla realmente esté leyendo Firestore.

Por ejemplo, esto sigue siendo un dato fijo:

```
const Text('Titanes FC')
```

Aunque se cambie el nombre en Firebase, ese texto no cambiará.

Debe reemplazarse por un valor proveniente del modelo obtenido mediante `DataService`.

---

# 📝 Regla de desarrollo

No conectar todas las pantallas a Firestore al mismo tiempo.

Trabajar progresivamente:

```text
1. Firebase
      ↓
2. DataService
      ↓
3. Modelos
      ↓
4. Sede
      ↓
5. Equipos
      ↓
6. Jugadores
      ↓
7. Partidos
      ↓
8. Rankings
      ↓
9. Home del jugador
```

De esta manera será más sencillo detectar errores y validar cada parte antes de continuar.

---

# 🌙 Punto exacto para continuar

### Último estado

Firebase ya está inicializado y la aplicación abre correctamente.

Actualmente existe:

```text
lib/firebase_options.dart
```

y:

```text
lib/services/data_service.dart
```

con integración de:

```dart
cloud_firestore
```

La aplicación contiene las pantallas:

```text
Inicio
Rankings
Partidos
Sede / Admin
```

### Siguiente paso

Abrir primero:

```text
lib/services/data_service.dart
```

y:

```text
lib/models/app_models.dart
```

Revisar las clases y métodos que ya existen.

Después conectar:

```text
AdminDashboardScreen
        ↓
DataService
        ↓
Cloud Firestore
```

La primera prueba debe ser obtener desde Firestore el nombre de la sede.

Actualmente:

```text
Complejo Deportivo Reforma
```

está escrito directamente en la interfaz.

La meta es:

```text
Firestore
    ↓
DataService
    ↓
Field
    ↓
AdminDashboardScreen
```

Después se continuará con los equipos.

> **No crear nuevas colecciones en Firestore hasta revisar primero el `DataService` y `app_models.dart` actuales.**

---

# 📌 Inicio rápido para mañana

Abrir PowerShell:

```powershell
cd "E:\Proyecto N90\N90\flutter_code"
```

Ejecutar:

```powershell
flutter pub get
flutter analyze
flutter run
```

Después revisar:

```text
lib/services/data_service.dart
lib/models/app_models.dart
lib/main.dart
```

Y continuar con la conexión real de Firestore.
