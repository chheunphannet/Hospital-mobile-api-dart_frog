# Hospital Mobile App & REST API: MongoDB NoSQL Schema Design Specification (v2)

## 1. Executive Architecture Overview & MongoDB Modeling Strategy

This document provides the complete MongoDB NoSQL database schema specification (Version 2.0) for a multi-branch hospital mobile application and REST API backend. Modern healthcare platforms demand high read performance for public discovery features—such as hospital branches, specialized clinics, doctor profiles, medical checkup packages, news announcements, and health tips—alongside strict write consistency, secure session token rotation, atomic appointment booking workflows, patient feedback tracking, and an AI-driven Retrieval-Augmented Generation (RAG) medical assistant.

### 1.1 Core Architectural Principles
To ensure low query latency (sub-100ms API response times), horizontal scalability, and strict historical audit capability, this schema follows three core MongoDB data modeling strategies:

1. **Embedded Sub-Documents for Bounded, Co-accessed Data**: Entities that are strictly owned by a parent document, always retrieved together, and bounded in size (such as rich text `contentBlocks` in news/tips, itemized `inclusions` in medical packages, and individual `messages` within AI chat sessions) are embedded directly inside parent collections.
2. **Referencing for High-Cardinality and Dynamic Entities**: High-cardinality collections that grow continuously or require independent lifecycle management (such as `appointments` referencing `users` and `doctors`, or `refresh_tokens` referencing `users`) utilize `ObjectId` references.
3. **Point-in-Time Snapshotting for Historical Consistency**: To prevent historical audit distortion when a patient updates their personal profile (such as changing their phone number or legal name), operational collections like `appointments` store an embedded `patientInfo` snapshot captured at the exact moment of booking.

### 1.2 Authentication Infrastructure: Dual Local & Google OAuth 2.0 Support
Version 2.0 expands identity governance to support hybrid authentication:
- **Local Credential Authentication**: Users registering via email and password have a hashed password (`passwordHash`) generated via bcrypt/Argon2.
- **Google OAuth 2.0 Integration**: Users authenticating via Google Sign-In populate `googleId` (Google unique `sub` claim), `authProvider: "google"`, `avatarUrl`, and automatic `isEmailVerified: true`, leaving `passwordHash` set to `null`.
- **Sparse Unique Indexing**: To support both login methods, `googleId` uses a sparse unique index, ensuring non-Google users with `null` fields do not violate uniqueness constraints.

---

## 2. Comprehensive Collection Schemas & Data Models

### 2.1 Identity & Session Management

#### `users` Collection
Stores registered patient profile details, authentication credentials (local password hash or Google OAuth metadata), contact details, and demographic info.

```json
{
  "_id": ObjectId("6702e1a4f1a2b3c4d5e6f701"),
  "email": "chhernphannet0001@example.com",
  "phoneNumber": "098000999",
  "passwordHash": "$2b$12$password_hash_placeholder",
  "googleId": null,
  "authProvider": "local",
  "avatarUrl": "https://example.com/avatars/patient-701.jpg",
  "isEmailVerified": true,
  "personalInfo": {
    "firstName": "Phanet",
    "lastName": "Chheun",
    "dob": ISODate("2002-05-14T00:00:00Z"),
    "gender": "Female",
    "nationality": "Cambodian",
    "maritalStatus": "Single"
  },
  "location": {
    "address": "Phnom Penh, Cambodia",
    "city": "Phnom Penh"
  },
  "role": "Patient",
  "createdAt": ISODate("2026-10-01T08:00:00Z"),
  "updatedAt": ISODate("2026-10-06T10:00:00Z")
}
```

*Google OAuth 2.0 Example Document*:
```json
{
  "_id": ObjectId("6702e1a4f1a2b3c4d5e6f702"),
  "email": "sodara.patient@example.com",
  "phoneNumber": "012345678",
  "passwordHash": null,
  "googleId": "google_oauth_sub_109876",
  "authProvider": "google",
  "avatarUrl": "https://example.com/avatars/google-user.jpg",
  "isEmailVerified": true,
  "personalInfo": {
    "firstName": "Sodara",
    "lastName": "Nuth",
    "dob": ISODate("1995-08-20T00:00:00Z"),
    "gender": "Male",
    "nationality": "Cambodian",
    "maritalStatus": "Married"
  },
  "location": {
    "address": "Chamkarmon, Phnom Penh",
    "city": "Phnom Penh"
  },
  "role": "Patient",
  "createdAt": ISODate("2026-10-07T09:15:00Z"),
  "updatedAt": ISODate("2026-10-07T09:15:00Z")
}
```

