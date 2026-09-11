# Ha Giang Loop: social media and adventure travel

A reanalysis of my own 2025 research on how social media shapes tourism on the Ha
Giang Loop, a motorcycle route in northern Vietnam. I ran the original study through
Kenyon College's Summer Science Scholars program, advised by Prof. Sam Pack, coding
100 social media posts and surveying 61 travellers.

I got the headline finding wrong. This repository shows what I got wrong, corrects
it, and reports the three results that survive.

## What I got wrong

I claimed that travellers posting independently were more likely to depict local
residents than travellers in tour groups: 49% against 27%, χ²=4.08, p=.043.

I ran that test on `Sender_Type`, which records whether the *account* belongs to a
traveller or a tour operator. It says nothing about how anyone travelled. The
variable I described in the axis label is `Tour_Group`, a different column, and I
never tested it (see [`data/codebook.md`](data/codebook.md)).

My percentages were wrong too. For that test they are 44.4% and 24.3%.

And the association is platform, not account type. Instagram is 72% traveller
accounts against TikTok's 54%, and Instagram shows local residents more often
whoever posts. Put platform in the model and account type falls from p=.044 to
p=.098.

![Figure 4. Effect of account type on depicting local residents](figures/04_confounding.png)

I also ran fourteen bivariate tests and reported one. Under Holm correction the one
I reported ranks fourth and doesn't survive, at p_holm = .49. Two others do, and the
full table is in [`results/01_bivariate_tests.csv`](results).

There's a version of this that needs no model at all. Split the corpus by platform
and read the four cells: on Instagram, traveller posts show locals 56% of the time
against agencies' 29%, and on TikTok it's 30% against 22%. The gap is 27 points on
one platform and 8 on the other. Most of what my 2x2 test measured was the
difference between Instagram and TikTok.

## Agencies sell the group; travellers post the solo trip

Tour operator accounts show a visible tour group in 76% of posts, against 43% for
traveller accounts. OR = 5.04, p = .001. Unlike my original finding this one doesn't
move when platform enters the model, and it survives Holm correction at p = .020.

This is the mechanism behind the complaints in my interview data. Operators
advertise a group experience while the free advertising their customers produce
shows a trip that looks solitary.

This finding and the next one depend on coding nobody can audit, for reasons in
the limitations section below. The survey findings after them don't.

## Two kinds of post, and two thirds leave people out

Three of my seven codes describe human presence: locals, cultural practice,
villages and temples. Count them per post. A post carrying at least two of the
three is showing a place with people in it; one or none means scenery.

![Figure 1. Theme prevalence by post type](figures/01_content_types.png)

66 of the 100 posts are scenery, and 45 carry none of the three codes at all.
Operator accounts show a populated place in 19% of posts against 43% for traveller
accounts (χ² = 5.95, p = .015), and unlike my original finding this one holds when
platform enters the model, at OR = 0.34, p = .031.

You can check that split by hand from the CSV, which is the point of doing it this
way. [`R/05_latent_class_check.R`](R/05_latent_class_check.R) fits a latent class
model over all seven codes, chooses two classes by BIC, and lands on the same split:
the model and the counting rule agree on 97 of 100 posts, Cohen's kappa 0.93.

Platform compresses content independently of who's posting. Instagram posts carry
3.10 themes on average against TikTok's 2.12 (Welch t = 3.72, p = .0003), while
account type makes no difference to breadth at all (p = .31).

## TikTok recruits, Instagram archives

I asked every respondent both where they found the Loop and where they post about
it, so the comparison is paired within person.

![Figure 2. Platform of discovery and platform of publication](figures/02_discovery_vs_publication.png)

27 found the Loop through TikTok. Two of them post to TikTok. Nine found it through
Instagram and 55 post to Instagram. Exact McNemar gives p = 2.7e-05 and 3.5e-13.

The feedback loop I named in the original title is real, but it isn't one loop.
Discovery and publication happen on different platforms, and those platforms carry
measurably different pictures of the same place.

## The gap that beats all of it

![Figure 3. Reported enjoyment of local interaction, and depiction of locals in posts](figures/03_representation_gap.png)

All 61 respondents rated "I enjoyed interactions with locals, staff and easyriders"
at 4 or 5. Two named culture or socialising as a reason for going, against 40 who
named scenery. And 37% of posts contain a local resident at all.

People come for the landscape, unanimously enjoy the people, and post the landscape.

## What doesn't replicate, and one honest negative

I reported that perceived accuracy of the Loop's social media portrayal was
identical whether travellers heard about it from friends or from other sources,
p ≈ .99. That reproduces exactly: 4.21 against 4.21, p = .995. Split the same
variable by social-media discovery instead and it goes the other way, 4.41 against
4.00, p = .078, d = 0.47. The null belongs to one comparison and I should have
reported it as that comparison, not as "channel doesn't matter."

Nothing I measured predicts intention to return. Accommodation satisfaction is the
strongest correlate at r = .28, and 24 of 61 respondents are neutral. A destination
that nearly everyone recommends and few plan to revisit is a finding, just not a
comfortable one.

## Limitations

I recruited all 61 respondents from a single homestay. The demographic profile they
produce, young and European and travelling with friends, may belong to that
operator's clientele rather than to Loop travellers generally. I didn't say so on
the poster.

I coded all 100 posts myself, and I didn't archive them. `content_coding.csv`
carries an ID per post and nothing else, so the posts behind those IDs can't be
found again. Nobody can re-check my coding, including me. The two content findings
above rest on judgment calls a reader has to take on trust, and there is no
reliability statistic I can honestly report in place of that. The corpus file
should have carried a URL and a capture date on every row.

The survey half doesn't have this problem. `survey_responses.csv` holds every
response, so anyone can rerun script 04 and get my numbers.

My survey respondents didn't write the posts I coded, so the representation gap
above compares two populations rather than two measurements of one. And nothing
here identifies a causal feedback loop. The data are consistent with one.

## Reproducing

Base R 4.3 or later, no packages. The one model that needs a library, the latent
class check, is implemented directly in
[`R/05_latent_class_check.R`](R/05_latent_class_check.R) rather than pulling in
`poLCA`, so the whole repository runs anywhere R does.

```bash
Rscript R/01_content_tests.R     # 14 tests, Holm-corrected
Rscript R/02_logistic_models.R   # the confounding check
Rscript R/03_content_types.R     # scenery vs populated place
Rscript R/04_survey.R            # paired platform tests, representation gap
Rscript R/05_latent_class_check.R  # robustness check on script 03
Rscript R/06_figures.R           # all four figures
```

Or `bash run_all.sh`. Numbers land in `results/`, figures in `figures/`. Every
figure above is generated by script; I made none of them by hand.

```
data/     content_coding.csv, survey_responses.csv (de-identified), codebook.md
R/        00_prep.R and the six numbered analysis scripts
results/  csv output from each script
figures/  png output from 06_figures.R
```

## Data and ethics

The survey file here is de-identified. I deleted the interview-volunteer email
column, cut timestamps to dates, and replaced two easyriders named in a free-text
response. The raw Google Forms export holds five email addresses and isn't in this
repository. The posts I coded are public content. The file records themes
and nothing else, which protects the accounts involved and, as the limitations note,
also makes the coding impossible to audit.

## License

Code MIT. Data CC BY-NC 4.0.
