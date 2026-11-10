# Orienda International Hospital: Mobile App UI/UX Specification (Figma + Flutter)

**Target platform**: iOS and Android, design frame iPhone 16 / 15 Pro (`393 × 852`)
**Design tool target**: Figma AI / Figma Agent / Galileo / Relume
**Hospital reference**: https://www.oriendainternationalhospital.com.kh (verify this URL before publishing)
**Backend**: Dart Frog REST API, MongoDB (Atlas local image for vector search), Gemini for chat
**Specification version**: 2.1 (corrected against the built backend; see Section 9 for the change log)

---

## 1. Summary and Frame Count

### Exact number of frames: **18**

Six user flows:

| Flow | Frame | Name | Purpose |
| :--- | :--- | :--- | :--- |
| Onboarding and Auth | `01` | `01_Splash_Welcome` | Brand, language selector (Khmer / English), start button |
| | `02` | `02_Auth_Sign_In_Register` | Segmented control: Sign in / Create account. Email + password, and Google |
| Discovery | `03` | `03_Home_Dashboard` | Hub: branch pill, emergency button, quick actions, packages, specialists |
| | `04` | `04_Branch_Selector_Modal` | Bottom sheet to switch branch |
| | `05` | `05_Clinics_Catalog` | 8 clinics |
| | `06` | `06_Doctor_Directory` | Search and filter doctors |
| | `07` | `07_Doctor_Profile` | Bio, qualifications, languages, book button |
| Packages | `08` | `08_Packages_Catalog` | List of 5 health packages |
| | `09` | `09_Package_Detail` | Inclusions, price, preparation notes, book button |
| Booking | `10` | `10_Booking_Step1_Patient` | Self or family member, referral source |
| | `11` | `11_Booking_Step2_3_Schedule_Review` | Date, time slot, review, confirm |
| | `12` | `12_Booking_Success_Ticket` | Confirmation, reference code, QR |
| | `13` | `13_My_Appointments` | Upcoming and past visits, reschedule, cancel |
| AI and Emergency | `14` | `14_AI_Chat_Assistant` | Information assistant (RAG), logged-in users only |
| | `15` | `15_Emergency_Modal` | One-tap call, nearest branch, basic guidance |
| Knowledge and Profile | `16` | `16_News_Tips_List` | News and health tips, two tabs |
| | `17` | `17_Article_Reader` | Reader for one news item or tip |
| | `18` | `18_Profile_Settings` | Profile, language, feedback form, log out |

Bottom navigation (5 tabs): **Home, Doctors, AI Assistant (elevated center), Appointments, Profile**.
Frames 16 and 17 are reached from Home ("News and tips" row) and from Profile.

> Frame sizes are all `393 × 852` except modal frames 04 and 15, which are overlays on that size.

---

## 2. Generation Rules

> **No emojis and no decorative stickers anywhere in the design.** Use Lucide vector icons (Section 4) and
> native iOS 18 kit elements only: status bar (Dynamic Island, `9:41`, Wi-Fi, battery), home indicator
> (`134 × 5`), segmented controls, toggles, text inputs with floating labels, steppers, and pill badges.
> Language switcher uses text (`ខ្មែរ | English`), not flags.

**Sample data rule.** Phone numbers, reference codes, names, and prices in this document are sample data
for the mockup. The emergency number must be written as a variable `{EMERGENCY_PHONE}` in the real app and
come from backend config, so it is changed in one place. Do not publish any number that the hospital has not confirmed.

### 2.1 Design Tokens

