# N90 ⚽

Aplicación móvil para la administración y operación de sedes, equipos, jugadores, árbitros y ligas de fútbol.

El proyecto está desarrollado con:

* Flutter
* Dart
* Firebase
* Firebase Authentication
* Cloud Firestore

---

# 📋 Requisitos

Antes de comenzar, instalar las siguientes herramientas:

| Herramienta    | Versión / Requisito                               |
| -------------- | ------------------------------------------------- |
| Flutter        | 3.47.4                                            |
| Dart           | 3.13.3                                            |
| Android Studio | Recomendado                                       |
| Android SDK    | 36 o compatible                                   |
| Git            | Requerido                                         |
| JDK            | Compatible con la configuración de Android/Gradle |

Verificar Flutter:

```powershell
flutter --version
```

Verificar Dart:

```powershell
dart --version
```

Verificar la configuración general:

```powershell
flutter doctor
```

El objetivo es que no existan errores críticos relacionados con Flutter, Android SDK o las herramientas necesarias para ejecutar la aplicación.

---

# 📥 Instalación del proyecto

## 1. Clonar el repositorio

Desde una terminal:

```powershell
git clone <URL_DEL_REPOSITORIO>
```

Entrar al proyecto:

```powershell
cd <CARPETA_DEL_PROYECTO>
```

---

# 📦 2. Instalar dependencias

Ejecutar:

```powershell
flutter pub get
```

Este comando descarga todas las dependencias definidas en `pubspec.yaml`.

---

# 🔥 3. Configuración de Firebase

NOVENTA utiliza Firebase para autenticación y almacenamiento de información.

La configuración general del proyecto Firebase se encuentra en:

```text
lib/firebase_options.dart
```

## Configuración de Android

Para ejecutar NOVENTA en Android se necesita el archivo:

```text
android/app/google-services.json
```

Este archivo debe ser proporcionado directamente por el responsable del proyecto.

Después de recibirlo, colocarlo exactamente en:

```text
android/app/google-services.json
```

La estructura debe quedar:

```text
NOVENTA/
└── android/
    └── app/
        └── google-services.json
```

No cambiar el nombre ni la ubicación del archivo.

---

# 🗄️ 4. Cloud Firestore

NOVENTA utiliza Cloud Firestore como base de datos.

La configuración de Firestore del proyecto incluye:

```text
firestore.rules
firestore.indexes.json
```

Las reglas de seguridad se encuentran en:

```text
firestore.rules
```

Los índices se encuentran en:

```text
firestore.indexes.json
```

Las operaciones de datos de la aplicación se centralizan principalmente mediante los servicios ubicados en:

```text
lib/services/
```

Antes de modificar colecciones o crear nuevas estructuras en Firestore, revisar primero los servicios y modelos existentes.

---

# ▶️ 5. Ejecutar NOVENTA

Ver los dispositivos disponibles:

```powershell
flutter devices
```

Ejecutar la aplicación:

```powershell
flutter run
```

Para ejecutar en un dispositivo específico:

```powershell
flutter run -d <DEVICE_ID>
```

Por ejemplo:

```powershell
flutter run -d emulator-5554
```

---

# 🧹 6. Limpieza del proyecto

Si existen problemas relacionados con compilación o dependencias, ejecutar:

```powershell
flutter clean
```

Después:

```powershell
flutter pub get
```

Y finalmente:

```powershell
flutter run
```

---

# 🔍 7. Validación del código

Antes de realizar un commit, ejecutar:

```powershell
flutter analyze
```

Los errores reportados como:

```text
error
```

deben corregirse.

Los mensajes informativos o recomendaciones del analizador no necesariamente impiden ejecutar la aplicación.

---

# 📁 Estructura principal

```text
NOVENTA/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── assets/
│   └── images/
│
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── models/
│   │
│   ├── screens/
│   │
│   ├── services/
│   │
│   └── widgets/
│
├── firestore.indexes.json
├── firestore.rules
├── firebase.json
├── .firebaserc
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

# 🧩 Arquitectura general

La aplicación está organizada principalmente de la siguiente manera:

```text
Pantallas
    ↓
Servicios
    ↓
