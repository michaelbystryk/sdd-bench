# Where things stand — Builder activation

Notes from Priya (Head of Product) ahead of next week's planning. Sharing the
raw context so we're all looking at the same thing. I don't have a clean story
here yet, which is the problem.

## The product

We're **Stacklet** — a no-code internal-tools builder. Teams sign up, connect a
data source (Postgres, a Google Sheet, an Airtable, a REST API), and drag
together a "tool": a dashboard, an admin panel, a form that writes back to the
database. Think a lighter Retool aimed at smaller companies and ops teams rather
than engineers. Self-serve signup, $0 free tier (1 tool, 2 editors), paid plans
start at $99/mo for the team.

We've been live ~14 months. Signups are healthy and still growing month over
month — marketing is doing its job. The trouble is downstream.

## The thing that's bugging me

**People sign up, poke around, and a lot of them never build anything real.**
Roughly: of people who finish signup and land in the app, a bit under a third
ever connect a data source, and well under half of *those* publish a tool that
gets opened by anyone other than its creator. So the funnel from "signed up" to
"a tool someone actually uses at their company" is leaking badly somewhere in the
middle, and I can't tell you with confidence *where* or *why*.

I keep hearing different stories depending on who I ask, and they don't reconcile:

- **Sales** says the product is "too hard to get started with" and we need a
  guided onboarding / templates / a wizard. They lose deals, they say, because
  the buyer's team "couldn't get a quick win in the trial."
- **Support** says the top ticket category by volume is **data connections** —
  people can't connect their database. A lot of those turn out to be firewall /
  IP-allowlist issues on the customer's side (their DB isn't reachable from our
  cloud), but some are genuine confusion about connection strings and SSL.
- **Two of our power users** (both at slightly larger companies, both have an
  engineer on the team) told me the opposite — they think the product is great
  and they want *more* power: custom JavaScript, version control, staging vs
  prod. They're our loudest voice in the community Slack.
- **A designer on my team** is convinced the editor itself is the problem — that
  the drag-and-drop canvas is confusing and people bounce off it. She's been
  pushing a big editor redesign for two quarters.

## A few numbers I trust, and some I don't

Things I'm fairly confident in:

- Signup → land-in-app is fine (>90%). The leak is *after* they're in.
- Most signups select an **occupation/role** at signup. The mix is roughly:
  ~40% "operations / business ops", ~25% "founder / owner", ~20% "engineer /
  developer", ~15% other/blank.
- The accounts that *do* reach an actively-used published tool skew heavily
  toward ones with an **engineer** somewhere on the team — but engineers are a
  minority of signups. Most of our signups are non-technical ops people.
- Median time from signup to *first data source connected*, **for the accounts
  that connect at all**, is about 4 days — not 4 minutes. Whatever they do in
  that first session, connecting a real data source mostly isn't it.

Things I'm *not* sure about:

- We added a templates gallery 5 months ago (pre-built tools you can clone). I
  *think* template-starters activate better but I genuinely can't tell if that's
  the template helping or just that more-motivated people pick templates. We've
  never tested it cleanly.
- We don't have good instrumentation on *what people actually do* in that first
  session before they drop. We know the big funnel steps (signed up → connected
  source → published tool → tool opened by a 2nd person) but not the in-session
  detail. So a lot of the "why" is guesswork right now.
- Churn on *paid* accounts is actually fine — low single digits monthly. The
  people who get to a real, used tool tend to stick. The bleed is all up front,
  before money changes hands.

## What I want out of next week

I don't want a feature list and I don't want to just rubber-stamp whichever team
yelled loudest. Before we commit a quarter to "guided onboarding" or "editor
redesign" or "more power features," I want to know **what's actually stopping a
typical new account from getting to a tool their team uses** — and a cheap way to
find out that doesn't cost us the whole quarter to run. Help me think about this
properly.
