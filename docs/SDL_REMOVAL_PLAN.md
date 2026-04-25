# SDL Removal Plan

This project has already removed SDL from the windowing and main rendering path. The remaining SDL usage is now concentrated in a few subsystems, which makes it realistic to remove in smaller passes.

## Current SDL usage map

### Low-risk to replace first
- `integrations/carplay/fastcarplay/application.cpp`
  - `SDL_Init(SDL_INIT_TIMER | SDL_INIT_AUDIO)`
  - audio driver discovery helpers
- `integrations/carplay/fastcarplay/common/functions.h`
  - SDL event push helper
- `integrations/carplay/fastcarplay/pipe_listener.cpp`
  - synthesizes SDL keyboard events
- `integrations/carplay/fastcarplay/resource/colours.h`
  - uses `SDL_Color` as a simple colour struct

### Medium/high-risk, leave until later
- `integrations/carplay/fastcarplay/pcm_audio.*`
  - SDL audio device open/queue/pause/close
- `integrations/carplay/fastcarplay/recorder.*`
  - SDL capture device handling

## Recommended workflow

### Phase 1 — cleanup and quarantine
1. Keep the current stable render path unchanged.
2. Keep the existing SDL audio backend working.
3. Move toward a state where SDL is only referenced from a very small number of files.

### Phase 2 — remove non-audio SDL
1. Replace `SDL_Color` with a tiny local RGBA struct or `QColor`-adjacent plain struct.
2. Replace SDL event-push helpers with backend-owned callbacks or Qt-side signal dispatch.
3. Replace remaining SDL timer/init helpers with standard C++ or Qt equivalents.

### Phase 3 — isolate audio behind an interface
Before removing SDL audio, introduce an explicit backend such as:
- `IAudioOutput`
- `SdlAudioOutput`
- future `QtAudioOutput` or `AlsaAudioOutput`

Do the same for microphone capture if recorder support matters.

### Phase 4 — replace audio only if the value is clear
Only replace SDL audio if there is a concrete benefit:
- simpler deployment
- better target-platform support
- lower latency
- fewer dependencies

If SDL ends up isolated to a tiny audio adapter and it remains reliable, full removal may not be worth the risk.

## Suggested next implementation order
1. Cleanup/config/deployment hardening
2. Non-audio SDL removal
3. Audio abstraction
4. Optional audio backend replacement