```yaml
Figma_Tokens:
  Canvas:
    Width: 393
    Height: 852
    Background: "#F8FAFC"
  Colors:
    Primary_Burgundy: "#8B1E2D"      # CTA, active tab, headers
    Deep_Teal: "#0D5C75"             # secondary clinical accent, specialty chips
    Champagne_Gold: "#C5A059"        # premium badges. FILL OR BORDER ONLY, never text on white
    Emergency_Red: "#D92525"         # emergency button and banners
    Emergency_Crimson: "#991B1B"     # emergency modal background
    Success_Green: "#16A34A"         # badges and dots (fill only)
    Success_Green_Text: "#15803D"    # use for text on white (contrast about 5:1)
    Warning_Amber: "#D97706"         # icons and fills only
    Warning_Amber_Text: "#B45309"    # use for text on white (contrast about 5:1)
    Surface_White: "#FFFFFF"
    Text_Primary: "#0F172A"
    Text_Secondary: "#64748B"        # minimum for small secondary text
    Border_Subtle: "#E2E8F0"
  Typography:
    Font_Family: "Plus Jakarta Sans, Kantumruy Pro, sans-serif"   # Kantumruy Pro covers Khmer
    Display_Large: { size: 28, weight: 700, line_height: 34 }
    Title_Medium:  { size: 18, weight: 600, line_height: 24 }
    Body_Regular:  { size: 14, weight: 400, line_height: 20 }
    Caption:       { size: 12, weight: 500, line_height: 16 }
    Khmer_Note: "Khmer script needs more vertical room: use line-height about 1.6 x font size for Khmer text."
  Spacing: { base: 4, screen_padding: 20, card_radius: 16, button_radius: 14 }
  Touch_Targets: "Minimum 44 x 44 for every tappable element (icon buttons, chips, the emergency button)."
  Elevation:
    Card_Shadow: "0px 4px 16px rgba(15, 23, 42, 0.06)"
    Modal_Shadow: "0px -8px 24px rgba(15, 23, 42, 0.12)"
```

### 2.2 Global States (design one of each, reuse everywhere)

| State | Design |
| :--- | :--- |
| Loading | Skeleton cards, not a full-screen spinner |
| Empty | Icon + one line + action (for example "No appointments yet" + "Book now") |
| Error | Message from the API + `[Try again]`. Never show raw technical text |
| Offline | Top banner "No connection" and keep cached content visible |
| Session expired | Silent refresh first. Only if refresh fails, go to Frame 02 |

API errors have one shape, so one component handles all of them:
`{ "error": { "code": "...", "message": "..." } }` with codes `VALIDATION_ERROR`, `UNAUTHORIZED`,
`TOKEN_EXPIRED`, `NOT_FOUND`, `CONFLICT`, `EXTERNAL_SERVICE_ERROR`, `INTERNAL_ERROR`.

---

## 3. Image Asset Directory (placeholders)

> **Important.** These are stock photos from Unsplash used only as mockup placeholders. They are **not**
> photos of the real hospital, rooms, equipment, or doctors. The photo IDs were not verified, so open each one
> before using it, and replace any that fail or do not match. Do not ship stock portraits as real doctors.
> In the production app, store the hospital's own photos (with the doctors' consent) and return an `imageUrl`
> from the API. The earlier "Official Database URL" column was removed because those links were not verified.

### 3.1 Facilities

| Asset | Placeholder URL |
| :--- | :--- |
| Steung Meanchey campus (exterior) | `https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800&auto=format&fit=crop&q=80` |
| Chamkarmon branch | `https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&auto=format&fit=crop&q=80` |
| Maternity suite | `https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800&auto=format&fit=crop&q=80` |
| Delivery room | `https://images.unsplash.com/photo-1512678080530-7760d81faba6?w=800&auto=format&fit=crop&q=80` |
| MRI suite | `https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800&auto=format&fit=crop&q=80` |

### 3.2 Doctors (sample portraits)

| Doctor (specialty) | Placeholder URL |
| :--- | :--- |
| Dr. Nuth Sodara (OB/GYN) | `https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80` |
| Dr. Lim Chenda (Pediatrics) | `https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80` |
| Dr. Marie Dupont (IVF) | `https://images.unsplash.com/photo-1594824813637-2852277d3329?w=400&auto=format&fit=crop&q=80` |
| Dr. Kith Bunthan (Cardiology) | `https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&auto=format&fit=crop&q=80` |
| Dr. Heng Piseth (Orthopedics) | `https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop&q=80` |
| Dr. Vong Chantha (Emergency) | `https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&auto=format&fit=crop&q=80` |
| Dr. Sovann Reaksmey (Dermatology) | `https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80` |

### 3.3 Packages, News, Tips

