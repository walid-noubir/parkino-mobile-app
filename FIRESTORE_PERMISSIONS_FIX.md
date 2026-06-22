# 🔐 Correction des Permissions Firestore

##  Problème rencontré

```
[cloud_firestore/permission-denied] Missing or insufficient permissions.
Error deleting extra floor 2 slots...
```

## Solution

Les règles Firestore n'étaient pas complètes. Les collections `parking_slots`, `reservations`, `payments`, et `qr_codes` n'avaient pas les permissions correctes pour les opérations de **suppression** et **création**.

---

## 🔧 Comment corriger

### **Étape 1: Ouvrir Firebase Console**

1. Allez à: https://console.firebase.google.com
2. Sélectionnez votre projet **parkino-mobile-app**
3. Naviguez vers **Firestore Database**

### **Étape 2: Mettre à jour les règles**

1. Cliquez sur l'onglet **Rules** (en haut de Firestore)
2. **Supprimez TOUT le contenu** actuel
3. **Collez les nouvelles règles** depuis [FIRESTORE_RULES.txt](FIRESTORE_RULES.txt)
4. Cliquez sur **Publish** (bouton bleu)
5. Attendez la confirmation

---

## 📋 Résumé des règles actualisées

### **Collections maintenant couvertes:**

| Collection | Read | Write | Delete | Notes |
|------------|------|-------|--------|-------|
| `users/{uid}` | Prop | Prop | Prop | Utilisateur seulement |
| `parking_slots/*` | Auth | Auth | Auth | Tous les users |
| `reservations/*` | Auth | Prop | Prop | Users avec userId |
| `payments/*` | Auth | Auth | 🟡 Failed | Limité aux failed |
| `qr_codes/*` | Auth | Auth | Auth | Tous les users |
| `parkings/*` | Auth |  Non |  Non | Read-only |
| `notifications/*` | Auth |  Non |  Non | Read-only |

**Legend:**
- Autorisé
-  Refusé
- 🟡 Conditionnel
- Auth = Utilisateurs authentifiés
- Prop = Propriétaire du document

---

## 🚀 Après correction

### **Redémarrer l'application:**

```bash
# Option 1: Hot Restart
Appuyez sur "R" dans le terminal

# Option 2: Nettoyer et relancer
flutter clean
flutter pub get
flutter run
```

### **L'erreur devrait disparaître**, et vous pourrez:
- Créer des places de parking
- Supprimer des places
- Créer des réservations
- Créer des paiements
- Générer des QR codes

---

## 🔐 Sécurité

### **Politiques implémentées:**

1. **Authentification requise**
   - Tous les accès requièrent `request.auth != null`
   - Les utilisateurs anonymes sont bloqués

2. **Propriété du document**
   - Les utilisateurs ne peuvent modifier que leurs propres documents
   - Vérification avec `userId == request.auth.uid`

3. **Collections protégées**
   - `parkings` et `notifications` ne permettent que la lecture
   - Aucune modification par les utilisateurs

4. **Suppression limitée**
   - Les paiements ne peuvent être supprimés que s'ils ont échoué
   - Autres documents peuvent être supprimés par le propriétaire

---

## 🆘 Dépannage

### **L'erreur persiste?**

1. **Vérifier la publication**
   - Le bouton **Publish** a-t-il été cliqué?
   - Attendez 30 secondes que les règles se propagent

2. **Vérifier l'authentification**
   - L'utilisateur est-il authentifié dans Firebase?
   - Vérifier dans Firebase Console → Authentication

3. **Vider le cache**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Ajouter des logs**
   ```dart
   print('User UID: ${FirebaseAuth.instance.currentUser?.uid}');
   print('Auth state: ${FirebaseAuth.instance.currentUser}');
   ```

---

## 📝 Commandes útiles

### **Tester les permissions:**

```bash
# Depuis Firebase Console - Simuler les règles
# Rules → Simulator (onglet)
# Authentifié: true
# Path: parking_slots
# Operation: write
```

### **Vérifier les collections:**

```bash
# Dans Firebase Console → Firestore
# Voir la structure complète:
# - parking_slots
# - reservations
# - payments
# - qr_codes
# - users
# - parkings
# - notifications
```

---

## Règles appliquées avec succès

Après cette correction, vous devriez voir:

```
Firebase initialisé avec succès
Initializing parking slots...
Parking slots initialized successfully
Suppression des extra slots complétée
```

Au lieu de:
```
 Error deleting extra floor 2 slots: Missing or insufficient permissions.
```

---

## 📖 Fichiers de référence

- **Règles**: [FIRESTORE_RULES.txt](FIRESTORE_RULES.txt)
- **Configuration**: [FIRESTORE_RULES_SETUP.md](FIRESTORE_RULES_SETUP.md)
- **Guide complet**: [FIRESTORE_IMAGE_STORAGE_CONFIG.md](FIRESTORE_IMAGE_STORAGE_CONFIG.md)

---

**Les permissions sont maintenant correctes! 🔐**

Relancez l'application et l'erreur devrait être résolue.
