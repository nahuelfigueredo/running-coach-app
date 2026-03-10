# Configuración de Firestore

## Índices requeridos

Esta aplicación requiere índices compuestos en Firestore para funcionar correctamente.

### Opción 1: Desplegar automáticamente (Recomendado)

Si tienes Firebase CLI instalado:

```bash
# Instalar Firebase CLI (si no lo tienes)
npm install -g firebase-tools

# Login
firebase login

# Desplegar índices
firebase deploy --only firestore:indexes
```

### Opción 2: Crear manualmente en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a **Firestore Database** → **Índices**
4. Crea los siguientes índices compuestos:

#### Para `assignments`:
- **Campo 1:** `studentId` (Ascendente)
- **Campo 2:** `assignedAt` (Descendente)
- **Alcance:** Colección

#### Para `assignments` (coach):
- **Campo 1:** `coachId` (Ascendente)
- **Campo 2:** `assignedAt` (Descendente)
- **Alcance:** Colección

#### Para `routines` (coach):
- **Campo 1:** `coachId` (Ascendente)
- **Campo 2:** `createdAt` (Descendente)
- **Alcance:** Colección

#### Para `routines` (alumno):
- **Campo 1:** `studentId` (Ascendente)
- **Campo 2:** `createdAt` (Descendente)
- **Alcance:** Colección

#### Para `trainingSessions`:
- **Campo 1:** `studentId` (Ascendente)
- **Campo 2:** `scheduledDate` (Ascendente)
- **Alcance:** Colección

#### Para `trainingSessions` (con estado):
- **Campo 1:** `studentId` (Ascendente)
- **Campo 2:** `status` (Ascendente)
- **Campo 3:** `scheduledDate` (Ascendente)
- **Alcance:** Colección

#### Para `conversations`:
- **Campo 1:** `participantIds` (Array contiene)
- **Campo 2:** `lastMessageTime` (Descendente)
- **Alcance:** Colección

#### Para `messages`:
- **Campo 1:** `receiverId` (Ascendente)
- **Campo 2:** `read` (Ascendente)
- **Campo 3:** `timestamp` (Descendente)
- **Alcance:** Grupo de colección

### Opción 3: Usar el link del error

Cuando la app muestre un error de índice faltante:
1. Copia el link del error en la consola
2. Pégalo en tu navegador
3. Click en "Crear índice"
4. Espera 2-5 minutos

## Verificar índices

Una vez creados, verifica en:
- Firebase Console → Firestore Database → Índices
- Deben mostrar estado "Habilitado" (verde)

## Notas

- Los índices pueden tardar varios minutos en crearse
- La app mostrará errores hasta que todos los índices estén listos
- Los índices simples (un solo campo) se crean automáticamente
- El archivo `firebase/firestore.indexes.json` contiene la definición de todos los índices
