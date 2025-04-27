# 🎨 Generative Art with Flutter

Welcome to my **Generative Art** experiments using **Flutter's CustomPaint and Animation** features.  
This repo is about exploring how code and creativity can merge into beautiful visualizations!

---

## 📂 Projects

| Project | Preview | Description |
|:-------|:--------|:------------|
| [Hours of Dark](https://github.com/Chijama/generative_art_flutter/tree/hours_of_dark_%26_animated_version) | [![Hours of Dark](gifs/hours_of_dark.gif)](https://github.com/Chijama/generative_art_flutter/tree/hours_of_dark_%26_animated_version) | A Flutter recreation of the "Hours of Dark" generative art piece. 365 bars represent each day of the year. Each bar’s width shows the hours of darkness, and its angle reflects sunset behavior based on a simple trigonometric approximation. |
| [Data-Driven Hours of Dark](https://github.com/Chijama/generative_art_flutter/tree/data_driven_hours_of_darkXanimated_version) | [![Data Driven Hours of Dark](gifs/lagos_hours_of_dark.gif)](https://github.com/Chijama/generative_art_flutter/tree/data_driven_hours_of_darkXanimated_version) | A data-driven version that fetches **real astronomical sun data** for a specific city and year. The visualization encodes the actual rhythm of seasonal changes in the city. |

🔗 **Click the title or image to jump directly to the project's branch.**

---

## 📜 Requirements

This project uses:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0        # For API calls
  path_provider: ^2.0.15 # For saving and reading local files
  sunrise_sunset: ^1.0.3 # (or your API wrapper if custom)
```

- **Flutter SDK** installed
- **Familiarity** with Flutter's `CustomPainter` and `AnimationController`
- (Optional) An **API key** if using external astronomical data sources

---

## 🚀 How to Run

### Clone the repository:

```bash
git clone https://github.com/Chijama/generative_art_flutter.git
cd generative_art_flutter
```
### Checkout the branch you want:
For Hours of Dark:
```bash
git checkout hours_of_dark_&_animated_version
```
For Data-Driven Hours of Dark:
bash
```
git checkout data_driven_hours_of_darkXanimated_version
```
### Install packages:
```bash
flutter pub get
```
### Run the app:
```bash
flutter run
```
## ✨ About
This project began as a personal challenge to explore the artistic side of Flutter.
Using code to paint, animate, and bring real-world astronomical data into motion was both educational and creatively satisfying!

## 🧠 Future Plans
Create more generative pieces 

Launch a mini Flutter gallery app showcasing the different generative artworks

Write detailed tutorials and Medium posts to share the journey

## 📢 Notes
The data-driven version requires an internet connection initially to fetch sun data.

It saves JSON locally, avoiding excessive API requests once downloaded.

Some API services may have request limits — use caching wisely!

## 🛠️ License
This project is licensed under the MIT License — free to use, modify, and share!

## 📬 Connect
Feel free to follow my journey or reach out if you liked this project! 🚀