#### `refresh_tokens` Collection
Manages active JWT refresh sessions using cryptographic token hashes, device fingerprints, and automatic TTL expiration.

> **Schema Correction (v2.0)**: The user identification field has been standardized from `username` to `email` for complete API contract consistency with the `users` collection.

```json
{
  "_id": ObjectId("6702e200f1a2b3c4d5e6f702"),
  "tokenHash": "token_hash_a1b2c3d4e5f6",
  "userId": ObjectId("6702e1a4f1a2b3c4d5e6f701"),
  "email": "chhernphannet0001@example.com",
  "role": "Patient",
  "branchId": ObjectId("6702e300f1a2b3c4d5e6f710"),
  "deviceInfo": {
    "deviceId": "iPhone14,2-UUID-9876",
    "platform": "iOS",
    "ipAddress": "192.168.1.10"
  },
  "expiresAt": ISODate("2026-11-06T14:00:00Z"),
  "createdAt": ISODate("2026-10-06T14:00:00Z"),
  "isRevoked": false
}
```

---

### 2.2 Hospital Structure & Staffing

#### `branches` Collection
Represents physical hospital facilities, storing spatial coordinates for location-based branch discovery, contact numbers, and equipment highlights.

```json
{
  "_id": ObjectId("6702e300f1a2b3c4d5e6f710"),
  "name": "Doung Ngeap Branch",
  "code": "DNG",
  "contactNumbers": [
    "081 811 789",
    "078 233 789",
    "096 6233 789"
  ],
  "email": "info.dng@example.com",
  "address": "Street 271, Phnom Penh, Cambodia",
  "location": {
    "type": "Point",
    "coordinates": [104.916012, 11.545622]
  },
  "roomPhotos": [
    "https://example.com/branches/dng/deluxe-room.jpg",
    "https://example.com/branches/dng/icu-wing.jpg"
  ],
  "hardwareDetails": "3.0T MRI, 128-Slice CT Scanner, 4D Ultrasound Diagnostic Suite",
  "isActive": true
}
```

#### `clinics` Collection
Represents specialized medical departments and clinical divisions across hospital branches.

```json
{
  "_id": ObjectId("6702e350f1a2b3c4d5e6f715"),
  "name": "Obstetric Clinic",
  "code": "OBSTETRIC",
  "description": "Comprehensive maternal, prenatal, and neonatal medical care.",
  "logoUrl": "https://example.com/clinics/obstetric-logo.png",
  "supportedBranchIds": [
    ObjectId("6702e300f1a2b3c4d5e6f710"),
    ObjectId("6702e301f1a2b3c4d5e6f711")
  ],
  "isActive": true
}
```

#### `doctors` Collection
Contains medical practitioner profiles, clinical specialties, languages spoken, and branch affiliations.

```json
{
  "_id": ObjectId("6702e400f1a2b3c4d5e6f720"),
  "name": "Dr. Nuth Sodara",
  "title": "Obstetrician and Gynecologist",
  "clinicId": ObjectId("6702e350f1a2b3c4d5e6f715"),
  "branchIds": [
    ObjectId("6702e300f1a2b3c4d5e6f710")
  ],
  "photoUrl": "https://example.com/doctors/dr-nuth-sodara.jpg",
  "bio": "Specialist in maternal-fetal medicine and high-risk pregnancy care with over 15 years of clinical practice.",
  "languagesSpoken": ["Khmer", "English", "French"],
  "qualifications": [
    "MD - University of Health Sciences",
    "Diploma in Maternal-Fetal Medicine (France)"
  ],
  "isAvailableForBooking": true
}
```

---

### 2.3 Medical Packages & Promotional Offers

#### `packages` Collection
Models promotional healthcare checkups, antenatal packages, and medical check lists using embedded sub-documents for inclusions.

