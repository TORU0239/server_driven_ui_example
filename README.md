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


## Supported View Types

| Type               | JSON `type`       | Notes                                                                                          |
| ------------------ | ----------------- | ---------------------------------------------------------------------------------------------- |
| Header             | `header`          | Large, bold section header                                                                     |
| Text               | `text`            | Paragraph/body text                                                                            |
| Image              | `image`           | Supports `asset://` and `http(s)://`, plus `fit`                                               |
| Button             | `button`          | Single action button (`action` field)                                                          |
| Card               | `card`            | Title/body, **card-wide `action` (primary)**, and action buttons (`actions[]`)                 |
| Horizontal List    | `horizontal_list` | Title + horizontal scroll of `square_card` items                                               |
| Square Card (item) | `square_card`     | **150×150 dp** card with background color/image and tap action (used inside `horizontal_list`) |


### Actions (side-effects)

* navigate — route within app (e.g. "/detail"), special route "back" pops.
* open_url — opens external browser.
* toast — shows a Snackbar.
* track — prints a tracking event (hook your analytics here).

Labels for card buttons: In card.actions[] you may add "label" to control the button text.
If omitted, the renderer derives a sensible default (e.g., navigate("/detail") → “Go to Detail”).

### JSON Examples
```assets/json/home.json```

```
{
  "version": 1,
  "title": "Home",
  "components": [
    { "type": "header", "text": "Welcome 👋 (Local JSON)" },
    { "type": "text", "text": "This Home page demonstrates components and labeled card actions." },
    { "type": "image", "url": "asset://images/banner.jpg", "fit": "cover" },

    {
      "type": "card",
      "title": "Promo Card",
      "body": "Card supports multiple actions with optional labels.",
      "actions": [
        { "type": "navigate", "route": "/detail", "label": "View Detail" },
        { "type": "toast", "message": "Hello from Card Action!", "label": "Say Hello" },
        { "type": "open_url", "url": "https://example.com", "label": "Open Example" },
        { "type": "track", "event": "promo_clicked", "props": { "origin": "home_card" }, "label": "Track Promo" }
      ]
    },

    { "type": "button", "text": "Go to Detail", "action": { "type": "navigate", "route": "/detail" } },
    { "type": "button", "text": "Say Hi (Toast)", "action": { "type": "toast", "message": "Hi from Button!" } },
    { "type": "button", "text": "Visit Example.com", "action": { "type": "open_url", "url": "https://example.com" } },
    { "type": "button", "text": "Track Event (Console)", "action": { "type": "track", "event": "home_track_tap", "props": { "from": "home_button" } } }
  ]
}
```

```assets/json/detail.json```

```
{
  "version": 1,
  "title": "SuperSoft Hoodie",
  "components": [
    { "type": "header", "text": "SuperSoft Hoodie" },
    { "type": "image", "url": "asset://images/banner.jpg", "fit": "cover" },
    { "type": "text", "text": "Ultra-soft fleece. Relaxed fit. 100% cotton lining. Limited colorways." },

    {
      "type": "card",
      "title": "Price & Actions",
      "body": "$49.90  •  Free shipping over $60",
      "action": { "type": "toast", "message": "Added to cart!" },
      "actions": [
        { "type": "toast", "message": "Added to cart!", "label": "Add to Cart" },
        { "type": "navigate", "route": "back", "label": "Back" },
        { "type": "open_url", "url": "https://example.com", "label": "More Info" }
      ]
    },

    {
      "type": "horizontal_list",
      "title": "You may also like",
      "items": [
        {
          "type": "square_card",
          "title": "Oversize Tee",
          "subtitle": "$19.90",
          "bgColor": "#F3F6FF",
          "image": "asset://images/banner.jpg",
          "action": { "type": "toast", "message": "Oversize Tee tapped" }
        },
        {
          "type": "square_card",
          "title": "Jogger Pants",
          "subtitle": "$29.90",
          "bgColor": "#FFF4F2",
          "image": "asset://images/banner.jpg",
          "action": { "type": "toast", "message": "Jogger Pants tapped" }
        },
        {
          "type": "square_card",
          "title": "Basic Cap",
          "subtitle": "$9.90",
          "bgColor": "#F5FFF6",
          "image": "asset://images/banner.jpg",
          "action": { "type": "toast", "message": "Basic Cap tapped" }
        }
      ]
    }
  ]
}
```

### Project Structure

```
lib/
  main.dart
  app.dart
  server_driven_ui/
    actions/
      server_driven_ui_action_handler.dart    # Centralized side-effects
      server_driven_ui_actions.dart           # Action model (navigate/open_url/toast/track)
    data/
      server_driven_ui_fallback_json.dart     # NotFound/Home fallback JSON strings
      server_driven_ui_page_repository.dart   # Loads JSON from assets by route
    models/
      server_driven_ui_component.dart         # Component union + LabeledAction + SquareCardItem
      server_driven_ui_page.dart              # Page (version/title/components)
    renderer/
      server_driven_ui_component_renderer.dart# Component -> Widget mapping (incl. horizontal list)
    screen/
      server_driven_ui_page_screen.dart       # Loads page & builds a ListView
    util/
      boxfit_parser.dart                      # "cover"/"contain"/... -> BoxFit
      color_parser.dart                       # "#RRGGBB"/"#AARRGGBB" -> Color
      route_asset_resolver.dart               # "/detail" -> assets/json/detail.json (with fallbacks)
assets/
  json/
    home.json
    detail.json
  images/
    banner.jpg
pubspec.yaml
```

## Rendering Sequence
1. Route requested via ```MaterialApp.onGenerateRoute```
→ creates ```ServerDrivenUIPageScreen(routeName: "/detail")```

2. Repository resolves asset
```ServerDrivenUIPageRepository.loadFromRoute("/detail")```
→ tries assets/json/detail.json → (fallbacks if needed)

3. Decode & parse
JSON → ```ServerDrivenUIPage.fromJson()``` → ServerDrivenUIComponent list

4. Render
```ListView``` → for each component,
```ServerDrivenUIComponentRenderer(component)``` builds the Widget:

* image → Image.asset/Image.network (via asset://)
* card → clickable InkWell (primary action) + action button row
* horizontal_list → ListView.horizontal with 150×150 square_card items

5. Actions
Taps delegate to ```ServerDrivenUIActionHandler.handle(context, action)```:

* ```navigate("back")``` → Navigator.pop
* ```navigate("/detail")``` → Navigator.pushNamed
* ```open_url("https://...")``` → external browser
* ```toast(...)``` → ScaffoldMessenger.showSnackBar(...)
* ```track(...)``` → (console) hook your analytics here
