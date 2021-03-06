; adapted from Q17: Dépistons ! Oui mais qui, quand et comment ?
; CoVprehension.org

;__includes [ "headless.nls" ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; GLOBAL VARIABLES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [
  ;; GUI variables
  vaccine-config
  initial-trust-level

  current-trust-average ;; current trust average

  population-size
  nb-infected-initialisation            ;; initial number of sick agents
  percentage-daily-vaccinations         ;; percentage of the population to vaccinate at each tick
  nb-daily-vaccinations                 ;; number of daily vaccinated agents
  max-nb-daily-vaccinations             ;; maximum number of daily vaccinated agents
  probability-transmission              ;; probability that an infected agent will infect a neighbour on same patch
  probability-asymptomatic              ;; probability that a susceptible agent will get to an asymptomatic state
  probability-hospitalised              ;; probability for an infected agent to get to a hospitalised state
  probability-deceased                  ;; probability for an hospitalised agent to get to a deceased state
  probability-susceptible               ;; probability for a recovered agent to get to a recovered state
  probability-transmission-vaccinated   ;; probability that an infected agent will infect a vacinated neighbour on same patch
  probability-asymptomatic-vaccinated   ;; probability for a susceptible agent to get to a asymptomatic state
  probability-hospitalised-vaccinated   ;; probability for a vacinated infected agent to get to a hospitalised state
  probability-deceased-vaccinated       ;; probability for a vacinated hospitalised agent to get to a deceased state
  probability-susceptible-vaccinated    ;; probability for a vaccinated recovered agent to get to a recovered state

  ;; movement
  initial-speed

  ;; event
  tick-trigger

  ;; patch boundaries
  min-x-hospitalised-patch
  max-x-hospitalised-patch
  min-y-hospitalised-patch
  max-y-hospitalised-patch

  infinity ;; default value for durations not in use

  ;; new globals pour dépistage
  on-going-vaccination? ;; is there a vaccination campaign currently
  nb-days-vaccination   ;; number of days elapsed since the beginning of the vaccination campaign
  nb-vaccinations-today ;; number of vaccines given on this current day
  list-vaccinations     ;; remember %vaccinated each day

  ;; hospitalised counters
  nb-total-hospitalised             ;; current total number agents who has been in a hospitalised state
  nb-total-hospitalised-vaccinated  ;; current total number vaccinated agents who has been in a hospitalised state

  ; mean and variance for random-gamma determining infection durations
  infection-mean
  infection-variance

  ; mean and variance for random-gamma determining asymptomatic infection durations
  asymptomatic-mean
  asymptomatic-variance

  ; mean and variance for random-gamma determining hospitalisation durations
  hospitalisation-mean
  hospitalisation-variance

  ; mean and variance for random-gamma determining recovered durations
  recovered-mean
  recovered-variance

  ; mean and variance for random-gamma determining vaccination durations
  vaccinated-mean
  vaccinated-variance

  ;; metrics
  nb-new-infections
  total-nb-infected

  nb-D-nV-nT
  nb-D-nV-T
  nb-D-V-nT
  nb-D-V-T

  nb-D-nV-nM
  nb-D-nV-M
  nb-D-V-nM
  nb-D-V-M

  ;; colors
  color-susceptible
  color-infected
  color-asymptomatic
  color-hospitalised
  color-recovered
  color-deceased
  color-vaccinated
  color-trust-level
  color-misinterpret
  color-H-nV-nT     ;; hospitalised, not vaccinated, not trusting
  color-H-nV-T      ;; hospitalised, not vaccinated, trusting
  color-H-V-nT      ;; hospitalised, vaccinated, not trusting
  color-H-V-T       ;; hospitalised, vaccinated, trusting
  color-D-nV-nT     ;; deceased, not vaccinated, not trusting
  color-D-nV-T      ;; deceased, not vaccinated, trusting
  color-D-V-nT      ;; deceased, vaccinated, not trusting
  color-D-V-T       ;; deceased, vaccinated, trusting
  color-D-nV-nM     ;; deceased, not vaccinated, no misinterpretation
  color-D-nV-M      ;; deceased, not vaccinated, misinterpretation
  color-D-V-nM      ;; deceased, vaccinated, no misinterpretation
  color-D-V-M       ;; deceased, vaccinated, misinterpretation
  transparency
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; AGENTS AND THEIR VARIABLES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

turtles-own [
  epidemic-state            ;; state of the agent among [Susceptible, Infected, Asymptomatic, Hospitalised, Recovered, Deceased]
  infection-date            ;; ticks when got infected
  infection-duration        ;; number of ticks before the end of the infectious state
  hospitalisation-date      ;; ticks when got hospitalised
  hospitalisation-duration  ;; number of ticks before the end of the hospitalised state
  recovered-date            ;; ticks when got recovered
  recovered-duration        ;; number of ticks before the end of the recovered state
  vaccinated-date           ;; ticks when got vaccinated
  vaccinated-duration       ;; number of ticks before the end of the vaccination effect
  deceased-date             ;; ticks when died
  infected?                 ;; shortcut for Infected

  ; demographics
  vaccinated?     ;; was already vaccinated

  trust-level     ;; level of trust normalised between 0.0 and 1.0
  misinterpret?   ;; interprets wrongly institutional information

  ;; movement
  speed
  on-visit? ;; is the agent currently visiting a hospitalised patch
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; SCENARIO-DEPENDENT SETUP ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  reset-ticks

  setup-GUI
  setup-globals
  setup-world
  setup-population
end


;; setup the GUI variables as global variables
;; useful for headless mode and for translation of the interface
to setup-GUI
  set initial-trust-level niveau-de-confiance-initial
end


;; generic setup
to setup-globals
  set vaccine-config 0.9

  set current-trust-average initial-trust-level
  set current-trust-average 0

  set infinity 99999
  set population-size 2000
  set nb-infected-initialisation 1
  set percentage-daily-vaccinations 100
  set nb-daily-vaccinations (percentage-daily-vaccinations * population-size / 100)

  set probability-transmission 0.25         ;; S->I|A - probability for an agent to get infected
  set probability-asymptomatic 0.125        ;; I|A - probability for an agent to go into a Infectious or a Asymptomatic state
  set probability-hospitalised 0.35         ;; I->H|R - after a duration, probability for an agent to go into a Hospitalised or a Recovered state
  set probability-deceased 0.25             ;; H->R|D - after a duration, probability for an agent to go into a Recovered or a Deceased state
  set probability-susceptible 0.25          ;; R->R|S - after a duration, probability for an agent to go into a Susceptible state

  set probability-transmission-vaccinated probability-transmission * (1 - vaccine-config)
  set probability-asymptomatic-vaccinated probability-asymptomatic * vaccine-config
  set probability-hospitalised-vaccinated probability-hospitalised * (1 - vaccine-config)
  set probability-deceased-vaccinated probability-deceased * (1 - vaccine-config)
  set probability-susceptible-vaccinated probability-susceptible * (1 - vaccine-config)

  ;; based on Q17 CoVprehension.org
  ;; I->H|R - duration of infection (random-gamma init)
  set infection-mean 2.1
  set infection-variance 0.1

  ;; A->R - duration of asymptomatic infection (random-gamma init)
  set asymptomatic-mean 1.5
  set asymptomatic-variance 0.2

  ;; https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7589278/
  ;; H->R|D - duration of hospitalisation (random-gamma init)
  set hospitalisation-mean 1
  set hospitalisation-variance 0.3

  ;; R->S - duration of recovered (random-gamma init)
  set recovered-mean 6
  set recovered-variance 3

  ;; duration of vaccination (random-gamma init)
  set vaccinated-mean 6
  set vaccinated-variance 3

  ;; movement
  set initial-speed 1

  ;; event
  set tick-trigger 5

  ;; patch boundaries
  set min-x-hospitalised-patch -6
  set max-x-hospitalised-patch -5
  set min-y-hospitalised-patch 5
  set max-y-hospitalised-patch 6

  ;; vaccination counters
  set on-going-vaccination? false
  set nb-days-vaccination 0
  set nb-vaccinations-today 0
  set list-vaccinations []

  ;; hospitalised counters
  set nb-total-hospitalised 0
  set nb-total-hospitalised-vaccinated 0

  ;; metrics
  set total-nb-infected 0

  set nb-D-nV-nT 0
  set nb-D-nV-T 0
  set nb-D-V-nT 0
  set nb-D-V-T 0

  set nb-D-nV-nM 0
  set nb-D-nV-M 0
  set nb-D-V-nM 0
  set nb-D-V-M 0

  ;; colors
  set color-susceptible [0 153 255]
  set color-infected [254 178 76]
  set color-asymptomatic [178 178 178]
  set color-hospitalised [255 0 0]
  set color-recovered [0 255 0]
  set color-deceased [0 0 0]
  set color-vaccinated [255 153 255]
  set color-trust-level [0 0 255]
  set color-misinterpret [178 76 76]

  set color-H-nV-nT [255 0 0]
  set color-H-nV-T [127 0 127]
  set color-H-V-nT [255 76 127]
  set color-H-V-T [255 153 255]

  set color-D-nV-nT [0 0 0]
  set color-D-nV-T [0 0 127]
  set color-D-V-nT [127 76 127]
  set color-D-V-T [255 153 255]

  set color-D-nV-nM [0 0 0]
  set color-D-nV-M [178 76 76]
  set color-D-V-nM [255 153 255]
  set color-D-V-M [178 114 255]

  set transparency 145
end


;; resize the world to have (nb-contacts + 1) agents on a patch, on average
to setup-world
  let nb-contacts 10
  let width sqrt (population-size / (nb-contacts + 1))
  let max-cor floor ((width - 1) / 2)
  resize-world (- max-cor) (max-cor) (- max-cor) (max-cor)
  ask patches [ set pcolor white ]
end


;; initialisation of agents
to setup-population
  set-default-shape turtles "circle"

  create-turtles population-size [
    move-to-random-outside-hospitalised-patch
    set size 0.3

    get-susceptible
    set vaccinated? false

    set speed initial-speed
    set on-visit? false
  ]

  setup-population-trust-level
  setup-population-misinterpretation

  ; set some agents to be initially infected to start the epidemics
  ask n-of nb-infected-initialisation turtles [ get-infected ]
end


;; initialisation of each agent's trust level
to setup-population-trust-level
  ;; number of currently initialised agents' trust
  let current-trust-average-count 0
  ask turtles
  [
    (ifelse
      ;; if current population's average trust is below initial trust level
      ;; set trust level between X and 1
      ;; X = opposite number to current average of population trust based on initial trust level
      current-trust-average < initial-trust-level
      [
        let trust-average-adjuster (initial-trust-level + (initial-trust-level - current-trust-average))
        if trust-average-adjuster > 1
        [
          set trust-average-adjuster 0.9
        ]
        set trust-level trust-average-adjuster + (random-float (1 - trust-average-adjuster))
      ]
      ;; if current population's average trust is above initial trust level
      ;; set trust level between 0 and X
      ;; X = opposite number to current average of population trust based on initial trust level
      current-trust-average > initial-trust-level
      [
        let trust-average-adjuster (initial-trust-level - (current-trust-average - initial-trust-level))
        if trust-average-adjuster < 0
        [
          set trust-average-adjuster 0.1
        ]
        set trust-level random-float trust-average-adjuster
      ]
      ;; if current average of population trust is equal to initial trust level
      ;; set trust level between 0 and 1
      [
        set trust-level random-float 1
      ]
    )

    set current-trust-average-count current-trust-average-count + 1
    set current-trust-average (current-trust-average * (current-trust-average-count - 1) / current-trust-average-count + trust-level / current-trust-average-count)
  ]
end


;; initialisation of agents' misinterpretation attribute
to setup-population-misinterpretation
  ask turtles
  [
    set misinterpret? false
  ]
  ask n-of (population-size / 2) turtles
  [
    set misinterpret? true
  ]
end


;;;;;;;;;;;;;;;;;;;;;;
;;;;; PROCEDURES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;

;; performed at each step
to go
  ;; stop criterion
  ifelse virus-present?
  [
    reset-counters
    visit-hospitalised
    move-alive
    virus-transmission
    influence-over-trust
    vaccinate-pop

    ;; update new counters and monitors
    update-states
    update-counters

    tick
  ]
  ; once virus is extinct, stop
  [ stop ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; MOVEMENTS & POSITIONS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; is the agent's next position a hospitalised patch?
to-report heading-in-hopitalised-patch [my-speed]
  let ahead-x [pxcor] of patch-here
  let ahead-y [pycor] of patch-here
  let next-patch patch-ahead my-speed
  if next-patch != nobody [
    ask next-patch [
      set ahead-x pxcor
      set ahead-y pycor
    ]
  ]
  report
    ahead-x > min-x-hospitalised-patch - 2 and
    ahead-x < max-x-hospitalised-patch + 2 and
    ahead-y > min-y-hospitalised-patch - 2 and
    ahead-y < max-y-hospitalised-patch + 2
end

;; move the agent into a random hospitalised patch
to move-to-hospitalised-patch
  let x min-x-hospitalised-patch + (random (max-x-hospitalised-patch - min-x-hospitalised-patch + 1))
  let y min-y-hospitalised-patch + (random (max-y-hospitalised-patch - min-y-hospitalised-patch + 1))
  set x x + 0.5 - (random-float 1)
  set y y + 0.5 - (random-float 1)
  setxy x y
end

;; move the agent on a random patch that is not considered to be a hospitalised patch
to move-to-random-outside-hospitalised-patch
  let x random-xcor
  let y random-ycor
  while [x > min-x-hospitalised-patch - 1 and x < max-x-hospitalised-patch + 1 and
         y > min-y-hospitalised-patch - 1 and y < max-y-hospitalised-patch + 1]
  [
    set x random-xcor
    set y random-ycor
  ]
  setxy x y
end

;; update hospitalised patches' visitors
to visit-hospitalised
  if ticks mod tick-trigger = 0 [
    ;; move visitors outside of hospitalised patches
    ask turtles with [on-visit?] [
      set on-visit? false
      move-to-random-outside-hospitalised-patch
    ]
    ;; move visitors into hospitalised patches, if any hospitalised agents
    if nb-H > 0 [
      ask up-to-n-of 10 turtles with [epidemic-state = "Susceptible" or epidemic-state = "Asymptomatic" or epidemic-state = "Recovered"] [
        set on-visit? true
        move-to-hospitalised-patch
      ]
    ]
  ]
end

to move-randomly [my-speed]
  set heading random 360
  ifelse epidemic-state = "Hospitalised" or on-visit?
  [
    ;; stay inside hospitalised patches
    if heading-in-hopitalised-patch my-speed
    [
      forward my-speed
    ]
  ]
  [
    ;; avoid hospitalised patches
    if heading-in-hopitalised-patch my-speed
    [
      set heading (heading + 180) mod 360
    ]
    forward my-speed
  ]
end

to move-alive
  ask turtles with [not (epidemic-state = "Deceased")] [
    move-randomly speed
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; VIRUS PROPAGATION ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; virus transmission to susceptibles only
to virus-transmission
  ask turtles with [infected?] [
    ;; my contacts are the other turtles on the same patch as me
    ask other turtles-here with [epidemic-state = "Susceptible" and not on-visit?] [
      ;; use a different transmission probability depending on agent's state
      let proba-trans (ifelse-value
        vaccinated? [ probability-transmission-vaccinated ]
        [ probability-transmission ]
      )
      ;; each contact can infect
      if random-float 1 < proba-trans [ get-infected ]
    ]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; INFLUENCE OVER TRUST ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to influence-over-trust
  if ticks mod tick-trigger = 0 [
    interpersonal-influence-over-trust
    observational-influence-over-trust
    institutional-influence-over-trust nb-H nb-H-V false
    institutional-influence-over-trust nb-D nb-D-V true
  ]
end

;; update agents' trust level when in contact with each other
to interpersonal-influence-over-trust
  ask turtles with [epidemic-state != "Hospitalised" and epidemic-state != "Deceased"] [
    let influencer-trust-level trust-level
    ask other turtles in-radius 0.1 with [epidemic-state != "Deceased"] [
      let proba-influ (ifelse-value
        ;; non-trusting agents are less influenced than trusting agents
        trust-level < 0.5 [ random-float trust-level / 0.5 ]
        [ random-float (1 - trust-level) + 0.5 ]
      )
      if random-float 1 < proba-influ
      [
        ;; influence trust
        (ifelse
          influencer-trust-level < 0.5
          [
            ;; influencer's trust level of 0.0 has an intensity of 1
            let influencer-influence-intensity 1 - (influencer-trust-level / 0.5)
            ;; high effectiveness on trust level 0.0 (low on 1.0)
            let influence-effectiveness 1 - trust-level
            let influence-update influencer-influence-intensity * influence-effectiveness
            set trust-level trust-level - influence-update
            if trust-level < 0 [ set trust-level 0 ]
          ]
          influencer-trust-level > 0.5
          [
            ;; influencer's trust level of 1.0 has an intensity of 1
            let influencer-influence-intensity (influencer-trust-level / 0.5) - 1
            ;; high effectiveness on trust level 1.0 (low on 0.0)
            let influence-effectiveness trust-level
            let influence-update influencer-influence-intensity * influence-effectiveness
            set trust-level trust-level + influence-update
            if trust-level > 1 [ set trust-level 1 ]
          ]
          ;; else influencer-trust-level == 0.5
          ;; influencer's trust level of 0.5 has an intensity of 0
        )
      ]
    ]
  ]
end

;; update agents' trust level according to the infectious & vaccination status of agents around them (as well as themselves)
to observational-influence-over-trust
  if on-going-vaccination?
  [
    ask turtles with [epidemic-state != "Hospitalised" and epidemic-state != "Deceased"] [
      let observer-update 0
      ask other turtles in-radius 0.5 with [epidemic-state != "Deceased"] [
        let is-other-vaccinated? vaccinated?
        let is-other-symptomatic? ((epidemic-state = "Infected") or (epidemic-state = "Hospitalised"))
        ;; negative information have more impact than positive information
        ;; https://onlinelibrary.wiley.com/doi/abs/10.1111/0272-4332.00030
        (ifelse
          is-other-vaccinated? and (not is-other-symptomatic?)
          [
            ;; positive information
            set observer-update observer-update + (0.01 * trust-level)
          ]
          is-other-vaccinated? and is-other-symptomatic?
          [
            ;; negative information
            set observer-update observer-update - (0.03 * (1 - trust-level))
          ]
        )
      ]
      set trust-level trust-level + observer-update
      if trust-level < 0 [ set trust-level 0 ]
      if trust-level > 1 [ set trust-level 1 ]
    ]
  ]
end

;; update agents' trust level comparing the percentage of agents in epidemiologic state X with the percentage of agents not in the epidemiologic state X
to institutional-influence-over-trust [nb-X nb-X-V is-X-D?]
  if on-going-vaccination? and nb-X > 0
  [
    ;; percentage of vaccinated among X
    let prop-X-V nb-to-prop nb-X-V nb-X
    ;; percentage of vaccinated not among X
    let prop-nX-V 0
    ifelse is-X-D?
      [set prop-nX-V nb-to-prop (total-vaccinations - nb-X-V) (population-size - nb-X)]
      [set prop-nX-V nb-to-prop (total-vaccinations - nb-X-V) (population-size - nb-X - nb-D)]
    ask turtles with [epidemic-state != "Hospitalised" and epidemic-state != "Deceased"] [
      let trust-level-update 0
      ;; institutional influence with a lack of knowledge or difficulties understanding statistics
      ifelse misinterpret? [
        set trust-level-update (prop-X-V / 100) * -1 * (1 - trust-level)
      ]
      ;; institutional influence with complete knowledge and understanding of statistics
      [
        let prop-nX-X-V-difference (prop-nX-V - prop-X-V) / 100

        ifelse prop-nX-X-V-difference >= 0 [
          ;; positive information is attenuated (* 0.5)
          ;; non-trusting agents will tend to neglect the positive information
          set trust-level-update prop-nX-X-V-difference * 0.5 * trust-level
        ]
        [
          ;; trusting agents will tend to neglect the negative information
          set trust-level-update prop-nX-X-V-difference * (1 - trust-level)
        ]
      ]
      set trust-level trust-level + trust-level-update
      if trust-level < 0 [ set trust-level 0 ]
      if trust-level > 1 [ set trust-level 1 ]
    ]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; VACCINTAION STRATEGIES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to vaccinate-pop
  set max-nb-daily-vaccinations count target-population

  if
    ;; if not vaccination currently and proportion of infected above the threshold and there are people to vaccinate
    not on-going-vaccination? and
    any? target-population [
      ;; start a vaccination campaign
      set on-going-vaccination? true
      set nb-days-vaccination 0
  ]

    ;; if vaccination is on-going
  if on-going-vaccination? [

    ;; reset today vaccination counter
    set nb-vaccinations-today 0

    ;; are there people to vaccinate?
    ifelse any? target-population
    ;; continue the campaign
    [
      ;; vaccinate the target population
      ask up-to-n-of nb-daily-vaccinations target-population [ vaccinate-one ]
      set nb-days-vaccination nb-days-vaccination + 1
    ]
    ;; stop the campaign
    [
      ;set on-going-vaccination? false
      ;ask turtles with [vaccinated?] [
        ;set vaccinated? false
      ;]
    ]
  ]
end

to-report target-population
  report turtles with [not vaccinated? and (epidemic-state = "Susceptible" or epidemic-state = "Asymptomatic")]
end


;; called on each vaccinated citizen
to vaccinate-one
  ;; update agent
  if random-float 1 <= trust-level
  [
    get-vaccinated
    set nb-vaccinations-today nb-vaccinations-today + 1
  ]
end



;;;;;;;;;;;;;;;;;;;
;;;;; UPDATES ;;;;;
;;;;;;;;;;;;;;;;;;;

to update-states
  ;; go from infected to either hospitalised or recovered
  ask turtles with [epidemic-state = "Infected" and
                     ticks > infection-date + infection-duration] [
    let proba-hosp (ifelse-value
      vaccinated? [ probability-hospitalised-vaccinated ]
      [ probability-hospitalised ]
    )
    ; probability to be hospitalised
    ifelse random-float 1 < proba-hosp [
      get-hospitalised
      set nb-total-hospitalised nb-total-hospitalised + 1
      if vaccinated?
      [ set nb-total-hospitalised-vaccinated nb-total-hospitalised-vaccinated + 1 ]
    ]
    [ get-recovered ]
  ]
  ;; go from asymptomatic to either recovered
  ask turtles with [epidemic-state = "Asymptomatic" and
                     ticks > infection-date + infection-duration] [
    get-recovered
  ]
  ;; go from hospitalised to either deceased or recovered
  ask turtles with [epidemic-state = "Hospitalised" and
                     ticks > hospitalisation-date + hospitalisation-duration] [
    let proba-death (ifelse-value
      vaccinated? [ probability-deceased-vaccinated ]
      [ probability-deceased ]
    )
    ; probability to die or recover
    ifelse random-float 1 < proba-death
    [ get-deceased ]
    [ get-recovered ]
  ]
  ;; go from recovered to susceptible
  ask turtles with [epidemic-state = "Recovered" and
                    ticks > recovered-date + recovered-duration] [
    let proba-susc (ifelse-value
      vaccinated? [ probability-susceptible-vaccinated ]
      [ probability-susceptible ]
    )
    if random-float 1 < proba-susc
    [
      get-susceptible
      if vaccinated?
      [ get-unvaccinated ]
    ]
  ]
  ;; dispose of deceased turtles
  ask turtles with [epidemic-state = "Deceased" and
                    ticks - deceased-date < transparency] [
    let new-transparency (transparency - (ticks - deceased-date) * 10)
    if new-transparency < 0 [
      set new-transparency 0
    ]
    set color lput new-transparency color-deceased
  ]

  ask turtles with [vaccinated? and
                    ticks > vaccinated-date + vaccinated-duration] [
    get-unvaccinated
  ]
end

;; called in go at start of turn
to reset-counters
  set nb-new-infections 0
end


;; called in go after movement, transmission
to update-counters
  set total-nb-infected total-nb-infected + nb-new-infections
  set list-vaccinations lput nb-vaccinations-today list-vaccinations
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; EPIDEMIC STATES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; récapitule tous les états épidémiques et les variables agent associées
to get-susceptible
  set epidemic-state "Susceptible"
  set color lput transparency color-susceptible
  set infection-date infinity
  set infection-duration infinity
  set hospitalisation-date infinity
  set hospitalisation-duration infinity
  set recovered-date infinity
  set recovered-duration infinity
  set infected? false
  set speed initial-speed
end

to get-infected
  let proba-asymp (ifelse-value
    vaccinated? [ probability-asymptomatic-vaccinated ]
    [ probability-asymptomatic ]
  )
  ;; probability to be asymptomatic
  ifelse random-float 1 < proba-asymp
  [
    set epidemic-state "Asymptomatic"
    set color lput transparency color-asymptomatic
    set infection-duration gamma-law asymptomatic-mean asymptomatic-variance
  ]
  [
    set epidemic-state "Infected"
    set color lput transparency color-infected
    set infection-duration gamma-law infection-mean infection-variance
  ]
  set infection-date ticks
  set hospitalisation-date infinity
  set hospitalisation-duration infinity
  set recovered-date infinity
  set recovered-duration infinity
  set infected? true
  set speed initial-speed
end

to get-hospitalised
  set epidemic-state "Hospitalised"
  set color lput transparency color-hospitalised
  set hospitalisation-date ticks
  set hospitalisation-duration gamma-law hospitalisation-mean hospitalisation-variance
  set recovered-date infinity
  set recovered-duration infinity
  set infected? true
  set speed initial-speed / 50
  move-to-hospitalised-patch
end

to get-recovered
  if epidemic-state = "Hospitalised"
  [ move-to-random-outside-hospitalised-patch ]
  set epidemic-state "Recovered"
  set color lput transparency color-recovered
  set infection-date infinity
  set infection-duration infinity
  set hospitalisation-date infinity
  set hospitalisation-duration infinity
  set recovered-date ticks
  set recovered-duration gamma-law recovered-mean recovered-variance
  set infected? false
  set speed initial-speed
end

to get-deceased
  set epidemic-state "Deceased"
  set color lput transparency color-deceased
  set infection-duration infinity
  set hospitalisation-duration infinity
  set recovered-duration infinity
  set deceased-date ticks
  set infected? false
  set speed 0
  (ifelse
    not vaccinated? and trust-level < 0.5
    [ set nb-D-nV-nT nb-D-nV-nT + 1 ]
    not vaccinated? and trust-level > 0.5
    [ set nb-D-nV-T nb-D-nV-T + 1 ]
    vaccinated? and trust-level < 0.5
    [ set nb-D-V-nT nb-D-V-nT + 1 ]
    vaccinated? and trust-level > 0.5
    [ set nb-D-V-T nb-D-V-T + 1 ]
  )
  (ifelse
    not vaccinated? and not misinterpret?
    [ set nb-D-nV-nM nb-D-nV-nM + 1 ]
    not vaccinated? and misinterpret?
    [ set nb-D-nV-M nb-D-nV-M + 1 ]
    vaccinated? and not misinterpret?
    [ set nb-D-V-nM nb-D-V-nM + 1 ]
    vaccinated? and misinterpret?
    [ set nb-D-V-M nb-D-V-M + 1 ]
  )
end

to get-vaccinated
  set vaccinated? true
  set shape "triangle"
  set vaccinated-date ticks
  set vaccinated-duration gamma-law vaccinated-mean recovered-variance
end

to get-unvaccinated
  set vaccinated? false
  set shape "circle"
end



;;;;;;;;;;;;;;;;;;;;;
;;;;; REPORTERS ;;;;;
;;;;;;;;;;;;;;;;;;;;;

;;; UTILS ;;;

;; gamma law for all durations
to-report gamma-law [avg var]
  let alpha avg * avg / var
  let lambda avg / var
  report floor random-gamma alpha lambda
end

;; transform count numbers into proportions
to-report nb-to-prop [number pop-totale]
  ifelse pop-totale > 0
  [ report number / pop-totale * 100 ]
  [ report 0 ]
end


;;; TRUE VALUES ;;;

to-report nb-S
  report count turtles with [epidemic-state = "Susceptible"]
end

to-report nb-I
  report count turtles with [epidemic-state = "Infected"]
end

to-report nb-A
  report count turtles with [epidemic-state = "Asymptomatic"]
end

to-report nb-H
  report count turtles with [epidemic-state = "Hospitalised"]
end

to-report nb-H-nV
  report count turtles with [epidemic-state = "Hospitalised" and not vaccinated?]
end

to-report nb-H-V
  report count turtles with [epidemic-state = "Hospitalised" and vaccinated?]
end

to-report nb-H-nV-nT
  report count turtles with [epidemic-state = "Hospitalised" and not vaccinated? and trust-level < 0.5]
end

to-report nb-H-nV-T
  report count turtles with [epidemic-state = "Hospitalised" and not vaccinated? and trust-level > 0.5]
end

to-report nb-H-V-nT
  report count turtles with [epidemic-state = "Hospitalised" and vaccinated? and trust-level < 0.5]
end

to-report nb-H-V-T
  report count turtles with [epidemic-state = "Hospitalised" and vaccinated? and trust-level > 0.5]
end

to-report nb-R
  report count turtles with [epidemic-state = "Recovered"]
end

to-report nb-D
  report count turtles with [epidemic-state = "Deceased"]
end

to-report nb-D-nV
  report count turtles with [epidemic-state = "Deceased" and not vaccinated?]
end

to-report nb-D-V
  report count turtles with [epidemic-state = "Deceased" and vaccinated?]
end

to-report nb-D-nT
  report count turtles with [epidemic-state = "Deceased" and trust-level < 0.5]
end

to-report nb-D-T
  report count turtles with [epidemic-state = "Deceased" and trust-level > 0.5]
end

to-report nb-nV-nT
  report count turtles with [not vaccinated? and trust-level < 0.5]
end

to-report nb-nV-T
  report count turtles with [not vaccinated? and trust-level > 0.5]
end

to-report nb-V-nT
  report count turtles with [vaccinated? and trust-level < 0.5]
end

to-report nb-V-T
  report count turtles with [vaccinated? and trust-level > 0.5]
end

; boolean reporter
to-report virus-present?
  report nb-I > 0 or nb-A > 0 or nb-H > 0
end

to-report total-living-population
  report count turtles with [epidemic-state != "Deceased"]
end

to-report total-living-population-without-misinterpret
  report count turtles with [epidemic-state != "Deceased" and misinterpret? = false]
end

to-report total-living-population-misinterpret
  report count turtles with [epidemic-state != "Deceased" and misinterpret? = true]
end

to-report living-turtles
  report turtles with [epidemic-state != "Deceased"]
end

to-report total-vaccinations
  report count turtles with [vaccinated? and epidemic-state != "Deceased"]
end

to-report trust-average
  report sum [trust-level] of turtles with [epidemic-state != "Deceased"]
end

to-report trust-average-without-misinterpret
  report sum [trust-level] of turtles with [epidemic-state != "Deceased" and misinterpret? = false]
end

to-report trust-average-misinterpret
  report sum [trust-level] of turtles with [epidemic-state != "Deceased" and misinterpret? = true]
end

to-report nb-misinterpret
  report count living-turtles with [misinterpret?]
end
@#$#@#$#@
GRAPHICS-WINDOW
301
10
829
539
-1
-1
40.0
1
10
1
1
1
0
0
0
1
-6
6
-6
6
1
1
1
ticks
30.0

TEXTBOX
14
10
283
100
Pour lancer une simulation:\n 1 - Ajuster le niveau de confiance moyen \n      initial de la population\n 2 - Cliquer sur \"Initialiser\"\n 3 - Cliquer sur \"Simuler\"\n\n
12
15.0
1

BUTTON
11
157
140
194
Initialiser
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
154
157
283
194
Simuler
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
847
10
1363
242
Dynamique épidémique
Jours
% cas
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Infectés" 1.0 0 -16777216 true "" "set-plot-pen-color color-infected plot nb-to-prop nb-I population-size"
"Asymptomatiques" 1.0 0 -16777216 true "" "set-plot-pen-color color-asymptomatic plot nb-to-prop nb-A population-size"
"Hospitalisés" 1.0 0 -16777216 true "" "set-plot-pen-color color-hospitalised plot nb-to-prop nb-H population-size"
"Guéris" 1.0 0 -16777216 true "" "set-plot-pen-color color-recovered plot nb-to-prop nb-R population-size"
"Décédés" 1.0 0 -16777216 true "" "set-plot-pen-color color-deceased plot nb-to-prop nb-D population-size"
"Vaccinés" 1.0 0 -16777216 true "" "set-plot-pen-color color-vaccinated plot nb-to-prop total-vaccinations population-size"
"Confiance" 1.0 0 -16777216 true "" "set-plot-pen-color color-trust-level plot nb-to-prop trust-average total-living-population"

PLOT
847
242
1363
474
Niveau de confiance par statut de mésinterprétation
Temps
%
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Interprétation correcte" 1.0 0 -16777216 true "" "set-plot-pen-color color-trust-level plot nb-to-prop trust-average-without-misinterpret total-living-population-without-misinterpret"
"Interprétation incorrecte" 1.0 0 -16777216 true "" "set-plot-pen-color color-misinterpret plot nb-to-prop trust-average-misinterpret total-living-population-misinterpret"

PLOT
847
474
1363
706
Décès par état de vaccination et statut de mésinterprétation
Temps
Nombre de décès
0.0
100.0
0.0
5.0
true
true
"" ""
PENS
"Non-vaccinés et interprétation correcte" 1.0 0 -16777216 true "" "set-plot-pen-color color-D-nV-nM plot nb-D-nV-nM"
"Non-vaccinés et interprétation incorrecte" 1.0 0 -16777216 true "" "set-plot-pen-color color-D-nV-M plot nb-D-nV-M"
"Vaccinés et interprétation correcte" 1.0 0 -16777216 true "" "set-plot-pen-color color-D-V-nM plot nb-D-V-nM"
"Vaccinés et interprétation incorrecte" 1.0 0 -16777216 true "" "set-plot-pen-color color-D-V-M plot nb-D-V-M"

SLIDER
11
113
283
146
niveau-de-confiance-initial
niveau-de-confiance-initial
0.1
0.9
0.5
0.1
1
NIL
HORIZONTAL

TEXTBOX
14
223
283
343
Légende des couleurs :\n- bleu    = susceptible\n- jaune  = infecté\n- gris     = asymptomatique\n- rouge = hospitalisé\n- vert     = guéri\n- noir     = décédé
12
15.0
1

TEXTBOX
14
356
283
401
Légende des formes :\n- rond      = non-vacciné\n- triangle = vacciné
12
15.0
1

@#$#@#$#@
## Description

Ce modèle est un outil pédagogique qui permet d'explorer, à travers une simulation, l'influence de la confiance sur la vaccination suivant différent scénarios adaptable par l'utilisateur.


## Fonctionnalité

L'utilisateur choisi un niveau pour les paramètre de la dangerosité du virus, de l'efficacité du vaccin et de la confiance moyenne initiale de la population.
Il peut également choisir d'activer ou non la mauvaise interprétation des informations institutionnelles par la population.

Une fois le choix des paramètres terminé, l'utilisateur initialise le simulateur en cliquant sur "Initialiser" et lance la simulation en cliquant sur "Simuler".


## CREDITS AND REFERENCES

Modèle développé par Calvin Massonnet dans la continuité des projets du site https://covprehension.org/ et financé par le projet MODCOV19 du CNRS.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

circle white
false
0
Circle -7500403 true true 0 0 300
Circle -1 true false 30 30 240

computer workstation
false
0
Rectangle -7500403 true true 60 45 240 180
Polygon -7500403 true true 90 180 105 195 135 195 135 210 165 210 165 195 195 195 210 180
Rectangle -16777216 true false 75 60 225 165
Rectangle -7500403 true true 45 210 255 255
Rectangle -10899396 true false 249 223 237 217
Line -16777216 false 60 225 120 225

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

sploch
true
0
Polygon -2674135 true false 60 105 45 60 90 75 120 15 150 90 240 45 240 90 285 165 210 225 210 165 180 195 165 255 135 240 135 180 45 225 120 120 30 135

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="misinterpretation" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>nb-D-nV-nM</metric>
    <metric>nb-D-nV-M</metric>
    <metric>nb-D-V-nM</metric>
    <metric>nb-D-V-M</metric>
    <metric>nb-to-prop trust-average-without-misinterpret total-living-population-without-misinterpret</metric>
    <metric>nb-to-prop trust-average-misinterpret total-living-population-misinterpret</metric>
    <steppedValueSet variable="niveau-de-confiance-initial" first="0.1" step="0.1" last="0.9"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