```json
{
  "_id": ObjectId("6702e500f1a2b3c4d5e6f730"),
  "title": "Antenatal Program (12th Weeks)",
  "department": "Obstetric",
  "price": 688.00,
  "currency": "USD",
  "posterUrl": "https://example.com/packages/antenatal-12w.jpg",
  "isLimitedOffer": true,
  "isActive": true,
  "inclusions": {
    "specialistConsultationsCount": 12,
    "completeBloodCounts": 4,
    "labTests": [
      "Blood group & Rh typing",
      "Viral Marker Panel (Hepatitis B/C)",
      "Comprehensive Blood Sugar Panel",
      "Coagulation Function Profile",
      "Liver Function Panel",
      "Kidney Function Panel",
      "Prenatal Antibody & Rubella Screening",
      "Thyroid Function Panel",
      "Gestational Diabetes Screening (24th-28th weeks)"
    ],
    "urineAnalysisCount": 7,
    "ultrasoundsCount": 7,
    "ntScreening": true,
    "supplements": "90 tablets of Prenatal Multivitamins"
  },
  "metadata": {
    "prepaymentRequired": true,
    "instructions": "Patients must settle payment prior to checkup and arrive 10 minutes early with valid passport or ID.",
    "termsAndConditions": "Prices include doctor fee. Non-refundable. Package pricing settled directly with hospital only.",
    "branchNames": ["Doung Ngeap Branch", "Chamkarmon Branch"],
    "supportedBranchIds": [
      ObjectId("6702e300f1a2b3c4d5e6f710"),
      ObjectId("6702e301f1a2b3c4d5e6f711")
    ]
  },
  "createdAt": ISODate("2026-09-15T00:00:00Z")
}
```

---

### 2.4 Patient Appointments & Booking Engine

#### `appointments` Collection
Captures appointment requests submitted via the mobile app, embedding a point-in-time snapshot of patient contact info while referencing clinic, branch, and doctor entities.

```json
{
  "_id": ObjectId("6702e5b8f1a2b3c4d5e6f740"),
  "patientId": ObjectId("6702e1a4f1a2b3c4d5e6f701"),
  "patientInfo": {
    "name": "Chheun Phanet",
    "email": "chhernphannet0001@example.com",
    "phone": "098000999"
  },
  "bookingFor": "Myself",
  "referral": {
    "type": "Influencer",
    "sourceName": "Social Campaign"
  },
  "branchId": ObjectId("6702e300f1a2b3c4d5e6f710"),
  "department": "Obstetric",
  "doctorId": ObjectId("6702e400f1a2b3c4d5e6f720"),
  "scheduling": {
    "isEarliestAvailable": true,
    "requestedDate": ISODate("2026-10-10T09:00:00Z")
  },
  "personalRequest": "Please call before confirmation.",
  "status": "pending",
  "hospitalNotes": null,
  "createdAt": ISODate("2026-10-06T14:00:00Z")
}
```

---

### 2.5 Content Management & Patient Engagement

#### `news` Collection
Stores hospital announcements and multi-image news blocks designed for dynamic rendering in Flutter UI.

```json
{
  "_id": ObjectId("6702e600f1a2b3c4d5e6f750"),
  "title": "Orienda Hospital Expands New Obstetric Wing",
  "posterUrl": "https://example.com/news/obstetric-wing.jpg",
  "publishedAt": ISODate("2026-10-06T00:00:00Z"),
  "contentBlocks": [
    {
      "imageUrl": "https://example.com/news/ribbon-cutting.jpg",
      "caption": "Ribbon cutting ceremony at the new wing.",
      "text": "Orienda Hospital officially inaugurated its state-of-the-art obstetric wing..."
    },
    {
      "imageUrl": "https://example.com/news/fetal-monitor.jpg",
      "caption": "Advanced fetal monitoring equipment.",
      "text": "The new facility is equipped with next-generation monitoring devices..."
    }
  ]
}
```

#### `health_tips` Collection
Stores health educational articles and doctor talk transcriptions, categorized by clinic.

```json
{
  "_id": ObjectId("6702e650f1a2b3c4d5e6f755"),
  "title": "Understanding Trimester Milestones",
  "clinic": "Obstetric",
  "posterUrl": "https://example.com/tips/trimester-guide.jpg",
  "isPopular": true,
  "viewCount": 1540,
  "publishedAt": ISODate("2026-10-01T00:00:00Z"),
  "contentBlocks": [
    {
      "imageUrl": "https://example.com/tips/first-trimester.jpg",
      "caption": "First Trimester Care",
      "text": "During the first 12 weeks, crucial development takes place requiring regular checkups..."
    }
  ]
}
```

