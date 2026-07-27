# ASK IMAN — Next Features: Charity + Family Control + Admin Panel

## Overview

Add two major features to the existing ASK IMAN app, with a separate web-based admin panel for management. All data lives in the **same Firebase project** (Firestore, Storage, Auth, FCM). Existing features remain **completely untouched** — no UI changes, no refactoring, no regressions.

---

## Architecture

```
Firebase Project (ask-iman-xxxxx)
├── Firestore (all data)
├── Storage (images / screenshots)
├── Authentication (users + admin custom claims)
├── Cloud Messaging FCM (push notifications)
└── Extensions → Trigger Email (free transactional emails)

Android App (Flutter)                    Admin Web (Flutter or React)
├── Charity screens                     ├── Dashboard
│   ├── Browse causes                   ├── Manage Causes (CRUD)
│   ├── Donate (upload proof)           ├── Confirm/Reject Donations
│   └── Request charity                 ├── Approve/Decline Requests
├── Family screens                      └── View Family Groups
│   ├── Create/Join group
│   ├── Create reminders
│   └── Streak tracking
├── Profile (My Donations, My Family)
└── [EVERYTHING ELSE UNCHANGED]
```

---

# PART 1: IN-APP FEATURES (Android — ask_iman)

---

## 1A. CHARITY FEATURE

### Collections & Schema

**`charity_causes`**
```
id: string (auto)
title: string
description: string (multi-line)
goalAmount: number
raisedAmount: number (default 0)
accountDetails: {
  bankName: string,
  accountNumber: string,
  iban: string,
  accountHolder: string
}
imageUrl: string (Storage URL)
status: 'active' | 'completed' | 'paused' | 'archived'
createdAt: timestamp
updatedAt: timestamp
createdBy: string (admin uid)
```

**`charity_donations`**
```
id: string (auto)
causeId: string (ref → charity_causes)
userId: string (ref → users)
userDisplayName: string
userEmail: string
amount: number
screenshotUrl: string (Storage path)
note: string (optional)
status: 'pending' | 'confirmed' | 'rejected'
adminNote: string (optional)
createdAt: timestamp
confirmedAt: timestamp (null until confirmed)
confirmedBy: string (admin uid, null until confirmed)
```

**`charity_requests`**
```
id: string (auto)
userId: string
userDisplayName: string
userEmail: string
amount: number
idCardNumber: string
accountDetails: {
  bankName: string,
  accountNumber: string
}
legalProfile: {
  fullName: string,
  address: string,
  phone: string
}
supportingPhotos: [string, string] (2 Storage URLs)
description: string (multi-line)
status: 'pending' | 'approved' | 'declined' | 'cancelled'
adminNote: string (optional)
respondedAt: timestamp (null until actioned)
createdAt: timestamp
```

### Screens (in app)

| Screen | Description |
|---|---|
| `CharityListScreen` | Lists all active causes with progress bars, goal amount, raised amount |
| `CharityDetailScreen` | Full cause details + account info + Donate button + Request button |
| `DonateScreen` | Amount field + photo picker (screenshot) + optional note → submit |
| `RequestCharityScreen` | Multi-step form: personal info → account details → legal profile → 2 photos → description → submit |
| `MyCharityScreen` | Tabbed: My Donations (list with status) / My Requests (list with status) |

### Navigation Entry Points
- **Home screen** — "Events" tile (index 5) currently shows "Coming Soon" → redirect to CharityListScreen instead
- **Profile screen** — add "My Charity" item linking to MyCharityScreen

### Edge Cases

| Edge Case | Solution |
|---|---|
| **Concurrent admin confirmations** | Use Firestore `runTransaction`: read current `raisedAmount`, add donation amount, write back. If another admin confirmed simultaneously, the transaction retries automatically. |
| **Goal already reached** | Before submit, client checks `raisedAmount < goalAmount`. Server-side: Firestore Security Rules deny write if `raisedAmount >= goalAmount` (via custom function). Show "100% Funded" badge + disable button. |
| **User submits donation, then deletes account** | Donation stays as `pending`; admin still sees it; admin note can mark as orphaned. |
| **Screenshot upload fails mid-way** | Use Firebase Storage upload with `putFile` and `.catch` — show retry UI. Store URL only after upload success. |
| **Empty/0 amount entered** | Validation: amount must be > 0. |
| **Wrong file type (not image)** | Client: accept only `image/jpeg`, `image/png`. Server: Security Rules check content-type. |
| **Photo too large** | Compress on client side to max 1024px width, max 5MB. |
| **User submits request, then edits it** | Not allowed — no edit after submit. User must cancel and re-submit. |
| **Request cancelled after admin started reviewing** | Allow cancel only if `status == 'pending'`. Admin sees cancelled requests as separate status. |
| **Email fails to send** | Trigger Email extension retries 3 times with exponential backoff. Log failure in Firestore for admin visibility. |
| **User requests more than goal amount** | Allow any amount; admin approves/declines based on merit + availability. |
| **Fully funded cause gets another donation** | Transactions prevent `raisedAmount` exceeding `goalAmount` — donation auto-rejected at transaction level. |
| **Bank account details change mid-cause** | Admin edits `charity_causes.accountDetails`; old donations reference the cause, not the account directly. |

