# Hospital Mobile App & REST API: MongoDB NoSQL Schema Design Specification

## 1. Executive Architecture Overview & MongoDB Modeling Strategy

This document specifies the MongoDB NoSQL schema design for a multi-branch hospital mobile application and REST API backend. Modern hospital management platforms require high read throughput for promotional and organizational discovery (branches, clinics, doctor profiles, medical packages, and health articles) alongside consistent write isolation for session authentication, appointment bookings, patient feedback workflows, and an AI-driven Retrieval-Augmented Generation (RAG) assistant.

### 1.1 Core Architectural Principles
To maximize query efficiency, lower API latency, and maintain data integrity, this schema adheres to three foundational MongoDB modeling principles:

1. **Embedded Sub-Documents for Bounded, Co-accessed Data**: Atomic entities that are accessed together and have bounded growth (such as rich text `contentBlocks` in news articles, structured inclusions in medical packages, and message entries within chat sessions) are embedded directly within parent documents.
2. **Referencing for High-Cardinality and Dynamic Entities**: High-cardinality collections and independent entities that grow indefinitely or require independent administrative lifecycle management (such as `appointments` linking to `users`, `doctors`, and `branches`, or `refresh_tokens` referencing `users`) use `ObjectId` references.
3. **Point-in-Time Snapshotting for Historical Consistency**: To prevent historical audit distortion when a patient updates their personal profile, operational collections like `appointments` store an embedded `patientInfo` snapshot at the moment of booking rather than relying exclusively on live joins.

---

## 2. Comprehensive Collection Schemas & Data Models

### 2.1 Identity & Session Management

#### `users` Collection
Stores registered patient profile details, contact information, and demographic metadata required for account management and personal booking.

```json
{
  "_id": ObjectId("6702e1a4f1a2b3c4d5e6f701"),
  "email": "chhernphannet0001@gmail.com",
  "phoneNumber": "098000999",
  "passwordHash": "$2b$12$eImiTXuWVxfM37uY4JANjO...hash",
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

#### `refresh_tokens` Collection
Manages JWT refresh sessions using hashed tokens, device metadata, and a Time-To-Live (TTL) index to enforce automatic session expiration and support secure token rotation.

```json
{
  "_id": ObjectId("6702e200f1a2b3c4d5e6f702"),
  "tokenHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "userId": ObjectId("6702e1a4f1a2b3c4d5e6f701"),
  "username": "chhernphannet0001@gmail.com",
  "role": "Patient",
  "branchId": ObjectId("6702e300f1a2b3c4d5e6f710"),
  "deviceInfo": {
    "deviceId": "iPhone14,2-UUID-9876",
    "platform": "iOS",
    "ipAddress": "203.144.88.12"
  },
  "expiresAt": ISODate("2026-11-06T14:00:00Z"),
  "createdAt": ISODate("2026-10-06T14:00:00Z"),
  "isRevoked": false
}
```

---

### 2.2 Hospital Structure & Staffing

#### `branches` Collection
Represents physical hospital branch facilities, containing spatial coordinates for location-based branch selection, contact numbers, and gallery assets.

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
  "email": "info.dng@oriendahospital.com",
  "address": "Street 271, Phnom Penh, Cambodia",
  "location": {
    "type": "Point",
    "coordinates": [104.916012, 11.545622]
  },
  "roomPhotos": [
    "https://cdn.hospital.com/branches/dng/deluxe-room.jpg",
    "https://cdn.hospital.com/branches/dng/icu-wing.jpg"
  ],
  "hardwareDetails": "配备 3.0T MRI, 128-Slice CT Scanner, 和 4D 彩超诊断仪",
  "isActive": true
}
```

#### `clinics` Collection
Represents medical departments and specialized clinics across hospital branches.

```json
{
  "_id": ObjectId("6702e350f1a2b3c4d5e6f715"),
  "name": "Obstetric Clinic",
  "code": "OBSTETRIC",
  "description": "Comprehensive maternal, prenatal, and neonatal medical care.",
  "logoUrl": "https://cdn.hospital.com/clinics/obstetric-logo.png",
  "supportedBranchIds": [
    ObjectId("6702e300f1a2b3c4d5e6f710"),
    ObjectId("6702e301f1a2b3c4d5e6f711")
  ],
  "isActive": true
}
```

#### `doctors` Collection
Contains medical practitioner profiles, clinical specialties, spoken languages, and qualifications used for appointment scheduling and AI vector search retrieval.

