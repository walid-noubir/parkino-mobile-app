# Firestore Image Storage Configuration

## Vue d'ensemble

L'application stocke maintenant les images de profil **directement dans Firestore** au lieu d'utiliser Firebase Storage. Cela simplifie la gestion et élimine les problèmes de configuration.

## Stockage des images

### Comment ça fonctionne

1. L'image sélectionnée est **lue en bytes**
2. Convertie en **base64string**
3. Stockée dans le champ `photoUrl` du document utilisateur Firestore
4. Encodée automatiquement lors de l'affichage

### Format

```dart
// Document Firestore: /users/{userId}
{
  "photoUrl": "base64encodedImageString...",  // Image en base64
  "displayName": "John Doe",
  "email": "user@example.com",
  "phone": "+1234567890",
  "createdAt": Timestamp(...),
  "updatedAt": Timestamp(...)
}
```

## Configuration requise

### 1. Mise à jour des règles Firestore

Allez dans **Firebase Console > Firestore Database > Rules** et remplacez par :

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and update their own user document
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId && 
                      validateUserDocument(request.resource.data);
      allow create: if request.auth.uid == userId &&
                       validateUserDocument(request.resource.data);
      
      // Helper function to validate user document
      function validateUserDocument(data) {
        return data.keys().hasAll(['email']) || 
               (data.size < 2000000); // Max 2MB per document
      }
    }

    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Puis cliquez **Publier**.

### 2. Vérifier dans Firebase Console

Allez dans **Storage** et supprimez la collection `users/.../ profile-images` si elle existe (elle n'est plus nécessaire).

## Avantages

**Pas d'erreur Firebase Storage**
**Configuration plus simple**
**Données consolidées** (profil + image au même endroit)
**Gestion plus facile** (une seule base de données)
**Pas de limites de quota de stockage séparé**

## Limitations

⚠️ **Taille max du document Firestore : 1 MB**
- Les images sont compressées à 85% de qualité
- Cela permet de stocker une seule image compressée (150-300 KB typiquement)
- Pour les images très volumineuses, implémenter la compression supplémentaire

## Code modifié

Les fichiers suivants ont été mis à jour :
- `lib/screens/profile/profile_screen_modern.dart` - Utilise maintenant Firestore + base64
- `FIREBASE_STORAGE_RULES.txt` - Remplacé par les règles Firestore

## Dépannage

### L'image ne s'affiche pas

```dart
// Vérifier dans les logs:
I/flutter: Image converted to base64
I/flutter: Profile image saved to Firestore
```

### Erreur "data too large"

L'image est supérieure à 1 MB. Réduire la qualité de compression :

```dart
final XFile? pickedFile = await _imagePicker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 50,  // Reduced from 85
);
```

### Vérifier la taille du document

Dans Firebase Console > Firestore > Collection `users` > Afficher la taille du document