---

### 2.6 Patient Feedback & Admin Governance

#### `feedbacks` Collection
Captures patient complaints and feedback, embedding patient snapshot info while powering staff assignment and status tracking workflows.

```json
{
  "_id": ObjectId("6702e700f1a2b3c4d5e6f760"),
  "patientId": ObjectId("6702e1a4f1a2b3c4d5e6f701"),
  "personalInfo": {
    "firstName": "Phanet",
    "lastName": "Chheun",
    "dob": ISODate("2002-05-14T00:00:00Z"),
    "nationality": "Cambodian",
    "role": "Patient"
  },
  "contact": {
    "phoneNumber": "098000999",
    "email": "chhernphannet0001@example.com",
    "responseRequired": true
  },
  "visitDetails": {
    "clinicId": ObjectId("6702e350f1a2b3c4d5e6f715"),
    "clinicName": "Obstetric Clinic"
  },
  "feedback": {
    "type": "Complaint",
    "title": "Long waiting time at reception",
    "message": "Arrived 15 minutes early for ultrasound checkup, waited 45 minutes past appointment time."
  },
  "adminWorkflow": {
    "status": "pending",
    "priority": "high",
    "assignedStaffId": null,
    "internalNotes": []
  },
  "createdAt": ISODate("2026-10-06T15:40:00Z")
}
```

---

### 2.7 AI Assistant & RAG Knowledge Pipeline

#### `knowledge_chunks` Collection
Stores vectorized chunks of hospital documentation for MongoDB Atlas Vector Search.

```json
{
  "_id": ObjectId("6702e800f1a2b3c4d5e6f770"),
  "sourceType": "package",
  "sourceId": ObjectId("6702e500f1a2b3c4d5e6f730"),
  "metadata": {
    "title": "Antenatal Program (12th Weeks)",
    "clinic": "Obstetric Clinic",
    "branches": ["Doung Ngeap Branch", "Chamkarmon Branch"],
    "tags": ["pregnancy", "maternity", "ultrasound", "blood test", "screening"]
  },
  "content": "Antenatal Program (12th Weeks) priced at $688. Includes 12 Specialist Consultations, 4 Complete Blood counts, and lab tests for Hepatitis B/C, Blood Sugar, and Screening. Also includes 7 Obstetric Ultrasounds, NT Screening, and 90 tablets of Prenatal Multivitamins.",
  "embedding": [0.0124, -0.0452, 0.0891, 0.0032]
}
```

#### `chat_sessions` Collection
Stores patient AI conversation state and recommended action triggers.

```json
{
  "_id": ObjectId("6702e850f1a2b3c4d5e6f780"),
  "patientId": ObjectId("6702e1a4f1a2b3c4d5e6f701"),
  "startedAt": ISODate("2026-10-06T16:00:00Z"),
  "lastInteractionAt": ISODate("2026-10-06T16:02:00Z"),
  "messages": [
    {
      "sender": "user",
      "text": "What is included in the pregnancy package and how much is it?",
      "timestamp": "2026-10-06T16:00:05Z"
    },
    {
      "sender": "assistant",
      "text": "Our Antenatal Program (12th Weeks) is $688 at both Doung Ngeap and Chamkarmon branches. It includes 12 Specialist Consultations, lab tests, 7 Ultrasounds, and 90 multivitamin tablets.",
      "suggestedAction": {
        "type": "NAVIGATE_PACKAGE_DETAIL",
        "targetId": ObjectId("6702e500f1a2b3c4d5e6f730")
      },
      "timestamp": "2026-10-06T16:00:08Z"
    }
  ]
}
```

---

## 3. Relationship Matrix & Architectural Rationale

The table below summarizes the architectural decisions and modeling trade-offs across all 11 collections:

