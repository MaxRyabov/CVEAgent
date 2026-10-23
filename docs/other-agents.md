# Запуск в других агентах: Hermes Agent, OpenClaw

Агент — это промпт плюс расписание, поэтому он переносится на любую платформу, где есть:

1. планировщик (cron);
2. веб-поиск и загрузка страниц;
3. чтение и запись файлов (для списка ПО и состояния);
4. доставка результата (Telegram, Slack, почта и т. п.).

В Hermes Agent и OpenClaw всё это есть. Артефакт с базой работает только в Claude, поэтому здесь используется файловый вариант промпта — `prompt/routine-prompt.local.md` — и данные в `data/*.local.json`.

## Подготовка (для обеих платформ)

```bash
git clone https://github.com/MaxRyabov/CVEAgent.git ~/CVEAgent
cd ~/CVEAgent
cp data/software.json data/software.local.json      # затем отредактируйте под себя
cp data/state.initial.json data/state.local.json
```

Короткое задание для планировщика (одинаковое для обеих платформ) — промпт читается из файла, поэтому обновления из git подхватываются без пересоздания задачи:

```text
Выполни инструкции из файла ~/CVEAgent/prompt/routine-prompt.local.md. DATA_DIR = ~/CVEAgent/data.
```

## Hermes Agent (Nous Research)

```bash
hermes cron create "45 8,20 * * *" \
  "Выполни инструкции из файла ~/CVEAgent/prompt/routine-prompt.local.md. DATA_DIR = ~/CVEAgent/data." \
  --name "Мониторинг CVE" \
  --workdir ~/CVEAgent \
  --deliver telegram
```

- Задаче нужны наборы инструментов `web` и `file` (через `hermes tools` для платформы `cron` или `enabled_toolsets` в задаче), иначе она не сможет искать и сохранять состояние.
- Время cron считается в часовом поясе, который настроен в Hermes. Проверьте его, если сервер не в Москве.
- Модель задачи: `--provider <p> --model <m>` или `hermes config set cron.model <name>`.
- Планировщик работает внутри шлюза, его нужно держать запущенным: `hermes gateway install`.
- Проверка: `hermes cron run "Мониторинг CVE"`, результаты — в `~/.hermes/cron/output/`.

Документация: [Hermes Agent — Cron](https://hermes-agent.nousresearch.com/docs/user-guide/features/cron).

## OpenClaw

```bash
openclaw automations add --cron "45 8,20 * * *" --tz "Europe/Moscow" \
  --name "Мониторинг CVE" \
  --announce --channel telegram --to "<chat_id>" \
  "Выполни инструкции из файла ~/CVEAgent/prompt/routine-prompt.local.md. DATA_DIR = ~/CVEAgent/data."
```

- `openclaw cron` — синоним `openclaw automations`.
- Нужен настроенный провайдер веб-поиска (Brave, Tavily, Exa, Perplexity или DuckDuckGo) — см. раздел Web search в документации.
- Запускайте задачу в изолированной сессии, чтобы отчёты не смешивались с основным диалогом. Параметр смотрите в `openclaw automations --help`.
- У агента должен быть доступ к файлам в `~/CVEAgent/data`.

Документация: [OpenClaw — Automations](https://docs.openclaw.ai/automation), [CLI cron](https://docs.openclaw.ai/cli/cron).

## Ограничения

- **Модель.** Промпт рассчитан на сильную модель. Слабые и локальные модели чаще выдумывают CVSS, версии и патчи, даже с правилом «н/д». Первые отчёты сверяйте с первоисточниками.
- **Поиск.** Качество отчёта зависит от провайдера веб-поиска. Если он не находит свежие публикации (последние 12 часов), отчёт будет неполным.
- **Безопасность.** Задача читает недоверенные веб-страницы. Не давайте ей прав больше нужного: без shell с доступом к сети и инфраструктуре, без лишних интеграций, запись только в `data/`.
- Синтаксис команд взят из документации платформ на октябрь 2026 года. Если команда не сработала, сверьтесь с `--help` вашей версии.
