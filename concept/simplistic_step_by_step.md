# Simplistic step-by-step

The simulation of [question 17: "Dépistons ! Oui mais qui, quand et comment ?"](https://covprehension.org/2020/05/12/q17.html) from the website [CoVprehension.org](https://covprehension.org/) has been chosen as basis for the following simulations. Its agents have five possible health states of which only three will be kept: susceptible, infected (i.e. symptomatic) and recovered.

## 1. Vaccine efficiency

Agents are given an additional parameter showing their vaccinated state, which is different from a health state. Either they are vaccinated, or they're not. Suscpetible agents can get vaccinated and infected. Infected agents can infect susceptible agents and recover from their infection over time, becoming recovered agents. The recovered state is a final state, thus giving full immunity to agents against the virus. The vaccinated parameter plays a role in the probability for agents to get infected and in the time it takes them to recover from their infection. In other words, vaccinated agents have less chance to get infected by other agents and recover faster from their infected state.

### 1.1 Static

>Given a fixed percentage of vaccinated agents in a population, how does it affect the spread of the virus in that population?

The static version of this simulation requires the user to give a fixed percentage of vaccinated agents among the population before the start of the simulation. The simulation will then run with this fixed percentage until all agents reach the recovered state.

Results of this simulation are viewed in a graph showing the number of infected agents across time.

### 1.2 Dynamic

>Given a rate at which to vaccinate a percentage of the population, how does it affect the spread of the virus in that population?

The dynamic version of this simulation enables the user to give a rate at which a given percentage of agents will get vaccinated. The simulation will then run until all agents reach the recovered state.

Results of this simulation are viewed in a graph showing the number of infected agents and the number of vaccinated agents across time.

## 2. Public trust

The following simulations add a trust parameter to agents, normalised from 0 to 1. This parameter is used as a probability for agents to get vaccinated. Agents with a higher trust level have a higher chance "to want" to get vaccinated while agents with a lower trust level have a smaller chance to be inclined to.

### 2.1 Static

>Given a fixed level of trust for all agents and a rate at which to vaccinate a percentage of the population, how does it affect the spread of the virus in that population?

The static version of this simulation makes use of a given fixed level of trust that all agents will carry. The simulation will then run with this fixed level of trust until all agents reach the recovered state.

Results of this simulation are viewed in a graph showing the number of infected agents and the number of vaccinated agents across time.

### 2.2 Dynamic

>Given an average trust level, an amount at which it will decrease and a rate at which to vaccinate a percentage of the population, how does it affect the spread of the virus in that population?

The dynamic version of this simulation gives the user the possibility to give an average initial trust level among the population and an amount at which its trust level will decrease. This decrease will happen at each step of the simulation. The simulation will then run with this decreasing trus level until all agents reach the recovered state.

Results of this simulation are viewed in a graph showing the number of infected agents, the number of vaccinated agents across time and the average trust level of the population.

## 3. Decreasing immunity

Immunity to deseases usually decrease over time. Implementing this in the simulation reasons into recovered state not being a final state anymore, thus no more giving agents full immunity to the virus. In other words, recovered agents will become susceptible to infections again.

<TODO>