| Relationship Pair | Strategy | Technical Rationale & Performance Impact |
| :--- | :--- | :--- |
| **User → Refresh Tokens** | **Referencing** (`refresh_tokens.userId`) | Sessions grow dynamically per device login. Storing tokens separately avoids unbounded growth in `users` and enables per-session TTL cleanup. |
| **User → Google OAuth** | **Embedded Fields** (`googleId`, `authProvider`) | Native 1-to-1 identity attributes embedded directly in `users` for zero-join login verification. |
| **Branch → Clinics** | **Referencing** (`clinics.supportedBranchIds`) | Many-to-many relationship. Clinics operate across multiple branches; referencing prevents data duplication. |
| **Clinic → Doctors** | **Referencing** (`doctors.clinicId`) | Doctors have independent schedules and availability cycles. |
| **Package → Inclusions** | **Embedding** (`packages.inclusions`) | Bounded 1-to-1 relationship. Package inclusions are always fetched together on the package detail page. |
| **Appointment → Patient** | **Hybrid Snapshot** (`appointments.patientId` + `patientInfo`) | References `patientId` for relational queries, but embeds a snapshot of patient details to preserve historical audit accuracy. |
| **Article → Content Blocks** | **Embedding** (`news.contentBlocks`) | Bounded array of rich content blocks embedded in narrative order. Eliminates `$lookup` joins in Flutter. |
| **Feedback → Admin Workflow** | **Embedding** (`feedbacks.adminWorkflow`) | Ensures atomic updates (`$set`, `$push`) during feedback triaging without distributed transactions. |
| **Session → Messages** | **Embedding** (`chat_sessions.messages`) | Co-locates chat history for fast windowed retrieval during LLM prompt construction. |

---

## 4. Enterprise Indexing Strategy & Query Optimization

To maintain sub-100ms REST API response times, every collection must be equipped with targeted B-tree, Geospatial, TTL, or Vector indexes.

### 4.1 Master Indexing Matrix Across All Collections

| Collection | Indexed Field(s) | Index Type | Primary Technical Purpose |
| :--- | :--- | :--- | :--- |
| **`users`** | `email` | **Unique** | Fast logarithmic user login lookup & duplicate prevention. |
| **`users`** | `googleId` | **Sparse Unique** | Sub-millisecond Google OAuth authentication lookup. |
| **`refresh_tokens`** | `tokenHash` | **Unique** | Instant session validation during JWT access token rotation. |
| **`refresh_tokens`** | `expiresAt` | **TTL Index** | Auto-purges expired sessions (`expireAfterSeconds: 0`). |
| **`refresh_tokens`** | `userId` | Standard | Bulk session revocation upon logout from all devices. |
| **`branches`** | `location` | **2dsphere** | Spatial GPS proximity query (`$near`) for branch discovery. |
| **`branches`** | `code` | **Unique** | Fast lookup by branch code (e.g., `"DNG"`). |
| **`clinics`** | `code` | **Unique** | Unique identification for medical departments. |
| **`doctors`** | `branchIds` | Standard | Filtering doctors available at a specific branch. |
| **`doctors`** | `clinicId`, `isAvailableForBooking` | **Compound** | Fetching available doctors within a medical clinic. |
| **`packages`** | `metadata.supportedBranchIds`, `isActive` | **Compound** | Displaying active promotional checkup offers per branch. |
| **`appointments`** | `patientId`, `status`, `createdAt` | **Compound** | Fetching patient appointment history sorted chronologically. |
| **`appointments`** | `doctorId`, `scheduling.requestedDate` | **Compound Unique** | Doctor schedule availability lookup & double-booking prevention. |
| **`news`** | `publishedAt` | Standard | Chronological news feed ordering (`publishedAt: -1`). |
| **`health_tips`** | `clinic`, `isPopular`, `publishedAt` | **Compound** | Popular health tip feed filtering by clinic. |
| **`feedbacks`** | `adminWorkflow.status`, `adminWorkflow.priority` | **Compound** | Admin dashboard filtering for high-priority complaints. |
| **`chat_sessions`** | `patientId`, `lastInteractionAt` | **Compound** | Fetching patient chat history for AI assistant UI. |
| **`knowledge_chunks`** | `embedding` | **Atlas Vector Search** | Cosine similarity vector search for AI RAG pipeline. |

---

### 4.2 Complete MongoDB Shell Index Creation Scripts

Run the following script in `mongosh` to initialize all required indexes across your database:

