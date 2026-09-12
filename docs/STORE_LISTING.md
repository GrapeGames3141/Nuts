# Nuts! — Google Play store listing

Copy-paste source for the Play Console listing. Assets live in
`builds/store/nuts/` (git-ignored; regenerate with the commands at the bottom).

- Package name: `com.grapegames.nuts`
- Category: Games → Puzzle (secondary: Casual)
- Contains ads: **Yes** (bottom banner)
- In-app purchases: No

## App name (30 char max)

```
Nuts!
```

## Short description (80 char max — this is 70)

```
Catch falling acorns in recipe order. 50 levels of squirrel timing.
```

## Long description (4000 char max)

```
Help a hungry red squirrel fill his winter pantry — one acorn at a time, in exactly the right order.

Nuts! is a relaxed one-thumb timing game. Every level gives you a recipe: a short list of acorns and pinecones to collect in sequence. Acorns fall through five lanes of forest canopy. Drag the squirrel left and right, catch the one your recipe wants next, and let the rest drop past. Catch the wrong one and the recipe starts over — so read the falling nuts, pick your lane, and time it.

FIFTY LEVELS, FIVE TREES
Climb five tree trails from roots to crown. Each trail adds a new wrinkle to the same simple rule, and finished levels stay unlocked so you can replay any of them for a cleaner run.

FOUR SEASONS OF FOREST
Play through spring oaks, deep summer green, autumn colour, and snowbound pines. Nights bring out the moon and drifting fireflies; storms bring out the lightning.

WATCH WHAT ELSE IS FALLING
It is not only acorns coming down. Dodge drifting leaves and pine needles, brace for gusts that blow the nuts off course, get clear of falling branches and icicles, and keep your head down when a hawk or an owl comes through the canopy.

EASY TO PICK UP
One finger. No timers counting you down, no lives to run out, no score chase. Drag, catch, and go at whatever pace suits you.

PLAYS ANYWHERE
Everything runs on your device. No account, no sign-in, and no internet connection needed to play — your progress is saved right on your phone.

Four acorn varieties to learn, fifty recipes to fill, and one very determined squirrel. Good luck out there.
```

## Graphic assets

| Play Console slot | File | Size |
| --- | --- | --- |
| App icon | `builds/store/nuts/App icon.png` | 512 × 512 PNG, no alpha |
| Feature graphic | `builds/store/nuts/Feature graphic.png` | 1024 × 500 PNG |
| Phone screenshots | `builds/store/nuts/Phone screenshots/*.png` | 8 × 1080 × 1920 PNG |

Play requires between 2 and 8 phone screenshots; upload all eight in filename
order — they read as a tour of the game from title to victory.

## Content rating and data safety

Answer the Play questionnaire with the shipped build in mind:

- No violence, no user-generated content, no chat, no location.
- **Contains ads: yes.** The build shows a single bottom AdMob banner.
- Data safety: the game collects and transmits **no** user data itself. The
  AdMob SDK collects device/advertising identifiers for ad delivery — declare
  that under "Device or other IDs → Advertising or marketing".
- No account creation, no sign-in. Progress is stored locally in `user://`.

## Regenerating the assets

The icon and feature graphic are composed from shipped game art, and the
screenshots are captured from the real build — so both regenerate from source:

```bash
# App icon + feature graphic (needs Pillow)
python3 tools/build_store_graphics.py

# Phone screenshots — needs a real display, not --headless
godot --path . --script tools/store_capture.gd --resolution 1080x1920
cp ~/.local/share/godot/app_userdata/'Nuts!'/store/*.png \
  'builds/store/nuts/Phone screenshots/'
```
