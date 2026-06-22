# ⚡ Guide rapide - Correction permissions Firestore

## 3 étapes pour corriger l'erreur

### **1️⃣ Copier les nouvelles règles**

Ouvrez: **c:\Users\Walid NOUBIR\parkino-mobile-app\FIRESTORE_RULES.txt**

Sélectionnez **TOUT** le contenu et copiez-le.

---

### **2️⃣ Appliquer dans Firebase Console**

1. Allez à: https://console.firebase.google.com
2. Projet: **parkino-mobile-app**
3. **Firestore Database**
4. Onglet: **Rules**
5. **Supprimer** le contenu actuel
6. **Coller** les nouvelles règles
7. **Cliquer** sur "Publish" (bleu)
8. **Attendre** la confirmation

**Temps: ~1 minute**

---

### **3️⃣ Relancer l'app**

```bash
# Dans le terminal Flutter:
# Appuyez sur: R
# Ou exécutez:
flutter run
```

---

## Résultat attendu

**Avant (Erreur):**
```
 Error deleting extra floor 2 slots: Missing or insufficient permissions.
```

**Après (Succès):**
```
Firebase initialisé avec succès
Initializing parking slots...
Parking slots initialized successfully
```

---

## 📞 Si ça ne fonctionne pas

1. **Vérifier** que le bouton **Publish** a bien été cliqué
2. **Attendre** 30 secondes que les règles se propagent
3. **Nettoyer** l'app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
4. **Consulter**: [FIRESTORE_PERMISSIONS_FIX.md](FIRESTORE_PERMISSIONS_FIX.md)

---

**C'est tout! 🎉**
