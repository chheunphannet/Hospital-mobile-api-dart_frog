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
```* B. health_tips Collection

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
