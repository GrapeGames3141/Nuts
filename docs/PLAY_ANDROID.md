# Nuts! Android Play + AdMob setup

| Game | Play package | Debug package | AdMob App ID |
| --- | --- | --- | --- |
| Nuts! | `com.grapegames.nuts` | `com.grapegames.nuts.debug` | Create in AdMob, then store as `NUTS_ADMOB_ANDROID_APP_ID` |

Banner unit (production — **not used while closed testing**):

- Create one Android banner unit under publisher `pub-2846735043546429`
- Store it as `NUTS_ADMOB_ANDROID_BANNER_UNIT_ID`

Closed test currently serves Google's official test banner
`ca-app-pub-3940256099942544/6300978111`. Restore the production unit in
`autoload/ad_bar_service.gd` and `scripts/ci/godot-export-android.sh`
(search `TODO(ads-live)`) before going live.

## GitHub secrets (required for deploy)

On `GrapeGames3141/Nuts` → Settings → Secrets and variables → Actions → **Secrets**:

| Secret | Copy from | Purpose |
| --- | --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Peregrine / Unicorn Arcade | Same GrapeGames release keystore |
| `KEY_ALIAS` | Peregrine / Unicorn Arcade | Keystore alias (e.g. `grapegames`) |
| `KEYSTORE_PASSWORD` | Peregrine / Unicorn Arcade | Keystore password (ASCII only) |
| `SERVICE_ACCOUNT_JSON` | Peregrine / Unicorn Arcade | Play API service account JSON |
| `NUTS_ADMOB_ANDROID_APP_ID` | **New** — AdMob app you create | `ca-app-pub-2846735043546429~…` |
| `NUTS_ADMOB_ANDROID_BANNER_UNIT_ID` | **New** — AdMob banner you create | `ca-app-pub-2846735043546429/…` |

The first four secrets are the same values already on Peregrine and Unicorn Arcade.
Copy them; do not generate a new keystore.

Deploy workflow: [`.github/workflows/deploy-android.yml`](../.github/workflows/deploy-android.yml)

- Triggers on push to `main`/`master` and **workflow_dispatch**
- Signs an AAB and uploads it to Play **closed testing** (`alpha`) track
  — `alpha` is the Play API identifier for the default Closed testing
  track; a custom-named closed track would use its own name instead
- It does not publish GitHub Actions artifacts

Export preset: `Android Play`.

## Play Console checklist (manual — no API can create the app)

- [ ] Create app **Nuts!** as a **Game**, **Free**
- [ ] Package name must be **`com.grapegames.nuts`** (first upload locks this)
- [ ] Grant service account `github-actions@advance-anvil-449102-v7.iam.gserviceaccount.com` **Release to production, exclude devices, and use Play App Signing** on this app (same grant as Peregrine)
- [ ] Store settings → Website = `https://patguettler.github.io`
- [ ] Privacy policy = `https://patguettler.github.io/privacy-policy.html`
- [ ] Closed testing: create the tester list (email list or Google Group) and opt in
- [ ] After first CI upload: install from the closed testing opt-in link
- [ ] Later: store listing, **Contains ads**, **Data safety**, content rating

Shared GrapeGames privacy policy:

- Privacy policy: `https://patguettler.github.io/privacy-policy.html`
- Data deletion URL: `https://patguettler.github.io/privacy-policy.html#data-deletion`

Skip Play Integrity unless you adopt it deliberately.

## AdMob checklist (manual)

1. AdMob → Apps → **Add app** → Android → name **Nuts!** → package `com.grapegames.nuts`
2. Create one **Banner** ad unit
3. Copy App ID (`…~…`) and banner unit (`…/…`) into the two Nuts GitHub secrets
4. AdMob → Nuts! → **Add store** → Google Play → `com.grapegames.nuts`
5. AdMob → **app-ads.txt** → **Check for updates** (already live for this publisher)

`app-ads.txt` (already hosted, no repo change):

```
https://patguettler.github.io/app-ads.txt
```

```
google.com, pub-2846735043546429, DIRECT, f08c47fec0942fa0
```

Runtime config is all-ages (`child_directed: false`, max rating `PG`).
Prefer Google test banners until QA finishes; avoid clicking live ads.

## Store listing

Listing copy (short/long description), the graphic-asset inventory, and the
content-rating / data-safety answers live in
[`STORE_LISTING.md`](STORE_LISTING.md). The icon, feature graphic, and phone
screenshots are generated into `builds/store/nuts/` — that path is git-ignored,
so regenerate them from the commands in that document rather than looking for
them in a fresh clone.

## Local export

```bash
./scripts/ci/godot-export-android.sh
```

Requires `ANDROID_SDK_ROOT`, Java 17, and the same keystore env vars if signing a release AAB.

## Pull request checks

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) imports the project
and runs the four headless test scripts on every PR. It does not export Android
builds; only a push to `master` does that.
