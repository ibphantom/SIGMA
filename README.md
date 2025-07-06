# SIGMA
Secure Identity &amp; GPG Media Authority

SIGMA is a secure, browser-based platform for digitally signing media and conducting encrypted communication using modern OpenPGP-compatible cryptography. Built for individuals, organizations, and governments, SIGMA emphasizes authenticity, privacy, and cryptographic clarity—without sacrificing usability.

---

## 🔐 Purpose

- Digitally **sign images, videos, and documents** to prove authorship and integrity.
- Securely **send and receive encrypted messages** with full public/private key control.
- Offer an easy-to-use **graphical interface** for drag-and-drop signing and intuitive key management.
- Ensure cryptographic operations are performed with memory-safe, peer-reviewed tools and modern best practices.

---

## 🛠️ Features

- ✅ Strong digital signatures using **Ed25519**
- ✅ End-to-end encryption using **Curve25519 + AES-256**
- ✅ Drag-and-drop file interface for signing and verifying media
- ✅ Encrypted messaging with transparent key handling
- ✅ Persistent GPG keyring with support for multiple labeled keypairs
- ✅ Optional full keyring wipe (secure zero-out)
- ✅ Built with **Rust** (Axum) and **Elm** for memory safety
- ✅ Dockerized with Alpine Linux for minimal, secure deployment

---

## 📦 Architecture

- **OS**: Alpine Linux (Docker containerized)
- **Backend**: Rust + Sequoia OpenPGP (via Axum)
- **Frontend**: Elm (compiled to static assets)
- **Service orchestration**: Docker Compose
- **Persistent GPG data**: Stored in mounted volume `/data/gnupg/`

---

## 🚀 Getting Started

```bash
git clone https://github.com/yourusername/sigma.git
cd sigma
docker-compose up --build