```json
{
  "_id": ObjectId("6702e400f1a2b3c4d5e6f720"),
  "name": "Dr. Nuth Sodara",
  "title": "Obstetrician and Gynecologist",
  "clinicId": ObjectId("6702e350f1a2b3c4d5e6f715"),
  "branchIds": [
    ObjectId("6702e300f1a2b3c4d5e6f710")
  ],
  "photoUrl": "https://cdn.hospital.com/doctors/dr-nuth-sodara.jpg",
  "bio": "Specialist in maternal-fetal medicine and high-risk pregnancy care with over 15 years of clinical practice.",
  "languagesSpoken": ["Khmer", "English", "Spanish"],
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
Models multi-item promotional medical checkups and maternal programs using hierarchical sub-documents for structured inclusions and terms.

```json
{
  "_id": ObjectId("6702e500f1a2b3c4d5e6f730"),
  "title": "Antenatal Program (12th Weeks)",
  "department": "Obstetric",
  "price": 688.00,
  "currency": "USD",
  "posterUrl": "https://cdn.hospital.com/packages/antenatal-12w.jpg",
  "isLimitedOffer": true,
  "inclusions": {
    "specialistConsultationsCount": 12,
    "completeBloodCounts": 4,
    "labTests": [
      "Blood group",
      "Hepatitis B",
      "Hepatitis C",
      "HIV",
      "Blood Sugar",
      "Coagulation Function Test",
      "Liver Function Test",
      "Kidney Function Test",
      "Syphilis",
      "Rubella",
      "Toxoplasmosis",
      "Electrolyte",
      "Thyroid Function",
      "Vaginal CBS Screening (35th-37th weeks)",
      "Gestational Diabetes Screening (24th-28th weeks)"
    ],
    "urineAnalysisCount": 7,
    "ultrasoundsCount": 7,
    "ntScreening": true,
    "supplements": "90 tablets of SELANCY Multivitamins"
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
Captures appointment requests made via the mobile app, embedding a point-in-time snapshot of patient details while linking to clinic, branch, and doctor entities.

```json
{
  "_id": ObjectId("6702e5b8f1a2b3c4d5e6f740"),
  "patientId": ObjectId("6702e1a4f1a2b3c4d5e6f701"),
  "patientInfo": {
    "name": "Chheun Phanet",
    "email": "chhernphannet0001@gmail.com",
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
Stores hospital announcements and multi-image news updates using an array of `contentBlocks` to ensure seamless rendering in Flutter WYSWYG components.

```json
{
  "_id": ObjectId("6702e600f1a2b3c4d5e6f750"),
  "title": "Orienda Hospital Expands New Obstetric Wing",
  "posterUrl": "https://cdn.hospital.com/news/obstetric-wing.jpg",
  "publishedAt": ISODate("2026-10-06T00:00:00Z"),
  "contentBlocks": [
    {
      "imageUrl": "https://cdn.hospital.com/news/ribbon-cutting.jpg",
      "caption": "Ribbon cutting ceremony at the new wing.",
      "text": "Orienda Hospital officially inaugurated its state-of-the-art obstetric wing..."
    },
    {
      "imageUrl": "https://cdn.hospital.com/news/fetal-monitor.jpg",
      "caption": "Advanced fetal monitoring equipment.",
      "text": "The new facility is equipped with next-generation monitoring devices..."
    }
  ]
}
```

#### `health_tips` Collection
Stores educational health articles and doctor talk transcriptions, categorized by clinic and tagged for popular feed views.

```json
{
  "_id": ObjectId("6702e650f1a2b3c4d5e6f755"),
  "title": "Understanding Trimester Milestones",
  "clinic": "Obstetric",
  "posterUrl": "https://cdn.hospital.com/tips/trimester-guide.jpg",
  "isPopular": true,
  "viewCount": 1540,
  "publishedAt": ISODate("2026-10-01T00:00:00Z"),
  "contentBlocks": [
    {
      "imageUrl": "https://cdn.hospital.com/tips/first-trimester.jpg",
      "caption": "First Trimester Care",
      "text": "During the first 12 weeks, crucial development takes place requiring regular checkups..."
    }
  ]
}
```

---

### 2.6 Patient Feedback & Admin Governance

#### `feedbacks` Collection
Captures patient complaints, suggestions, or praise, embedding contact and visit details while powering staff assignment and auto-escalation workflows.

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
    "email": "chhernphannet0001@gmail.com",
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

#### `knowledge_chunks` Collection (MongoDB Atlas Vector Search)
Serves as the high-dimensional vector store powering the AI medical assistant's semantic search pipeline.

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
  "content": "Antenatal Program (12th Weeks) priced at $688. Includes 12 Specialist Consultations, 4 Complete Blood counts, and lab tests for Hepatitis B/C, HIV, Blood Sugar, Rubella, and Syphilis. Also includes 7 Obstetric Ultrasounds, NT Screening, and 90 tablets of SELANCY Multivitamins.",
  "embedding": [0.0124, -0.0452, 0.0891, 0.0032]
}
```

#### `chat_sessions` Collection
Stores conversational state between patients and the AI assistant, embedding chat messages and deep-link action triggers.

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
      "text": "Our Antenatal Program (12th Weeks) is $688 at both Doung Ngeap and Chamkarmon branches. It includes 12 Specialist Consultations, lab tests (Hepatitis B/C, HIV, Rubella), 7 Ultrasounds, and 90 multivitamin tablets.",
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

The table below outlines the structural relationships and the engineering trade-offs governing embedding versus referencing across the backend.

| Relationship Pair | Strategy | Technical Rationale & Performance Impact |
| :--- | :--- | :--- |
| **User → Refresh Tokens** | **Referencing** (`refresh_tokens.userId`) | Devices and refresh sessions expand dynamically over time. Storing tokens separately prevents parent `users` document growth and enables individual TTL indexing per token. |
| **Branch → Clinics** | **Referencing** (`clinics.supportedBranchIds`) | Many-to-many cardinality. Clinics operate independently across multiple branches; embedding clinics inside branches would duplicate clinic descriptions and logos. |
| **Clinic → Doctors** | **Referencing** (`doctors.clinicId`) | Doctors are independent administrative entities with separate schedules, qualifications, and booking availability. |
| **Package → Inclusions** | **Embedding** (`packages.inclusions`) | Strict 1-to-1 bounded relationship. Package inclusions are always rendered together on the package detail screen, eliminating secondary query lookups. |
| **Appointment → Patient** | **Hybrid Snapshot** (`appointments.patientId` + `patientInfo`) | References `patientId` for relational queries, but embeds `patientInfo` (name, email, phone) to ensure historical booking records remain intact even if user profiles change. |
| **Article → Content Blocks** | **Embedding** (`news.contentBlocks`) | Bounded array of image-caption-paragraph blocks representing a single article body. Eliminates complex `$lookup` joins when fetching articles in Flutter. |
| **Feedback → Admin Workflow** | **Embedding** (`feedbacks.adminWorkflow`) | Ensures atomic updates (`$set`, `$push`) when updating feedback status or appending internal staff notes without distributed transaction overhead. |
| **Session → Messages** | **Embedding** (`chat_sessions.messages`) | Keeps conversation context co-located for fast window retrieval (last 3–4 messages) during LLM prompt assembly. |

---

## 4. Indexing Strategy & Query Optimization

To maintain sub-100ms response times across the mobile REST API, specific indexes must be built on MongoDB Atlas:

### 4.1 TTL Index for Session Expiration
```javascript
db.refresh_tokens.createIndex(
  { "expiresAt": 1 },
  { expireAfterSeconds: 0 }
);
```
*Rationale*: MongoDB background thread automatically deletes documents once `expiresAt` passes, eliminating manual database cleanup scripts.

### 4.2 Geospatial 2dsphere Index for Branch Discovery
```javascript
db.branches.createIndex(
  { "location": "2dsphere" }
);
```
*Rationale*: Enables `$near` and `$geoWithin` spherical queries so mobile clients can locate the nearest hospital branch based on GPS coordinates.

### 4.3 Compound Indexes for Frequent Query Patterns
```javascript
// Patient appointment listing by status and date
db.appointments.createIndex(
  { "patientId": 1, "status": 1, "createdAt": -1 }
);

// High-priority feedback filtering for admin desk
db.feedbacks.createIndex(
  { "adminWorkflow.status": 1, "adminWorkflow.priority": 1 }
);

// Popular health article feed ordering
db.health_tips.createIndex(
  { "clinic": 1, "isPopular": -1, "publishedAt": -1 }
);
```

### 4.4 MongoDB Atlas Vector Search Index Definition
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
*Rationale*: Powers the RAG pipeline by performing vector cosine similarity searches over 1536-dimensional embeddings generated by OpenAI/Gemini models.

---

## 5. Security, Concurrency & Governance

1. **Write Skew & Booking Concurrency**: To prevent double-booking doctors during identical time slots, appointment confirmation endpoints should utilize MongoDB ACID sessions with conditional update filters (`status: "pending"`) or unique compound index constraints on `{ doctorId: 1, "scheduling.requestedDate": 1 }`.
2. **Emergency Intent Bypass in AI Pipeline**: The Dart Frog backend must intercept user chat inputs *before* querying `knowledge_chunks` or triggering LLM inference. Query strings matching emergency keywords ("severe bleeding", "chest pain", "unconscious") instantly bypass the database and return a hardcoded emergency hotline card.
3. **Data Lifecycle & Compliance**: Inactive user accounts and old feedback records can be archived to cold storage, while session tokens are automatically purged via WiredTiger storage engine TTL background threads.
