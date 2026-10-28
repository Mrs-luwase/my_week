<h1 align="center">My Week</h1>

<p align="center">
  A weekly class timetable that adds up your hours, warns you about clashes, and remembers everything you enter.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3F6B52?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3F6B52?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/shared__preferences-3F6B52?style=for-the-badge" alt="shared_preferences">
  <img src="https://img.shields.io/badge/DummyJSON_API-3F6B52?style=for-the-badge" alt="DummyJSON API">
  <img src="https://img.shields.io/badge/Material_3-3F6B52?style=for-the-badge" alt="Material 3">
</p>

<p align="center">
  <img src="docs/banner.svg" alt="My Week, a Flutter timetable app " width="100%">
</p>

<p align="center">
  <sub>Mobile Programming, AIC | Session 5 assignment</sub>
</p>

---

<h2 align="center">About the project</h2>

My Week is a small Flutter app I built as a beginner. I wrote this README the way I would explain the project to another beginner who wants to learn from it.

**Project chosen:** My Week, from the Mini Project Building list.

What the app does:

- Shows one day at a time (Monday to Friday) as cards with the real date of the current week.
- Lists that day's courses in order of start time, with the total hours for the day and for the whole week.
- Marks clashing courses in red and names every course they clash with.
- Adds and edits courses with a form that refuses invalid input: an empty name, times like `8h` or `25:00`, or an end time that is not after the start time.
- Deletes a course after an "Are you sure?" confirmation, with an Undo option.
- Saves all courses on the device, so nothing is lost when the app closes.
- Shows a quote from an online API, with a loading spinner, a clear error message and a Retry button when there is no internet.

---

<h2 align="center">Project at a glance</h2>

| | |
|---|---|
| Screens | 2 (week view, add and edit form), plus a delete confirmation |
| Source files | 2 (`main.dart`, `quote.dart`) |
| Packages | 2 (`http`, `shared_preferences`) |
| Online API | 1 (DummyJSON quotes, no account needed) |
| Saved on the device | The full course list, under one key |
| States on the quote card | 3 (loading, error, data) |

---

<h2 align="center">Screenshots</h2>

<table align="center">
  <tr>
    <td align="center">
      <img src="screenshots/before.PNG" alt="My Week with courses added, before closing the app" width="260"><br>
      <sub>Before closing: courses I added, with a clash in red.</sub>
    </td>
    <td align="center">
      <img src="screenshots/after.PNG" alt="My Week after stopping and running the app again, with the same courses" width="260"><br>
      <sub>After running again: everything is still there.</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/api.PNG" alt="My Week showing a live quote from the API" width="260"><br>
      <sub>Live data: a quote from the DummyJSON API.</sub>
    </td>
    <td align="center">
      <img src="screenshots/no-internet.PNG" alt="My Week showing the no internet message and Retry button" width="260"><br>
      <sub>No internet: a clear message and a Retry button.</sub>
    </td>
  </tr>
</table>

---

<h2 align="center">How it works, for another beginner</h2>

**1. Every app is data, a screen, and actions.**
The data is the list of courses. The screen draws that list. When the user taps something, an action changes the data, and the screen draws again. In Flutter, the line that says "the data changed, draw again" is `setState`.

**2. Times are stored as minutes.**
`08:30` is saved as `510` (8 x 60 + 30). Numbers can be compared, sorted and subtracted, while text like `"08:30"` cannot. This one choice makes the clash check and the hour totals simple.

**3. The clash rule.**
Two courses clash when they are on the same day and each one starts before the other ends:

```dart
a.startMinutes < b.endMinutes && b.startMinutes < a.endMinutes
```

I use `<` and not `<=`, so a class ending at 11:00 and another starting at 11:00 do not count as a clash.

<h2 align="center">Think questions</h2>

**My Week: write your clash condition in plain words. Why `<` and not `<=`?**
Two courses clash when they are on the same day and each one starts before the other one ends. I use `<` and not `<=` because a class that ends at 11:00 and another that starts at 11:00 only touch each other. They do not overlap, so they should not turn red. With `<=` they would be flagged by mistake.

