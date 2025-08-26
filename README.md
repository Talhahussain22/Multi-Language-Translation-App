LangRush

A **multi-language translation and vocabulary learning app** built with Flutter. LangRush integrates API-based translation, flashcards, quizzes, and topic-based learning — with offline support and clean state management.

"APP LINK" https://drive.google.com/file/d/10uXjUlBRsBrgluTh9lNOgKIOCtnX4MNT/view?usp=drive_link

---

🚀 Features

* 🌍 **Multi-language translation** via REST API.
* ⭐ **Favourite words** with flashcard generation.
* 🗂 **Topic-based summaries** for organized learning.
* 📝 **Quizzes**:

* From Favourite words.
* General language quizzes (MCQs, typing, matching).
* 📦 **Offline-first** with **Hive** local storage.
* ⚡ **Bloc** state management for predictable and scalable UI.
* 🧩 **Clean modular architecture** (data, domain, presentation).

---

🛠️ Tech Stack

* **Flutter** – UI framework
* **Bloc** – State management
* **Hive** – Local storage & caching
* **Dio/HTTP** – REST API client
* **Equatable** – Value equality for Bloc states/events

---
## 📊 State Management

* Blocs: `TranslateBloc`, `FavoritesBloc`, `FlashcardsBloc`, `QuizBloc`, `TopicsBloc`
* Pattern: **Event → UseCase → Repository → DataSource → State**



---

🗄️ Local Storage

* Hive **boxes**: `favorites`, `flashcards`, `topics`, `settings`, `cache_translations`
* Cached translations reduce API calls with TTL strategy.

---

📚 Flashcards & Quizzes

* Flashcards generated from Favourite words.
* Topic-based flashcards for focused practice.
* Quizzes support MCQ, typing, and matching formats.



