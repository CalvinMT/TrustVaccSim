# TrustVaccSim
Trust and misinterpretation influence over vaccination using an educational agent-based simulation

Research project performed at the [Laboratoire d’Informatique de Grenoble (LIG)](https://www.liglab.fr/en) as an internship part of the [Masters of Science in Informatics of Grenoble (MoSIG)](https://mosig.imag.fr/MainEn/HomePage) curriculum and funded by the [Centre National de la Recherche Scientifique (CNRS)](https://www.cnrs.fr/en).

Under the supervision of:
 - [Carole ADAM](https://scholar.google.com/citations?user=S3-AmJMAAAAJ&hl=en&oi=ao), Associate Professor at the Université Grenoble Alpes
 - [Didier GEORGES](https://scholar.google.com/citations?user=oF1ahtcAAAAJ&hl=en&oi=ao), Professor at the Grenoble INP/Université Grenoble Alpes

With the valuable help of:
 - [Pierrick TRANOUEZ](https://scholar.google.com/citations?user=tyfVtnsAAAAJ&hl=en&oi=ao), computer scientist and research engineer at the University of Rouen Normandie

## Content

The [docs/](/docs/) directory contains the latex source files and the PDF file for both the final version of the presentation and the report. Additionally, two previous versions of the presentation can be found as PDF files.

The [ideas/](/ideas/) directory contains different concepts not necessarily part of the final implementation. Images in a `drawio` format representing agent interactions and a simulation design in a `ods` format can also be found in a subfolder.

The [src/](/src/) directory contains the NetLogo source code of both the step-by-step and the final model. Both models can be run using either the [NetLogo software](https://ccl.northwestern.edu/netlogo/) or its web version, NetLogo Web: [step-by-step](https://www.netlogoweb.org/launch#https://raw.githubusercontent.com/CalvinMT/TrustVaccSim/main/src/simplistic/simplistic_step_by_step.nlogo), [TrustVaccSim](https://www.netlogoweb.org/launch#https://raw.githubusercontent.com/CalvinMT/TrustVaccSim/main/src/trustvaccsim.nlogo).

## Abstract

**Introduction:** Vaccine controversies has been an ongoing threat preventing the population from gaining trust in vaccination. Misinformation and disinformation, such as Wakefield's claim of vaccine-autism connection, inevitably leads to an increase in the number of deaths accredited to the vaccine's targeted disease. A population's trust has a major effect on an epidemic's outcome, but this factor is not part of common knowledge. Thus, the goal is to educate the population on this aspect and to make institutions aware of their responsibility in the precision of their information.

**Methods:** After some research over existing works and agent-based models of epidemics, vaccination, and trust, it was decided to create a NetLogo agent-based simulation in which each agent's epidemiological state follows an SIAHRD state model. Additionally, agents possess a vaccination status attribute and a trust level float attribute. The latter is updated through three influence methods: interpersonal, observational, and institutional. The institutional influence informs the population on the ongoing epidemic, for which half of the population will be misinterpreting.

**Results:** A design of experiments was run on the single input parameter that lets the user decide of the population's initial average trust level (from 0.1 to 0.9 with steps of 0.1). For each input steps, the simulation ran 100 times and the results were averaged out. It is possible to observe that there is a higher death rate among agents that incorrectly interpret institutional information. In addition, a high population's initial average trust level inhibits the effect of misinterpretation on vaccination, thus lowering the death rate.

**Conclusion:** Although some additional user experiments are required to validate the simulation's output interpretations, it is possible to notice that a population's average trust level at the start of an epidemic has a significant effect on its outcome.
