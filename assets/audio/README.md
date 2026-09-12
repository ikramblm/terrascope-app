# TerraScope sound effects

`SoundService` (`lib/features/game_engine/sound/sound_service.dart`) expects
these files here once added:

| File | Used for |
|---|---|
| `correct.mp3` | Correct answer |
| `wrong.mp3` | Incorrect answer |
| `tap.mp3` | General UI tap |
| `complete.mp3` | Game session finished |
| `level_up.mp3` | Player levels up (Phase 6) |
| `achievement.mp3` | Achievement unlocked (Phase 6) |

Until these exist, every `SoundService` call fails silently (by design —
see the class doc) so gameplay isn't blocked on sound assets landing.

Once added, also add this to `pubspec.yaml` under `flutter: assets:`:

```yaml
    - assets/audio/
```

## Licensing

Only use royalty-free / CC0-licensed sound effects here (e.g.
[Kenney.nl](https://kenney.nl) game asset packs, explicitly CC0). Keep a
note of the source next to this file if it's not obvious from the
filenames, so provenance stays traceable.