```javascript
// 1. users Collection Indexes
db.users.createIndex({ "email": 1 }, { unique: true, name: "idx_users_email_unique" });
db.users.createIndex({ "googleId": 1 }, { unique: true, sparse: true, name: "idx_users_google_sparse" });

// 2. refresh_tokens Collection Indexes
db.refresh_tokens.createIndex({ "tokenHash": 1 }, { unique: true, name: "idx_tokens_hash_unique" });
db.refresh_tokens.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0, name: "idx_tokens_ttl" });
db.refresh_tokens.createIndex({ "userId": 1 }, { name: "idx_tokens_userId" });

// 3. branches Collection Indexes
db.branches.createIndex({ "location": "2dsphere" }, { name: "idx_branches_geo" });
db.branches.createIndex({ "code": 1 }, { unique: true, name: "idx_branches_code_unique" });

// 4. clinics Collection Indexes
db.clinics.createIndex({ "code": 1 }, { unique: true, name: "idx_clinics_code_unique" });

// 5. doctors Collection Indexes
db.doctors.createIndex({ "branchIds": 1 }, { name: "idx_doctors_branchIds" });
db.doctors.createIndex({ "clinicId": 1, "isAvailableForBooking": 1 }, { name: "idx_doctors_clinic_booking" });

// 6. packages Collection Indexes
db.packages.createIndex({ "metadata.supportedBranchIds": 1, "isActive": 1 }, { name: "idx_packages_branch_active" });

// 7. appointments Collection Indexes
db.appointments.createIndex({ "patientId": 1, "status": 1, "createdAt": -1 }, { name: "idx_appointments_patient_history" });
db.appointments.createIndex({ "doctorId": 1, "scheduling.requestedDate": 1 }, { name: "idx_appointments_doctor_schedule" });

// 8. news Collection Indexes
db.news.createIndex({ "publishedAt": -1 }, { name: "idx_news_published" });

// 9. health_tips Collection Indexes
db.health_tips.createIndex({ "clinic": 1, "isPopular": -1, "publishedAt": -1 }, { name: "idx_tips_clinic_popular" });

// 10. feedbacks Collection Indexes
db.feedbacks.createIndex({ "adminWorkflow.status": 1, "adminWorkflow.priority": 1 }, { name: "idx_feedbacks_admin_workflow" });

// 11. chat_sessions Collection Indexes
db.chat_sessions.createIndex({ "patientId": 1, "lastInteractionAt": -1 }, { name: "idx_chat_patient_recent" });
```

---

### 4.3 Technical Rationale: Indexing Decisions & Non-Indexed Fields

#### Why `email` and `tokenHash` MUST Be Indexed
1. **`email`**: The primary lookup field during authentication (`findOne({ email })`). Without an index, login requests force a full collection scan across all patient records, causing CPU spikes under load. The unique constraint also prevents duplicate user registrations during concurrent sign-ups.
2. **`tokenHash`**: Queried on every API request to `/auth/refresh`. A unique index ensures sub-millisecond session validation during token rotation.

#### Why `passwordHash` Should NOT Be Indexed
1. **Never Queried directly**: Authentication workflows lookup users by `email` or `googleId`, fetch the document, and pass `passwordHash` to application memory for comparison (`bcrypt.compare()`). An index on `passwordHash` would never be used by the query optimizer.
2. **High Entropy & RAM Bloat**: Password hashes are long, unique cryptographic strings. Indexing high-entropy strings bloats the B-Tree index size in RAM (WiredTiger working set) and increases write latency during password changes with zero performance benefit.

---

### 4.4 MongoDB Atlas Vector Search Configuration

For the AI RAG assistant (`knowledge_chunks` collection), configure the following Atlas Search index:

```json
{
  "mappings": {
    "dynamic": true,
    "fields": {
      "embedding": {
        "dimensions": 1536,
        "similarity": "cosine",
        "type": "knnVector"
      }
    }
  }
}
```

---

## 5. Security, Concurrency & Operational Governance

1. **Double-Booking Prevention**: High concurrency on doctor appointments is handled using MongoDB ACID transactions or conditional update queries with `status: "pending"` filters.
2. **Urgent Intent Filtering**: The backend API intercepts user chat inputs before vector search; urgent medical queries immediately trigger a hardcoded emergency assistance response card.
3. **Session Purging**: Expired JWT refresh tokens are automatically removed from disk by WiredTiger background threads via the TTL index on `expiresAt`.