| Item | Placeholder URL |
| :--- | :--- |
| Antenatal care package | `https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=800&auto=format&fit=crop&q=80` |
| Delivery package | `https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=800&auto=format&fit=crop&q=80` |
| Executive health checkup | `https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800&auto=format&fit=crop&q=80` |
| Cardiac screening | `https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800&auto=format&fit=crop&q=80` |
| Pediatric well-child | `https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=800&auto=format&fit=crop&q=80` |
| News: Stroke center | `https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800&auto=format&fit=crop&q=80` (same photo as the MRI suite; pick a different one) |
| News: Tele-radiology | `https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?w=800&auto=format&fit=crop&q=80` |
| Tip: Warning signs in pregnancy | `https://images.unsplash.com/photo-1584362917165-526a968579e8?w=800&auto=format&fit=crop&q=80` |
| Tip: Newborn vaccines | `https://images.unsplash.com/photo-1632053001850-2d88698f2671?w=800&auto=format&fit=crop&q=80` |

---

## 4. Icon Directory (Lucide)

Icons come from Lucide via `https://api.iconify.design/lucide:<name>.svg`. Names below are the current Lucide
names (`home` is now `house`, `check-circle-2` is now `circle-check`; the old names still resolve as aliases but use the new ones).

| Purpose | Figma component | Lucide name |
| :--- | :--- | :--- |
| Home tab | `Icon/Home` | `house` |
| Doctors tab, general medicine | `Icon/Stethoscope` | `stethoscope` |
| Branch / hospital | `Icon/Hospital` | `building-2` |
| AI assistant (use only for AI) | `Icon/Sparkles` | `sparkles` |
| Appointments | `Icon/Calendar` | `calendar` |
| Profile | `Icon/User` | `user` |
| Emergency call | `Icon/PhoneCall` | `phone-call` |
| Emergency / siren | `Icon/Siren` | `siren` |
| Location | `Icon/MapPin` | `map-pin` |
| Directions | `Icon/Navigation` | `navigation` |
| Search | `Icon/Search` | `search` |
| Filter | `Icon/Filter` | `sliders-horizontal` |
| QR pass | `Icon/QrCode` | `qr-code` |
| Success / verified | `Icon/CheckCircle` | `circle-check` |
| Next | `Icon/ChevronRight` | `chevron-right` |
| Back | `Icon/ArrowLeft` | `arrow-left` |
| Time | `Icon/Clock` | `clock` |
| Package | `Icon/Package` | `package` |
| OB/GYN | `Icon/Heart` | `heart` |
| Pediatrics | `Icon/Baby` | `baby` |
| Fertility / IVF | `Icon/Dna` | `dna` |
| Cardiology | `Icon/HeartPulse` | `heart-pulse` |
| Orthopedics | `Icon/Bone` | `bone` |
| Dermatology | `Icon/ScanFace` | `scan-face` |
| Privacy / security | `Icon/ShieldCheck` | `shield-check` |
| News | `Icon/Newspaper` | `newspaper` |
| Share / bookmark | `Icon/Share`, `Icon/Bookmark` | `share-2`, `bookmark` |
| Rating | `Icon/Star` | `star` |
| Send message | `Icon/Send` | `send` |
| Language | `Icon/Languages` | `languages` |
| Show / hide password | `Icon/Eye`, `Icon/EyeOff` | `eye`, `eye-off` |
| Log out | `Icon/LogOut` | `log-out` |

---

## 5. Screen Specifications

Data names in the specs (branch names, clinic names, doctor details) must match the database exactly.
Sample values below were taken from the seeded data.

### Frame 01: `01_Splash_Welcome`
- **Fill**: `#8B1E2D` to `#5A121D` vertical gradient. iOS status bar (white), home indicator (white).
- **Layout**: vertical auto layout, padding `[60, 24, 34, 24]`, gap `32`, centered.
- **Hero image**: exterior placeholder, `345 × 360`, radius `28`, 15% black overlay.
- **Logo**: the hospital's **official logo** (`48 × 48`). Do not draw a caduceus; use the real logo file.
- **Title**: "Orienda International Hospital" (26, bold, white).
- **Subtitle**: "Maternal, pediatric and specialist care in Phnom Penh." (14, `#F1F5F9`). Avoid unverified claims like "leading".
- **Language switcher**: segmented control `ខ្មែរ | English`. Saved to device and sent as the app language.
- **Primary button**: `Get Started` (white fill, burgundy text, height 52, radius 16) goes to Frame 02.
- **Text link**: `Emergency: {EMERGENCY_PHONE}` with `Icon/PhoneCall` (`#FFD2D7`), height at least 44.

