# SIGMA  
**Secure Identity & GPG Media Authority**

SIGMA is a browser-based platform for digitally signing media and conducting encrypted communication using modern OpenPGP-compatible cryptography. Built for individuals, organizations, and governments, SIGMA emphasizes privacy, authenticity, and clarity.

## 🔐 Key Features

- Media signing with Ed25519
- Message encryption using Curve25519 + AES-256
- File verification using detached signatures
- Encrypted messaging with labeled keypairs
- Persistent keyring in secure volume
- Key wipe and regeneration on demand
- Fully Dockerized, Unraid-compatible

---

## 📦 Stack

| Component | Tech |
|----------|------|
| Frontend | Elm |
| Backend  | Rust (Axum, Sequoia) |
| Deployment | Docker, Docker Compose |
| Base OS | Alpine Linux |

---

## 🚀 Getting Started

```bash
git clone https://github.com/ibphantom/SIGMA.git
cd SIGMA

# Optional: customize environment
cp .env .env.local
nano .env.local

# Build and launch
docker-compose up --build
