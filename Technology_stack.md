* Security
  - Access & Refresh Tokens
  - refresh_tokens collection: store hashed refresh tokens paired with the user's ID and device info.
  - Apply a Time-To-Live: index on the expiresAt field so MongoDB automatically deletes expired tokens.
  - Token Rotation: The backend then generates a new Access Token and a new Refresh Token

* Document Modeling for Hospital Features
  - Hierarchical Packages: Store complex medical packages as structured sub-documents within a single packages document.

* AI Assistant & RAG Implementation
  - MongoDB Atlas Vector Search: Leverage Atlas Vector Search to index doctor bios..., allowing your RAG pipeline to perform fast semantic searches.

* appointment
```json
{
  "_id": ObjectId("..."),
  "patientId": ObjectId("..."),
  "patientInfo": {
    "name": "Chheun Phanet",
    "email": "chhernphannet0001@gmail.com",
    "phone": "098000999"
  },
  "bookingFor": "Myself",
  "referral": {
    "type": "Influencer", 
    "sourceName": "Optional name"
  },
  "branchId": ObjectId("..."),
  "department": "Obstetric",
  "doctorId": ObjectId("..."), // Optional
  "scheduling": {
    "isEarliestAvailable": true,
    "requestedDate": null // or ISODate("2026-10-10T09:00:00Z") if "Choose a date" is picked
  },
  "personalRequest": "Please call before confirmation.",
  "status": "pending", // pending, confirmed, rejected, completed
  "hospitalNotes": null, // filled by staff upon confirmation
  "createdAt": ISODate("2026-10-06T14:00:00Z")
}
```

* promotions and package
  - packages collection: flexible documents with nested arrays
  - Core Fields: Store the package title, department (e.g., Obstetric), price (e.g., $688), posterUrl, and an isLimitedOffer flag.
  - Categorized Inclusions: Use a structured sub-document or array for items like lab tests, vaccinations, medications...
  - Metadata Fields: Embed plain text fields for instructions, termsAndConditions, and an array of supported branch names or IDs (Doung Ngeap and Chamkarmon).

* News (Hospital Updates) and Health Tips & Doctor Talks
  * A. news Collection
  - MongoDB Schema Design: multi-image articles where each image pairs with its own paragraph, use a structured array of content blocks rather than a single monolithic text field.
```json
{
  "_id": ObjectId("..."),
  "title": "Orienda Hospital Expands New Obstetric Wing",
  "posterUrl": "https://...",
  "publishedAt": ISODate("2026-10-06T00:00:00Z"),
  "contentBlocks": [
    {
      "imageUrl": "https://...",
      "caption": "Ribbon cutting ceremony at the new wing.",
      "text": "Orienda Hospital officially inaugurated its state-of-the-art obstetric wing..."
    },
    {
      "imageUrl": "https://...",
      "caption": "Advanced fetal monitoring equipment.",
      "text": "The new facility is equipped with next-generation monitoring devices..."
    }
  ]
}
```

  * B. health_tips Collection
```json
{
  "_id": ObjectId("..."),
  "title": "Understanding Trimester Milestones",
  "clinic": "Obstetric", // e.g., Obstetric, Gynecology, Pediatrics
  "posterUrl": "https://...",
  "isPopular": true,
  "viewCount": 1540,
  "publishedAt": ISODate("2026-10-01T00:00:00Z"),
  "contentBlocks": [
    {
      "imageUrl": "https://...",
      "text": "During the first 12 weeks, crucial development takes place..."
    }
  ]
}
```

  * Store article as .md syntax
    - instead of raw markdown we use "WYSWYG" convert to markdow before store in database.

  * MongoDB Schema Design (feedbacks collection)
```json
{
  "_id": ObjectId("6702e5b8..."),
  "patientId": ObjectId("..."), // Optional: populated if user is logged in
  "personalInfo": {
    "firstName": "Phanet",
    "lastName": "Chheun",
    "dob": ISODate("2002-05-14T00:00:00Z"),
    "nationality": "Cambodian",
    "role": "Patient" // "Patient" | "Other"
  },
  "contact": {
    "phoneNumber": "098000999",
    "email": "chhernphannet0001@gmail.com",
    "responseRequired": true
  },
  "visitDetails": {
    "clinicId": ObjectId("..."), // References the Obstetric Clinic, Surgery Clinic, etc.
    "clinicName": "Obstetric Clinic"
  },
  "feedback": {
    "type": "Complaint", // "Praise" | "Suggestion" | "Complaint"
    "title": "Long waiting time at reception",
    "message": "Arrived 15 minutes early for ultrasound checkup, waited 45 minutes past appointment time."
  },
  "adminWorkflow": {
    "status": "pending", // "pending" | "in_review" | "contacted" | "resolved"
    "priority": "high", // Automatically set to "high" if type == "Complaint" and responseRequired == true
    "assignedStaffId": null,
    "internalNotes": []
  },
  "createdAt": ISODate("2026-10-06T15:40:00Z")
}
```

  * AI Assistant operates as a Retrieval-Augmented Generation (RAG) pipeline