### Frame 02: `02_Auth_Sign_In_Register`
Matches what the backend supports: **email + password** and **Google**. Phone OTP is not built, so it is not in the design.
- **Fill**: `#F8FAFC`. Dark status bar. Back button `44 × 44`.
- **Segmented control**: `[ Sign in ]  [ Create account ]`.
- **Sign in tab**:
  - Email input, password input with `Icon/Eye` toggle.
  - Primary button `Sign In` (burgundy, height 50, radius 14).
  - Divider "or continue with", then `Continue with Google` (white, border `#E2E8F0`, Google logo per Google brand rules).
  - Error text slot under the form (for example "Invalid email or password").
- **Create account tab**:
  - Email, password (helper text "At least 8 characters"), optional phone number.
  - Checkbox: "I agree to the Privacy Policy and Terms." (link text opens the policy).
  - Primary button `Create Account`.
  - Same Google button below.
- **Google note**: an account created with Google has no password. If someone tries password sign in for it, show "This account uses Google sign-in."
- **Footer**: `Icon/ShieldCheck` + "Your health data is sent over an encrypted connection."
  (Do not claim HIPAA or ISO certification unless the hospital confirms it.)
- **Not included yet**: "Forgot password" (not built in the backend). Add the link when the endpoint exists.

### Frame 03: `03_Home_Dashboard`
- **Fill**: `#F8FAFC`. Bottom nav with 5 tabs, center `Icon/Sparkles` button elevated (burgundy, shadow `0 4px 12px rgba(139,30,45,0.3)`).
- **Header**: greeting "Hello, {firstName}" (18, bold). If the profile has no name yet, show "Hello".
  - Branch pill: `Icon/MapPin` + branch name + chevron (white, border, radius 999). Opens Frame 04.
  - Emergency button: `Icon/Siren` + "Emergency" (`#D92525`, white text, **height 44**). Opens Frame 15.
- **Quick actions (2 × 2, gap 12)**: Find Doctor (`Icon/Stethoscope`), Our Clinics (`Icon/Hospital`), Health Packages (`Icon/Package`), AI Assistant (`Icon/Sparkles`). Cards white, radius 16.
- **Featured packages carousel**: cards `300 × 180`, radius 18, image + title + price from the API.
- **Top specialists**: horizontal avatars `64 × 64` with a green dot only if `isAvailableForBooking` is true.
- **News and tips row**: title "News and Health Tips" + `See all` goes to Frame 16.

### Frame 04: `04_Branch_Selector_Modal`
- **Overlay**: `#000000` at 40%. **Bottom sheet**: height about 560, white, radius `28 28 0 0`, drag handle `40 × 5` (`#CBD5E1`).
- **Title**: "Select Branch".
- **Branch card 1**: "Orienda International Hospital (Steung Meanchey)". Image (height 120, radius 16), address, equipment badges from the data (for example 24/7 Emergency, ICU, MRI), radio selected.
- **Branch card 2**: "Orienda Chamkarmon Hospital". Image, address, badges, radio unselected.
- **Actions**: `Directions` (opens maps) on each card, and `Confirm` (burgundy, height 50).
- Branch names, addresses, and badges all come from the `branches` data, not hard-coded text.

### Frame 05: `05_Clinics_Catalog`
- **Header**: back arrow, title "Clinics", subtitle "8 specialties".
- **Search**: "Search clinic or condition".
- **List** (single column, gap 12). Each row: icon in a tinted circle, name, one-line description from the API, chevron.

| Clinic | Icon |
| :--- | :--- |
| Obstetrics & Gynecology (OB-GYN) | `Icon/Heart` |
| Pediatrics and Neonatology | `Icon/Baby` |
| Fertility and IVF Center | `Icon/Dna` |
| Cardiovascular Center | `Icon/HeartPulse` |
| Orthopedic and Spine Surgery | `Icon/Bone` |
| Emergency and Trauma (24/7) | `Icon/Siren` |
| Dermatology | `Icon/ScanFace` |
| General Internal Medicine | `Icon/Stethoscope` |

Use the exact clinic names stored in the database (they are also used as the filter value in the chat search).

### Frame 06: `06_Doctor_Directory`
- **Sticky filters**: search field, chips (`All`, one per clinic), and two dropdowns: Branch, Language.
- **Doctor card**: photo `72 × 72` (radius 16), name, title, language badges, availability badge ("Available for booking" in `Success_Green_Text` with a green dot), button `Book` (burgundy, radius 12, height 44).
- **Sample**: Dr. Nuth Sodara, "Senior Consultant Obstetrician & Gynecologist", Khmer / English / French. Dr. Marie Dupont, "Lead IVF & Reproductive Endocrinologist", English / French.
- Doctors with `isAvailableForBooking = false` are hidden or shown greyed without a book button.

