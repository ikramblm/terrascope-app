# TerraScope — Google Play Store Listing

_Updated for the version with Google AdMob ads (1.0.0+2)._

## App name
TerraScope

## Short description (max 80 characters)
Explore the world through fast, fun geography quiz games.
(58 characters)

## Full description (max 4000 characters)
TerraScope turns the world map into a game. Test how well you really know
your geography across four core challenges, then dig deeper with more modes
as you unlock them.

FOUR CORE GAMES
• Guess by Flags — see a flag, name the country.
• Guess by Location — tap the country on the world map.
• Name the Alphabet — name a country for every letter before time runs out.
• Capital Speed Run — race the clock naming capital cities.

MORE WAYS TO PLAY
Explore additional modes — guess by outline, borders, capital, clues, and
more. Easy, Medium and Hard decide which countries you get, from famous
ones to the truly obscure.

BUILT TO KEEP YOU COMING BACK
• Daily Challenge — a fresh question set every day.
• Streaks, XP, and levels — track your progress and earn prestige titles.
• Reward chests — unlock coins, titles, and streak protection as you play.
• Duels — challenge a friend with a shareable code and compare scores.
• A world coverage map on your profile shows every country you've mastered.

NO ACCOUNT NEEDED
No sign-in and no account. The games play offline, and your progress is
saved on your own device. TerraScope shows ads to stay free.

Whether you're brushing up before a trip, studying for a geography class, or
just love maps, TerraScope makes learning the world genuinely fun.

## Category
Education (alternative: Trivia, under Games)

## Tags / keywords
geography, quiz, world map, countries, flags, capitals, trivia, education,
learning game

---

# Play Console forms — exact answers

## App content → Ads
**Yes, my app contains ads** (Google AdMob banner at the top of the four main
tab screens; never during a game).

## App content → Target audience and content
Pick **13 and over** age groups (13–15, 16–17, 18+), and say the app is
**not** designed for children under 13. The privacy policy states exactly
this. If you pick any under-13 group Play applies the Families policy,
which restricts ads to Families-certified setups — not what the app is
configured for.

## App content → Privacy policy
https://ikramblm.github.io/terrascope-app/privacy-policy.html

## App content → Data safety

**Does your app collect or share any of the required user data types?** Yes.

**Is all of the user data collected by your app encrypted in transit?** Yes
(Google states the ads SDK's data is sent over TLS).

**Do you provide a way for users to request that their data is deleted?** No
(nothing is tied to an account; users can reset their Advertising ID in
Android settings).

Declare these data types as **Collected** and **Shared** (shared with Google
as the ads service provider), purposes **Advertising or marketing**,
**Analytics** and **Fraud prevention, security, and compliance**. This
follows Google's published AdMob disclosure
(developers.google.com/admob/android/play-data-disclosure) for the Google
Mobile Ads SDK:

| Play data type | What it is | Required? |
|---|---|---|
| Location → Approximate location | IP address, which can estimate general location | Collection not optional |
| App activity → App interactions | App launches, taps, video views | Collection not optional |
| App info and performance → Diagnostics | Launch time, hang rate, energy usage | Collection not optional |
| Device or other IDs | Android advertising ID, app-set ID | Optional (user can reset/delete the ad ID) |

Nothing else is collected: the display name, scores, streaks and settings
stay on the device and are never transmitted.

Google says you remain responsible for the answers, so compare this table
with that page once more when you fill the form.

## App content → Advertising ID
**Yes, the app uses the advertising ID** — purpose: **Advertising or
marketing**. The `AD_ID` permission is added to the app automatically by the
ads SDK.

## App content → Content rating
Run the questionnaire. Expected result: **Everyone / PEGI 3**. Ads shown in
the app are capped at general-audience (G) content.

## App content → other declarations
Government app: No. Financial features: No. Health: No. News: No.
COVID-19 contact tracing: No.

## Permissions the app ends up with
Read from the merged manifest of the release build:
- `POST_NOTIFICATIONS`, `VIBRATE` — local streak reminder
  (flutter_local_notifications)
- `INTERNET`, `ACCESS_NETWORK_STATE` — added by the ads SDK to load ads
- `AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_ATTRIBUTION`,
  `ACCESS_ADSERVICES_TOPICS` — advertising ID / Android ad services, ads SDK
- `WAKE_LOCK`, `FOREGROUND_SERVICE` — standard, added by Google's ads and
  Play services libraries. No foreground-service type is declared and the
  app runs no foreground service of its own, so no extra Play declaration
  is needed.
