 # WaspitoPlus

WaspitoPlus is a comprehensive healthcare application designed to connect patients with medical services, pharmacists, and doctors efficiently. The app provides a seamless experience for consulting professionals, checking symptoms, managing prescriptions, making payments, and tracking medicine delivery—all from a single, user-friendly platform.

## Features

### 1. **Consult a Doctor**
- Browse a list of available doctors with profiles including:
  - Name, Title, Specialty, License Number
  - Experience, Consultations Count, Ratings
  - Languages spoken, Hospital affiliation
- Tap on a profile to view detailed information.
- Interactive buttons to **consult** or **follow** a doctor.
- Toast messages and popups for feedback during interactions.

### 2. **Symptom Checker**
- Input symptoms to get guidance on potential conditions.
- Provides advice to see a doctor or pharmacist based on severity.
- Works offline for basic symptom input and guidance.

### 3. **Offline Mode**
- Key features like viewing saved profiles, previous consultations, and symptom checker work offline.
- Ensures users can access critical information even without an internet connection.

### 4. **Pharmacy & Prescription Management**
- Personalized pharmacist messages for each patient.
- Payment integration to ensure prescriptions are processed securely.
- Dosage guidance dynamically calculated based on patient age:
  - Children (<12): spoon measurements
  - Adults (<60): tablets 3x/day
  - Seniors (60+): tablets 2x/day with water
- Follow-up questions and app feedback collection.
- Delivery confirmation with phone number submission and animated delivery tracking.

### 5. **User Profiles**
- Each patient has a secure, personalized account.
- Profiles store consultation history, prescriptions, and follow-up notes.
- Doctors can have detailed profiles for patients to view.

### 7. **Interactive Notifications**
- Users receive confirmations for consultations, prescriptions, and payments.
- Alerts and popups for important actions and feedback.

## Architecture

WaspitoPlus follows the **MVVM (Model-View-ViewModel)** architecture:

- **Models:** Define the structure for users, doctors, prescriptions, obstacles, and app states.
- **ViewModels:** Handle business logic, data management, and state updates.
- **Views:** SwiftUI interfaces that bind to ViewModels for real-time updates.
- **Offline Handling:** Core Data and local storage ensure offline functionality.

## Installation

1. Clone the repository:
```bash
git clone https://github.com/YourUsername/WaspitoPlus.git