### Frame 07: `07_Doctor_Profile`
- **Hero photo** `393 × 280`, floating back and share buttons (`44 × 44`).
- **Overview card** (radius `24 24 0 0`, overlaps the photo by 24): name (22, bold), clinic badge (for example "Obstetrics & Gynecology (OB-GYN)"), branches the doctor works at.
- **Tabs**: `About | Qualifications | Schedule`.
  - About: bio text from the database. Sample: "Senior Obstetrician with over 18 years of clinical experience specializing in high-risk pregnancies, maternal-fetal medicine, and advanced 4D anomaly ultrasounds."
  - Qualifications (with `Icon/CheckCircle`):
    - MD - University of Health Sciences (Cambodia)
    - Diploma in Maternal-Fetal Medicine (Paris Descartes University, France)
    - Fellowship in Laparoscopic Gynecological Surgery (Singapore)
  - Schedule: shown only if the API provides schedule data.
- **Rating and consultation fee**: show "rating" and "Consultation from $X" **only if the API provides them**. They are not in the current data, so leave these out of the first version.
- **Sticky bottom bar**: `Book Appointment` (burgundy, height 52).

### Frame 08: `08_Packages_Catalog`
- **Top bar**: "Health Packages". **Chips**: `All`, then one per department (Maternity, Wellness, Heart, Children).
- **Package card** (white, radius 18, border): image (height 160), title, summary of inclusions, price with currency, `View Details`.
- **Sample**: "Comprehensive Antenatal Care Program", "12 specialist visits, 7 ultrasound scans, lab panels", "$688.00 USD". Use the exact title and numbers stored in the database, and the same title on Frames 09 and 14.
- **Discount line** ("regular price, save 25%"): show only if the API has a regular-price field. Otherwise show the price alone.

### Frame 09: `09_Package_Detail`
- **Hero image** (height 240). **Title block**: package title, price (burgundy, 24, bold), branch availability badges.
- **Accordion inclusions** (data from the package `inclusions`): consultations, ultrasounds, laboratory tests, supplements.
- **Preparation card** (fill `#FEF3C7`, border `#FDE68A`, text `Warning_Amber_Text`): instructions and terms from the package data.
- **Sticky bottom bar**: `Book This Package` (burgundy, height 52, radius 16). If the user is not signed in, go to Frame 02 first and return here after.

### Frame 10: `10_Booking_Step1_Patient`
- **Stepper**: "Step 1 of 3: Patient" (33%).
- **Segmented control**: `Myself | Family member`.
- **Myself**: card with name, phone, age from the profile. If any field is missing, show an inline `Add` link.
- **Family member**: dropdown or `Add dependent` form.
- **Referral source dropdown**: "How did you hear about us?" (options from the API or a fixed list).
- **Button**: `Continue` (burgundy, height 50).

### Frame 11: `11_Booking_Step2_3_Schedule_Review`
- **Stepper**: 3 steps, step 2 active (67%). The review card and confirm button at the bottom of the same frame complete step 3.
- **Toggle**: "Book earliest available slot" (on or off). When on, the date and time pickers are disabled.
- **Date strip**: `Tue 27`, `Wed 28`, `Thu 29`, `Fri 30` (Tue 27 active). Dates must be in the future.
- **Time chips**: Morning `09:00 AM`, `10:30 AM`, `11:15 AM`. Afternoon `02:00 PM`, `03:30 PM`, `04:45 PM`. Booked slots are greyed.
- **Review card**: doctor or package, branch, date and time, patient, optional note field.
- **Button**: `Confirm Appointment (pay at hospital)` (burgundy, height 52).
- Errors: slot already taken (`CONFLICT`) shows "That slot was just booked. Please pick another."

### Frame 12: `12_Booking_Success_Ticket`
- **Fill**: `#8B1E2D`. Small, calm confirmation mark (no heavy confetti).
- **Ticket** (white, radius 24, dashed separator): status "Appointment confirmed", reference code (sample `OR-2026-8841`), doctor, "Tue 27 Oct 2026, 09:00 AM", branch name.
- **QR code** (`160 × 160`): encodes the booking reference. Text: "Show this code at reception when you arrive."
  (Do not promise "zero waiting time".)
