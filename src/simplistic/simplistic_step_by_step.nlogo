; adapted from Q17: Dépistons ! Oui mais qui, quand et comment ?
; Calvin Massonnet

; adapted from Q3: simulateur central
; Carole et Helene

;__includes [ "headless.nls" ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; GLOBAL VARIABLES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [
  ;; GUI variables
  virus-type
  vaccine-type
  percentage-initialy-vaccinated ;; initial percentage of vaccinated agents
  vaccination-threshold     ;; when to start a screening campaign
  percentage-daily-vaccinations
  initial-trust-level
  use-trust-level?
  is-initial-trust-average?
  enable-contact-trust-influence?
  enable-asymptomatic?
  enable-observation-trust-influence?
  information-type ;; type of the information spread among [1. None, 2. Positive, 3. Negative]
  enable-limited-natural-immunity?
  enable-limited-vaccination-immunity?

  current-trust-average
  current-trust-average-count

  population-size
  nb-infected-initialisation ;; initial number of sick agents
  nb-initialy-vaccinated ;; initial number of vaccinated agents
  nb-daily-vaccinations ;; number of daily vaccinated agents
  probability-transmission ;; probability that an infected agent will infect a neighbour on same patch
  probability-reinfection ;; probability that a susceptible agent previously infected gets infected again
  probability-asymptomatic ;; probability that a susceptible agent will get to an asymptomatic state
  probability-hospitalised ;; probability for an infected agent to get to a hospitalised state
  probability-deceased ;; probability for an hospitalised agent to get to a deceased state
  probability-susceptible ;; probability for a recovered agent to get to a recovered state
  probability-transmission-vaccinated ;; probability that an infected agent will infect a vacinated neighbour on same patch
  probability-reinfection-vaccinated ;; probability that a vaccinated susceptible agent previously infected gets infected again
  probability-asymptomatic-vaccinated ;; probability for a susceptible agent to get to a asymptomatic state
  probability-hospitalised-vaccinated ;; probability for a vacinated infected agent to get to a hospitalised state
  probability-deceased-vaccinated ;; probability for a vacinated hospitalised agent to get to a deceased state
  probability-susceptible-vaccinated ;; probability for a vaccinated recovered agent to get to a recovered state

  ;; movement
  initial-speed

  min-x-hospitalised-patch
  max-x-hospitalised-patch
  min-y-hospitalised-patch
  max-y-hospitalised-patch

  infinity ;; default value for durations not in use

  ;; new globals pour dépistage
  on-going-vaccination? ;; is there a vaccination campaign currently
  nb-days-vaccination   ;; number of days elapsed since the beginning of the vaccination campaign
;  nb-campaigns      ;; number of vaccination campaigns
  nb-vaccinations-today
  list-vaccinations        ;; remember %vaccinated each day

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

  ;; metrics
  nb-new-infections
  total-nb-infected

  ;; colors
  color-susceptible
  color-infected
  color-asymptomatic
  color-hospitalised
  color-recovered
  color-deceased
  color-vaccinated
  color-trust-level
  transparency
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; AGENTS AND THEIR VARIABLES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

turtles-own [
  epidemic-state      ;; state of the agent among [Susceptible, Infected, Asymptomatic, Hospitalised, Recovered, Deceased]
  infection-date      ;; ticks when got infected
  infection-duration
  hospitalisation-date   ;; ticks when got hospitalised
  hospitalisation-duration
  recovered-date   ;; ticks when got recovered
  recovered-duration
  deceased-date   ;; ticks when died
  infected?           ;; shortcut for Infected

  previously-infected?  ;; was previously infected
  previously-vaccinated?  ;; was previously vaccinated

  ; demographics
  vaccinated?     ;; was already vaccinated

  trust-level     ;; level of trust normalised between 0.0 and 1.0

  ;; movement
  speed
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
  set virus-type variant-covid-19
  set vaccine-type vaccin-covid-19
  set percentage-initialy-vaccinated pourcentage-vaccinations-initial
  set vaccination-threshold seuil-infectes-debut-vaccination
  set percentage-daily-vaccinations pourcentage-vaccinations-quotidiens
  set initial-trust-level niveau-de-confiance
  set use-trust-level? activer-niveau-de-confiance?
  set is-initial-trust-average? activer-niveau-de-confiance-moyen?
  set enable-contact-trust-influence? activer-influence-par-contact?
  set enable-asymptomatic? activer-infection-asymptomatique?
  set enable-observation-trust-influence? activer-influence-par-observation?
  set information-type type-information-diffusée
  set enable-limited-natural-immunity? activer-immunite-naturelle-limitee?
  set enable-limited-vaccination-immunity? activer-immunite-vaccination-limitee?
end


;; generic setup
to setup-globals
  set current-trust-average initial-trust-level
  set current-trust-average 0

  set infinity 99999
  set population-size 2000
  set nb-infected-initialisation 1
  set nb-initialy-vaccinated (percentage-initialy-vaccinated * population-size / 100)
  set nb-daily-vaccinations (percentage-daily-vaccinations * population-size / 100)

  (ifelse
    member? "Alpha" virus-type [
      ; TODO
    ]
    member? "Beta" virus-type [
      ; TODO
    ]
    member? "Delta" virus-type [
      set probability-transmission 0.3 ; https://covidtracker.fr/covidtracker-world/ - October 4th 2021
      set probability-reinfection 0.098 ; https://www.nejm.org/doi/full/10.1056/NEJMc2200133
      set probability-asymptomatic 0.2435 ; https://academic.oup.com/jtm/article/27/5/taaa066/5828924
      set probability-hospitalised 0.2 ; TODO
      set probability-deceased 0.15 ; TODO
      set probability-susceptible 0.15 ; TODO
      (ifelse
        member? "AstraZeneca" vaccine-type [
          ; TODO
        ]
        member? "Johnson" vaccine-type [
          ; https://www.nejm.org/doi/full/10.1056/NEJMoa2117128
          ;; for 2 vaccine shots
          set probability-transmission-vaccinated 0.252
          set probability-reinfection-vaccinated 0.21 ; TODO
          set probability-asymptomatic-vaccinated 0.1 ; TODO
          set probability-hospitalised-vaccinated 0.142
          set probability-deceased-vaccinated 0.141
          set probability-susceptible-vaccinated 0.6 ; TODO
        ]
        member? "Moderna" vaccine-type [
          ; https://www.nejm.org/doi/full/10.1056/NEJMoa2117128
          ;; for 2 vaccine shots
          set probability-transmission-vaccinated 0.041
          set probability-reinfection-vaccinated 0.01 ; TODO
          set probability-asymptomatic-vaccinated 0.5 ; TODO
          set probability-hospitalised-vaccinated 0.028
          set probability-deceased-vaccinated 0.014
          set probability-susceptible-vaccinated 0.3 ; TODO
        ]
        member? "Pfizer" vaccine-type [
          ; https://www.nejm.org/doi/full/10.1056/NEJMoa2117128
          ;; for 2 vaccine shots
          set probability-transmission-vaccinated 0.055
          set probability-reinfection-vaccinated 0.02 ; TODO
          set probability-asymptomatic-vaccinated 0.16 ; TODO
          set probability-hospitalised-vaccinated 0.036
          set probability-deceased-vaccinated 0.02 ; https://www.nejm.org/doi/full/10.1056/NEJMoa2115624
          set probability-susceptible-vaccinated 0.4 ; TODO
        ]
      )
    ]
    member? "Gamma" virus-type [
      ; TODO
    ]
    member? "Omicron" virus-type [
      ; TODO
    ]
  )

  ; TODO - change to real value
  ;; duration of infection (random-gamma init)
  set infection-mean 21
  set infection-variance 1

  ; TODO - change to real value
  ;; duration of asymptomatic infection (random-gamma init)
  set asymptomatic-mean 15
  set asymptomatic-variance 2

  ;; https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7589278/
  ;; duration of hospitalisation (random-gamma init)
  set hospitalisation-mean 10
  set hospitalisation-variance 3

  ; TODO - change to real value
  ;; duration of recovered (random-gamma init)
  set recovered-mean 6
  set recovered-variance 1

  ;; movement
  set initial-speed 1

  set min-x-hospitalised-patch -6
  set max-x-hospitalised-patch -5
  set min-y-hospitalised-patch 5
  set max-y-hospitalised-patch 6

  ;; vaccinations counters
  set on-going-vaccination? false
  set nb-days-vaccination 0
;  set nb-campaigns 0
  set nb-vaccinations-today 0
  set list-vaccinations []

  ;; metrics
  set total-nb-infected 0

  ;; colors
  set color-susceptible [0 153 255]
  set color-infected [254 178 76]
  set color-asymptomatic [178 178 178]
  set color-hospitalised [255 0 0]
  set color-recovered [0 255 0]
  set color-deceased [0 0 0]
  set color-vaccinated [255 153 255]
  set color-trust-level [0 0 255]
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
    set previously-infected? false
    set vaccinated? false
    set previously-vaccinated? false

    set speed initial-speed
  ]

  setup-population-trust-level

  ; set some agents to be initially infected to start the epidemics
  ask n-of nb-infected-initialisation turtles [ get-infected ]
  ; set some agents to be initially vaccinated to start the epidemics
  ask n-of nb-initialy-vaccinated turtles [ get-vaccinated ]
end


;; initialisation of agents' trust level
to setup-population-trust-level
  ask turtles
  [
    ;; if initial trust level in population is an average
    ifelse is-initial-trust-average?
    [
      (ifelse
        ;; if current average of population trust is below initial trust level
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
        ;; if current average of population trust is above initial trust level
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
    ;; if initial trust level in population is not an average
    [
      ;; all agents have the same trust level
      set trust-level initial-trust-level
    ]
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
    move-alive
    virus-transmission
    trust-influence
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

to-report heading-in-hopitalised-patch [my-speed]
  let ahead-x 0
  let ahead-y 0
  ask patch-ahead my-speed [
    set ahead-x pxcor
    set ahead-y pycor
  ]
  report
    ahead-x > min-x-hospitalised-patch - 2 and
    ahead-x < max-x-hospitalised-patch + 2 and
    ahead-y > min-y-hospitalised-patch - 2 and
    ahead-y < max-y-hospitalised-patch + 2
end

to move-to-hospitalised-patch
  let x min-x-hospitalised-patch + (random (max-x-hospitalised-patch - min-x-hospitalised-patch + 1))
  let y min-y-hospitalised-patch + (random (max-y-hospitalised-patch - min-y-hospitalised-patch + 1))
  set x x + 0.5 - (random-float 1)
  set y y + 0.5 - (random-float 1)
  setxy x y
end

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

to move-randomly [my-speed]
  set heading random 360
  ifelse epidemic-state = "Hospitalised"
  [
    ;; stay in patch 0 0
    if heading-in-hopitalised-patch my-speed
    [
      forward my-speed
    ]
  ]
  [
    ;; avoid patch 0 0
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
    ask other turtles-here with [epidemic-state = "Susceptible"] [
      ;; use a different transmission probability depending on agent's state
      let proba-trans (ifelse-value
        previously-infected? [ probability-reinfection ]
        previously-vaccinated? and not previously-infected? [ probability-transmission-vaccinated ]
        [ probability-transmission ]
      )
      ;; each contact can infect
      if random-float 1 < proba-trans [ get-infected ]
    ]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; TRUST INFLUENCE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

to trust-influence
  if ticks mod 5 = 0 [
    contact-trust-influence
    observation-trust-influence
  ]
end

to contact-trust-influence
  if enable-contact-trust-influence?
  [
    ask turtles with [epidemic-state != "Deceased"] [
      let contact-trust-level trust-level
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
            contact-trust-level < 0.5
            [
              ;; contact trust level of 0.0 has an intensity of 1
              let contact-influence-intensity 1 - (contact-trust-level / 0.5)
              ;; high effectiveness on trust level 0.0 (low on 1.0)
              let influence-effectiveness 1 - trust-level
              let contact-influence contact-influence-intensity * influence-effectiveness
              set trust-level trust-level - contact-influence
              if trust-level < 0 [ set trust-level 0 ]
            ]
            contact-trust-level > 0.5
            [
              ;; contact trust level of 1.0 has an intensity of 1
              let contact-influence-intensity (contact-trust-level / 0.5) - 1
              ;; high effectiveness on trust level 1.0 (low on 0.0)
              let influence-effectiveness trust-level
              let contact-influence contact-influence-intensity * influence-effectiveness
              set trust-level trust-level + contact-influence
              if trust-level > 1 [ set trust-level 1 ]
            ]
            ;; else contact-trust-level == 0.5
            ;; contact trust level of 0.5 has an intensity of 0
          )
        ]
      ]
    ]
  ]
end

to observation-trust-influence
  if enable-observation-trust-influence? and on-going-vaccination?
  [
    ask turtles with [epidemic-state != "Deceased"] [
      let observer-update 0
      ask other turtles in-radius 0.5 with [epidemic-state != "Deceased"] [
        let is-other-vaccinated? vaccinated?
        let is-other-symptomatic? ((epidemic-state = "Infected") or (epidemic-state = "Hospitalised"))
        ; TODO - to justify (0.01, 0.01, 0.03, 0.05)
        ;; negative information have more impact than positive information
        ;; https://onlinelibrary.wiley.com/doi/abs/10.1111/0272-4332.00030
        (ifelse
          (not is-other-vaccinated?) and (not is-other-symptomatic?)
          [
            ;; negative information
            set observer-update observer-update - (0.01 * (1 - trust-level))
          ]
          (not is-other-vaccinated?) and is-other-symptomatic?
          [
            ;; positive information
            set observer-update observer-update + (0.01 * trust-level)
          ]
          is-other-vaccinated? and (not is-other-symptomatic?)
          [
            ;; positive information
            set observer-update observer-update + (0.03 * trust-level)
          ]
          is-other-vaccinated? and is-other-symptomatic?
          [
            ;; negative information
            set observer-update observer-update - (0.05 * (1 - trust-level))
          ]
        )
      ]
      set trust-level trust-level + observer-update
      if trust-level < 0 [ set trust-level 0 ]
      if trust-level > 1 [ set trust-level 1 ]
    ]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; VACCINTAION STRATEGIES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to vaccinate-pop
  if
    ;; if not vaccination currently and proportion of infected above the threshold and there are people to vaccinate
    not on-going-vaccination? and
    (nb-to-prop nb-I population-size) > vaccination-threshold and
    any? target-population [
      ;; start a vaccination campaign
      set on-going-vaccination? true
;      set nb-campaigns nb-campaigns + 1
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
  report turtles with [not vaccinated? and (epidemic-state != "Susceptible" or epidemic-state != "Asymptomatic")]
end


;; called on each vaccinated citizen
to vaccinate-one
  ;; update agent
  ifelse use-trust-level?
  [
    if random-float 1 < trust-level
    [
      get-vaccinated
      set nb-vaccinations-today nb-vaccinations-today + 1
    ]
  ]
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
    ifelse random-float 1 < proba-hosp
    [ get-hospitalised ]
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
  if enable-limited-natural-immunity? or enable-limited-vaccination-immunity?
  [
    ask turtles with [epidemic-state = "Recovered" and
                      ticks > recovered-date + recovered-duration] [
      let proba-susc (ifelse-value
        enable-limited-vaccination-immunity? and vaccinated? [ probability-susceptible-vaccinated ]
        enable-limited-natural-immunity? [ probability-susceptible ]
        [ -1 ]
      )
      if random-float 1 < proba-susc
      [
        get-susceptible
        if enable-limited-vaccination-immunity? and vaccinated?
        [ get-unvaccinated ]
      ]
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
    enable-asymptomatic? and vaccinated? [ probability-asymptomatic-vaccinated ]
    enable-asymptomatic? and not vaccinated? [ probability-asymptomatic ]
    [ -1 ]
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
  set previously-infected? true
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
end

to get-vaccinated
  set vaccinated? true
  set previously-vaccinated? true
  set shape "triangle"
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

to-report nb-R
  report count turtles with [epidemic-state = "Recovered"]
end

to-report nb-D
  report count turtles with [epidemic-state = "Deceased"]
end

; boolean reporter
to-report virus-present?
  report nb-I > 0 or nb-H > 0
end

to-report total-vaccinations
  report count turtles with [vaccinated?]
end

to-report trust-average
  report sum [trust-level] of turtles
end
@#$#@#$#@
GRAPHICS-WINDOW
553
117
1081
646
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
260
111
Pour lancer une simulation:\n1 - Choisir un variant du virus et un vaccin\n2 - Ajuster les paramètres nécessaires\n3 - Cliquer sur \"Initialiser\"\n4 - Cliquer sur \"Simuler\"\n\n
12
15.0
1

BUTTON
317
118
413
155
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
426
118
520
155
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
554
721
1070
946
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
"Confiance" 1.0 0 -16777216 true "" "set-plot-pen-color color-trust-level plot nb-to-prop trust-average population-size"

PLOT
1099
117
1615
349
Répartition de la confiance
Niveau de confiance
Nombre d'agent
0.0
2000.0
0.0
1.0
false
false
"set-plot-x-range 0 1\n set-plot-y-range 0 100\n set-histogram-num-bars 200" ""
PENS
"turtles" 1 1 -2674135 true "" "histogram [trust-level] of turtles"

PLOT
1099
349
1615
581
Influence de la confiance
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
"Vaccinés" 1.0 0 -16777216 true "" "set-plot-pen-color color-vaccinated plot nb-to-prop nb-vaccinations-today nb-daily-vaccinations"
"Confiance" 1.0 0 -16777216 true "" "set-plot-pen-color color-trust-level plot nb-to-prop trust-average population-size"

PLOT
1099
581
1615
813
Hospitalisation
Temps
Nombre d'hospitalisé
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Non-vaccinés" 1.0 0 -16777216 true "" "set-plot-pen-color color-hospitalised plot nb-H-nV"
"Vaccinés" 1.0 0 -16777216 true "" "set-plot-pen-color color-vaccinated plot nb-H-V"

CHOOSER
11
118
283
163
Variant-COVID-19
Variant-COVID-19
"Delta"
0

CHOOSER
11
175
283
220
Vaccin-COVID-19
Vaccin-COVID-19
"Johnson&Johnson (2 doses)" "Moderna (2 doses)" "Pfizer (2 doses)"
0

TEXTBOX
11
243
283
273
1.1 Efficacité de la vaccination (statique)
12
15.0
1

SLIDER
11
264
283
297
pourcentage-vaccinations-initial
pourcentage-vaccinations-initial
0
100
0.0
1
1
%
HORIZONTAL

TEXTBOX
11
317
283
347
1.2 Efficacité de la vaccination (dynamique)
12
15.0
1

SLIDER
11
336
283
369
seuil-infectes-debut-vaccination
seuil-infectes-debut-vaccination
0
100
0.0
1
1
%
HORIZONTAL

SLIDER
11
369
283
402
pourcentage-vaccinations-quotidiens
pourcentage-vaccinations-quotidiens
0
10
0.0
0.1
1
%
HORIZONTAL

TEXTBOX
11
422
283
452
2.1 Confiance de la population (statique)
12
15.0
1

SWITCH
11
441
283
474
activer-niveau-de-confiance?
activer-niveau-de-confiance?
1
1
-1000

SLIDER
11
474
283
507
niveau-de-confiance
niveau-de-confiance
0
1
0.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
11
527
383
557
2.2 Confiance de la population (dynamique - par contact)
12
15.0
1

SWITCH
11
546
283
579
activer-niveau-de-confiance-moyen?
activer-niveau-de-confiance-moyen?
1
1
-1000

SWITCH
11
579
283
612
activer-influence-par-contact?
activer-influence-par-contact?
1
1
-1000

TEXTBOX
11
632
383
662
2.3 Confiance de la population (dynamique - par observation)
12
15.0
1

SWITCH
11
651
283
684
activer-infection-asymptomatique?
activer-infection-asymptomatique?
1
1
-1000

SWITCH
11
684
283
717
activer-influence-par-observation?
activer-influence-par-observation?
1
1
-1000

CHOOSER
11
717
283
762
type-information-diffusée
type-information-diffusée
"1. Aucune" "2. Positive uniquement" "3. Négative uniquement"
0

TEXTBOX
11
782
383
812
3 Immunité naturelle limitée
12
15.0
1

SWITCH
11
803
283
836
activer-immunite-naturelle-limitee?
activer-immunite-naturelle-limitee?
1
1
-1000

TEXTBOX
11
856
383
886
4 Immunité de la vaccination limitée
12
15.0
1

SWITCH
11
877
283
910
activer-immunite-vaccination-limitee?
activer-immunite-vaccination-limitee?
1
1
-1000

MONITOR
554
662
682
707
nb de jours de vaccinations
nb-days-vaccination
17
1
11

MONITOR
690
662
852
707
nb total de vaccinations effectuées
total-vaccinations
17
1
11

MONITOR
861
662
996
707
% personnes guéries
nb-to-prop nb-R population-size
2
1
11

TEXTBOX
559
10
725
110
Légende des couleurs :\n- bleu = susceptible\n- jaune = infecté\n- gris = asymptomatique\n- rouge = hospitalisé\n- vert = guéri\n- noir = décédé
12
15.0
1

TEXTBOX
750
10
900
55
Légende des formes :\n- rond = non-vacciné\n- triangle = vacciné
12
15.0
1

@#$#@#$#@
## Qu'est-ce que c'est ?

Ce modèle propose d'explorer différents processus liés à la diffusion d'un virus dans une population d'individus sains et non immunisés. Les guérisons et décés ne sont pas pris en compte.

## Comment ça marche ?

Il suffit de choisir une simulation dans le menu déroulant, de l'initialiser (bouton "Prêt ?" et de la lancer (bouton "Partez!")


## CREDITS AND REFERENCES

Modèle développé par Arnaud Banos pour le site https://covprehension.org/
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
