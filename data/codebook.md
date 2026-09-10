# Codebook

Two datasets, collected separately, from different populations. They are **not**
linked: no post can be traced to a survey respondent, and no respondent's own posts
are in the corpus. Any comparison across the two files is descriptive.

---

## `content_coding.csv` — 100 social media posts

Posts carrying `#hagiangloop`, sampled from TikTok and Instagram in June–July 2025,
50 per platform. Coded by one person (the author). **No intercoder reliability check
has been run yet** — see `R/05_reliability.R`.

| Column | Values | Meaning |
|---|---|---|
| `ID` | 1–100 | Post identifier |
| `Platform` | Instagram, TikTok | Where the post was published |
| `Sender_Type` | Tourist, Agency | **Who owns the posting account.** Tourist = a personal traveller account. Agency = a tour operator, homestay or booking business. This describes the *account*, not how any traveller travelled. |
| `Content_Type` | Photo_dump, Short_vid, Infographic, Advertisement, Vlog | Post format |

Seven binary theme codes, `Yes` / `No`, each answering "does this appear anywhere in
the post?" Codes are not mutually exclusive; a post can carry all seven or none.

| Code | Coded `Yes` when the post shows... |
|---|---|
| `Harsh_Roads` | Difficult, narrow, damaged or dangerous road conditions |
| `Villages_Temples` | Built settlements: villages, houses, temples, markets |
| `Rivers_Fields` | Natural landscape: rivers, valleys, rice terraces, mountains |
| `Culture` | Cultural practice: dress, craft, ceremony, food preparation, language |
| `Locals` | Ha Giang residents as visible people, including easyriders and homestay staff |
| `Tour_Group` | A group of riders travelling together, visible as a group |
| `Eating_Partying` | Meals, drinking, karaoke, nightlife |

### A note on `Sender_Type` vs `Tour_Group`

These are different variables and the 2025 poster conflated them. `Sender_Type`
is a property of the **account**. `Tour_Group` is a property of the **image**. A
solo traveller's account can post a picture full of riders (`Tourist`,
`Tour_Group = Yes`), and an agency can post an empty landscape (`Agency`,
`Tour_Group = No`). The poster's figure axis read "Independent / Tour Group" while
the test underneath it was run on `Sender_Type`. Neither label was correct for
the other variable. Every result in this repo names the variable it used.

---

## `survey_responses.csv` — 61 travellers

Google Form administered June–July 2025 to guests at one homestay in Ha Giang.
Recruitment through a single operator is the study's main limitation: the sample
describes that operator's guests, not Loop travellers generally.

**De-identification.** Five respondents gave email addresses to volunteer for
interviews. That column has been deleted from this file. Timestamps are truncated
to the date. Two easyriders named in a free-text response are replaced with
`[NAME]`. The raw export is not in this repository and should not be added to it.

| Column | Values | Meaning |
|---|---|---|
| `timestamp` | date | Submission date |
| `age` | 18-24 … 65+ | Age band |
| `gender` | Male, Female, Non-Binary | Self-reported |
| `origin` | Europe, NA, Asia, Oceania, Africa, SA, Vietnam | Region of origin, as offered by the form |
| `travel_party` | Alone, Friends, With family, Partner, With a tour group, Null | Who they travelled with. `Null` is a literal string in the export, meaning unanswered |
| `found_via` | multi-select, comma-joined | How they heard of the Loop |
| `motivation` | multi-select, comma-joined | Why they went. Includes free-text write-ins |
| `upload_platforms` | multi-select, comma-joined | Where they post or intend to post |
| `open_ended` | free text | Optional closing comment |

Likert items, all `1` strongly disagree → `5` strongly agree:

| Column | Statement |
|---|---|
| `q_locals` | I enjoyed interactions with locals, staff and easyriders |
| `q_danger` | The roads were more dangerous than I had expected |
| `q_price` | The price I paid for the trip was worth it |
| `q_stay` | I was satisfied overall with the homestays' accommodation |
| `q_upload` | I intend to upload / have uploaded my photos from the trip |
| `q_recommend` | I intend to recommend the Loop to friends and family |
| `q_accurate` | My experience overall was accurate to social media portrayal |
| `q_highlight` | Ha Giang Loop is the highlight of my Vietnam trip |
| `q_return` | I plan to return to Ha Giang in the future |
| `q_party` | I enjoyed the partying/drinking culture |

### A note on `q_party`

Only 14 of 61 responses. The item was **added to the form on 19 July 2025**, part
way through collection, so the 47 blanks are people who never saw the question,
not people who declined it. Do not analyse it as if all 61 chose whether to answer.
