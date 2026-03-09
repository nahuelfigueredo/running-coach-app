# Running Coach App 🏃‍♂️

Aplicación móvil completa en Flutter para la gestión de entrenamientos de running entre profesores y alumnos.

## 📱 Características Principales

### Para Profesores (Coach)
- ✅ Crear y gestionar rutinas de entrenamiento personalizadas
- ✅ Asignar rutinas a alumnos con fechas de inicio y fin
- ✅ Ver lista de alumnos con su información
- ✅ Chat en tiempo real con cada alumno
- ✅ Dashboard con accesos rápidos

### Para Alumnos (Student)
- ✅ Ver rutinas asignadas por el coach
- ✅ Calendario interactivo con entrenamientos programados
- ✅ Marcar entrenamientos como completados con datos reales
- ✅ Estadísticas personales con gráficos
- ✅ Chat en tiempo real con el coach

## 🛠️ Stack Tecnológico

| Tecnología | Uso |
|---|---|
| **Flutter** | Framework de UI multiplataforma |
| **Firebase Auth** | Autenticación de usuarios |
| **Cloud Firestore** | Base de datos en tiempo real |
| **Firebase Messaging** | Notificaciones push |
| **Provider** | Gestión de estado |
| **Google Fonts (Poppins)** | Tipografía |
| **Table Calendar** | Calendario interactivo |
| **FL Chart** | Gráficos de estadísticas |
| **flutter_local_notifications** | Notificaciones locales |

## 📋 Requisitos Previos

- Flutter SDK >= 3.10.7
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Cuenta de Firebase
- Git

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/nahuelfigueredo/running-coach-app.git
cd running-coach-app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

#### 3.1 Crear proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Sigue los pasos para crear el proyecto

#### 3.2 Configurar Firebase para Android

1. En Firebase Console, agrega una app Android
2. Package name: `com.example.running_coach_app`
3. Descarga `google-services.json`
4. Colócalo en `android/app/google-services.json`

#### 3.3 Configurar Firebase para iOS

1. En Firebase Console, agrega una app iOS
2. Bundle ID: `com.example.runningCoachApp`
3. Descarga `GoogleService-Info.plist`
4. Colócalo en `ios/Runner/GoogleService-Info.plist`

#### 3.4 Instalar FlutterFire CLI y configurar

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Esto generará automáticamente `lib/firebase_options.dart`.

#### 3.5 Habilitar servicios en Firebase Console

- **Authentication**: Habilitar Email/Password
- **Cloud Firestore**: Crear base de datos en modo producción
- **Cloud Messaging**: Habilitado por defecto

#### 3.6 Desplegar reglas de Firestore

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 4. Ejecutar la aplicación

```bash
flutter run
```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada, Firebase init, providers
├── models/
│   ├── user_model.dart          # Modelo de usuario (coach/student)
│   ├── routine_model.dart       # Modelo de rutina de entrenamiento
│   ├── workout_model.dart       # Modelo de workout individual
│   ├── assignment_model.dart    # Modelo de asignación rutina-alumno
│   ├── training_session_model.dart  # Modelo de sesión de entrenamiento
│   └── message_model.dart       # Modelo de mensaje de chat
├── services/
│   ├── auth_service.dart        # Firebase Authentication
│   ├── database_service.dart    # Cloud Firestore CRUD
│   ├── chat_service.dart        # Chat en tiempo real
│   └── notification_service.dart  # Notificaciones push/locales
├── providers/
│   ├── auth_provider.dart       # Estado de autenticación
│   ├── routine_provider.dart    # Estado de rutinas
│   ├── workout_provider.dart    # Estado de workouts
│   └── chat_provider.dart       # Estado de chat
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Pantalla de login
│   │   └── register_screen.dart  # Pantalla de registro
│   ├── coach/
│   │   ├── coach_home_screen.dart    # Dashboard del coach
│   │   ├── students_list_screen.dart  # Lista de alumnos
│   │   ├── create_routine_screen.dart  # Crear/editar rutina
│   │   └── assign_routine_screen.dart  # Asignar rutina
│   ├── student/
│   │   ├── student_home_screen.dart    # Dashboard del alumno
│   │   ├── my_routines_screen.dart     # Rutinas asignadas
│   │   ├── calendar_screen.dart        # Calendario de entrenamientos
│   │   ├── workout_detail_screen.dart  # Detalle de workout
│   │   └── my_statistics_screen.dart   # Estadísticas personales
│   └── chat/
│       └── chat_room_screen.dart  # Sala de chat en tiempo real
├── widgets/
│   ├── custom_button.dart       # Botón con loading state
│   ├── custom_text_field.dart   # TextField con validación
│   ├── routine_card.dart        # Card de rutina
│   ├── workout_card.dart        # Card de workout
│   └── loading_widget.dart      # Indicadores de carga/error/vacío
└── utils/
    ├── constants.dart           # Constantes (colecciones, roles, tipos)
    ├── validators.dart          # Validadores de formularios
    ├── date_helpers.dart        # Helpers de fechas
    └── theme.dart               # Theme Material Design 3

firebase/
├── firestore.rules              # Reglas de seguridad de Firestore
└── firestore.indexes.json       # Índices de Firestore
```

## 🗄️ Estructura de Firestore

```
users/{userId}
  - email: string
  - name: string
  - role: 'coach' | 'student'
  - coachId?: string
  - createdAt: timestamp

routines/{routineId}
  - name: string
  - description: string
  - coachId: string
  - level: 'beginner' | 'intermediate' | 'advanced'
  - durationWeeks: number
  - goals: string[]

workouts/{workoutId}
  - routineId: string
  - name: string
  - type: 'continuous' | 'intervals' | 'fartlek' | 'series' | 'recovery'
  - distance: number
  - duration: number
  - pace: string

assignments/{assignmentId}
  - routineId: string
  - studentId: string
  - coachId: string
  - startDate: timestamp
  - endDate: timestamp
  - status: 'active' | 'completed' | 'paused'

trainingSessions/{sessionId}
  - workoutId: string
  - studentId: string
  - assignmentId: string
  - scheduledDate: timestamp
  - status: 'pending' | 'completed' | 'skipped'
  - actualDistance?: number
  - actualDuration?: number

messages/{chatId}/chats/{messageId}
  - senderId: string
  - receiverId: string
  - message: string
  - timestamp: timestamp
  - read: boolean
```

## 🎨 Diseño

- **Primary Color**: Azul `#2196F3`
- **Secondary Color**: Naranja `#FF9800`
- **Typography**: Poppins (Google Fonts)
- **Design System**: Material Design 3

## 📸 Screenshots

> *(Próximamente)*

## 🗺️ Roadmap

- [ ] Subida de foto de perfil
- [ ] Notificaciones push automáticas
- [ ] Exportar estadísticas a PDF
- [ ] Integración con GPS/running tracker
- [ ] Dark mode
- [ ] Soporte multiidioma
- [ ] Web app

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para más detalles.