---

## 1B. FAMILY / CHILD CONTROL FEATURE

### Collections & Schema

**`family_groups`**
```
id: string (auto)
name: string
createdBy: string (uid)
inviteCode: string (6-char alphanumeric, unique)
members: [string, string, ...] (array of uids)
createdAt: timestamp
isActive: boolean (default true)
```

**`family_reminders`**
```
id: string (auto)
groupId: string (ref → family_groups)
createdBy: string (uid)
title: string
type: 'namaz' | 'tasbeeh' | 'quran' | 'custom'
description: string (optional)
schedule: {
  days: ['monday', 'tuesday', ...]  // empty = every day
  time: '05:00'  // 24h format
}
frequency: 'daily' | 'weekly' | 'once' | 'custom'
isActive: boolean (default true)
createdAt: timestamp
```

**`family_streaks`**
```
id: string (auto)
reminderId: string (ref → family_reminders)
groupId: string
userId: string
currentStreak: number (default 0)
longestStreak: number (default 0)
lastCompletedDate: string (YYYY-MM-DD, null if never)
completedDates: [string, string, ...] (array of YYYY-MM-DD)
createdAt: timestamp
updatedAt: timestamp
```

**`family_activity`**
```
id: string (auto)
groupId: string
userId: string
type: 'completed' | 'joined' | 'left' | 'streak_milestone'
message: string
createdAt: timestamp
```

### FCM Notification Document

**`notifications`** (in-app notification center)
```
id: string (auto)
userId: string (target)
title: string
body: string
type: 'family_reminder' | 'streak_update' | 'charity_update'
data: map (extra payload)
read: boolean (default false)
createdAt: timestamp
```

### Screens (in app)

| Screen | Description |
|---|---|
| `FamilyHomeScreen` | My Groups list + Create Group button + Join Group input |
| `CreateGroupScreen` | Group name → created → shows invite code for sharing |
| `JoinGroupScreen` | Enter 6-char invite code → join |
| `GroupDetailScreen` | Members list with streaks, Reminders list, Activity log, Create Reminder button |
| `CreateReminderScreen` | Title, type selector, schedule (days + time), description |
| `ReminderDetailScreen` | Show when due, Mark Complete button, who completed, group streak view |

### Key Logic — Streak Calculation

```
On "Mark Complete" tap:
  today = DateTime.now().toYyyyMmDd()
  if lastCompletedDate == today:
    // Already completed today — do nothing
  else if lastCompletedDate == yesterday:
    currentStreak += 1
  else:
    currentStreak = 1
  if currentStreak > longestStreak:
    longestStreak = currentStreak
  lastCompletedDate = today
  completedDates.add(today)
  if currentStreak % 7 == 0:
    // Milestone: post to family_activity
```

### Navigation Entry Points
- **Bottom nav** — add "Family" as a 5th tab, OR put it under "Community" tab as a sub-section
- **Profile** — add "My Family" entry

### Edge Cases

| Edge Case | Solution |
|---|---|
| **Invite code collision** | Generate code, check uniqueness via `.where('inviteCode', isEqualTo: code).get()`. Retry if exists (5 max tries, then error). |
| **Member leaves group** | Remove uid from `members` array. Their streak data stays (for history). |
| **Group creator leaves** | Transfer ownership to next member by join order. If group empty, auto-delete after 30 days (Cloud Function). |
| **Multiple completions same day** | Check `lastCompletedDate == today` — reject duplicate. |
| **Streak miss due to timezone** | All dates stored in UTC YYYY-MM-DD. Streak based on UTC day. User sees notification in their own timezone. |
| **Phone offline when reminder fires** | FCM queue delivers on reconnect. Also: app shows pending reminders on next open. |
| **Notification not clicked** | Stays in `notifications` collection with `read: false`. User can check notification center later. |
| **Reminder fires for deleted group** | When loading reminder, check group still active. If not, delete reminder. |
| **5 friends = 5 different timezones** | Each reminder has creator's timezone stored. When checking, compare against each user's known timezone (stored in user profile). For MVP: use UTC for all. |
| **User deletes account** | Remove from all groups' `members` arrays. If they're the only member, mark group inactive. |
| **Max members per group** | Enforce 20 max client-side + Firestore Security Rules check. |
| **FCM rate limits** | Max 1 notification per reminder per user per day. Batch sends use FCM topic (per group). |

