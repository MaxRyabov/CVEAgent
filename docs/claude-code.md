# Запуск в Claude Code

Нужна подписка Claude (Pro, Max, Team или Enterprise) и вход в Claude Code через аккаунт claude.ai, а не через API-ключ. Есть два способа запуска:

| | **A. Облачная задача (routine)** — рекомендуется | **B. Локальная задача в Claude Desktop** |
|---|---|---|
| Где работает | В облаке Anthropic, компьютер можно выключить | На вашем компьютере, нужен включённый компьютер и запущенное приложение |
| Где список ПО и состояние | Артефакт с базой (`artifact/watchlist.html`) | Файлы `data/*.local.json` в папке репозитория |
| Промпт | `prompt/routine-prompt.md` | `prompt/routine-prompt.local.md` |
| Редактирование списка ПО | Страница в браузере или телефоне | Правка JSON-файла |

## A. Облачная задача (routine)

### 1. Опубликуйте страницу со списком ПО

В Claude Code (в папке с клоном репозитория) или в приложении Claude попросите:

> Опубликуй artifact/watchlist.html как артефакт с capability db. Затем загрузи записи из data/software.json в коллекцию software этого артефакта.

Сохраните URL артефакта (`https://claude.ai/artifact/...`). Список дальше редактируйте на этой странице. Перед загрузкой замените `data/software.json` своими данными или загрузите только нужные записи.

### 2. Создайте задачу

**Из CLI** — в любой локальной сессии Claude Code:

```text
/schedule
```

Claude задаст вопросы о расписании, репозитории и промпте. Отвечайте так:

- **Промпт** — содержимое `prompt/routine-prompt.md`, где `{{ARTIFACT_URL}}` заменён на URL из шага 1. Можно попросить: «возьми промпт из prompt/routine-prompt.md и подставь URL артефакта».
- **Расписание** — «дважды в день в 08:45 и 20:45 по Москве». Если Claude предложит только пресет, после создания выполните `/schedule update` и задайте cron `45 8,20 * * *` в часовом поясе Europe/Moscow.
- **Репозиторий** — можно выбрать `CVEAgent`, но промпт самодостаточен и файлы репозитория не читает.
- **Модель** — самая сильная из доступных: от неё зависит, будут ли выдуманные CVSS и версии.

**Из браузера** — [claude.ai/code/routines](https://claude.ai/code/routines) → **New routine**, те же поля. В Claude Desktop: вкладка **Code** → **Routines** → **New routine** → **Cloud**.

### 3. Проверьте настройки задачи

- **Connectors** — уберите все лишние. Задача использует только веб-поиск и артефакт, а любой подключённый коннектор доступен ей без подтверждений.
- **Environment** — подходит **Default**. Если в отчёте появятся пометки о недоступных источниках из-за сети, добавьте их домены в **Network access → Custom → Allowed domains**: `nvd.nist.gov`, `cisa.gov`, `security-tracker.debian.org`, `bdu.fstec.ru`.
- Нажмите **Run now** и прочитайте отчёт в сессии запуска. Зелёный статус значит только, что сессия завершилась без сбоя инфраструктуры, а не что отчёт получился.

### Полезные команды

```text
/schedule list                    # все задачи
/schedule run                     # запустить сейчас
/schedule update                  # изменить промпт, расписание, модель
/schedule почему утренний отчёт CVE пустой?   # разбор последних запусков
```

Если `/schedule` отвечает «Unknown command», вы вошли через API-ключ или сторонний провайдер (Bedrock, Vertex). Выполните `/login` через аккаунт claude.ai или создайте задачу в браузере.

## B. Локальная задача в Claude Desktop

Подходит, если список ПО не должен покидать ваш компьютер.

1. Подготовьте данные в папке клона репозитория (файлы `*.local.json` в `.gitignore` и не попадут в git):

   ```powershell
   cd D:\Projects\CVEAgent
   Copy-Item data\software.json data\software.local.json
   Copy-Item data\state.initial.json data\state.local.json
   ```

   Отредактируйте `data\software.local.json` под свои системы.

2. Claude Desktop → вкладка **Code** → **Routines** → **New routine** → **Local**. Рабочая папка — `D:\Projects\CVEAgent`, расписание — 08:45 и 20:45. Промпт:

   ```text
   Выполни инструкции из файла prompt/routine-prompt.local.md. DATA_DIR = data.
   ```

3. Разрешите задаче веб-поиск и загрузку страниц, а также чтение и запись файлов в `data/`.

Задача не запустится, если компьютер выключен или приложение закрыто в момент запуска.

Подробнее: [Routines](https://code.claude.com/docs/en/routines), [Desktop scheduled tasks](https://code.claude.com/docs/en/desktop-scheduled-tasks).
