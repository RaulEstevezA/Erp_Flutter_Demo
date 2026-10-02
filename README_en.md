# ERP Flutter · Web demo of an ERP app in production

> [!IMPORTANT]
> **This is the public demo of a real application.**
> I built the original app during my internship at **Microvalencia Soluciones Informáticas**, and the company uses it with its ERP. Its source code belongs to the company and is not public.
>
> This repository is a **from-scratch rewrite** so that the app can be shown: same features, navigation and screen design, but with a different name, colours and logo, **made-up data** and a static backend instead of the Laravel API. It contains no Microvalencia code or data.

**Live demo:** [raulesteveza.github.io/demos/ERP_Flutter](https://raulesteveza.github.io/demos/ERP_Flutter/)\
**Video of the real app:** [youtu.be/lrgRXaBEdI4](https://youtu.be/lrgRXaBEdI4)\
**Project page:** [Projects](https://raulesteveza.github.io/projects.html) · [Experience](https://raulesteveza.github.io/experience.html)

<p align="center">
  <img src="img/login.png" alt="Login screen" width="180" />
  &nbsp;
  <img src="img/main.png" alt="Home screen of an admin user" width="180" />
  &nbsp;
  <img src="img/holidays_black.png" alt="A worker's holidays in dark mode" width="180" />
</p>

---

## Contents

- [The real project](#the-real-project)
- [This demo](#this-demo)
- [How to try it](#how-to-try-it)
- [Modules](#modules)
- [Roles and permissions](#roles-and-permissions)
- [Differences from the real app](#differences-from-the-real-app)
- [Static backend](#static-backend)
- [Architecture](#architecture)
- [Running locally](#running-locally)
- [Tests](#tests)
- [Deployment](#deployment)
- [Legal notice](#legal-notice)

---

## The real project

**Company:** Microvalencia Soluciones Informáticas S.L.\
**Role:** Software Developer Intern · March – June 2026 · 383 h\
**Status:** in production · version 2.3.7 · the company is preparing its release on Google Play Store and App Store

### Goal

Bring part of the company's daily ERP work to the phone, so staff can use it on the move **without replacing the main system**. Through REST APIs, the app works with users, permissions, clients, clock-ins, work reports, visits, holidays, documents and messaging.

The scope was set by the company. Many more features could have been added technically, but the goal was not to give the phone full autonomy over the ERP: the app is **day-to-day support** for staff who already use it. That is why some actions deliberately stay in the desktop ERP; for example, the description and remarks of work reports can be read on the phone but not edited.

### Both sides of the stack

- **Mobile app (Flutter):** I designed and built it end to end.
- **Backend (Laravel/PHP):** I designed and implemented from scratch about **90 % of the API controllers and routes** the app uses. These are mobile-specific endpoints with optimised responses, validation, per-profile permissions and data formats tailored to Flutter.

I started with no prior experience in Flutter, PHP or Laravel, and learned and applied all three on this production project.

### Features

- Authentication with a **configurable server URL**, options to remember the URL and user, automatic session restore and secure logout.
- **Clock-in/out** with optional GPS location, monthly history and a per-employee grouped view for admins.
- **Clock-in incidents:** creation, detail and status tracking.
- **Internal messaging** with periodic polling and an unread counter.
- **Work reports** with line items, audio recording, image attachments and **digital client signature**.
- **Visit reports** linked to clients, with optional travel distance and time.
- **Clients:** search, detail view, five document types (quotes, orders, delivery notes, invoices and recurring invoices) and opening addresses in Maps.
- **Holidays** with a visual calendar, requests, approval, rejection and cancellation.
- **Role-based access control** with six profiles: superadmin, admin, user, worker, client and supplier.
- **Internationalisation** in Spanish, Valencian, Catalan and English, plus light/dark theme.

### Technical highlights

- **Feature-based** structure with **MVVM** architecture and **SOLID** principles: one ViewModel per module, immutable state and strict layer separation.
- **Three-layer error handling** (network exception → domain exception → localised UI message) with 15 error types, from SSL certificate problems and timeouts to wrong credentials or a server outage.
- **Encrypted session** using the device's secure storage (FlutterSecureStorage), with a specific workaround for the Keystore on Xiaomi/MIUI phones.
- Real-time **server outage detection** that blocks navigation in a controlled way, so no screen is left half-loaded.
- The home screen and side menu work out which modules each role sees from the **session stored on the device**, so navigation is available even if the server does not respond at startup.
- Handling of the Android **back gesture** and bottom padding on devices with gesture navigation.
- **Two production variants** (full and *lite*) from the same code base using **Flutter Flavors**. The *lite* one only keeps clock-ins, incidents and holidays.
- **Chat polling** only notifies the UI when the message count or the last message changes, to avoid needless rebuilds.
- **Technical documentation**, **changelog** and **semantic versioning** (16 releases up to 2.3.7). Tested on real devices and emulators, with fixes for different screen sizes and Android versions.

**Technologies:** Flutter, Dart, PHP, Laravel, REST API, MVVM, SOLID, Dio, FlutterSecureStorage, Geolocator, Flutter Flavors.

---

## This demo

To show the app without depending on the company's ERP, I rewrote it entirely in this repository:

1. **Clean rewrite.** The code is written anew; the original app was only used as a reference for features and design.
2. **A different identity.** The name *ERP Flutter*, indigo, violet and teal colours, and its own vector logo.
3. **Made-up data.** The company, users, clients, documents, reports, photos and messages are fictional.
4. **Static backend.** The Laravel API is replaced by JSON files generated by a script. Anything that would be a write in the API (clocking in, signing, adding a line...) is stored on the device.
5. **Always current.** Dates are stored relative to today, so the demo shows recent activity even if the JSON was generated months ago.
6. **Runs in the browser** and on Android, iOS and macOS. The web build is published automatically on my website.

## How to try it

Open the [live demo](https://raulesteveza.github.io/demos/ERP_Flutter/) or run it locally. On the login screen the `demo` server is already filled in, and the account can be picked under **“Cuentas de demostración”**. The password for every account is `demo1234`.

| Account | Role | What it sees |
|---|---|---|
| `superadmin@erpflutter.dev` | Superadmin | Everything: clock-ins, holidays and work reports for all staff, clients and visits |
| `admin@erpflutter.dev` | Admin | Same as superadmin |
| `usuario@erpflutter.dev` | User | Their own clock-ins, incidents, holidays and the work reports they are assigned to |
| `trabajador@erpflutter.dev` | Worker | Same as user |
| `cliente@erpflutter.dev` | Client | Messaging |
| `proveedor@erpflutter.dev` | Supplier | Messaging |

Some things to try:

- **Clock in** from the home screen and check the record and its location under *Ver fichajes*.
- **Request holidays** as a worker and **approve them** as an admin.
- **Message** any user: the recipient “replies” a few seconds later.
- **Open a work report**, add catalogue lines (labour is charged per hour based on the minutes), change their price, attach photos or voice notes and **sign** it.
- **Reset the data** from the side menu to go back to the initial state.

The interface is in Spanish by default; the language can be switched to English, Valencian or Catalan from the login screen.

## Modules

| Module | Contents |
|---|---|
| **Home** | Live clock, clock-in button with confirmation, shortcuts to the role's modules and a floating messages button with unread count |
| **Clock-ins** | By month or date range, grouped by employee (management), location in Maps and reporting an incident from a record |
| **Incidents** | List by period, grouping by employee and detail with status |
| **Holidays** | Yearly list and calendar, day summary, request and cancellation (staff), approval and rejection (management) |
| **Messaging** | Conversations, chat with periodic polling, new message with recipient search and unread counter |
| **Clients** | Search, detail (addresses, contacts, payment) and five document types with lines and totals |
| **Visit reports** | Company selection, visits by month, range or search, detail and creation with technicians and travel |
| **Work reports** | Active and finished, search, dates, grouping by company, lines with products and prices, files (camera, gallery and audio) and client signature |

## Roles and permissions

Permissions live in a single matrix ([`permissions.dart`](lib/core/roles/permissions.dart)). Each module is shown or hidden according to it, and the repositories check it again: even if someone reached a screen, they would not get data they are not allowed to see.

| Permission | Superadmin / Admin | User / Worker | Client / Supplier |
|---|:---:|:---:|:---:|
| Clock in and see own clock-ins | ✅ | ✅ | |
| See clock-ins for all staff | ✅ | | |
| Holidays: request | | ✅ | |
| Holidays: see all and approve | ✅ | | |
| Work reports: own | ✅ | ✅ | |
| Work reports: all | ✅ | | |
| Clients and visit reports | ✅ | | |
| Messaging | ✅ | ✅ | ✅ |

## Differences from the real app

| | Real app (Microvalencia) | This demo |
|---|---|---|
| Backend | Laravel/PHP REST API on top of the ERP | Static JSON generated by a script |
| Writes | Stored in the ERP | Stored on the device; can be reset |
| Data | The company's | Made up |
| Identity | Microvalencia branding | *ERP Flutter*: different colours and logo |
| Network and session | Dio, FlutterSecureStorage, server outage detection | `http`, SharedPreferences, simulated latency |
| Location | Real GPS (Geolocator) | Simulated coordinates |
| Variants | Full and *lite* (Flutter Flavors) | A single one |
| Messages | Messages with file attachments | Text only, with automatic replies |
| Files | Uploaded to the ERP | App folder (mobile and desktop) or browser (web) |

The demo also has a few additions that are not in the real app: catalogue prices on work report lines (editable per line), labour calculated per hour from the minutes, the report total and the button to reset the data.

## Static backend

```
backend/
├── index.html                 Landing page listing the endpoints
└── api/
    ├── users.json             Users and roles
    ├── company.json           Company
    ├── clock_in_records.json  Clock-ins
    ├── clock_in_incidents.json
    ├── holidays.json          Holidays, public holidays and yearly allowance
    ├── messages.json          Conversations, messages and automatic replies
    ├── clients.json           Clients with addresses, contacts and payment
    ├── client_documents.json  Quotes, orders, delivery notes and invoices
    ├── visit_reports.json     Visit reports
    ├── workers.json           Technicians
    ├── products.json          Catalogue with prices
    └── work_reports.json      Work reports with lines, files and signatures
```

- **Generation:** `python3 tool/generate_backend.py`. It uses a fixed seed, so it always produces the same data.
- **Relative dates:** stored as working days before today plus a time, and converted by the app when it opens.
- **`demo` server:** reads the JSON bundled with the app. With a URL, it requests `<url>/api/<resource>.json`, for example `https://raulesteveza.github.io/demos/ERP_Flutter`.
- **Sample files:** the work report photos are illustrations drawn with `flutter test tool/render_demo_files_test.dart`; the voice note is generated by the Python script.

## Architecture

```
lib/
├── core/       Theme, logo, roles and permissions, session, network, dependency
│               injection, reusable widgets and base ViewModels
├── data/       Repositories (one per module) and local storage
├── domain/     Models
├── features/   One folder per module: screens, ViewModels and their widgets
└── l10n/       Translations (es, en, ca and Valencian)
```

- **MVVM** with `ChangeNotifier` and `ListenableBuilder`, without external state packages.
- **Repositories** that apply business and permission rules, independent of the screens.
- **Base ViewModels** for lists with periods, search, infinite paging and discarding stale responses.
- **File storage** with one implementation per platform (files or browser) via conditional imports.
- **Internationalisation** with `gen-l10n`, with Valencian as a variant of Catalan.

## Running locally

Requires Flutter 3.47 or later.

```bash
flutter pub get
flutter run            # Android, iOS or macOS
flutter run -d chrome  # Web
```

To see it exactly as published (page with the phone frame, the app under `app/` and the backend under `api/`):

```bash
flutter build web --release --base-href /demos/ERP_Flutter/app/

mkdir -p /tmp/site/demos/ERP_Flutter
cp -R showcase/. /tmp/site/demos/ERP_Flutter/
cp -R build/web /tmp/site/demos/ERP_Flutter/app
cp -R backend/api /tmp/site/demos/ERP_Flutter/api
cp backend/index.html /tmp/site/demos/ERP_Flutter/backend.html
cd /tmp/site && python3 -m http.server 8000
# Open http://localhost:8000/demos/ERP_Flutter/
```

To regenerate the app icons from the vector logo:

```bash
flutter test tool/render_app_icon_test.dart
dart run flutter_launcher_icons
```

## Tests

```bash
flutter test
```

There are 49 tests. They cover each role's permissions, the working-day calendar, clocking in, holidays, messaging, clients, visits and work reports (lines, prices, hourly labour, signature, files and resetting). There are also screen walkthroughs at phone size.

## Deployment

The [`deploy-demo.yml`](.github/workflows/deploy-demo.yml) workflow runs on every push to `main` and can also be started manually from *Actions*:

1. Runs `flutter analyze` and `flutter test`.
2. Builds the web app for the `/demos/ERP_Flutter/app/` path.
3. Publishes to `demos/ERP_Flutter/` in the [RaulEstevezA.github.io](https://github.com/RaulEstevezA/RaulEstevezA.github.io) repository:

| Path | Contents |
|---|---|
| `demos/ERP_Flutter/` | Showcase page with the app in a phone frame ([`showcase/`](showcase/index.html)) |
| `demos/ERP_Flutter/app/` | Web app |
| `demos/ERP_Flutter/api/` | Static backend |
| `demos/ERP_Flutter/backend.html` | Backend landing page |

It needs the `PORTFOLIO_DEPLOY_TOKEN` Actions secret: a *fine-grained* token with **Contents: Read and write** permission on `RaulEstevezA.github.io` only. The website's `demos/ERP_Flutter/` folder is fully replaced on every deployment, so it must not be edited by hand.

## Legal notice

The original application, its code and its data belong to **Microvalencia Soluciones Informáticas S.L.** This repository contains none of them: it is an independent rewrite for portfolio purposes, with a made-up visual identity and data. The sample illustrations were drawn for this demo.

## Developer

**Raul Estevez**

- [Personal Website](https://raulesteveza.github.io/)
- [LinkedIn Profile](https://www.linkedin.com/in/raulesteveza/)

[Back to main README](./README.md)