- **Buttons**: `Add to Calendar` (light), `Back to Home` (outline, white).

### Frame 13: `13_My_Appointments`
- **Segmented control**: `Upcoming | Past`.
- **Upcoming card** (white, radius 20): date badge "27 OCT 2026, 09:00 AM", doctor, branch pill, status badge, and three actions: `Directions`, `Reschedule`, `Cancel` (opens a confirmation bottom sheet).
- **Past card**: date, doctor, status `Completed`.
- **Not included**: "View consultation summary and prescription" was removed. The backend has no such data. Add it later only when the data exists.
- Empty state for each tab.

### Frame 14: `14_AI_Chat_Assistant`
The assistant answers from hospital data (doctors, clinics, branches, packages, news, tips). It does **not** diagnose.
- **Access**: signed-in users only. If not signed in, show a card "Sign in to chat" with a button to Frame 02.
- **Top bar**: title "AI Assistant", `New chat` button, `Emergency` button (`Icon/Siren`, opens Frame 15).
- **Disclaimer strip** (under the top bar, `#F1F5F9`): "General information only. This assistant does not give medical diagnosis. For emergencies call {EMERGENCY_PHONE}."
- **Welcome bubble**: sparkles avatar in a burgundy circle, "Hello! I can help with doctors, clinics, packages, and branches."
- **Prompt chips** (horizontal scroll): "Pregnancy package price?", "Which doctors speak French?", "Where is the Chamkarmon branch?"
- **User bubble**: burgundy fill, white text, right aligned.
- **Assistant bubble**: white, border, left aligned. A typing indicator appears while waiting.
- **Action card** (under an assistant bubble, only when the API returns `suggestedAction`):
  - `NAVIGATE_PACKAGE_DETAIL`: card with package image, title, price, chevron, opens Frame 09.
  - `NAVIGATE_DOCTOR_DETAIL`: card with doctor photo, name, specialty, chevron, opens Frame 07.
  - `SHOW_EMERGENCY`: red card "Emergency help" that opens Frame 15 (the reply text is a fixed emergency message).
- **Input bar** (floating): text field "Ask about doctors, packages, branches", send button (burgundy). Max 500 characters, show a counter near the limit.
- **Not in the first version**: voice input (no backend or package yet). Add a mic icon later if it is built.
- **Error states**: "The assistant is unavailable right now" for `EXTERNAL_SERVICE_ERROR`, with a retry button. Rate limit reached shows "Please wait a moment before sending another message."

### Frame 15: `15_Emergency_Modal`
- **Fill**: `#991B1B`. White status bar.
- **Top icon**: `Icon/Siren` (`72 × 72`, white). No looping animation (reduced-motion friendly).
- **Header**: "Emergency assistance" (26, bold, white). Subtext: "For a life-threatening emergency, call now."
- **Primary button**: `Call {EMERGENCY_PHONE}` (white, text `#991B1B`, height 60, 20 bold). Uses the phone dialer; it never calls automatically.
- **Nearest emergency department**: card with branch name, address, `Directions` button (data from the `branches` collection).
- **Secondary**: `Call Chamkarmon branch` (white 20% fill), if that branch has a number.
- **Guidance (3 steps)**: 1. Stay calm and say clearly what happened. 2. Give your exact location. 3. Follow the instructions of the person on the phone.
  (The earlier "ambulance dispatched within 3 minutes" promise was removed. Only promise what the hospital confirms.)
- **Dismiss**: `Back to app` (text button, height 44).

### Frame 16: `16_News_Tips_List`
- **Segmented control**: `News | Health Tips`.
- **Chips** (tips tab): clinic filter.
- **Card**: image (height 140), clinic tag, title, date, chevron. Opens Frame 17.
- Empty and error states.

### Frame 17: `17_Article_Reader`
- **Top bar**: back, bookmark, share.
- **Hero image** (height 220). **Header**: clinic tag, headline (20, bold), date.
- **Body**: rendered from the article `contentBlocks`: each block has an optional caption (section heading) and a text paragraph.
- **Related action**: if the tip belongs to a clinic, show `Find a doctor in {clinic}`.
- Sample news: "24/7 Stroke and Cardiac Rapid Response Center launch". Use the real article from the database.