Firebase / Firestore
```

Los modelos representan las entidades utilizadas por la aplicación.

Ubicación:

```text
lib/models/
```

Los servicios contienen la lógica de acceso y operaciones con datos.

Ubicación:

```text
lib/services/
```

Las pantallas se encuentran en:

```text
lib/screens/
```

Los componentes reutilizables se encuentran en:

```text
lib/widgets/
```

---

# 🔐 Firebase Authentication

NOVENTA utiliza Firebase Authentication para la gestión de usuarios.

El flujo de autenticación se encuentra principalmente en:

```text
lib/services/auth_service.dart
```

Las pantallas relacionadas con autenticación se encuentran en:

```text
lib/screens/login/
```

y:

```text
lib/screens/registration/
```

---

# 👤 Roles de usuario

NOVENTA contempla diferentes roles dentro de una sede:

```text
player
managerTeam
referee
adminField
```

Los permisos y la navegación de la aplicación dependen del rol asignado al usuario.

La información de membresía y roles se gestiona mediante Firebase y Cloud Firestore.

---

# 🗂️ Colecciones principales de Firestore

El proyecto utiliza diferentes colecciones para representar la información de NOVENTA.

Entre ellas:

```text
users
fieldMembers
teamMemberships
teams
players
matches
events
standings
lineups
leagueMembers
playerNames
```

Antes de modificar la estructura de cualquiera de estas colecciones:

1. Revisar los modelos existentes.
2. Revisar los servicios existentes.
3. Revisar las reglas de Firestore.
4. Confirmar que el cambio no duplique información existente.

---

# 🧑‍💻 Flujo de desarrollo

El desarrollo debe realizarse mediante ramas independientes.

Estructura general:

```text
prod
  ↑
 QA
  ↑
feature / fix / refactor
```

Las funcionalidades nuevas deben desarrollarse en ramas:

```text
feat/<nombre>
```

Los errores deben corregirse mediante ramas:

```text
fix/<nombre>
```

Los cambios de arquitectura pueden utilizar:

```text
refactor/<nombre>
```

---

# 🔄 Antes de comenzar a trabajar

Actualizar la rama correspondiente:

```powershell
git pull
```

Después instalar o actualizar dependencias:

```powershell
flutter pub get
```

Validar el proyecto:

```powershell
flutter analyze
```

Y ejecutar:

```powershell
flutter run
```

---

# 💾 Antes de realizar un commit

Verificar los cambios:

```powershell
git status
```

Revisar las modificaciones:

```powershell
git diff
```

Validar Flutter:

```powershell
flutter analyze
```

Probar la aplicación:

```powershell
flutter run
```

Después agregar los archivos correspondientes:

```powershell
git add .
```

Revisar nuevamente:

```powershell
git status
```

Realizar el commit:

```powershell
git commit -m "tipo: descripción del cambio"
```

Ejemplos:

```text
feat: add player registration flow
fix: correct login navigation
refactor: update authentication service
```

---

# 🚀 Instalación rápida

Después de clonar el proyecto:

```powershell
git clone <URL_DEL_REPOSITORIO>
cd <CARPETA_DEL_PROYECTO>
flutter pub get
```

Solicitar al responsable del proyecto:

```text
android/app/google-services.json
```

Colocar el archivo en:

```text
android/app/google-services.json
```

Después ejecutar:

```powershell
flutter doctor
flutter devices
flutter analyze
flutter run
```

---

# 🛠️ Solución de problemas

## La aplicación no compila

Ejecutar:

```powershell
flutter clean
flutter pub get
flutter run
```

## Firebase no inicializa

Verificar:

```text
lib/firebase_options.dart
```

Y, para Android:

```text
android/app/google-services.json
```

También verificar que el proyecto Firebase utilizado sea el correspondiente a NOVENTA.

## No aparecen datos de Firestore

Verificar:

* Proyecto Firebase seleccionado.
* Colección utilizada.
* ID del documento.
* Nombre de los campos.
* Tipo de los campos.
* Reglas de Firestore.
* Usuario autenticado.
* Permisos correspondientes.

## Flutter no encuentra un dispositivo

Ejecutar:

```powershell
flutter devices
```

Si no aparece el dispositivo Android, verificar que el emulador o dispositivo físico esté iniciado y que Android Debug Bridge esté disponible.

---

# 📌 Estado del proyecto

NOVENTA se encuentra actualmente en desarrollo.

La aplicación cuenta con:

* Integración con Firebase.
* Firebase Authentication.
* Cloud Firestore.
* Registro de usuarios.
* Inicio de sesión.
* Gestión de roles.
* Gestión de sedes.
* Gestión de equipos.
* Flujo de jugadores.
* Navegación diferenciada según el rol.
* Estructura para administración de sede.

Las funcionalidades continúan evolucionando y algunas áreas pueden encontrarse en proceso de integración o refactorización.

---

# 📍 Punto de continuación

Antes de implementar una nueva funcionalidad:

1. Revisar `lib/main.dart`.
2. Revisar los modelos correspondientes en `lib/models/`.
3. Revisar los servicios en `lib/services/`.
4. Revisar las pantallas relacionadas.
5. Revisar las reglas de Firestore cuando el cambio involucre datos o permisos.

No crear nuevas colecciones, modelos o servicios sin comprobar primero si ya existe una implementación para esa funcionalidad.

---

# ⚽ NOVENTA

Flutter · Firebase · Cloud Firestore