---

# PART 2: SEPARATE ADMIN WEB PANEL

## Approach

Create a **new, independent project** (not modifying ask_iman). This is a web app that uses the **same Firebase project** for authentication and data.

**Options:**
- **Flutter Web** (recommended if the team knows Flutter): `flutter create --platforms=web admin_panel`
- **React + Firebase SDK** (lighter, faster to build): `npx create-react-app admin-panel`

Both options are **free to host** on Firebase Hosting (`admin.askiman.com`) or on Namecheap.

## Pages / Routes

```
/                     → Login screen (Firebase Auth + admin email/password)
/dashboard            → Summary cards, quick stats
/causes               → List all charity causes (CRUD)
/causes/new           → Create new cause
/causes/:id/edit      → Edit cause
/donations            → List all donations (filter by status)
/donations/:id        → View donation detail + confirm/reject
/requests             → List all charity requests (filter by status)
/requests/:id         → View request detail + approve/decline
/family-groups        → List all family groups
/family-groups/:id    → View group details, members, reminders
/settings             → Admin profile, notification settings
```

## Firebase Admin SDK Setup

Admin accounts get a **custom claim**:
```javascript
// Run once from a Cloud Function or local script
admin.auth().setCustomUserClaims(uid, { admin: true })
```

Then Firestore Security Rules check:
```
match /charity_donations {
  allow read: if request.auth != null;
  allow write: if request.auth.token.admin == true;
}
match /charity_causes {
  allow read: if true;
  allow write: if request.auth.token.admin == true;
}
```

## Admin Features Detail

### Dashboard
- Total active causes
- Total raised (sum of confirmed donations)
- Pending donations count
- Pending requests count
- Quick links to each pending section

### Manage Causes
- **Create**: Title, description, goal amount (number), account details (bank name, number, IBAN, holder), upload image → writes to `charity_causes`
- **Edit**: Update any field
- **Status toggle**: Active / Pause / Complete / Archive
- **Delete**: Only allowed if `raisedAmount == 0` (no confirmed donations). If donations exist, status = 'archived' instead.

### Confirm / Reject Donations
- List view: avatar + name + amount + status badge (colored)
- Detail view (tap row):
  - User info (name, email, user ID link)
  - Amount donated
  - Screenshot displayed in full (clickable lightbox)
  - Optional note from user
  - **Confirm** button → Firestore transaction: `raisedAmount += donation.amount`, status = 'confirmed'
  - **Reject** button → textarea for admin note, status = 'rejected'
- Filter by status: All / Pending / Confirmed / Rejected

### Approve / Decline Requests
- List view: name + amount + status badge
- Detail view:
  - All submitted data displayed
  - 2 supporting photos (lightbox)
  - **Approve** → status = 'approved', email sent to user via Trigger Email
  - **Decline** → reason textarea required, status = 'declined', email sent

### View Family Groups
- List all groups with member count + creation date
- Detail view: members list, active reminders, activity log
- Ability to delete group (if violating terms)
- Ability to remove member from group

## Hosting

**Firebase Hosting** (recommended — tight integration):
```
firebase init hosting
firebase deploy --only hosting
```
Free tier: 10GB storage, 360MB/day bandwidth.

**Namecheap** (if preferred):
```
flutter build web --release
# or: npm run build
# upload build/web/ or build/ to public_html/admin/
```

---

# PART 3: FIREBASE CONFIGURATION

## Firestore Indexes

Create these composite indexes for queries:

| Collection | Fields | Order |
|---|---|---|
| `charity_donations` | `causeId` Asc, `createdAt` Desc | — |
| `charity_donations` | `status` Asc, `createdAt` Desc | — |
| `charity_requests` | `userId` Asc, `createdAt` Desc | — |
| `charity_requests` | `status` Asc, `createdAt` Desc | — |
| `family_streaks` | `groupId` Asc, `userId` Asc | — |
| `family_streaks` | `reminderId` Asc, `currentStreak` Desc | — |
| `family_activity` | `groupId` Asc, `createdAt` Desc | — |

## Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAdmin() {
      return request.auth.token.admin == true;
    }
    function isLoggedIn() {
      return request.auth != null;
    }

    // Charity causes — read: anyone, write: admin only
    match /charity_causes/{doc} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    // Charity donations — create: logged-in user (own doc only), read: admin + owner
    match /charity_donations/{doc} {
      allow read: if isAdmin() || request.auth.uid == resource.data.userId;
      allow create: if isLoggedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAdmin();
    }

    // Charity requests — create: logged-in user (own doc only), read: admin + owner
    match /charity_requests/{doc} {
      allow read: if isAdmin() || request.auth.uid == resource.data.userId;
      allow create: if isLoggedIn() && request.resource.data.userId == request.auth.uid;
      allow update: if isAdmin();
      allow delete: if false;  // never delete, only update status
    }

    // Family groups
    match /family_groups/{doc} {
      allow read: if isLoggedIn() && request.auth.uid in resource.data.members;
      allow create: if isLoggedIn();
      allow update: if isLoggedIn() && request.auth.uid in resource.data.members;
      allow delete: if isAdmin();
    }

    // Family reminders
    match /family_reminders/{doc} {
      allow read, write: if isLoggedIn();
    }

    // Family streaks
    match /family_streaks/{doc} {
      allow read, write: if isLoggedIn();
    }

    // Notifications
    match /notifications/{doc} {
      allow read: if isLoggedIn() && request.auth.uid == resource.data.userId;
      allow create: if true;
      allow update: if isLoggedIn() && request.auth.uid == resource.data.userId;
    }
  }
}
```

## Firebase Storage Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /charity/screenshots/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null
                    && request.resource.size < 5 * 1024 * 1024
                    && request.resource.contentType.matches('image/.*');
    }
    match /charity/requests/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null
                    && request.resource.size < 5 * 1024 * 1024
                    && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Cloud Function — Send Email on Status Change

A 2-line Firebase Cloud Function (free tier, 2M invocations/month):

```javascript
exports.onCharityRequestStatusChange = functions.firestore
  .document('charity_requests/{id}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.status === 'pending' && after.status === 'approved') {
      await sendEmail({
        to: after.userEmail,
        subject: 'Your Charity Request Has Been Approved',
        body: `Dear ${after.userDisplayName}, your request for $${after.amount} has been approved. ${after.adminNote || ''}`
      });
    }
    if (before.status === 'pending' && after.status === 'declined') {
      await sendEmail({
        to: after.userEmail,
        subject: 'Your Charity Request Status',
        body: `Dear ${after.userDisplayName}, your request was declined. Reason: ${after.adminNote || 'No reason provided.'}`
      });
    }
  });
```

## FCM — Sending Family Reminders

Use Firebase Cloud Functions + Cloud Scheduler (free tier):

```javascript
// Scheduled function runs every 10 minutes
exports.checkReminders = functions.pubsub.schedule('every 10 minutes').onRun(async () => {
  const now = new Date();
  const time = `${String(now.getHours()).padStart(2,'0')}:${String(now.getMinutes()).padStart(2,'0')}`;
  const day = ['sunday','monday','tuesday','wednesday','thursday','friday','saturday'][now.getDay()];
  
  const reminders = await admin.firestore()
    .collection('family_reminders')
    .where('isActive', '==', true)
    .where('schedule.time', '<=', time)
    .get();
  
  for (const doc of reminders.docs) {
    const reminder = doc.data();
    // Check day match
    if (reminder.schedule.days.length > 0 && !reminder.schedule.days.includes(day)) continue;
    // Send to all group members via FCM topic
    await admin.messaging().sendToTopic(`group_${reminder.groupId}`, {
      notification: { title: reminder.title, body: reminder.description || 'Time for your reminder!' }
    });
  }
});
```

---

# PART 4: IMPLEMENTATION ORDER

## Phase 1 — Backend & Admin (Week 1-2)
- [ ] Set up Firestore collections and indexes
- [ ] Apply Security Rules
- [ ] Create admin custom claim function
- [ ] Build Admin Web Panel (Flutter Web or React)
  - [ ] Firebase Auth login
  - [ ] Dashboard page
  - [ ] Causes CRUD
  - [ ] Donations review
  - [ ] Requests review

## Phase 2 — Charity (In-App, Week 3-4)
- [ ] Charity data layer (repository/models)
- [ ] CharityListScreen + CharityDetailScreen
- [ ] DonateScreen (with photo upload)
- [ ] RequestCharityScreen (multi-step form)
- [ ] MyCharityScreen
- [ ] Navigation integration

## Phase 3 — Family Control (In-App, Week 5-6)
- [ ] Family data layer
- [ ] CreateGroupScreen + JoinGroupScreen
- [ ] FamilyHomeScreen (list groups)
- [ ] GroupDetailScreen (members, streaks, reminders)
- [ ] CreateReminderScreen
- [ ] Streak logic + Mark Complete
- [ ] FCM notification setup
- [ ] Navigation integration

## Phase 4 — Polish (Week 7)
- [ ] Email integration (Trigger Email)
- [ ] Error handling + loading states
- [ ] Edge case testing
- [ ] Admin panel final touches
