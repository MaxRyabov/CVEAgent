# Создаёт приватный репозиторий CVEAgent на GitHub и отправляет туда проект.
# Запуск из D:\Projects\CVEAgent:  powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1
# Нужны git и GitHub CLI (gh), вход: gh auth login
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
if (-not (Test-Path .git)) { git init -b main; git add -A; git commit -m "CVEAgent: initial import" }
gh repo create CVEAgent --private --source . --remote origin --push
gh repo view CVEAgent --web
