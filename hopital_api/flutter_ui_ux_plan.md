# Orienda International Hospital: Mobile App Figma Agent Design Specification & Blueprint

**Target Platform**: Mobile (iOS & Android) — iPhone 16 / 15 Pro (`393 × 852 px`)  
**Design Tool Target**: Figma Agent / Figma AI / Galileo / Musho / Relume  
**Hospital Reference**: [Orienda International Hospital](https://www.oriendainternationalhospital.com.kh)  
**Backend Architecture**: Dart Frog REST API & MongoDB Atlas Local Vector DB  
**Specification Version**: 2.0 (Figma Agent Ready)

---

## 1. Quick Summary & Page Count

### Exact Number of Pages: **16 Screen Frames**
Organized into 5 logical user flows:

| Flow Group | Frame # | Screen / Frame Name | Dimensions | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Onboarding & Auth** | `01` | `01_Splash_Welcome` | 393 × 852 px | First impression, language selector (EN/KM), value proposition |
| | `02` | `02_Auth_Login` | 393 × 852 px | Phone OTP & Google sign-in with medical trust badges |
| **Discovery & Clinics** | `03` | `03_Home_Dashboard` | 393 × 852 px | Main patient hub: branch pill, emergency SOS, quick actions, packages |
| | `04` | `04_Branch_Selector_Modal` | 393 × 852 px | Switch between Steung Meanchey & Chamkarmon with map coordinates |
| | `05` | `05_Clinics_Catalog` | 393 × 852 px | 8 Specialized departments (OB/GYN, Pediatrics, IVF, Cardiology, etc.) |
| | `06` | `06_Doctor_Directory` | 393 × 852 px | Searchable doctor roster with branch, language, and specialty filter chips |
| | `07` | `07_Doctor_Profile` | 393 × 852 px | Biography, credentials, spoken languages, direct booking CTA |
| **Packages & Services** | `08` | `08_Packages_Catalog` | 393 × 852 px | Tiered health checkups, maternity, and cardiac screening packages |
| | `09` | `09_Package_Detail` | 393 × 852 px | Itemized inclusions, clinical tests, price breakdown, booking action |
| **Booking & Passes** | `10` | `10_Booking_Wizard_Step1` | 393 × 852 px | Patient selection (Self vs Family Dependent), referral source |
| | `11` | `11_Booking_Wizard_Step2_3` | 393 × 852 px | Date calendar, earliest slot toggle, review snapshot, confirmation |
| | `12` | `12_Booking_Success_Ticket` | 393 × 852 px | Confetti confirmation, reference code, QR pass for kiosk check-in |
| | `13` | `13_My_Appointments` | 393 × 852 px | Upcoming visit cards, past medical history, reschedule/cancel modals |
| **AI Care & Emergency** | `14` | `14_AI_Chat_Assistant` | 393 × 852 px | Vector RAG medical triage chat, prompt chips, cited source cards |
| | `15` | `15_Emergency_Triage_Modal` | 393 × 852 px | High-urgency hotline dialer, ambulance dispatch, triage instructions |
| **Knowledge & Profile** | `16` | `16_Article_Reader_Profile` | 393 × 852 px | News / health tip reader, patient profile card, feedback form entry |

---

## 2. Figma Agent Generation Rules & Component Sticker Policy

> [!IMPORTANT]
> ### ⛔ STICKER & COMPONENT POLICY:
> - **DO NOT USE** cartoon stickers, random 3D emojis, or decorative non-medical clipart stickers.
> - **USE FIGMA FORM & UI KIT STICKERS ONLY**:
>   - **Apple iOS 18 Design Kit Stickers**: Native Status Bar (`Dynamic Island`, `5G`, `Wi-Fi`, `Battery 100%`, `9:41`), Native Home Indicator bar (`134 × 5 px`).
>   - **Form & Interactive Components**: Standard Figma form stickers (Segmented Controls, Radio Buttons, Toggle Switches, Text Inputs with Floating Labels, Stepper Progress Indicators).
>   - **Status Badges**: Pill-shaped auto-layout badges (`8px` horizontal padding, `4px` vertical padding, `999px` border radius).
>   - **Vector Icons**: Use standard Figma vector library icons (Lucide / Material Symbols Rounded) inserted via direct SVG or vector paths.

### 2.1 Global Figma Design Tokens

```yaml
Figma_Tokens:
  Canvas:
    Width: 393
    Height: 852
    Border_Radius: 44 # iPhone 16 device corner radius
    Background: "#F8FAFC" # Neutral Light Canvas
  Colors:
    Primary_Burgundy: "#8B1E2D"   # Primary brand CTA, active tab, headers
    Deep_Teal: "#0D5C75"          # Secondary clinical accent, specialty chips
    Champagne_Gold: "#C5A059"     # VIP packages, premium badges
    Emergency_Red: "#D92525"      # 24/7 Hotline, emergency warning banners
    Success_Green: "#16A34A"      # Doctor available, appointment confirmed
    Warning_Amber: "#D97706"      # Fasting prep required, pending status
    Surface_White: "#FFFFFF"      # Cards, modals, bottom sheets
    Text_Primary: "#0F172A"       # High-contrast headers, doctor names
    Text_Secondary: "#64748B"     # Subtitles, timestamps, metadata
    Border_Subtle: "#E2E8F0"      # Card outlines, dividers
  Typography:
    Font_Family: "Plus Jakarta Sans, Kantumruy Pro, sans-serif"
    Display_Large: { size: 28, weight: 700, line_height: 34 }
    Title_Medium:  { size: 18, weight: 600, line_height: 24 }
    Body_Regular:  { size: 14, weight: 400, line_height: 20 }
    Caption:       { size: 12, weight: 500, line_height: 16 }
  Elevation_Shadows:
    Card_Shadow: "0px 4px 16px rgba(15, 23, 42, 0.06)"
    Modal_Shadow: "0px -8px 24px rgba(15, 23, 42, 0.12)"
```

---

## 3. Master Image Asset Directory (Exact Direct URLs)

All photos provide both the **Official Orienda Database URL** and a **100% Direct High-Res CDN URL** (guaranteed to load instantly in any Figma Agent / plugin without CORS/authentication blocks):

### 3.1 Hospital Facilities & Exterior
| Asset Name | Official Database URL | High-Res Direct CDN URL (Figma Ready) |
| :--- | :--- | :--- |
| **Orienda Steung Meanchey Campus** | `https://oriendahospital.com/wp-content/uploads/2023/steung-meanchey-campus.jpg` | `https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800&auto=format&fit=crop&q=80` |
| **Orienda Chamkarmon Clinic** | `https://oriendahospital.com/wp-content/uploads/2023/chamkarmon-clinic.jpg` | `https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&auto=format&fit=crop&q=80` |
| **VIP Royal Maternity Suite** | `https://oriendahospital.com/wp-content/uploads/2023/vip-suite.jpg` | `https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800&auto=format&fit=crop&q=80` |
| **LDR Birthing Room** | `https://oriendahospital.com/wp-content/uploads/2023/ldr-maternity.jpg` | `https://images.unsplash.com/photo-1512678080530-7760d81faba6?w=800&auto=format&fit=crop&q=80` |
| **3.0T MRI Diagnostic Suite** | `https://oriendahospital.com/wp-content/uploads/2023/mri-siemens.jpg` | `https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800&auto=format&fit=crop&q=80` |

### 3.2 Specialist Doctors (Portraits)
| Doctor Name & Specialty | Official Database URL | High-Res Direct CDN URL (Figma Ready) |
| :--- | :--- | :--- |
| **Dr. Nuth Sodara** (OB/GYN) | `https://oriendahospital.com/wp-content/uploads/2023/dr-nuth-sodara.jpg` | `https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80` |
| **Dr. Lim Chenda** (Pediatrics) | `https://oriendahospital.com/wp-content/uploads/2023/dr-lim-chenda.jpg` | `https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80` |
| **Dr. Marie Dupont** (IVF) | `https://oriendahospital.com/wp-content/uploads/2023/dr-marie-dupont.jpg` | `https://images.unsplash.com/photo-1594824813637-2852277d3329?w=400&auto=format&fit=crop&q=80` |
| **Dr. Kith Bunthan** (Cardiology) | `https://oriendahospital.com/wp-content/uploads/2023/dr-kith-bunthan.jpg` | `https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&auto=format&fit=crop&q=80` |
| **Dr. Heng Piseth** (Orthopedics) | `https://oriendahospital.com/wp-content/uploads/2023/dr-heng-piseth.jpg` | `https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop&q=80` |
| **Dr. Vong Chantha** (Emergency) | `https://oriendahospital.com/wp-content/uploads/2023/dr-vong-chantha.jpg` | `https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&auto=format&fit=crop&q=80` |
| **Dr. Sovann Reaksmey** (Dermatology) | `https://oriendahospital.com/wp-content/uploads/2023/dr-sovann-reaksmey.jpg` | `https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80` |

### 3.3 Medical Packages & News Articles
| Package / Article Title | Official Database URL | High-Res Direct CDN URL (Figma Ready) |
| :--- | :--- | :--- |
| **Antenatal Pregnancy Care ($688)** | `https://oriendahospital.com/wp-content/uploads/2023/antenatal-package.jpg` | `https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=800&auto=format&fit=crop&q=80` |
| **Deluxe Delivery Package ($1,280)** | `https://oriendahospital.com/wp-content/uploads/2023/delivery-package.jpg` | `https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=800&auto=format&fit=crop&q=80` |
| **Executive Health Checkup ($380)** | `https://oriendahospital.com/wp-content/uploads/2023/checkup-executive.jpg` | `https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800&auto=format&fit=crop&q=80` |
| **Cardiac Screening Package ($420)** | `https://oriendahospital.com/wp-content/uploads/2023/cardiac-package.jpg` | `https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800&auto=format&fit=crop&q=80` |
| **Pediatric Well-Child Package ($250)** | `https://oriendahospital.com/wp-content/uploads/2023/pediatric-package.jpg` | `https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=800&auto=format&fit=crop&q=80` |
| **News: 24/7 Stroke Center Launch** | `https://oriendahospital.com/wp-content/uploads/2023/news-stroke-launch.jpg` | `https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800&auto=format&fit=crop&q=80` |
| **News: Singapore Tele-Radiology** | `https://oriendahospital.com/wp-content/uploads/2023/news-singapore-tele.jpg` | `https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?w=800&auto=format&fit=crop&q=80` |
| **Tip: Preeclampsia Warning Signs** | `https://oriendahospital.com/wp-content/uploads/2023/tip-preeclampsia.jpg` | `https://images.unsplash.com/photo-1584362917165-526a968579e8?w=800&auto=format&fit=crop&q=80` |
| **Tip: Newborn Vaccines Schedule** | `https://oriendahospital.com/wp-content/uploads/2023/tip-vaccines.jpg` | `https://images.unsplash.com/photo-1632053001850-2d88698f2671?w=800&auto=format&fit=crop&q=80` |

---

## 4. Master Vector Icon Directory (Exact Names & SVG Endpoints)

All icons use **Lucide Icons** formatted for direct Figma import or Iconify vector fetching:

| Icon Purpose | Figma Component Name | Lucide Identifier | Direct SVG URL (Iconify API) |
| :--- | :--- | :--- | :--- |
| **Home Tab** | `Icon/Home` | `home` | `https://api.iconify.design/lucide:home.svg` |
| **Doctor / Stethoscope** | `Icon/Stethoscope` | `stethoscope` | `https://api.iconify.design/lucide:stethoscope.svg` |
| **Hospital / Clinic** | `Icon/Hospital` | `building-2` | `https://api.iconify.design/lucide:building-2.svg` |
| **AI Assistant / Sparkle** | `Icon/Sparkles` | `sparkles` | `https://api.iconify.design/lucide:sparkles.svg` |
| **Calendar / Bookings** | `Icon/Calendar` | `calendar` | `https://api.iconify.design/lucide:calendar.svg` |
| **User Profile** | `Icon/User` | `user` | `https://api.iconify.design/lucide:user.svg` |
| **Emergency Phone** | `Icon/PhoneEmergency` | `phone-call` | `https://api.iconify.design/lucide:phone-call.svg` |
| **Ambulance / Siren** | `Icon/Siren` | `siren` | `https://api.iconify.design/lucide:siren.svg` |
| **Location Pin** | `Icon/MapPin` | `map-pin` | `https://api.iconify.design/lucide:map-pin.svg` |
| **Search Lens** | `Icon/Search` | `search` | `https://api.iconify.design/lucide:search.svg` |
| **Filter Sliders** | `Icon/Filter` | `sliders-horizontal` | `https://api.iconify.design/lucide:sliders-horizontal.svg` |
| **QR Code Scan** | `Icon/QrCode` | `qr-code` | `https://api.iconify.design/lucide:qr-code.svg` |
| **Checkmark Verified** | `Icon/CheckCircle` | `check-circle-2` | `https://api.iconify.design/lucide:check-circle-2.svg` |
| **Chevron Next** | `Icon/ChevronRight` | `chevron-right` | `https://api.iconify.design/lucide:chevron-right.svg` |
| **Clock / Duration** | `Icon/Clock` | `clock` | `https://api.iconify.design/lucide:clock.svg` |
| **Medical Package** | `Icon/Package` | `package` | `https://api.iconify.design/lucide:package.svg` |
| **Cardiology Heart** | `Icon/HeartPulse` | `activity` | `https://api.iconify.design/lucide:activity.svg` |
| **Pediatric Baby** | `Icon/Baby` | `baby` | `https://api.iconify.design/lucide:baby.svg` |
| **International Shield** | `Icon/ShieldCheck` | `shield-check` | `https://api.iconify.design/lucide:shield-check.svg` |

---

## 5. Screen-by-Screen Figma Agent Generation Specifications

### Frame 01: `01_Splash_Welcome`
- **Dimensions**: `393 × 852 px` | **Fill**: `#8B1E2D` (Primary Burgundy gradient down to `#5A121D`)
- **Stickers from Figma**: iOS 18 Status Bar (White, Dynamic Island, 9:41), iOS Home Indicator (White).
- **Auto Layout**: Vertical, `padding: [60px, 24px, 34px, 24px]`, `gap: 32px`, `align: center`.
- **Hero Image Layer**:
  - Image URL: `https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800&auto=format&fit=crop&q=80`
  - Dimensions: `345 × 360 px`, `border-radius: 28px`, overlay opacity: `15%` black.
- **Content Hierarchy**:
  - Hospital Emblem: Orienda Gold Caduceus badge (`48 × 48 px`).
  - Title: *"Orienda International Hospital"* (`26px`, Bold, `#FFFFFF`).
  - Subtitle: *"Cambodia's Leading Maternal, Pediatric & Specialist Healthcare Center."* (`14px`, `#F1F5F9`).
  - Language Switcher Sticker: Pill segmented control (`[🇰🇭 ភាសាខ្មែរ] | [🇬🇧 English]`).
- **CTA Actions**:
  - Primary Button: `[Get Started >]` (`fill: #FFFFFF`, `text: #8B1E2D`, `height: 52px`, `border-radius: 16px`).
  - Emergency Speed-Dial Text Link: `[🚨 24/7 Emergency Line: 081 811 789]` (`#FFD2D7`).

---

### Frame 02: `02_Auth_Login`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Stickers from Figma**: iOS 18 Status Bar (Dark), Segmented Phone/Email Tab, iOS Home Indicator (Dark).
- **Auto Layout**: Vertical, `padding: [54px, 20px, 34px, 20px]`, `gap: 20px`.
- **Header**:
  - Back Button: `[< Back]` circular icon button (`40 × 40 px`, `fill: #FFFFFF`).
  - Headline: *"Welcome to Orienda"* (`24px`, Bold, `#0F172A`).
  - Subtext: *"Enter your phone number to access your medical records and appointments."*
- **Form Controls (Figma Form Stickers)**:
  - Phone Input: Country code selector sticker `[🇰🇭 +855]` + Text field `[012 345 678]`.
  - Checkbox Sticker: *"I agree to the Orienda Patient Privacy & Medical Terms."*
  - Primary CTA: `[Send Verification Code]` (`fill: #8B1E2D`, `height: 50px`, `border-radius: 14px`).
  - Divider: *"or continue with"* (`#CBD5E1`).
  - Google Social Login Button: `[G Continue with Google]` (`fill: #FFFFFF`, border: `#E2E8F0`).
- **Trust Badge Footer**:
  - Icon: `Icon/ShieldCheck` + *"ISO 9001:2015 Certified & HIPAA Encrypted Health Records"*.

---

### Frame 03: `03_Home_Dashboard`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Persistent Bottom Nav Bar**: 5 Tabs with elevated center AI Assistant button (`fill: #8B1E2D`, `shadow: 0 4px 12px rgba(139,30,45,0.3)`).
- **Header Frame**:
  - Greeting: *"Hello, Phanet 👋"* (`18px`, Bold, `#0F172A`).
  - Branch Selector Pill: `[📍 Steung Meanchey Flagship ▼]` (`fill: #FFFFFF`, `border: #E2E8F0`, `radius: 999px`).
  - Emergency SOS Button: `[🚨 081 811 789]` (`fill: #D92525`, `text: #FFFFFF`, `height: 36px`).
- **Quick Action Grid (2×2 Layout, gap: 12px)**:
  - Card 1: `🩺 Find Doctor` (`fill: #FFFFFF`, `radius: 16px`)
  - Card 2: `🏥 Our Clinics`
  - Card 3: `📦 Health Packages`
  - Card 4: `💬 AI Assistant`
- **Featured Packages Carousel (Horizontal Auto-Layout, gap: 14px)**:
  - Card: `300 × 180 px`, `radius: 18px`, Image: `https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=800&auto=format&fit=crop&q=80`
  - Tag: `[Antenatal Care - $688.00]`.
- **Top Specialists Avatars (Horizontal Scroll)**:
  - Doctor circular avatars (`64 × 64 px`) with green availability badge: Dr. Nuth Sodara, Dr. Marie Dupont, Dr. Lim Chenda.

---

### Frame 04: `04_Branch_Selector_Modal`
- **Dimensions**: `393 × 852 px` | **Fill**: Overlay `#000000 40%` with Bottom Sheet (`height: 560px`, `fill: #FFFFFF`, `radius: 28px 28px 0 0`).
- **Drag Handle**: Pill `40 × 5 px` (`#CBD5E1`).
- **Title**: *"Select Hospital Campus"* (`20px`, Bold).
- **Branch Card 1 (Steung Meanchey Campus - Flagship)**:
  - Image: `https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800&auto=format&fit=crop&q=80` (`width: 100%`, `height: 120px`, `radius: 16px`).
  - Address: *"Building 66, Street 31cc, Steung Meanchey, Phnom Penh"*.
  - Badges: `[24/7 Emergency]` `[ICU / NICU]` `[3.0T MRI]` `[Delivery Suites]`.
  - Radio Button Sticker: `(● Selected)`.
- **Branch Card 2 (Chamkarmon Urban Clinic)**:
  - Image: `https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&auto=format&fit=crop&q=80` (`height: 120px`, `radius: 16px`).
  - Address: *"Building #9A, Street 466, Tonle Bassak, Chamkarmon"*.
  - Badges: `[Maternity LDR]` `[Pediatric Clinic]` `[Digital X-Ray]`.
  - Radio Button Sticker: `(○ Unselected)`.
- **Action**: `[Confirm Branch Selection]` (`fill: #8B1E2D`, `height: 50px`).

---

### Frame 05: `05_Clinics_Catalog`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Header**: Top app bar with back arrow and title *"Medical Clinics & Centers"* (`18 Specialized Specialties`).
- **Search Bar**: `[🔍 Search department or condition...]` (`fill: #FFFFFF`, `border: #E2E8F0`).
- **Clinic Grid (Vertical 2-column or list view, gap: 12px)**:
  - 1. **Obstetrics & Gynecology**: Icon `Icon/Baby`, *"Antenatal, 4D ultrasound, high-risk delivery"*.
  - 2. **Pediatrics & Neonatology**: Icon `Icon/Baby`, *"Newborn care, NICU, pediatric emergencies"*.
  - 3. **Fertility & IVF Center**: Icon `Icon/Sparkles`, *"ICSI, embryo genetics, ovarian stimulation"*.
  - 4. **Cardiovascular Center**: Icon `Icon/HeartPulse`, *"ECG, echocardiogram, cardiac rehabilitation"*.
  - 5. **Orthopedic & Spine Surgery**: Icon `Icon/Activity`, *"Endoscopic spine decompression, joints"*.
  - 6. **Emergency & Trauma (24/7)**: Icon `Icon/Siren`, *"Stroke triage, acute trauma resuscitation"*.
  - 7. **Dermatology & Aesthetic**: Icon `Icon/Sparkles`, *"Laser therapy, skin cancer screening"*.
  - 8. **General Internal Medicine**: Icon `Icon/Stethoscope`, *"Diabetes, hypertension, chronic disease"*.

---

### Frame 06: `06_Doctor_Directory`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Sticky Filter System**:
  - Live Search field: `[🔍 Search doctor name or specialty...]`.
  - Horizontal Chips (Figma Chip Stickers): `[All Doctors]` `[OB/GYN]` `[Pediatrics]` `[Cardiology]` `[Spine Surgeon]`.
  - Secondary Filter: `[📍 All Branches ▼]` `[🗣️ French / English ▼]`.
- **Doctor Card Component (Auto-Layout, vertical stack)**:
  - **Card 1**: Dr. Nuth Sodara
    - Photo: `https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80` (`72 × 72 px`, `radius: 16px`).
    - Title: *"Senior Consultant Obstetrician & Gynecologist"*.
    - Language Badges: `[Khmer]` `[English]` `[French]`.
    - Availability: `🟢 Available Today`.
    - CTA: `[Book >]` (`fill: #8B1E2D`, `radius: 12px`).
  - **Card 2**: Dr. Marie Dupont
    - Photo: `https://images.unsplash.com/photo-1594824813637-2852277d3329?w=400&auto=format&fit=crop&q=80`.
    - Title: *"Lead IVF & Reproductive Endocrinologist"*.
    - Language Badges: `[English]` `[French]`.
    - CTA: `[Book >]`.

---

### Frame 07: `07_Doctor_Profile`
- **Dimensions**: `393 × 852 px` | **Fill**: `#FFFFFF`
- **Hero Image Section**:
  - Full-bleed photo: `https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=800&auto=format&fit=crop&q=80` (`height: 280px`).
  - Floating circular back button & share button.
- **Doctor Overview Card (`radius: 24px 24px 0 0`, marginTop: `-24px`, `fill: #FFFFFF`)**:
  - Doctor Name: *"Dr. Nuth Sodara"* (`22px`, Bold).
  - Clinic Badge: `[🏥 Obstetrics & Gynecology Clinic]`.
  - Experience Metric: `18+ Years Exp.` | `4.9 ★ (120+ Reviews)`.
- **Tabbed Sections (Figma Tab Component)**:
  - Tab: `[About]` | `[Qualifications]` | `[Schedule]`.
  - Bio: *"Senior Obstetrician specializing in high-risk pregnancies, maternal-fetal medicine, and 4D anomaly ultrasounds."*
  - Qualifications List with `Icon/CheckCircle`:
    - *"MD - University of Health Sciences (Cambodia)"*
    - *"Diploma in Maternal-Fetal Medicine (Paris Descartes University, France)"*
    - *"Fellowship in Gynecological Surgery (Singapore)"*
- **Sticky Bottom Action**:
  - Price: *"Consultation from $35.00"* | `[Book Appointment]` (`fill: #8B1E2D`, `height: 52px`).

---

### Frame 08: `08_Packages_Catalog`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Top Bar**: *"Health Packages & Screenings"*.
- **Category Filter Chips**: `[All Packages]` `[Maternity]` `[Wellness]` `[Heart & Stroke]` `[Children]`.
- **Package Card (Auto-Layout, `fill: #FFFFFF`, `radius: 18px`, `border: #E2E8F0`)**:
  - Poster Image: `https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=800&auto=format&fit=crop&q=80` (`height: 160px`).
  - Badge: `[Comprehensive Antenatal Care]`.
  - Inclusions Summary: *"12 Specialist Visits • 7 Ultrasound Scans • Complete Lab Panels"*.
  - Price & Savings: `"$688.00 USD"` (Regular $920.00 - Save 25%).
  - Action: `[View Inclusions >]`.

---

### Frame 09: `09_Package_Detail`
- **Dimensions**: `393 × 852 px` | **Fill**: `#FFFFFF`
- **Hero Poster**:
  - Image: `https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=800&auto=format&fit=crop&q=80` (`height: 240px`).
- **Title Block**:
  - Title: *"Comprehensive Antenatal Pregnancy Care Program"* (`20px`, Bold).
  - Price Tag: `"$688.00 USD"` (`#8B1E2D`, `24px`, Bold).
  - Campus Availability: `[📍 Steung Meanchey]` `[📍 Chamkarmon]`.
- **Itemized Accordion Inclusions**:
  - 🩺 *Consultations*: 12 Visits with OB/GYN Specialist.
  - 📡 *Ultrasound Imaging*: 7 Scans including 4D Anomaly & Nuchal Translucency.
  - 🔬 *Laboratory Tests*: CBC, Blood Type, Rubella, Hepatitis B/C, Blood Glucose, Urinalysis.
  - 💊 *Vitamins*: 90 Days Iron & Folic Acid Supplements.
- **Preparation Guidance Card (Warning Fill `#FEF3C7`, border `#FDE68A`)**:
  - Icon: `Icon/Clock` + *"No fasting required for initial consultation. Please bring prior medical records."*
- **Sticky Bottom Action**:
  - `[Book This Package ($688)]` (`fill: #8B1E2D`, `height: 52px`, `radius: 16px`).

---

### Frame 10: `10_Booking_Wizard_Step1`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Progress Indicator Sticker**: `Step 1 of 3: Patient Information` (33% Burgundy progress line).
- **Patient Toggle (Figma Segmented Control Sticker)**:
  - `[ ● Book for Myself ]` vs `[ ○ Book for Family Member ]`.
- **Pre-filled Profile Card**:
  - Full Name: *"Phanet Sok"* | Phone: *"012 888 999"* | Age: *"29 Years"*.
- **Family Dependent Input (Hidden when 'Myself' active)**:
  - Dropdown: `[Select Child or Dependent ▼]`.
- **Referral Source Dropdown**:
  - Label: *"How did you hear about Orienda Hospital?"*
  - Dropdown: `[Facebook / Social Media ▼]`.
- **Bottom Navigation**:
  - `[Continue to Schedule >]` (`fill: #8B1E2D`, `height: 50px`).

---

### Frame 11: `11_Booking_Wizard_Step2_3`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Progress Indicator Sticker**: `Step 2 & 3: Date, Time & Confirmation` (100% Burgundy progress line).
- **Earliest Available Switch (Figma Toggle Switch Sticker)**:
  - Label: *"Book Earliest Available Slot"* `[ (● ON) ]`.
- **Interactive Calendar Strip**:
  - Horizontal date cards (Day & Number): `[Mon 12]` `[Tue 13 (Active)]` `[Wed 14]` `[Thu 15]`.
- **Time Slot Chips (Figma Chip Stickers)**:
  - Morning: `[09:00 AM (Active)]` `[10:30 AM]` `[11:15 AM]`.
  - Afternoon: `[02:00 PM]` `[03:30 PM]` `[04:45 PM]`.
- **Point-in-Time Snapshot Card**:
  - Doctor: Dr. Nuth Sodara (OB/GYN)
  - Location: Steung Meanchey Campus (Building 66)
  - Note field: `[Personal requests or symptoms...]`.
- **Submit Action**:
  - `[Confirm Appointment (Pay at Hospital)]` (`fill: #8B1E2D`, `height: 52px`).

---

### Frame 12: `12_Booking_Success_Ticket`
- **Dimensions**: `393 × 852 px` | **Fill**: `#8B1E2D`
- **Animated Confetti Elements** (Subtle vector stars & checkmark badge `#FFFFFF`).
- **Ticket Container (`fill: #FFFFFF`, `radius: 24px`, `padding: 24px`, dashed coupon separator)**:
  - Status: `🟢 Appointment Confirmed`.
  - Booking Reference Code: `OR-2026-8841`.
  - Doctor: Dr. Nuth Sodara (`10 OCT 2026 at 09:00 AM`).
  - Branch: Steung Meanchey Flagship Campus.
  - QR Code Sticker: High-contrast kiosk reception pass (`160 × 160 px`).
  - Text: *"Present this QR code at hospital kiosk on arrival for zero waiting time."*
- **Action Buttons**:
  - `[Add to Apple Calendar]` (`fill: #F1F5F9`, `text: #0F172A`).
  - `[Back to Home Dashboard]` (`fill: #FFFFFF 20%`, `text: #FFFFFF`).

---

### Frame 13: `13_My_Appointments`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Segmented Control Sticker**: `[ Upcoming Visits (1) ]` | `[ Past History (3) ]`.
- **Upcoming Booking Card (`fill: #FFFFFF`, `radius: 20px`, `border: #E2E8F0`)**:
  - Date & Time Badge: `10 OCT 2026, 09:00 AM` (`#8B1E2D`).
  - Doctor Info: Dr. Nuth Sodara — Obstetrics & Gynecology.
  - Location Pill: `[📍 Steung Meanchey Campus]`.
  - Action Row (3 Action Buttons):
    - `[🗺️ Directions]` (Opens Google Maps).
    - `[🔄 Reschedule]` (Changes appointment date/time).
    - `[❌ Cancel]` (Prompts cancellation bottom sheet).
- **Past Checkup Card**:
  - Date: `15 AUG 2026` — Dr. Lim Chenda (Pediatrics).
  - Status Badge: `[Completed]`.
  - Action: `[View Consultation Summary & Prescription]`.

---

### Frame 14: `14_AI_Chat_Assistant`
- **Dimensions**: `393 × 852 px` | **Fill**: `#F8FAFC`
- **Emergency Top Strip**:
  - Red Warning Banner: *"For life-threatening emergencies, call 081 811 789 immediately."* (`fill: #D92525`, `text: #FFFFFF`).
- **Chat Dialogue Canvas**:
  - **Bot Welcome Bubble**:
    - Avatar: `Icon/Sparkles` in burgundy circle.
    - Message: *"Hello! I am Orienda Virtual Assistant. I can help you with doctors, clinics, checkup packages, and appointments."*
  - **Quick Prompt Chips (Horizontal Scroll)**:
    - `[💡 Pregnancy package price?]`
    - `[💡 Which doctors speak French?]`
    - `[💡 Where is Chamkarmon branch?]`
  - **User Bubble**:
    - Text: *"What is included in the pregnancy package?"* (`fill: #8B1E2D`, `text: #FFFFFF`, right-aligned).
  - **Bot Grounded Response Bubble**:
    - Text: *"Our Comprehensive Antenatal Care Program ($688.00) includes 12 specialist consultations, 7 ultrasounds, and complete lab panels."*
    - **Interactive Cited Source Card**:
      - Image thumbnail: `https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=800&auto=format&fit=crop&q=80`.
      - Text: `[Antenatal Package ($688) >]` (`fill: #F1F5F9`, `radius: 12px`).
- **Floating Input Field**:
  - Text input: `[Ask about doctors, packages, branches...]` + Mic icon + Send button (`fill: #8B1E2D`).

---

### Frame 15: `15_Emergency_Triage_Modal`
- **Dimensions**: `393 × 852 px` | **Fill**: `#991B1B` (Emergency Crimson)
- **Stickers from Figma**: iOS 18 Status Bar (White), Emergency Call Dial Pad / One-Tap Action.
- **Top Icon**: Pulsing Siren Badge `Icon/Siren` (`72 × 72 px`, `#FFFFFF`).
- **Header**:
  - *"24/7 Emergency & Ambulance Dispatch"* (`26px`, Bold, `#FFFFFF`).
  - *"Immediate hospital triage, cardiac arrest resuscitation & acute trauma."*
- **Primary One-Tap Call Button**:
  - `[📞 Call 081 811 789 Now]` (`fill: #FFFFFF`, `text: #991B1B`, `height: 60px`, `font-size: 20px`, Bold).
- **Secondary Hotline**:
  - Chamkarmon Hotline: `[📞 Call 023 999 789]` (`fill: #FFFFFF 20%`, `text: #FFFFFF`).
- **Emergency Triage Guidance (3 Quick Steps)**:
  - 1. *Stay Calm & State Exact Location in Phnom Penh*.
  - 2. *Ambulance Mobile ICU Dispatched within 3 Minutes*.
  - 3. *Trauma Team Prepared on Hospital Arrival*.
- **Close / Dismiss Button**: `[Cancel / Back to App]`.

---

### Frame 16: `16_Article_Reader_Profile`
- **Dimensions**: `393 × 852 px` | **Fill**: `#FFFFFF`
- **Top App Bar**: Back button, bookmark icon, share icon.
- **Hero Article Poster**:
  - Image: `https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800&auto=format&fit=crop&q=80` (`height: 220px`).
- **Article Header**:
  - Clinic Tag: `[Cardiology & Emergency Center]`.
  - Headline: *"Orienda Officially Launches 24/7 Stroke & Cardiac Rapid Response Center"* (`20px`, Bold).
  - Published Date: *"15 Mar 2026 • 4 min read"*.
- **Article Body Text**:
  - Markdown formatted reading text with quotation callout and secondary photo.
- **Quality Feedback Entry Banner**:
  - Card: *"Help us improve hospital service"*.
  - Action: `[Submit Patient Feedback Form >]` (`fill: #F8FAFC`, `border: #E2E8F0`).

---

## 6. Copy-Paste Prompt for Figma AI / Figma Agent

Copy and paste the prompt below directly into **Figma AI** or any AI frame generator:

```markdown
Generate a high-fidelity mobile healthcare app design system for "Orienda International Hospital" (Cambodia). 
Device: iPhone 16 / 15 Pro (393 × 852 px).
Style: Premium, modern international hospital.
Color Palette: 
- Primary Burgundy: #8B1E2D
- Deep Teal: #0D5C75
- Champagne Gold: #C5A059
- Emergency Red: #D92525
- Background: #F8FAFC
- Card Surface: #FFFFFF

CRITICAL RULES:
1. Generate exactly 16 connected mobile screen frames numbered 01 to 16.
2. DO NOT USE casual cartoon stickers or emojis.
3. USE FIGMA FORM & UI KIT STICKERS ONLY: iOS 18 native status bars, home indicators, segmented controls, toggle switches, and pill status badges.
4. Use standard vector icons (Lucide / Material Symbols): Home, Stethoscope, Hospital, Sparkles, Calendar, User, PhoneCall, Siren, MapPin, Search.
5. Populate image fills using real direct medical photos:
   - Hospital exterior: https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800&auto=format&fit=crop&q=80
   - Female Doctor: https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80
   - Male Doctor: https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&auto=format&fit=crop&q=80
   - Pregnancy package: https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=800&auto=format&fit=crop&q=80
   - Newborn baby: https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=800&auto=format&fit=crop&q=80
   - Emergency ambulance: https://images.unsplash.com/photo-1587745416684-47953f16f02f?w=800&auto=format&fit=crop&q=80

Screen List to generate:
- 01_Splash_Welcome
- 02_Auth_Login
- 03_Home_Dashboard
- 04_Branch_Selector_Modal
- 05_Clinics_Catalog
- 06_Doctor_Directory
- 07_Doctor_Profile
- 08_Packages_Catalog
- 09_Package_Detail
- 10_Booking_Wizard_Step1
- 11_Booking_Wizard_Step2_3
- 12_Booking_Success_Ticket
- 13_My_Appointments
- 14_AI_Chat_Assistant
- 15_Emergency_Triage_Modal
- 16_Article_Reader_Profile
```
