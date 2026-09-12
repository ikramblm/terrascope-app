# TerraScope sound effects

`SoundService` (`lib/features/game_engine/sound/sound_service.dart`) plays
these files:

| File | Used for |
|---|---|
| `correct.wav` | Correct answer |
| `wrong.wav` | Incorrect answer |
| `tap.wav` | General UI tap |
| `complete.wav` | Game session finished |
| `level_up.wav` | Player levels up (Phase 6) |
| `achievement.wav` | Achievement unlocked (Phase 6) |

If a file is ever missing, every `SoundService` call fails silently (by
design — see the class doc) so gameplay is never blocked on sound assets.

## Provenance

Sourced from Kenney's **Interface Sounds** pack (CC0 — no attribution
required, see `KENNEY_LICENSE.txt`), converted from the pack's original
`.ogg` to `.wav` (iOS's AVAudioPlayer doesn't support Ogg Vorbis, so `.wav`
— supported natively on both iOS and Android — was used instead):

| TerraScope file | Source file (Kenney Interface Sounds) |
|---|---|
| `correct.wav` | `confirmation_002.ogg` |
| `wrong.wav` | `error_004.ogg` |
| `tap.wav` | `click_002.ogg` |
| `complete.wav` | `confirmation_004.ogg` |
| `level_up.wav` | `select_002.ogg` |
| `achievement.wav` | `select_004.ogg` |

## Licensing

Only use royalty-free / CC0-licensed sound effects here. Keep a note of
the source next to this file if it's not obvious from the filenames, so
provenance stays traceable — as above.
