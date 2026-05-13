# devctl GUI для Windows

GUI — тонкая оболочка поверх `devctl.py`: CLI остаётся ядром конвейера, а окно показывает статус, dry-run-план, live-лог запуска и ссылку на отчёт.

## Что уже реализовано

- выбор корня рабочей области;
- инициализация нового workspace из GUI: parent folder + имя workspace + optional Git remote;
- запоминание последней рабочей области в пользовательском config-файле;
- карточки состояния: проект, Git, патч, push;
- вкладки `План`, `Запуск`, `Отчёт`;
- большая кнопка `Запустить конвейер`;
- запуск `start` в отдельном процессе без зависания окна;
- live-лог выполнения;
- `start --no-push` из GUI;
- кнопки открытия `report.md`, `archives/`, `project/`;
- PyInstaller child-mode: собранный exe может запускать bundled `devctl` как дочерний процесс без установленного Python.

## Инициализация нового workspace

Кнопка `Новый workspace` / `Инициализировать workspace` запускает мастер создания рабочей области. Он спрашивает:

1. директорию, внутри которой появится новая папка workspace;
2. имя workspace;
3. необязательный GitHub/Git URL для `origin`;
4. имя основной ветки, по умолчанию `main`.

После подтверждения GUI создаёт структуру:

```text
<workspace>/
  .devctl/
    workspace.json
    state.json
  project/
    .git/
  patches/
  archives/
```

Если remote URL указан, локальный репозиторий `project/` связывается с ним как `origin`. После успешной инициализации GUI автоматически открывает новый workspace так, как если бы он был выбран кнопкой `Выбрать`. Для будущего commit/push на машине должны быть настроены Git identity и доступ к remote через Git Credential Manager/SSH.

## Запуск из исходников

```bash
python gui/devctl_gui.py
```

Для проверки CLI JSON-режима:

```bash
python devctl.py status --json
python devctl.py plan --json
python devctl.py start --json --no-push
```

## Сборка Windows EXE

На Windows 10/11 установите Python 3.11+ и выполните из корня репозитория:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip pyinstaller
pyinstaller build\pyinstaller.spec --clean --noconfirm
```

Готовый файл появится здесь:

```text
release/devctl-gui.exe
```

## Smoke-тест после сборки

1. Запустите `release/devctl-gui.exe` двойным кликом.
2. Выберите корень рабочей области, где есть `.devctl/workspace.json`, `patches/`, `archives/` и каталог проекта.
3. Нажмите `Показать статус`.
4. Нажмите `Построить план`.
5. Для безопасной локальной проверки нажмите `Запустить без push`.
6. После завершения откройте отчёт кнопкой `Открыть отчёт`.

## Важные замечания

- GUI не меняет правила конвейера: все preflight-проверки, commit, push и отчёты выполняет `devctl.py`.
- В собранном EXE `devctl.py` импортируется как bundled-модуль через child-mode `--devctl-child`.
- Для реального commit/push на машине пользователя всё равно нужен установленный Git и доступный remote.
- Если Git отсутствует, GUI покажет понятную ошибку в карточке `Git` и в отчёте запуска.

## Новое в v0.1.2

- Добавлен мастер `Новый workspace`.
- `devctl init` получил JSON-режим, создание `project/`, `git init`, branch `main` и optional `origin`.
- Пустой Git-репозиторий теперь корректно определяется по symbolic HEAD, поэтому новый workspace можно использовать до первого commit.
- Если remote-ветка ещё не существует, preflight больше не валит запуск заранее: первый успешный push сможет создать ветку.

## Исправления Windows-сборки v0.1.1

- Frozen-сборка больше не подставляет `C:\Users\...\Temp\_MEI...` как рабочую область по умолчанию.
- Если старый `_MEI...` уже попал в `%APPDATA%\devctl-gui\config.json`, новая сборка игнорирует такой путь. Также можно вручную выбрать рабочую область кнопкой `Выбрать`.
- Дочерний процесс запускается с UTF-8 окружением, чтобы русский JSON и live-лог не превращались в `����`.
- `build_exe.ps1` не содержит кириллицы, чтобы его корректно читал Windows PowerShell.