### Frame 18: `18_Profile_Settings`
- **Header card**: avatar, name, email, phone. `Edit profile` button (name and phone can be completed here).
- **List rows**: My Appointments, Language (`ខ្មែរ | English`), Send Feedback, Privacy Policy, Terms.
- **Feedback sheet** (bottom sheet): star rating, comment field, `Submit`.
- **Log out** button (outline, `Emergency_Red` text). It calls the logout endpoint with the refresh token, then clears secure storage.
- Show the app version at the bottom.

---

## 6. Flutter Implementation Mapping

| Topic | Choice |
| :--- | :--- |
| Theme | Map Section 2.1 tokens to `ThemeData` / `ColorScheme`, and text styles to `TextTheme` |
| Fonts | `google_fonts`: Plus Jakarta Sans and Kantumruy Pro |
| Routing | `go_router` with a guard: protected routes redirect to Frame 02 |
| HTTP | `dio` with an interceptor that adds the access token and, on `TOKEN_EXPIRED`, calls refresh once, then retries |
| Token storage | `flutter_secure_storage` (never SharedPreferences) |
| Google sign-in | `google_sign_in` with `serverClientId` set to the **Web** client ID; send the `idToken` to `POST /auth/google` |
| Calls and maps | `url_launcher` (`tel:` and map links) |
| QR | `qr_flutter` |
| Images | `cached_network_image` |
| Dates | `intl` (also for Khmer date formats) |
| State management | Riverpod or Bloc, one repository per API area |

### Screen to API mapping

Auth and chat paths match the backend as built. The others are examples, so adjust them to your real routes.

| Frame | Calls |
| :--- | :--- |
| 02 | `POST /auth/login`, `POST /auth/register`, `POST /auth/google` |
| Session | `POST /auth/refresh`, `POST /auth/logout` |
| 03 | `GET /branches`, `GET /packages`, `GET /doctors`, `GET /news`, `GET /health-tips` |
| 05, 06, 07 | `GET /clinics`, `GET /doctors`, `GET /doctors/{id}` |
| 08, 09 | `GET /packages`, `GET /packages/{id}` |
| 10 to 13 | `POST /appointments`, `GET /appointments`, update and cancel routes |
| 14 | `POST /chat` with `{ "sessionId": optional, "message": "..." }` |
| 16, 17 | `GET /news`, `GET /health-tips` |
| 18 | profile routes, `POST /feedbacks`, `POST /auth/logout` |

Chat reply shape: `{ "sessionId": "...", "message": { "sender", "text", "suggestedAction": { "type", "targetId" }, "timestamp" } }`.
Keep the `sessionId` after the first reply and send it with later messages in the same conversation.

---

## 7. Accessibility Checklist

- Minimum tap target 44 × 44 on every interactive element.
- Text contrast at least 4.5:1: use `Success_Green_Text` and `Warning_Amber_Text` for text, and never put gold text on white.
- Support larger system text sizes without clipping; avoid fixed-height text containers.
- Every icon-only button has a label for screen readers.
- Respect "reduce motion": no looping animations.
- Do not use color alone to show status (add text such as "Confirmed" or "Cancelled").
- Test every screen in Khmer, since the text is longer and taller than English.

---

## 8. Open Items to Confirm with the Hospital and Backend

| Item | Why |
| :--- | :--- |
| Real emergency and branch phone numbers | The numbers in the old draft were unverified samples |
| Official logo and approved photos (and doctor consent for portraits) | Stock images are placeholders only |
| Certifications (ISO, accreditation) | Do not show any badge until confirmed in writing |
| Khmer translations of clinic, doctor, package, and article content | Data is currently English only; the language switcher changes only the UI unless content is translated |
| Doctor rating and consultation fee fields | Not in the current data; remove from Frame 07 until they exist |
| Regular price and discount field on packages | Needed for the "save 25%" line on Frame 08 |
| Profile name collection | Registration currently sends email, password, and optional phone only; name is added in Frame 18 |
| Forgot password and phone OTP | Not built yet; add screens only when the endpoints exist |
| Consultation summary and prescription | No such data in the backend; excluded from Frame 13 |
| Privacy policy and terms text | Required before the checkbox on Frame 02 can link anywhere |
| Chat wording and emergency keywords (including Khmer) | Must be reviewed by hospital medical staff |

