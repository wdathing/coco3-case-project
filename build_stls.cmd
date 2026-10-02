@echo off
rem SPDX-License-Identifier: CC-BY-4.0
rem Copyright (c) 2026 Bill Athing
rem Runs build_stls.ps1 without needing to change the PowerShell execution policy. Same arguments.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_stls.ps1" %*
