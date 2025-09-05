## Server-Driven UI (Flutter, Local Assets)

Render entire screens from JSON — no server required. Convention-based routing, typed components/actions, centralized side-effects, and production-ready structure.

## Introduction

This repository is a Server-Driven UI (SDUI) playground built with Flutter.
Instead of hard-coding screens, the app loads local JSON assets and renders views at runtime.

* Convention-over-configuration routing: "/detail" → assets/json/detail.json
* Typed components & actions with a clean renderer layer
* Centralized side-effects (navigation / open URL / toast / track)
* Clickable cards (primary tap action) and horizontal, scrollable lists
* Asset image scheme: asset://images/banner.jpg (offline-friendly)

This is ideal for demonstrating architecture thinking and product-grade code quality without spinning up a backend.
