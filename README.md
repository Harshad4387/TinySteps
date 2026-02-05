# 👶 Tiny Steps: From Bump to Baby
> **Your Intelligent, AI-Powered Partner for the Parenting Journey.**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey)]()

---

## 📺 Project Demo
Experience Tiny Steps in action:
**[▶️ Watch the Demo Video](https://drive.google.com/drive/folders/1g0YMSYZEjnEA7HC1Hjfm4FiiBpAsHwfb?usp=sharing)**

## 📲 Download the App
Get the latest build for Android:
**[📥 Download APK (Google Drive)](https://drive.google.com/drive/folders/1xlRx3wtiNpLJCzhCtL2rBjl61FVy0mAo)**

---

## 📖 Overview
**Tiny Steps** is a holistic ecosystem designed to bridge the gap in maternal and infant healthcare. By integrating continuous monitoring, personalized medical insights, and partner-inclusive care, we transform the fragmented journey of parenthood into a unified, data-driven experience.



---

## 🚩 The Challenge
Parenting today is fragmented and overwhelming.
* **📝 Manual Tracking:** Parents struggle juggling vaccinations, growth milestones, and feeding schedules.
* **🥗 Nutrition Gaps:** 15M+ pregnant women in India suffer from anemia; generic advice is often unreliable.
* **🧠 Silent Struggles:** Postpartum Depression (PPD) affects 5–6M women annually but often goes undiagnosed.
* **🤝 Gender Imbalance:** Most platforms ignore partners, placing the mental load solely on the mother.

---

## 🚀 Key Features

### 🥗 AI Smart Food Safety Scanner
* **What it does:** Identifies safe vs. unsafe food items in real-time.
* **Tech:** Uses **ML Kit Vision** to classify risks and suggest healthy substitutes.

### 🤖 RAG-Based Medical Chatbot
* **What it does:** A 24/7 personalized health companion.
* **Tech:** Uses **RAG (Retrieval-Augmented Generation)** to link LLMs with private health data (EHR/Lab reports).

### 🧠 Multi-Model PPD Screening
* **What it does:** Early detection of Postpartum Depression risk using a **Stacked Ensemble ML model**.

### 📈 Intelligent Growth Engine
* **What it does:** Automated tracking of milestones. Predictive analytics flag abnormal growth patterns early.

---

## 🛠 Tech Stack

| Domain | Technologies |
| :--- | :--- |
| **Frontend** | 📱 Flutter, 🎨 Tailwind CSS |
| **Backend** | 🐍 Python (FastAPI/Django), 🚀 Node.js, 🐳 Docker |
| **AI / ML** | 🤖 TensorFlow, 🔥 PyTorch, 🧪 Scikit-Learn, 👁️ Google ML Kit |
| **LLM & RAG** | 🦜️🔗 LangChain, 🧠 OpenAI/Llama 3, 📚 Pinecone (Vector DB) |
| **Database** | 🐘 PostgreSQL, 🍃 MongoDB, ⚡ Redis |
| **Cloud** | ☁️ AWS/GCP, ☸️ Kubernetes, 🔄 GitHub Actions |
| **Security** | 🔐 Zero Trust Architecture, 🧬 AES-256 Encryption |

---

## 🏗 System Architecture

1.  **Microservices Architecture:** Independent services scale horizontally to handle traffic spikes.
2.  **Hybrid AI Processing:** On-device ML for low-latency scans + Cloud AI for deep RAG insights.
3.  **Privacy-First Design:** Consent-based access and fully encrypted health data handling.

---

## 📈 Impact & Scalability
* **🌍 Massive Reach:** Targeting **25 Million** pregnancies annually in India.
* **💰 Economic Potential:** Tapping into the **$5.52B** Indian FemTech market.
* **🏥 Social Impact:** Directly combating maternal anemia and infant mortality.

---

## 🔧 Installation & Setup

### 🔙 Backend Setup
```bash
# Navigate to backend
cd tiny-steps/backend
pip install -r requirements.txt
# Run the server
python main.py
# Navigate to frontend
cd tiny-steps/frontend
# Install dependencies
flutter pub get
# Run the application
flutter run