**Session 5: what would happen to the screen if `http.get` made the app wait without `async` and `await`?**
The whole screen would freeze: no taps would work and the spinner would stop turning until the server answered. On a slow connection that can last many seconds, so the person would think the app is broken. With `await`, only that one line waits, and the rest of the app keeps running and drawing.

**Session 5: what happens to the saved data if I change phone or open the app on a second phone? What kind of place would keep it for every phone?**
The data is saved on one device only, so another phone would start with the sample courses. To keep the data for every phone, it would need to live on a server with a database, and the app would load it from there after the person logs in.

---
**4. Saving the data.**
The phone can only save text. So each course is turned into a Map (`toJson`), the whole list becomes one piece of text (`jsonEncode`) and is saved under the key `courses`. When the app opens, the text is read back and each Map becomes a course again (`fromJson`). The first time the app ever opens, nothing is saved yet, so the sample courses are shown. Every add, edit, delete and undo saves again.

**5. Loading from the internet has three states.**
A request to a server can be slow or can fail. The quote card keeps three variables (`quote`, `loading`, `error`) and shows the right one in this order: the spinner while waiting, the message and Retry button on failure, and the quote on success. The request is wrapped in `try / catch`, so a missing connection shows a message and not a crash.

---

<h2 align="center">Project structure</h2>

```
my_week/
  lib/
    main.dart      screens, clash and time rules, saving, quote card
    quote.dart     the Quote model and fetchQuote()
  screenshots/     the four images shown above
  pubspec.yaml     the list of packages the app uses
```

---

<h2 align="center">Run it yourself</h2>

You need the Flutter SDK and Google Chrome.

```
git clone https://github.com/YOUR-USERNAME/my_week.git
cd my_week
flutter pub get
flutter run -d chrome --web-port=8080
```

Keep `--web-port=8080`. In Chrome, saved data belongs to the web address, and without a fixed port the address changes on every run, so the app would look like it forgot everything.

---

<h2 align="center">What I learned</h2>

- A widget is a building block of the screen, and a screen is blocks inside blocks.
- A screen that never changes can be stateless. A screen that must remember something that changes needs a State, and changes go inside `setState`.
- Rules (checking times, finding clashes, saving) belong in functions outside the screens, so I can test them alone.
- Hot reload keeps the app's memory, hot restart resets it, and adding a new package needs a full stop and run.
- Saving data on the web depends on the address, which is why the port is fixed.
- Setting Chrome's developer tools to Offline also broke hot restart. Pointing the code at a wrong web address is a safer way to test the error state.

---
<h2 align="center">Challenges I met</h2>

- **The emulator.** The phone emulator crashed every time and took a very long time to load on my computer, so I could not use it. I ran and tested the app in Chrome instead, in a narrow window so the screen is close to a phone's size. All the screenshots come from Chrome.
- **Android Studio froze** for almost an hour while creating the project. I stopped it and created the project from the terminal with `flutter create`, which was faster.
- **Saved data seemed to disappear in Chrome.** The cause was that Chrome ties saved data to the web address, and the port changed on every run. Fixing the port (`--web-port=8080`) solved it.
- **Stateless and stateful, APIs workarounds, future, async, awaits.** took me a few rounds to understand. What helped was asking a question at a time: for eg.; does this screen need to remember something that changes?

---
<h2 align="center">Limits and next steps</h2>

- Data is saved on one device (or one browser) only. Opening the app on another phone shows the sample courses. Sharing data between devices would need a server and a database.
- The quote changes every time the app opens. A true "quote of the day" would save today's date and quote, and only ask the server once per day.
- Only Monday to Friday is supported.
- Next, I would split `main.dart` into smaller files (one per screen) and write a few tests for the clash and time rules.

---


<h2 align="center">Acknowledgements</h2>

- Course material from the Mobile Programming course training
- The DummyJSON public API for the quote data,
- Step-by-step guidance from an Model tutor (Claude), Which I used to understand each part of the code.
---

<h2 align="center">Signature</h2>

**Author : Leiss Uwase ID 27064**

---