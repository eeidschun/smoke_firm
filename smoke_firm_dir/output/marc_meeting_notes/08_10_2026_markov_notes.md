Once I know today's state, I don't need to know the entire history that produced it in order to predict tomorrow.

That is the Markov idea

process is Markov if

P(S
t+1
	​

∣S
t
	​

,S
t−1
	​

,S
t−2
	​

,…)=P(S
t+1
	​

∣S
t
	​

).

In words:

Conditional on the current state, earlier history contains no additional information about the distribution of next period's state. It does not mean that history doesn't matter.

History matters enormously.

It means that history matters through the current state.

Markov” doesn't dictate what belongs in the state. It says that you've constructed the state richly enough that, conditional on it, deeper history isn't needed.


A Markov strategy might be

a
V,t
	​

=σ
V
	​

(S
t
	​

).

That means:

Vuse's decision today depends on the current state, not the entire historical path.

For example:

If I'm technologically behind the leader and the market is profitable, invest; otherwise don't.

That could be a Markov strategy

The complication is that Vuse isn't alone.

Its return to investment depends on what JUUL, NJOY, Blu, etc. do.

Suppose the full state is

S
t
	​

=(ω
V,t
	​

,ω
J,t
	​

,ω
N,t
	​

,ω
B,t
	​

).

Then Vuse has a strategy

σ
V
	​

(S
t
	​

),

JUUL has

σ
J
	​

(S
t
	​

),

and so on.

Each firm's optimal decision depends on what it expects the other firms to do.

A Nash equilibrium is a collection of strategies such that:

Given everybody else's strategy, no player wants to change its own strategy.

So if

(σ
V
∗
	​

,σ
J
∗
	​

,σ
N
∗
	​

,…)

is an equilibrium, Vuse cannot improve its expected value by switching to another strategy while everyone else keeps theirs.

**A Markov Perfect Equilibrium (MPE) requires the strategies to constitute an equilibrium at every possible state of the game.**

11. So Pakes is separating two assumptions

This is the core distinction.

Assumption A: Markov

The current state summarizes the payoff-relevant history.

Pakes is basically saying:

This can still be useful.

For your application, perhaps Vuse's relevant current information is summarized by:

S
t
	​

=(own technology,competitive position,market conditions).

We don't need the entire history since 2013.

Assumption B: Markov perfection

Firms have equilibrium-optimal policies defined for every possible state, and their beliefs about rivals' behavior are correct throughout that state space.

Pakes is saying:

This is much more demanding, both computationally and behaviorally.

That's what he wants to relax.

Now suppose Vuse actually experiences only a tiny fraction of all mathematically possible competitive situations.

Maybe management learns:

“When we're technologically behind the leader by about this much, and market conditions look like this, historically investment has paid off.”

That is a much weaker informational requirement.

They don't need to know the correct equilibrium strategy for some bizarre industry configuration they've never encountered.

This is the intuition behind the later Experience-Based Equilibrium discussion.

Roughly:

Require firms' beliefs to be consistent with what they repeatedly experience, rather than requiring perfect equilibrium beliefs throughout the entire theoretical state space.

so overall : markov = history can be summarized into prior state. donn't need to literally look at history to nform strategy. "markov perfect" means that you look for nash equilibrium for every possible combination of states (computationally very expensive)

What “recurrent” means

For one state S, recurrence roughly means:

If the system starts at S, there is probability one that it eventually returns to S.

A recurrent class is a connected collection of such states: starting from any state in that class, the process can move among the others, and it doesn't escape permanently into some different part of the state space.

Pakes uses this because it distinguishes:

states firms repeatedly experience
	​


from

states that are mathematically possible but essentially never encountered
	​

.

That distinction becomes important for relaxing Markov perfection.

For example, Vuse repeatedly encounters situations where:

it uses modern technology;
JUUL also uses modern technology;
both are major competitors;
market concentration lies in a typical range.

After enough experience, it is reasonable to think Vuse learns:

When the market looks like this and I take action a, what generally happens next?

Why this becomes a counterfactual problem

Suppose your estimated historical process spends nearly all its time in a recurrent region R.

Your data may tell you a lot about behavior there.

Then you conduct a counterfactual:

What happens if nicotine regulations eliminate high-nicotine technology?

That might push the industry into states outside the historically relevant recurrent region.

Now firms' historical experience doesn't tell you what beliefs to use.

This is why Pakes warns that the weaker equilibrium concept can be particularly difficult for counterfactuals: alternative beliefs about unfamiliar states can imply different responses.

Transient states are states the process passes through and may never revisit. A recurrent class is a region of the state space the process returns to repeatedly. Experience can discipline beliefs in the recurrent class much more strongly than in states firms essentially never encounter.

EBE says that if Vuse repeatedly experiences J, its beliefs about those experienced outcomes cannot systematically contradict the data it sees.

Very loosely,

belief
Vuse’s perceived distribution of outcomes∣J,a
	​

	​


must agree with

experience
distribution Vuse actually experiences∣J,a
	​

	​

.

That is what “experience-based” means.

EBE says that if Vuse repeatedly experiences J, its beliefs about those experienced outcomes cannot systematically contradict the data it sees.

Very loosely,

belief
Vuse’s perceived distribution of outcomes∣J,a
	​

	​


must agree with

experience
distribution Vuse actually experiences∣J,a
	​

	​

.

That is what “experience-based” means.