---

## 9. Change Log from v2.0

| Area | Was | Now |
| :--- | :--- | :--- |
| Frame count | 16 | 18 (added News and Tips list, Profile and Settings; split Article Reader from Profile) |
| Login | Phone OTP + Google | Email + password + Google (matches the built backend); register merged into Frame 02 |
| Emojis and flags | Used throughout, while the rules said "no emojis" | Removed; Lucide icons and text only |
| Emergency numbers | Specific numbers presented as real | Variable `{EMERGENCY_PHONE}`, confirm with the hospital |
| Emergency promise | "Ambulance dispatched within 3 minutes" | Removed; generic safe guidance |
| Certification claims | "ISO 9001 and HIPAA encrypted" | Removed until confirmed |
| Chat | "Medical triage chat", mic input, "cited source cards" | Information assistant with disclaimer; action card from `suggestedAction`; login required; mic removed |
| Dates | Calendar strip on 12 to 15, ticket on 10 Oct 2026 (mixed, and in the past) | Consistent future dates: Tue 27 Oct 2026 |
| Stepper | "Step 2 and 3" at 100% | 3-step stepper at 67% with review in the same frame |
| Clinic count | Header "18 specialties" for 8 clinics | "8 specialties" |
| Clinic and branch names | "Steung Meanchey Campus", "Chamkarmon Urban Clinic", "OB-GYN Clinic" | Names from the database |
| Doctor qualification | "Fellowship in Gynecological Surgery" | "Fellowship in Laparoscopic Gynecological Surgery" (as in the data) |
| Package title | Four different wordings | One title taken from the database |
| Icons | `Icon/Activity` undefined, `HeartPulse` mapped to `activity`, Sparkles reused for IVF and skin | Each clinic has its own icon; Sparkles only for AI; current Lucide names |
| Image table | "Official database URLs" and "100% guaranteed to load" | Official column removed; placeholders marked unverified; stock photos not to ship |
| Colors | Gold, green, and amber used as text | Text-safe variants added |
| Touch targets | Emergency button 36, back button 40 | 44 minimum |
| Consultation summary and prescription | Present on past visits | Removed (no backend data) |
| Doctor rating and fee | Shown as fixed values | Optional, only if the API provides them |
| Added | | Global states, error format, Flutter mapping, API mapping, accessibility checklist, open items |

---

## 10. Copy-Paste Prompt for Figma AI

```markdown
Design a high-fidelity mobile healthcare app for "Orienda International Hospital" (Cambodia).
Device: iPhone 16 / 15 Pro, 393 x 852.
Style: calm, premium, trustworthy hospital app. Clean cards, generous spacing.
Colors: Primary Burgundy #8B1E2D, Deep Teal #0D5C75, Champagne Gold #C5A059 (fills only),
Emergency Red #D92525, Background #F8FAFC, Card #FFFFFF, Text #0F172A, Secondary text #64748B.
Font: Plus Jakarta Sans (Khmer: Kantumruy Pro).

RULES:
1. Create exactly 18 connected screen frames numbered 01 to 18 (list below).
2. No emojis, no cartoon stickers, no flags. Use Lucide icons and iOS 18 native elements only
   (status bar, home indicator, segmented controls, toggles, inputs, pill badges).
3. Every tappable element is at least 44 x 44.
4. Bottom nav on main screens: Home, Doctors, AI Assistant (elevated center), Appointments, Profile.
5. Use obviously fake sample data. Emergency phone shown as "000 000 000".
6. Images are placeholders from Section 3 of the spec; do not label them as real hospital photos.
7. Login is email + password and Google. Do not design phone OTP.
8. The AI chat screen needs a visible disclaimer: general information only, no diagnosis.

Frames:
01_Splash_Welcome, 02_Auth_Sign_In_Register, 03_Home_Dashboard, 04_Branch_Selector_Modal,
05_Clinics_Catalog, 06_Doctor_Directory, 07_Doctor_Profile, 08_Packages_Catalog, 09_Package_Detail,
10_Booking_Step1_Patient, 11_Booking_Step2_3_Schedule_Review, 12_Booking_Success_Ticket,
13_My_Appointments, 14_AI_Chat_Assistant, 15_Emergency_Modal, 16_News_Tips_List,
17_Article_Reader, 18_Profile_Settings
```
