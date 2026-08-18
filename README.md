# Movie Mind

Movie Mind is an AI-powered movie, TV show and people exploration app. You can discover what to watch through natural language recommendations from Google Gemini or through popular lists backed by real TMDB data. Built with SwiftUI, Swift Concurrency, and SwiftData.

![iOS](https://img.shields.io/badge/iOS-18.0%2B-D8C2AA?labelColor=5C4A3E&logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-6-D8C2AA?labelColor=5C4A3E&logo=swift&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-16%2B-D8C2AA?labelColor=5C4A3E&logo=xcode&logoColor=white)
![UI](https://img.shields.io/badge/UI-SwiftUI-D8C2AA?labelColor=5C4A3E&logo=swift&logoColor=white)
![AI](https://img.shields.io/badge/AI-Gemini-D8C2AA?labelColor=5C4A3E&logo=googlegemini&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-D8C2AA?labelColor=5C4A3E&logo=github&logoColor=white)

<img width="1920" height="1080" alt="screenshots" src="https://github.com/user-attachments/assets/1c9cd259-b727-43b5-a478-fefd9e4059a9" />

## Features

- ***AI recommendations:*** A "For You" rail on Home suggests titles from your library, and an "Ask AI" assistant.
- ***Home:*** Trending hero carousel, sections with Movie and TV toggles.
- ***Detail pages:*** Overview, metadata, cast, watch providers, collections and more.
- ***Search:*** Debounced multi-search, plus an inline entry point to ask AI about the same query.
- ***Upcoming:*** Release calendar with relative dates, region aware for movies.
- ***Library:*** Persistent library with category filters.

## App Preview

https://github.com/user-attachments/assets/92ff4eb4-040f-4bce-b6d2-374c0db858f7

## AI, without the hallucinations

`Library (prompt) ─▶ Gemini (structured JSON) ─▶ TMDB search ─▶ real MediaItem`

Movie Mind uses Gemini AI models. The model never invents database IDs, posters, or ratings. It only proposes titles, which are then resolved against TMDB in a second step.

- ***Structured output:*** Requests set a responseSchema, so Gemini returns JSON that decodes straight into project models.
- ***Grounded results:*** Every suggested title is looked up via TMDB search, matched by year, and de-duplicated.
- ***Multi-turn chat:*** "Ask AI" keeps conversation history, so follow-ups like "funnier ones" or "but shorter" work.
- ***Quota-friendly:*** Gemini is only called when the library actually changes.
- ***Fully optional:*** With no Gemini key the view warns instead of failing silently.
- ***Free tier:*** Resolves the current free Gemini Flash model via a -latest alias chain (gemini-flash-lite-latest → gemini-flash-latest → gemini-2.5-flash), so a deprecated model is handled automatically.

## Architecture

**MVVM + protocol-oriented services:**

```
Views (SwiftUI) ──▶ ViewModels (@MainActor, @Observable)
                         │  ViewState<T>
              ┌──────────┴───────────┐
              ▼                      ▼
  ListServicing, etc.        AIServicing (protocol)
   (per-use-case)                    │
         │                           ▼
         ▼                   GeminiService (actor)
  NetworkManager (actor)      Gemini generateContent
   TMDB REST API v3          (JSON via responseSchema)
```

```
MovieMindTests

MovieMind
├── App
├── Core
│   ├── Networking
│   ├── AI
│   ├── Images
│   ├── Persistence
│   └── Extensions
├── Models
│   ├── API
│   └── UI
├── Navigation
├── Components
├── Screens
└── PreviewContent
```

### Key decisions

- ***ViewState\<T>:*** One enum per screen (idle / loading / loaded / failed) makes conflicting states unrepresentable, and a generic StateContainerView renders all four, so no screen branches on state itself.

- ***Non-optional decoding:*** TMDB omits fields freely. A @Fallback property wrapper turns a missing, null or mistyped value into its empty form instead of failing the whole response, so models stay non-optional and views stop unwrapping. Only fields whose absence the UI reacts to (image paths, dates, ids) remain optional.

- ***actor NetworkManager:*** One actor holds the key, builds the URL, maps status codes to NetworkError and decodes. Endpoints are enums behind a small Endpoint protocol, and screens depend on narrow per-use-case protocols, rather than on the actor, which is also what makes them mockable.

- ***AI mirrors that shape:*** GeminiService is an actor behind an AIServicing protocol, and one shared AIMediaResolver turns the model's titles into real MediaItems for both the chat and the recommendations.

- ***Value-based navigation:*** Components emit a route and never build a destination. A single appDestinations modifier registers every route on every stack, so a rail keeps working wherever it is reused, and zoomSource / zoomDestination carry the Namespace.ID through the environment instead of through initializers.

- ***Image pipeline:*** Nuke owns image loading and its own disk cache; URLCache is left to JSON. View models start prefetching the next screen's posters before showing content, and AsyncPoster decodes at the size it draws rather than the size it was downloaded at.

- ***SwiftData:*** The library keeps an id, a type and just enough to draw a row: title and poster path. That copy is what lets the Library tab render offline without one request per row, at the cost of going stale if TMDB renames a title. Detail pages always refetch.

## Tech Stack

### Built with

- SwiftUI
- SwiftUI Previews
- Observation (`@Observable`)
- Zoom navigation transitions (`navigationTransition(.zoom)`)
- [FluidHeader](https://github.com/Segyun/FluidHeader)
- [Nuke](https://github.com/kean/Nuke)
- [Google Gemini API](https://ai.google.dev)
- async/await, async let, TaskGroup, actors
- Swift 6 strict concurrency
- Custom property wrappers (`@Fallback`)
- SwiftData
- URLSession
- xcconfig-based secret management
- [TMDB API v3](https://developer.themoviedb.org/docs/getting-started)
- DocC
- Swift Testing

### Also implemented

- Error handling
- Retry on failure
- Empty states
- Loading skeletons
- Debounced search
- Pagination
- Image caching and prefetching
- Offline support
- Haptics
- Basic unit tests (Swift Testing)
- Basic accessibility (VoiceOver)
- Code documentation (DocC)
- Project organization

## Setup

ⓘ *Requires Xcode 16 and an iOS 18.0+ simulator or device.*

1. Clone the repo and open `MovieMind.xcodeproj`

2. Get a free API key from [TMDB](https://developer.themoviedb.org/docs/getting-started) *(required)* and, if you want the AI features, from [Google AI Studio](https://ai.google.dev/gemini-api/docs/api-key#import-projects) *(optional)*

3. Copy `MovieMind/Core/Networking/SecretsExample.xcconfig` to `Secrets.xcconfig` in the same folder, then fill the placeholders:

   ```ini
   TMDB_API_KEY = your_tmdb_key_here
   GEMINI_API_KEY = your_gemini_key_here
   ```

   ⓘ *The project already points its build configuration at `Core/Networking/Secrets.xcconfig`, so the file name and location are all that matter. Nothing to wire up in Xcode.*

4. Build & run

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.

ⓘ *Streaming availability data provided by JustWatch via TMDB. This product uses the TMDB API but is not endorsed or certified by TMDB.*
