# Simplistic step-by-step

## 1. Vaccine efficiency

The simulation of [question 17: "Dépistons ! Oui mais qui, quand et comment ?"](https://covprehension.org/2020/05/12/q17.html) from the website [CoVprehension.org](https://covprehension.org/) has been chosen as basis for the following simulations. Its agents have five possible health states: susceptible, incubating, asymptomatic, symptomatic and recovered. For the first following simplistic simulations, agents will keep three of those health states: susceptible, infected (i.e. symptomatic) and recovered. Agents will have an additional parameter showing their vaccinated state, which is different form a health state. Either they are vaccinated, or they're not. Suscpetible agents can get vaccinated and infected. Infected agents can infect susceptible agents and recover from their infection over time, becoming recovered agents. The recovered state is a final state, thus giving full immunity to agents against the virus. The vaccinated parameter plays a role in the probability for agents to get infected and in the time it takes them to recover from their infection. In other words, vaccinated agents have less chance to get infected by other agents and recover faster from their infected state.

### 1.1 Static

>Given a fixed percentage of vaccinated agents in a population, how does it affect the spread of the virus in that population?

The static version of this simulation requires the user to give a fixed percentage of vaccinated agents among the population before the start of the simulation. The simulation will then run with this fixed percentage until all agents reach the recovered state.

Results of this simulation are viewed in a graph showing the number of infected agents across time.

### 1.2 Dynamic

>Given a rate at which to vaccinate a percentage of the population, how does it affect the spread of the virus in that population?

The dynamic version of this simulation enables the user to give a rate at which a given percentage of agents will get vaccinated. The simulation will then run until all agents reach the recovered state.

Results of this simulation are viewed in a graph showing the number of infected agents and the number of vaccinated agents across time.

## 2. Public trust

<TODO>

## 3. Decreasing immunity

<TODO>
