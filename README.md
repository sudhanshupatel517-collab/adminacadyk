# 🚀 Acadyk Native Admin Panel (Flutter / Dart)

This repository contains the **Acadyk Native Admin Panel**, built with Flutter & Dart using modern responsive design, light/dark themes, graphical analytics, and role-based access control.

---

## ⚡ One-Click Vercel Deployment

This project includes pre-configured **ercel.json** and **uild.sh** for automatic building on Vercel:

1. Go to [vercel.com](https://vercel.com) and click **"Add New Project"**.
2. Import this repository: https://github.com/sudhanshupatel517-collab/adminacadyk
3. Vercel will automatically detect ercel.json and run ash build.sh.
4. Click **Deploy**!

### Manual Project Settings (if configuring manually on Vercel):
- **Build Command**: ash build.sh
- **Output Directory**: uild/web
- **Install Command**: *(leave empty)*

---

## 💻 Local Development

### Prerequisites
- Flutter SDK (>=3.0.0)
- Chrome or any modern browser

### Run locally:
`ash
# Run on Chrome
flutter run -d chrome

# Or build for web production
flutter build web --release --no-wasm-dry-run

# Serve production build locally
npx serve -s build/web -l 3000
`

---

## 🔐 Default Admin Credentials
- **Email**: dmin@acadyk.edu
- **Password**: SuperAdmin2026!
- **Role**: Super Admin

---

## 📱 Responsive & Theme Support
- **Mobile (<=600px)**: Left-sliding profile drawer, logo-only header, 5-tab bottom navigation, adaptive cards.
- **Tablet (600px–1024px)**: Collapsed icon rail, 2-column grids.
- **Desktop (>=1024px)**: Full sidebar (260px), top bar with page breadcrumbs & profile dropdown, 4-column stat grids, full-width data tables, interactive graphical charts.
- **Theme**: Seamless Light / Dark mode toggle (accessible via top-right in mobile and desktop top bar).