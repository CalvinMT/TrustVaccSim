# Simplistic step-by-step

The simulation of [question 17: "Dépistons ! Oui mais qui, quand et comment ?"](https://covprehension.org/2020/05/12/q17.html) from the website [CoVprehension.org](https://covprehension.org/) has been chosen as basis for the following simulations. Its agents have five possible health states of which three are kept and two are added: susceptible, infected (i.e. symptomatic), recovered, hospitalised and deceased. Suscpetible agents can get infected. Infected agents can infect susceptible agents, recover from their infection over time by becoming recovered agents or get hospitalised as the infection gets worse. Hospitalised agents can either become recovered agents or deceased agents. The deceased state is a final state, as well as for the recovered state for the first simulations, thus giving full immunity to agents against the virus. The simulation ends once no more agents are in the infected or hospitalised state.

## 1. Vaccine efficiency

Agents are given an additional parameter showing their vaccinated state, which is different from a health state. Either they are vaccinated, or they're not. The vaccinated parameter plays a role in the probability for agents to get infected, in the time it takes them to recover from their infection and influences the chances they have not to get hospitalised and die. In other words, a good vaccine makes vaccinated agents have less chances to get infected by other agents, makes them recover faster from their infected state and should prevent them from being hospitalised.

The simulated vaccine has two adjustable parameters. One controlling the probability for a vaccinated agent to get infected and the other conrtolling the probability for a vaccinated agent to get hospitalised.

### 1.1 Static

>Given a fixed percentage of vaccinated agents in a population, how does it affect the spread of the virus in that population?

The static version of this simulation requires the user to give a fixed percentage of vaccinated agents among the population before the start of the simulation. Results of this simulation are viewed in a graph showing the number of infected agents across time.

### 1.2 Dynamic

>Given a rate at which to vaccinate a percentage of the population, how does it affect the spread of the virus in that population?

The dynamic version of this simulation enables the user to give a rate at which a given percentage of agents will get vaccinated. Results of this simulation are viewed in a graph showing the number of infected agents and the number of vaccinated agents across time.

## 2. Public trust

The following simulations add a normalised trust parameter to agents. This parameter is used as a probability for agents to get vaccinated. Agents with a higher trust level have a higher chance "to want" to get vaccinated while agents with a lower trust level have a smaller chance to be inclined to.

### 2.1 Static

>Given a fixed level of trust for all agents and a rate at which to vaccinate a percentage of the population, how does it affect the spread of the virus in that population?

The static version of this simulation makes use of a given fixed level of trust that all agents will carry. Results of this simulation are viewed in a graph showing the number of infected agents and the number of vaccinated agents across time.

### 2.2 Dynamic - Contact influence

>Given an average trust level shared amongst agents and a rate at which to vaccinate a percentage of the population, how does it affect the spread of the virus in that population?

The dynamic version of this simulation with contact influence gives the user the possibility to give an average initial trust level shared throughout the population. Agents in contact with each other will influence themselves into adjusting their trust level towards the one of their acquaintenance. This adjustement depends on the degree of polarisation of their trust level. Two highly polarised agents with opposite trust levels coming into contact will barely influence themselves, while an agent with a highly polarised trust level will have more influence on an agent with a moderately polarised trust level. Results of this simulation are viewed in a graph showing the number of infected agents, the number of vaccinated agents and the average trust level of the population across time.

### 2.3 Dynamic - Coherence influence

>Given an average trust level <TODO>

The dynamic version of this simulation with coherence influence requires the user to give an average initial trust level shared throughout the population, a radius of perception that all agents will carry and to choose the type of information to spread to the population at the a rate shifted to half of the vaccination rate. Types of information are: real, positive, negative and opposite. Real information reflects exactly the state the population. Positive information implifies good news, while negative information implifies bad news. And opposite information communicates the opposite of what is going on in the population. Results of this simulation are viewed in a graph showing the number of infected agents, the number of vaccinated agents and the average trust level of the population across time, along with moments of information broadcast.

## 3. Decreasing immunity

Immunity to deseases usually decrease over time. Implementing this in the simulation reasons into recovered state not being a final state anymore, thus no more giving agents full immunity to the virus. In other words, recovered agents will become susceptible to infections again.

<TODO>
