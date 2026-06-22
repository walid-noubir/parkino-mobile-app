# Configuration Firebase Firestore - Guide Complet

## 🚀 **Configuration en 3 étapes**

### **Step 1: Mettre à jour les règles Firestore**

1. **Allez sur Firebase Console**
   - https://console.firebase.google.com
   - Sélectionnez votre projet "parkino-mobile-app"

2. **Naviguez vers Firestore Database**
   - Menu gauche → **Firestore Database**
   - Cliquez sur **Rules** (en haut)

3. **Copiez les nouvelles règles**
   
   Remplacez TOUT par:
   
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
         
         // Helper function to validate user document structure
         function validateUserDocument(data) {
           return data.keys().hasAll(['email']) || 
                  (data.size < 2000000);
         }
       }

       // Allow all authenticated users to read parkings data (read-only)
       match /parkings/{document=**} {
         allow read: if request.auth != null;
         allow write: if false;
       }

       // Allow all authenticated users to read notifications
       match /notifications/{document=**} {
         allow read: if request.auth != null;
         allow write: if false;
       }

       // Deny all other access
       match /{document=**} {
         allow read, write: if false;
       }
     }
   }
   ```

4. **Publiez les règles**
   - Cliquez sur le bouton **Publish** (bleu)
   - Attendez la confirmation

---

### **Step 2: Vérifier la structure Firestore**

Assurez-vous que vous avez ces collections :

```
Firestore Database
├── users/
│   └── {userId}/
│       ├── photoUrl: "base64ImageString..."  |
│       ├── displayName: "John Doe"
│       ├── email: "user@example.com"
│       └── phone: "+1234567890"
│
├── parkings/           <- Collection publique (lecture seule)
│   └── main_parking/
│       ├── floor1
│       ├── floor2
│       └── ...
│
└── notifications/      <- Collection publique (lecture seule)
    └── {notificationId}/
```

---

### **Step 3: Redémarrer l'application**

```bash
# Dans le terminal
flutter clean
flutter pub get
flutter run
```

Ou appuyez sur **R** dans le terminal en cours d'exécution pour hot-restart.

---

## **Résumé des permissions**

| Collection | Authentifiés | Non-authentifiés | Écriture |
|-----------|-------------|-----------------|----------|
| `/users/{userId}` | Lire/Écrire (propre) |  | (propre) |
| `/parkings/**` | Lire |  |  Backend only |
| `/notifications/**` | Lire |  |  Backend only |
| Autres |  |  |  |

---

## 🐛 **Dépannage**

### Erreur: "Missing or insufficient permissions"

→ Les règles ne sont pas publiées
→ Vérifiez que vous êtes authentifié
→ Attendez 30 secondes que les règles se propagent

### Erreur: "Document exceeds 1MB"

→ L'image en base64 est trop grande
→ Réduire `imageQuality` à 50 dans `image_picker`:

```dart
final XFile? pickedFile = await _imagePicker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 50,  // Réduit de 85 à 50
);
```

### L'image ne s'affiche pas

→ Vérifier les logs: chercher "Profile image saved"
→ Si absent, l'image ne s'est pas sauvegardée
→ Vérifier la connection internet

---

## 📊 **Fichiers modifiés**

- `FIREBASE_STORAGE_RULES.txt` - Règles Firestore
- `FIRESTORE_IMAGE_STORAGE_CONFIG.md` - Documentation
- `lib/screens/profile/profile_screen_modern.dart` - Code base64

---

## 🎉 **Vous êtes prêt !**

L'app fonctionnera correctement une fois les règles publiées. L'image de profil se sauvegarde dans Firestore et s'affiche avec succès! 📸
