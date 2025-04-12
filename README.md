# 📦 EssentialFeed

This is my main project for the **Essential iOS Course** — a modular iOS app architecture broken into clean, testable components. Built using layered targets like `EssentialFeed`, `EssentialFeediOS`, and `EssentialApp`.

---

## 🧱 Modular iOS Architecture Guide

This repo follows a clean modular architecture using `.xcworkspace` to compose separate `.xcodeproj` modules. Below are best practices and setup steps to ensure smooth integration.

---

## ✅ Integration Checklist

### 1. Module Ownership

- ✅ Each type (class, protocol, struct) **lives in one module only**
- ✅ Core business logic is in `EssentialFeed`
- ✅ UI composition and orchestration is in `EssentialFeediOS`
- ✅ `EssentialApp` depends only on the UI layer

---

### 2. Target Membership Discipline

- ❌ Avoid assigning the same file to multiple targets  
- ✅ Use `import EssentialFeed` instead of duplicating types or protocols  
- ✅ Test targets import modules instead of reusing source files  

---

### 3. Linking and Dependencies

- 📦 This project uses a `.xcworkspace` to manage multiple `.xcodeproj` files
- 🔗 Dependency flow:
  - `EssentialFeediOS` ➝ depends on `EssentialFeed`
  - `EssentialApp` ➝ depends on `EssentialFeediOS`

#### Setup:

- **Build Phases > Target Dependencies**
  - Add `EssentialFeed` to `EssentialFeediOS`

- **Build Phases > Link Binary With Libraries**
  - Link `EssentialFeed.framework` to `EssentialFeediOS`

---

### 4. Build Settings Consistency

| Setting                                      | Recommended Value       |
|---------------------------------------------|--------------------------|
| `Defines Module`                             | YES                      |
| `Build Libraries for Distribution`           | NO (unless shipping binary frameworks) |
| `Objective-C Generated Interface Header Name`| *(Clear or remove)*      |
| `Enable Modules (C and Objective-C)`         | YES                      |
| `iOS Deployment Target`                      | Match across all targets (e.g. 16.6) |

---

## 🧪 Pro Tips

- 💡 Clean build often when restructuring modules:
  ```sh
  rm -rf ~/Library/Developer/Xcode/DerivedData
