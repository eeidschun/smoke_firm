# Dynamic Games: Markov Assumption, Markov Perfection, and Experience-Based Equilibrium

The starting point is the Markov assumption. A state \(S_t\) is meant to summarize all information from the past that matters for predicting the future. 

\[
P(S_{t+1}\mid S_t,S_{t-1},S_{t-2},\ldots)
=
P(S_{t+1}\mid S_t).
\]

History matters through the current state. The key modeling task is therefore to construct the state richly enough that, conditional on \(S_t\), deeper history is no longer needed.

Looking at the data, it seems that investment in nicotine strength and the right e-cigarette type is what drives brand success. Some external policies do too (FDA / Markten). But maybe in consideration of the movements in HHI, a firm's current state might summarize its technology, competitive position, and current market conditions:

Suppose 
\[
S_t=
(\text{own technology},
\text{competitive position},
\text{market conditions}).
\]

A Markov strategy is then a rule such as

\[
a_{jt}=\sigma_j(S_t),
\]

meaning that firm \(j\)'s action depends on the current state rather than on the full historical path. For example, a firm might invest when it is technologically behind the leader and the market is sufficiently profitable.

The problem becomes a dynamic game because each firm's return to investment depends on its competitors. If the industry state is

\[
S_t=
(\omega_{V,t},\omega_{J,t},\omega_{N,t},\omega_{B,t}),
\]

then Vuse, JUUL, NJOY, Blu, etc. each have strategies that depend on the same competitive environment:

\[
\sigma_V(S_t),\quad
\sigma_J(S_t),\quad
\sigma_N(S_t),\ldots
\]

A Nash equilibrium is a collection of strategies such that, given the strategies of all other firms, no firm wants to deviate from its own strategy.

MPE imposes an additional requirement that strategies must form a NE at every possible state of the game. Thus, firms must have equilibrium-optimal policies and correct beliefs about rivals' behavior throughout the entire state space, including states that may be mathematically possible but never actually observed. State space can explode.

- Markov: the current state summarizes the payoff-relevant history.
- Markov perfection: firms have equilibrium-optimal strategies and correct beliefs at every possible state.

Pakes says Markov assumption can still be useful but that Markov perfection is much less feasible and might not summarize firm's behaviors accurately.

This motivates **experience-based equilibrium (EBE)**: focus on the states firms actually experience.

A recurrent state is one that the process eventually returns to with probability one. A recurrent class is a connected set of states that the process repeatedly moves among rather than permanently leaving. By contrast, transient states are states the industry passes through and may never revisit.

This distinction is useful because experience can discipline firms' beliefs in recurrent states much more strongly than in states that are only theoretically possible.

For example, suppose Vuse repeatedly encounters situations in which it and JUUL both use modern technology, both are important competitors, and concentration lies in a familiar range. Through repeated experience, Vuse can learn:

> When the market looks like this and I choose action \(a\), what tends to happen next?


In EBE, firms remain forward-looking and optimizing, but their beliefs only need to be consistent with what they repeatedly experience. If a firm repeatedly encounters information state \(J\) and takes action \(a\), then its perceived distribution of future outcomes should agree with the distribution it actually observes:

\[
\text{perceived outcomes}\mid J,a
\approx
\text{experienced outcomes}\mid J,a.
\]

Thus, EBE relaxes the requirement that firms have correct beliefs throughout the entire theoretical state space. Firms may have poorly disciplined beliefs about states or actions they have never experienced.

This makes EBE weaker than MPE. MPE is a special case in which beliefs are correct everywhere; EBE requires consistency primarily where experience provides information.

The tradeoff is that this creates a problem for counterfactuals. Suppose the observed industry spends most of its time in a recurrent region \(R\), so historical experience disciplines behavior there. A counterfactual such as eliminating high-nicotine technology may move the industry outside \(R\). Historical experience then provides little information about firms' beliefs or behavior in those unfamiliar states, and alternative beliefs can imply different counterfactual outcomes.

The main takeaway is therefore:

\[
\boxed{
\text{Markov: summarize history with a current state}
}
\]

\[
\boxed{
\text{MPE: require equilibrium behavior at every possible state}
}
\]

\[
\boxed{
\text{EBE: require beliefs to be consistent with repeated experience}
}
\]

**Next Step?**
Determine which dimensions of the environment firms respond to. My hunch is: nicotine strength or overall nicotine amount, market structure, external regulatory sources, consumer preferences for product-types.