```text
┌─────────────────┐       HTTPS / SSE       ┌──────────────────────┐
│  Flutter Client │ ◄─────────────────────► │   Dart Frog Server   │
└─────────────────┘                         └──────────┬───────────┘
                                                       │
                   ┌───────────────────────────────────┼──────────────────────────────────┐
                   ▼                                   ▼                                  ▼
        ┌─────────────────────┐             ┌─────────────────────┐            ┌────────────────────┐
        │  Embedding Service  │             │ MongoDB Atlas Search│            │     LLM Engine     │
        │ (OpenAI / Gemini)   │             │   (Vector Store)    │            │ (GPT-4o / Gemini)  │
        └─────────────────────┘             └─────────────────────┘            └────────────────────┘
```

- Intake & Intent Filtering: client sends user query text. Dart Frog checks if the message matches medical emergency keywords (e.g., "severe bleeding", "chest pain"). If flagged, the pipeline skips the LLM and instantly returns an emergency emergency-hotline card.
- Query Vectorization: The backend sends the user query to the Embedding model to generate a query vector.
- Similarity Search: Dart Frog executes a MongoDB $vectorSearch pipeline, retrieving the top 3–5 most relevant chunks (e.g., the Antenatal Program details and Doung Ngeap branch contacts).
  - Context Injection & Prompt Assembly: The system compiles:
    - System Prompt: Hospital persona, behavioral guidelines, medical disclaimer rules, and branch boundaries.
    - Retrieved Knowledge: Injected text blocks from the vector query.
    - Recent History: Last 3–4 messages from chat_sessions.
    - User Query: Current questi
- LLM Inference & Streaming: The model synthesizes an accurate answer strictly grounded in the injected data and streams the tokens back to Flutter via Server-Sent Events (SSE).

A. knowledge_chunks Collection (Vector Store)

```json
{
  "_id": "ObjectId",
  "sourceType": "package", // "package" | "doctor" | "clinic" | "branch" | "faq" | "policy"
  "sourceId": "ObjectId",   // References original package, doctor, or clinic document
  "metadata": {
    "title": "Antenatal Program (12th Weeks)",
    "clinic": "Obstetric Clinic",
    "branches": ["Doung Ngeap", "Chamkarmon"],
    "tags": ["pregnancy", "maternity", "ultrasound", "blood test", "screening"]
  },
  "content": "Antenatal Program (12th Weeks) priced at $688. Includes 12 Specialist Consultations, 4 Complete Blood counts, and lab tests for Hepatitis B/C, HIV, Blood Sugar, Rubella, and Syphilis. Also includes 7 Obstetric Ultrasounds, NT Screening, and 90 tablets of SELANCY Multivitamins. Pre-payment is required. Patients must bring ID/passport and arrive 10 minutes early.",
  "embedding": [0.0124, -0.0452, 0.0891, "..."] // 1536-dimensional vector
}
```

B. chat_sessions Collection (Conversation History)

```json
{
  "_id": "ObjectId",
  "patientId": "ObjectId", // Nullable for anonymous guests
  "startedAt": "ISODate",
  "lastInteractionAt": "ISODate",
  "messages": [
    {
      "sender": "user",
      "text": "What is included in the pregnancy package and how much is it?",
      "timestamp": "ISODate"
    },
    {
      "sender": "assistant",
      "text": "Our Antenatal Program (12th Weeks) is $688 at both Doung Ngeap and Chamkarmon branches. It includes 12 Specialist Consultations, lab tests (Hepatitis B/C, HIV, Rubella), 7 Ultrasounds, and 90 multivitamin tablets.",
      "suggestedAction": {
        "type": "NAVIGATE_PACKAGE_DETAIL",
        "targetId": "ObjectId"
      },
      "timestamp": "ISODate"
    }
  ]
}
```