# 📦 EssentialFeed

The goal of this project is to display deep understanding of advanced, platform agnostic engineering concepts — It features modular iOS app architecture broken into clean, testable components. Built using layered targets like `EssentialFeed`, `EssentialFeediOS`, and `EssentialApp`.

---

## 🧱 Modular iOS Architecture Guide

This repo follows a clean modular architecture using `.xcworkspace` to compose separate `.xcodeproj` modules.

---

### 1. Module Ownership

- ✅ Each type (class, protocol, struct) **lives in one module only**
- ✅ Core business logic is in `EssentialFeed`
- ✅ UI composition and orchestration is in `EssentialFeediOS`
- ✅ `EssentialApp` depends only on the UI layer

---

### 2. Target Membership Discipline

- ✅ Use `import EssentialFeed` instead of duplicating types or protocols  
- ✅ Test targets import modules instead of reusing source files  

---

### 3. Linking and Dependencies

- 📦 This project uses a `.xcworkspace` to manage multiple `.xcodeproj` files
- 🔗 Dependency flow:
  - `EssentialFeediOS` ➝ depends on `EssentialFeed`
  - `EssentialApp` ➝ depends on `EssentialFeediOS`
