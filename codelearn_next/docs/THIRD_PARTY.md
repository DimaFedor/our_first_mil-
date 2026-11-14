# Сторонні компоненти

Flutter/Dart-залежності зафіксовані в `pubspec.lock`; їхні notices доступні через стандартний механізм Flutter licenses. Джерела JavaScript-рушія та залежності зафіксовані в `tool/runtime/package-lock.json`.

- Pyodide 0.27.7: https://github.com/pyodide/pyodide/tree/0.27.7 — MPL-2.0; містить CPython та його стандартну бібліотеку з відповідними ліцензіями Python.
- Babel standalone: https://github.com/babel/babel — MIT. Bundled notices збережені у зібраному JavaScript.
- SQLite WASM для sqlite3 2.9.4: https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-2.9.4 — SQLite public domain; Dart-обгортка за ліцензією пакета sqlite3.
- Git/CLI/C++/HTML навчальні компоненти походять із вихідного CodeLearn (MIT), адаптовані та ізольовані; під час перенесення прибрано залежність від UI та виправлено виявлені перевірками дефекти.
- Аватари й навчальні матеріали перенесені з вихідного проєкту.
- WAV-звуки створені для цієї версії процедурним синтезом; зовнішні аудіозаписи не використовувалися.
