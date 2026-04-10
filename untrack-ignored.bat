@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0untrack-ignored.ps1" %1
