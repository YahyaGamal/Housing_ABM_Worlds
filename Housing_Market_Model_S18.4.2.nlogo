extensions [palette import-a fetch]
globals[
  setup?              ; at setup phase or not

  interestPerTick     ; interest rate, after cyclical variation has been applied; depends on interest rate and ticks per year
  medianPriceOfHousesForSale ;; median Price Of Houses For Sale
  medianPriceOfHousesForRent ;; median Price Of Houses For Rent

  nupShocked
  ndownShocked
  nUpshockedSell          ; number of owners putting their house for sale because their income has risen
  nDownshockedSell        ; number of owners putting their house for sale because their income has dropped
  nUpshockedRent          ; number of owners putting their house for rent because their income has risen
  nDownshockedRent        ; number of owners putting their house for rent because their income has dropped

  nDiscouraged        ;; number of owners who discouraged by homeless and leave the city
  nExit               ;; number of owners who naturally leave the city or cease to exist
  nEntry              ;; number of owners who naturally enter or born into the city
  moves               ; number of households moving in this step
  nDemolished

  nForceOutSell           ;; number of owners whose repayment is greater than income and force to leave
  nOwnersOffered      ;; number of owners who made an offer on a house (have enough money and have target to buy)
  meanIncomeForceOutSell  ;; cal the mean income of all owners who are forced out due to low income to repay mortgage
  nForceOutRent           ;; number of owners whose repayment is greater than income and force to leave
  meanIncomeForceOutRent  ;; cal the mean income of all owners who are forced out due to low income to repay mortgage
  nForceInSell
  meanIncomeForceInSell


  nEvictedMortgage           ;; number of evicted owners of type mortgage
  nEvictedRent               ;; number of evicted owners of type rent
  nEnterMarketMortgage       ;; number of owners entering the mortgage market
  nEnterMarketRent           ;; number of owners entering the rent market
  nEnterMarketBuyToLet       ;; number of owners entering the buy-to-let market
  nForceSell                 ;; number of owners forced to put one of their houses on the buy-to-let market
  meanIncomeEvictedMortgage  ;; mean income of evicted owners of type mortgage
  meanIncomeEvictedRent      ;; mean income of evicted owners of type rent

  nEvictedMortgageOneHouse
  nEvictedMortgageMoreHouses

  nHomeless                  ;; number of owners evicted from their houses (does not include owners coming into the system as immigrants)

  visualiseModeCurrent       ;; current used visualisation mode used (prices or types)

  ;; globals added for simplified UI
  medianSalePriceHouses
  medianRentPriceRentHouses
  setup-a
  setup-b

  ;; added for the simplified UI ABM
  ActWhenShocked
  Affordability
  BuyerSearchLength
  calculate-wealth?
  CapitalMortgage
  CapitalRent
  clusteringRepeat
  cooldownPeriodBTL
  cooldownPeriodMortgage
  CycleStrength
  Density
  EntryRate
  eviction-threshold-mortgage
  eviction-threshold-rent
  ExitRate
  FullyPaidMortgageOwners
  HouseConstructionRate
  HouseMeanLifetime
  income-shock
  InitialGeography
  Initialisation
  initialOccupancy
  investors


  Locality
  MaxForRentPeriodPoorLandlord
  MaxHomelessPeriod

  MaxRateDurationBTL
  MaxRateDurationM

  min-price-fraction
  MinRateDurationBTL
  MinRateDurationM



  new-owner-type
  nRealtors

  onMarketPeriodBTL
  onMarketPeriodMortgage
  Override-Income-Capital
  Owned-Rent-Percentage

  price-difference
  PriceDropRate

  RealtorMemory
  RealtorOptimism
  RealtorTerritory
  rent-difference
  RentDropRate
  Savings
  SavingsRent
  savings-to-rent-threshold
  scenario
  Shocked
  shock-frequency

  TicksPerYear
  upgrade-tenancy


]

breed [houses house ]      ; a house, may be occupied or not, and may be for sale/mortgage or for rent
breed [owners owner ]      ; a household, may be living in a house, or may be seeking one
breed [realtors realtor ]  ; an estate agent
breed [records record ]    ; a record of a sale, kept by realtors

houses-own[
  myType              ; type of house; owned or rented; can be others as well
  local-realtors      ; the local realtors of the house
  local-sales         ; the records for the sale transactions of houses in the intersection of the locality of self and realtor
  local-rents         ; the records for the rent transactions of houses in the intersection of the locality of self and realtor
  locality-houses     ; the houses in my own locality (an agentset)
  end-of-life         ; time step when this house will be demolished
  for-sale?           ; whether this house is currently for sale or rent
  for-rent?           ; whether this house is currently for rent
  on-market-period    ; time the house has been on the market
  date-for-sale       ; when the house was put on the market for sale
  date-for-rent       ; when the house was put on the market for rent
  my-owner            ; the owner of this house; owner may not be living in the house if it is rented
  sale-price          ; the price of this house (either now, or when last sold); price sold and rented
  rent-price          ; the rent price of this house
  quality             ; index of quality of this house relative to its neighbours
  my-realtor          ; if for sale/rent, which realtor is selling it
  offered-to          ; which owner has already made an offer for this house
  offer-date          ; date of the offer (in ticks)
  rented-to           ; which renter has already made an offer for this house
  rent-date           ; date of the rent offer (in ticks)
  my-occupier         ; the individual that lives here; can be the owner or the renter
  diversity           ; the diversity index of the house (only used for visualisation)
  G                   ; Getis-Ord z-score for the hotspot analysis
]

owners-own[
  my-house            ; the house which this owner owns/rents
  income              ; current income from work per year (this is the ONLY yearly measure)
  income-rent         ; income from rent per tick
  income-surplus      ; residual income after spending on housing commodities
  surplus-rent        ; residual rent for each house after deducing its repayment
  mortgage            ; value of mortgage - reduces as it is paid off
  mortgage-initial    ; value of initial mortgage (does not decrease every tick)
  mortgage-duration   ; the remaining time on the mortgage
  rate                ; the yearly interest rate of the currently aggreed mortgage
  rate-duration       ; the remaining years on the current rate (at the end updates)
  capital             ; capital that I have accumulated from selling my house
  wealth              ; capital + sale-prices of houses - mortgages
  repayment           ; my mortgage repayment amount, at each tick
  my-rent             ; rent at each tick
  homeless            ; count of the number of periods that this owner has been without a house
  myType              ; type of owner, 1 for owned and 0 for rented
  made-offer-on       ; house that this owner wants to buy/rent
  date-of-acquire     ; when my-house was bought/rented
  my-ownership        ; houses I own
  on-market?          ; currently on the market or not (myType depicts the type of the market I use)
  on-market-type      ; type of market a buyer is on now
  time-on-market      ; number of ticks a buyer has been on the market
  on-cooldown?        ; whether the owner is in the cooldown period or not (cooldown occurs after an owner gets discouraged from the BTL market)
  on-cooldown-type    ; type of market from which the owner is on cooldown ("mortgage" or "buy-to-let")
  time-on-cooldown    ; the number of ticks the owner has been on cooldown
  propensity          ; the probability I will invest in housing
]

realtors-own[
  my-houses-rent           ; the houses in my territory for rent
  sales-rent               ; the last few house for rent that I have made
  my-houses-sold           ; the houses in my territory for sale
  sales-sold               ; the last few house sales that I have made
  average-price       ; the average price (sale) of a house in my territory
  average-rent        ; the average rent of a house in my territory
]

records-own[
  the-house           ; the house that was sold or rented
  selling-price       ; the selling price
  ;;YG
  renting-price       ; the renting price
  date                ; the date of the transaction (in ticks)
  filed-at-houses     ; houses that filed the record
]

to reset
   ; baseline


  set ActWhenShocked false
  set Affordability 33
  set BuyerSearchLength 5
  set calculate-wealth? true
  set CapitalMortgage 100
  set CapitalRent 50
  set clusteringRepeat 3
  set cooldownPeriodBTL 6
  set cooldownPeriodMortgage 6
  set CycleStrength 0
  set Density 70
  set EntryRate 4
  set eviction-threshold-mortgage 2
  set eviction-threshold-rent 1
  set ExitRate 2
  set FullyPaidMortgageOwners 0
  set HouseConstructionRate 0.36
  set HouseMeanLifetime 100
  set income-shock 20
  set InitialGeography "Random"
  set Initialisation "repayment--> mortgage--> price"
  set initialOccupancy 0.95
  set InterestRate 3.7
  set investorspercentage 20
  set Locality 3
  set MaxForRentPeriodPoorLandlord 4
  set MaxHomelessPeriod 7
  set MaxLoanToValue 90
  set MaxRateDurationBTL 5
  set MaxRateDurationM 5
  set MeanIncome 30000
  set min-price-fraction 0.2
  set MinRateDurationBTL 2
  set MinRateDurationM 2
  set mInterest 8
  set MortgageDuration 25
  set mYear 100
  set new-owner-type "random"
  set nRealtors 6
  set nYears 300
  set onMarketPeriodBTL 1
  set onMarketPeriodMortgage 1
  set Override-Income-Capital false
  set Owned-Rent-Percentage 50
  set pLTV 90
  set price-difference 5000
  set PriceDropRate 3
  set RealtorMemory 10
  set RealtorOptimism 3
  set RealtorTerritory 16
  set rent-difference 500
  set RentDropRate 3
  set Savings 20
  set SavingsRent 5
  set savings-to-rent-threshold 5
  set scenario "base-line"
  set Shocked 20
  set shock-frequency 0
  set StampDuty? false
  set TicksPerYear 4
  set upgrade-tenancy 0
  set VisualiseMode "Prices"
  set WageRise 0

end

to setup
  clear-all
  reset-ticks
  reset

  ; identify the current state of the model is initialisation
  set setup? true

  ; yearly interest rate is converted to interest per tick to be used to calculate finances of the owners at the setup
  set interestPerTick InterestRate / ( TicksPerYear * 100 )
  set investors investorsPercentage / 100
  ;no-display ; if do not want to visualize

  ; create realtors
  build-realtors

  ; create houses
  let total count patches * Density / 100 ; houses density
  ; how many of the total for ownership and how many for rent
  let owned ceiling Owned-Rent-Percentage * total / 100
  let rented total - owned
  repeat (owned) [ build-house "mortgage"] ; create ownership houses
  repeat (rented) [ build-house "rent"] ; create rent houses

  ; create owners
  build-owners
  ask owners [update-surplus-income]

  ; empty houses are for sale/rent; setting sale price (not related to owner)
  reset-empty-houses
  if InitialGeography = "Clustered" [ cluster ]   ;; move houses to the neighbors with similar prices

  reset-houses-quality ; assign quality to houses based on prices in the neighborhood
  reset-realtors ;; initialize sales, my-houses, average-price
  build-records

  ;; calculate the wealth of each household
  if calculate-wealth? = true [ask owners [update-wealth]]

  set VisualiseModeCurrent VisualiseMode
  update-visualisation

  ; identify the current state of the model is running
  set setup? false
end

to simplified-setup-step-1
  clear-all
  reset-ticks
  type "Applied Setup step 1\n"
  fetch:url-async "https://raw.githubusercontent.com/YahyaGamal/Housing_ABM_Simple_UI/refs/heads/main/Worlds/S18.4.2_01_clean.csv" import-a:world
end

to simplified-setup-step-2
  reset-ticks
  ask realtors [draw-circle RealtorTerritory]
  set visualiseMode "Prices"
  update-visualisation
  set setup-a 1
  set setup-b 1
  random-seed new-seed
  type "Applied Setup step 2\n"
end


to build-realtors
  set-default-shape realtors "flag"  ;;
  let direction random 360
  create-realtors nRealtors [  ;; create one at a time, totally nRealtors
    set color red
    ; distribute realtors in a rough circle
    set heading direction
    jump (max-pxcor - min-pxcor) / 4  ;; jump outward by 1/4 of length of the world
    set direction direction + 120 + random 30 ; prepare direction of jump for the next realtor
    set size 1  ;; original 3, here only 1 is visually good
    ; draw a circle to indicate a realtor's territory
    draw-circle RealtorTerritory   ;; RealtorTerritory is slider global variable
  ]
end

to draw-circle [radius]
;; draw the circumference of a circle at the given radius
  hatch 1 [  ;; based on current turtle, let's create/hatch a new turtle which inherit its parent's properties
    set pen-size 1 set color white set heading -90 fd radius  ;; set up pen size, color and radius for drawing a circle
    set heading 0  ;; set the heading to be tanget line direction
    pen-down
    while [heading < 359 ] [ rt 1 fd (radius * sin 1)  ]  ;; drawing a circle, see the debug proof below
    die  ;; end the drawing turtle
   ]
end

; now we only builds mortgage houses during the run (no input is used with type "rent" in go, but we initially build rent houses at setup)
to build-house [mtype]
  set-default-shape houses "house"
  create-houses 1 [
    ; assign type
    set myType mtype
    if myType = "mortgage" [set color 45]
    if myType = "rent" [set color 95]
   ; for speed, dump the house anywhere, check if there is already a house there, and if so, move to an empty spot
    move-to one-of patches
    if count houses-here > 1 [  ;; if more than 1 houses on the current patch ;;  houses-here == turtles-here
      let empty-sites patches with [ not any? houses-here ]  ;; ask every patch to see whether it already has a house on it or not, if not consider it an empty-site
      if any? empty-sites [ move-to one-of empty-sites ]  ;; if empty-sites exist, let current house move to any one of the empty-site
      ]

    ifelse calculate-wealth? = true [
      ; find a list of the local-realtors (list type is required for wealth calculation)
      set local-realtors [self] of realtors with [ distance myself < RealtorTerritory ]
      let temp-locals-list (list)
      repeat length local-realtors [set temp-locals-list lput (list) temp-locals-list]
      set local-sales temp-locals-list
      set local-rents temp-locals-list
      set locality-houses [self] of houses with [distance myself <= locality]
      ask turtle-set locality-houses [set locality-houses lput  myself locality-houses]
      ; if no realtor assigned, then choose nearest
      if not any? turtle-set local-realtors [
        set local-realtors (list min-one-of realtors [ distance myself ])
        set local-sales (list (list))
        set local-rents (list (list))
      ]
    ]
    ; if calculate-wealth? = false
    [
      ; assign to a realtor or realtors if in their territory
      set local-realtors realtors with [ distance myself < RealtorTerritory ]  ;; if the realtor to the house distance < radius, make the realtor(s) for the house
      ; if no realtor assigned, then choose nearest
      if not any? local-realtors [ set local-realtors turtle-set min-one-of realtors [ distance myself ] ]  ;; turtle-set to check
    ]

    put-on-market  ; initially empty houses are for sale, exluded when owners are build in the setup; all houses created later are put on market
    set my-owner nobody
    set my-occupier nobody
    set rented-to nobody
    set offered-to nobody
    ; note how long this house will last before it falls down and is demolished
    set end-of-life ticks + int random-exponential ( HouseMeanLifetime * TicksPerYear )
  ]
end


;; Considers the presence of a rent market
to put-on-market
  ;; reset market period counter
  set on-market-period 0
  ;; add the house to the mortgage or rent market
  if myType = "mortgage" [put-on-sale-market]
  if myType = "rent" [put-on-rent-market]
end

;; adds the house to the sale market
to put-on-sale-market
  set for-sale? true
  set for-rent? false
  set offered-to nobody
  set date-for-sale ticks
  colour-house
end

;; adds the house to the renting market
to put-on-rent-market
  set for-sale? false
  set for-rent? true
  set offered-to nobody
  set date-for-rent ticks
  colour-house
end

;; create owners
to build-owners
  set-default-shape owners "dot"  ;; all owners are dots
  ; in the setup, how many houses are occupied
  let n floor (initialOccupancy * count houses) ; total occupancy
  let o floor (Owned-Rent-Percentage / 100 * n) ; owned occupancy
  let r n - o                                   ; rented occupancy
  let available-owned nobody
  let available-rented nobody
  let count-notavailable-owned 0
  let count-notavailable-rented 0
  ; setting availabilities
  if (o > count houses with [myType = "mortgage"]) [
    set available-owned houses with [myType = "mortgage"]
    set count-notavailable-owned o - count houses with [myType = "mortgage"]
  ]
  if (o <= count houses with [myType = "mortgage"]) [
    set available-owned n-of o houses with [myType = "mortgage"]
  ]
  if (r > count houses with [myType = "rent"]) [
    set available-rented houses with [myType = "rent"]
    set count-notavailable-rented r - count houses with [myType = "rent"]
  ]
  if (r <= count houses with [myType = "rent"]) [
    set available-rented n-of r houses with [myType = "rent"]
  ]

  ask available-owned [  ;; define each home-owner's properties
    ;; since owners living inside, it should not for-sale or for rent now
    set for-sale? false
    set for-rent? false
    hatch-owners 1 [  ;; create an owner inside this house
      set color black  ;; make owner red
      set size 0.7   ;; owner easy to see but not too big
      set propensity random-float 1.0
      set my-house myself  ;; owner claims its house
      ;; added occupier and rented-to
      set my-ownership (list myself)
      ask my-house [set my-owner myself set my-occupier myself set rented-to nobody] ;; ask the house to claim its owner and occupier

      set mytype "mortgage" ; owner
      assign-income ;; create income and capital for owner#
      ;; address rent from house (owner lives in the house, and accordingly income-rent = 0
      set income-rent (list 0)
      set surplus-rent (list 0)
      ;; address mortgage rate duration (can be assigned regardless of actual mortgage)
      set rate (list interestPerTick)
      set rate-duration (list ((MinRateDurationM + random (MaxRateDurationM - MinRateDurationM)) * ticksPerYear) )
      set mortgage-duration (list (MortgageDuration * ticksPerYear))

      let deposit 0

      if initialisation = "repayment--> mortgage--> price" [
        ; maximum repayment
        let max-repayment (income * Affordability / (ticksPerYear * 100))
        let max-mortgage min list ( (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear )) * max-repayment / interestPerTick )
        ( (capital * (MaxLoanToValue / 100)) / (1 - (MaxLoanToValue / 100)) )

        set mortgage (list max-mortgage)
        set mortgage-initial (list item 0 mortgage)
        set repayment (list( item 0 mortgage * interestPerTick / (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear )) ))
        set deposit ( item 0 mortgage * ( 100 /  MaxLoanToValue - 1 ) )  ;; create deposit

        ;set repayment (list (income * Affordability / (ticksPerYear * 100)) )
        ;set mortgage (list ( (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear )) * item 0 repayment / interestPerTick ))
        ;set mortgage-initial (list item 0 mortgage)
        ;set deposit ( item 0 mortgage * ( 100 /  MaxLoanToValue - 1 ) )  ;; create deposit
      ]

      if initialisation = "mortgage--> price" [
        ;; address mortgage, repayment and deposit
        set mortgage (list( income * Affordability / ( interestPerTick * ticksPerYear * 100 ) )) ;; create mortgage as a list
        set mortgage-initial (list item 0 mortgage)
        set deposit ( item 0 mortgage * ( 100 /  MaxLoanToValue - 1 ) )  ;; create deposit
                                                                         ;; create repayment as a list
        set repayment (list( item 0 mortgage * interestPerTick /
          (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear )) ))
      ]

      ;; create sale-price = mortgage + deposit for the house
      ask my-house [
        set sale-price [item 0 mortgage] of myself + deposit
        set rent-price 0
      ]
    ]
  ]

  ;; assign tenants and landlords to the houses rented
  ask available-rented [
    ;; since owners living inside, it should not be for-sale or for rent
    set for-sale? false
    set for-rent? false
    hatch-owners 1 [  ;; create an owner inside this house
      set color white  ;; make owner red
      set size 0.7   ;; owner easy to see but not too big
      set propensity random-float 1.0
      set my-house myself  ;; owner claims its house
      ;; manage ownership of house and owner agent
      set my-ownership (list)
      let owner-temp one-of owners with [mytype = "mortgage"]
      let house-temp myself
      set mytype "rent" ; renter/tenant (i.e., someone living now in a rented house)
      assign-income ;; create income and capital for owner (i.e. renter)
      ;; renters do not pay mortgage and have no repayments, but they pay rent
      let rent income * Affordability / (ticksPerYear * 100 ) ;; create rent
      ;; address mortgage rate duration (can be assigned regardless of actual mortgage)
      set rate (list)
      set rate-duration (list)
      set mortgage-duration (list)

      let price 0
      let repayment-temp 0

      if initialisation = "repayment--> mortgage--> price" [
        set repayment-temp income * Affordability / (ticksPerYear * 100 )
        set price (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear )) * repayment-temp / interestPerTick
      ]

      if initialisation = "mortgage--> price" [
        set price income * Affordability / ( interestPerTick * ticksPerYear * 100 )
        set repayment-temp price * interestPerTick / (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear ))
      ]


      ;; safegaurd that landlords at least recover their repayments from the rent (this leads to much higher rents with higher interest rates)
      if repayment-temp > rent [set rent repayment-temp]
      ;; add an owner to the rented house (required for adding the rent value to that person)
      ask my-house [
        set my-owner owner-temp
        set my-occupier myself
        set rented-to myself
        ;; set sale price of the rented house the same as the sale-price of my-house of the main owner
        ;set sale-price [sale-price] of ([my-house] of owner-temp)
        set sale-price price
        set rent-price rent
      ]
      ;; manage ownership, mortgage, repayment and rent of the landlord of the house
      ask owner-temp [
        set my-ownership lput (house-temp) (my-ownership)
        ;set mortgage lput (item 0 mortgage) (mortgage)
        set mortgage lput (price) (mortgage)
        set mortgage-initial lput (price) (mortgage-initial)
        ;set repayment lput (item 0 repayment) (repayment)
        set repayment lput (repayment-temp) (repayment)
        set income-rent lput rent income-rent
        set surplus-rent lput (rent - repayment-temp) surplus-rent
        ;; address mortgage rate duration (can be assigned regardless of actual mortgage)
        set rate lput (interestPerTick) (rate)
        set rate-duration lput ((MinRateDurationBTL + random (MaxRateDurationBTL - MinRateDurationBTL)) * ticksPerYear) (rate-duration)
        set mortgage-duration lput (MortgageDuration * ticksPerYear) mortgage-duration
      ]
      set my-rent rent
      ;; intialise mrotgage, repayment and income-rent as empty lists
      set mortgage (list)
      set mortgage-initial (list)
      set repayment (list)
      set income-rent (list)
      set surplus-rent (list)
      ask my-house [ set sale-price price set rent-price rent ] ;; create rent-price = rent
    ]
  ]

  ;; assign owners (i.e., landlords) to houses available on the rent market (i.e., not occupied)
  ask houses with [myType = "rent" and for-rent? = true] [
    let owner-temp one-of owners with [mytype = "mortgage"]
    let house-temp self
    ask owner-temp [
      set my-ownership lput (house-temp) (my-ownership)
      ;; repeat the mortgage (we assume sale-prices are based on income, this makes the sale-price of all houses owned by one owner the same at initialisation)
      set mortgage lput (item 0 mortgage) (mortgage)
      set mortgage-initial lput (item 0 mortgage-initial) (mortgage-initial)
      set repayment lput (item 0 repayment) (repayment)
      set income-rent lput 0 (income-rent)
      set surplus-rent lput (0 - item 0 repayment) surplus-rent
      ;; address mortgage rate duration (can be assigned regardless of actual mortgage)
      set rate lput (interestPerTick) (rate)
      set rate-duration lput ((MinRateDurationBTL + random (MaxRateDurationBTL - MinRateDurationBTL)) * ticksPerYear) (rate-duration)
      set mortgage-duration lput (MortgageDuration * ticksPerYear) mortgage-duration
    ]
    ask house-temp [
      set my-owner owner-temp
      set my-occupier nobody
      set rented-to nobody
      ;; set sale price of the rented house the same as the sale-price of my-house of the main owner (this is an assumption at set-up)
      set sale-price [sale-price] of ([my-house] of owner-temp)
      set rent-price median [rent-price] of houses with [myType = "rent" and for-rent? = false]
    ]
  ]

  ; houses not assigned
  if count-notavailable-owned > 0 [
    create-owners count-notavailable-owned [
      set color black  ;; make owner red
      set size 0.7   ;; owner easy to see but not too big
      ;; was nobody in 17.6
      ;; returned to nobody in 18.0
      ;set my-house one-of houses with [myType = "rent" and my-occupier = nobody]  ;; owner claims its house
      set my-house nobody
      set my-ownership (list)
      set mytype "mortgage" ; mortgage owner
      assign-income ;; create income and capital for owner
      ;let rent income * Affordability / (ticksPerYear * 100 ) ;; create rent
      set my-rent 0
      set mortgage (list)
      set mortgage-initial (list)
      set repayment (list)
      set income-rent (list)
      set surplus-rent (list)
      set rate (list)
      set rate-duration (list)
      set mortgage-duration (list)

      enter-market self myType
    ]
  ]

  ; tenants without houses at initialisation assigned
  if count-notavailable-rented > 0 [
    create-owners count-notavailable-rented [  ;; create an owner inside this house
      ;set hidden? true
      ;move-to one-of patches
      set color white  ;; make owner red
      set size 0.7   ;; owner easy to see but not too big
      ;; was nobody in 17.6
      ;; returned to nobody in 18.0
      ;set my-house one-of houses with [myType = "rent" and my-occupier = nobody]  ;; owner claims its house
      set my-house nobody
      set my-ownership (list)
      set mytype "rent" ; renter
      assign-income ;; create income and capital for owner
      ;let rent income * Affordability / (ticksPerYear * 100 ) ;; create rent
      set my-rent 0
      set mortgage (list)
      set mortgage-initial (list)
      set repayment (list)
      set income-rent (list)
      set surplus-rent (list)
      set rate (list)
      set rate-duration (list)
      set mortgage-duration (list)

      enter-market self myType
    ]
  ]

  ;; pay the mortgage of a portion of the owners (this cannot be applied when calculating the mortgages as the mortgage values are necessary to set prices)
  if FullyPaidMortgageOwners > 0 [

    ask owners with [myType = "mortgage"] [
      if FullyPaidMortgageOwners >= random 100 [
        let i 0
        let l length my-ownership
        ;; loop through all the ownership houses
        while [i < l] [
          set mortgage replace-item i mortgage 0
          set mortgage-initial replace-item i mortgage-initial 0
          set mortgage-duration replace-item i mortgage-duration nobody
          set repayment replace-item i repayment 0
          set surplus-rent replace-item i surplus-rent (item i income-rent)
          set rate replace-item i rate 0
          set rate-duration replace-item i rate-duration nobody
          set i i + 1
        ]
      ]
    ]
  ]
end


to assign-income

;; an owner's income is a random number from a particular gamma distribution
;; an owner's capital is a proportion of income

;; income distribution formula is based on the following paper
;; parameters taken from http://www2.physics.umd.edu/~yakovenk/papers/PhysicaA-370-54-2006.pdf

  let MeanIncome-temp MeanIncome
  ;; override mean income if it does not cover the mean repayments
  let mean-deposit 0
  let min-deposit 0
  if (Override-Income-Capital = true and setup? = false) [
    let mean-price 0
    let min-price 0
    if any? houses with [myType = "mortgage" and sale-price > 0 and for-sale? = true] [
      set mean-price max list (mean [sale-price] of houses with [myType = "mortgage" and sale-price > 0 and for-sale? = true]) (medianPriceOfHousesForSale)
      set min-price max list (min [sale-price] of houses with [myType = "mortgage" and sale-price > 0 and for-sale? = true]) (min [sale-price] of houses with [myType = "mortgage" and sale-price > 0])
    ]
    set mean-deposit mean-price * ( 1 - (MaxLoanToValue / 100) )
    set min-deposit min-price * ( 1 - (MaxLoanToValue / 100) )
    let mean-mortgage mean-price * (MaxLoanToValue / 100)
    let mean-repayment mean-mortgage * interestPerTick / ( 1 - (1 + interestPerTick) ^ (- MortgageDuration * TicksPerYear) )
    set MeanIncome-temp max list (mean-repayment * TicksPerYear) (MeanIncome)
  ]

  let alpha 1.3
  let lambda 1 / 20000
  set income 0

  ; avoid impossibly low incomes (i.e. less than half the desired mean income)
  while [ income < MeanIncome-temp / 2 ] [  ;; as long as income is less than half of median income
    set income (MeanIncome-temp * lambda / alpha ) * (random-gamma alpha lambda) *
    (1 + (WageRise / (TicksPerYear * 100)) ) ^ ticks  ;; redefine income value with this equation (check the paper for details )
  ]
  ;; assign the income-surplus initially as the income per tick (deductions will be made later from the income surplus)
  set income-surplus income / ticksPerYear

  ; if override capital is on, assure the mortgage owners have enough capital to at least buy the cheapest house on the market
  ifelse (Override-Income-Capital = true and setup? = false) [
    if myType = "mortgage" [set capital max list (income * CapitalMortgage / 100) ( (min-deposit + mean-deposit) / 2)]
  ]
  ; if not, give them a proportion of a year's income as their savings
  [
    if myType = "mortgage" [set capital income * CapitalMortgage / 100]
  ]
  if myType = "rent" [set capital income * CapitalRent / 100]


end

to update-surplus-income
  set income-surplus (income / ticksPerYear) + sum(income-rent) - sum(repayment) - my-rent
end

to update-cooldown
  ;; if the household is on BTL cooldown and have not reached the end of its cooldown period
  if on-cooldown? = true and on-cooldown-type = "buy-to-let" [
    if time-on-cooldown < cooldownPeriodBTL [set time-on-cooldown time-on-cooldown + 1]
    ;; if the household reached the end of its cooldown period
    if time-on-cooldown >= cooldownPeriodBTL [
      ;;type self type " | time-on-cooldown = " type time-on-cooldown type "\n"
      set on-cooldown? false
      set time-on-cooldown 0
      set on-cooldown-type nobody
    ]
  ]

  ;; if the household is on mortgage market cooldown and have not reached the end of its cooldown period
  if on-cooldown? = true and on-cooldown-type = "mortgage" [
    if time-on-cooldown < cooldownPeriodMortgage [set time-on-cooldown time-on-cooldown + 1]
    ;; if the household reached the end of its cooldown period
    if time-on-cooldown >= cooldownPeriodMortgage [
      ;;type self type " Mortgage | time-on-cooldown = " type time-on-cooldown type "\n"
      set on-cooldown? false
      set time-on-cooldown 0
      set on-cooldown-type nobody
    ]
  ]


end

to update-wealth
  if calculate-wealth? = True [
    let i 0
    set wealth capital
    while [i < length my-ownership] [
      let mortgage-temp item i mortgage
      let my-ownership-temp item i my-ownership
      let myType-temp [myType] of item i my-ownership
      let sale-price-temp 0
      ask my-ownership-temp [
        set my-realtor max-one-of turtle-set local-realtors [ valuation myself ]               ;; set the realtor that gives the current house the highest valuation to be my-realtor
        set myType "mortgage"
        ask my-realtor [set sale-price-temp valuation my-ownership-temp]
        set myType myType-temp
      ]
      set wealth wealth + (sale-price-temp - mortgage-temp)
      set i i + 1
    ]
  ]
end

to reset-empty-houses
  ;; For vacant houses, without owners, those houses have no sale-prices, my-owner properties

  let median-price 0
  let median-rent 0

  ; initial random assignments
  set median-price median [ sale-price ] of houses with [ sale-price > 0 and myType = "mortgage"] ;; median sale-prices of all houses with owners
  ;; consider rent-price for rented houses
  set median-rent median [ rent-price ] of houses with [ rent-price > 0 and myType = "rent"] ;; median sale-prices of all houses with owners
  ;; check my-occupier for empty houses
  ask houses with [ not (is-owner? my-occupier) and myType = "mortgage"] [  ;; loop each empty house owned?
    let local-houses-sale houses with [distance myself < Locality and sale-price > 0 and myType = "mortgage"]
    let local-houses-rent houses with [distance myself < Locality and rent-price > 0 and myType = "rent"]

    ;; assign sale
    ;; find all local houses of the empty house = locality distance and has owner with sale-price
    ifelse any? local-houses-sale ;; if there exist local houses,
        [ set sale-price  median [ sale-price ] of local-houses-sale
    ]  ;; use local houses median price as the empty house sale-price
    [ set sale-price  median-price
    ]  ;; otherwise, use all occupied houses median price for the empty house sale-price

    ;; assign rent
    ;; find all local houses of the empty house
    ifelse any? local-houses-rent
        [ set rent-price  median [ rent-price ] of local-houses-rent ]  ;; use local houses median price as the empty house sale-price
    [ set rent-price  median-rent ]  ;; otherwise, use all occupied houses median price for the empty house sale-price

  ]
  ;; consider rent-price of local houses
  ask houses with [ not (is-owner? my-occupier) and myType = "rent"] [  ;; loop each empty house NOT owned?
  let local-houses houses with [distance myself < Locality and rent-price > 0 and myType = "rent"]
  ;; find all local houses of the empty house
  ifelse any? local-houses
      [ set rent-price  median [ rent-price ] of local-houses ]  ;; use local houses median price as the empty house sale-price
  [ set rent-price  median-rent ]  ;; otherwise, use all occupied houses median price for the empty house sale-price
  ]
end

to cluster
  ;; cluster houses together based on price similarity
  let owned-houses houses with [myType = "mortgage"]
  let rented-houses houses with [myType = "rent"]
  cluster-type owned-houses price-difference
  cluster-type rented-houses rent-difference
end

to cluster-type [all-houses diff]
  repeat clusteringRepeat [  ;;  cluster all all houses x times
    let houses-to-move sort-by [ [ house1 house2 ] ->  price-diff house1 > price-diff house2 ] all-houses  ;; new-version
    ;; reorder every house based on price-difference to its neighbor houses, largest first, smallest last
    foreach houses-to-move [  ;; loop each house
      x -> if price-diff x >= diff [  ;; if current house price is way too different from its surroundign houses
        let vacant-plot one-of patches with [  ;; get one of many empty patches, where
                                   not any? houses-here and  ;; there is no house built
                                   abs (local-price - [ sale-price ] of x ) < (diff / 5) ]  ;; where the surrounding house prices is similar to the current house
        if vacant-plot != nobody [  ;; if those empty patches do exist
          ask x [  ;; ask this current house
            move-to vacant-plot  ;; to move to one of the empty patch
            if is-owner? my-occupier [  ;; whether it got an owner, if so
              ask my-occupier [ move-to myself ] ;; ask the owner move to where the house is
            ]
          ]
        ]
      ]
    ]
  ]
end

to-report price-diff [ a-house ]
  report abs ([sale-price] of a-house - [local-price] of a-house) ;; Note the use [ local-price ] of a-house
end

to-report local-price
  let local-houses houses-on neighbors  ;; based on the current patch, looking for its eight neighbor patches, put all the houses on those patches under `local-houses`
  ;; report prices of mortgaged houses only (do not report prices of rented houses)
  ifelse any? local-houses with [mytype = "mortgage"]  ;; if `loca-houses` is not empty
    [ report median [sale-price] of local-houses with [mytype = "mortgage"] ]  ;; report median price of all neighbor houses' sale-prices to be `local-price`
    [ report 0 ] ;; if no neighbor houses, report 0 to be `local-price`
end

to reset-houses-quality

  set medianPriceOfHousesForSale median [sale-price] of houses with [myType = "mortgage"]  ;; get median price for all houses owned
  set medianPriceOfHousesForRent median [rent-price] of houses with [myType = "rent"]  ;; get median price for all houses not owned

  ask houses with [myType = "mortgage"] [
    set quality sale-price / medianPriceOfHousesForSale  ;; quality is sale-price/median-price
    if quality > 3 [set quality 3] if quality < 0.3 [set quality 0.3]  ;; quality is between 0.3 to 3
    set color scale-color color quality 5 0  ;; quality by magenta scale
  ]

  ;; address rented houses
  ask houses with [myType = "rent"] [
    set quality rent-price / medianPriceOfHousesForRent  ;; quality is sale-price/median-price
    if quality > 3 [set quality 3] if quality < 0.3 [set quality 0.3]  ;; quality is between 0.3 to 3
    set color scale-color color quality 5 0  ;; quality by magenta scale
  ]
end

to reset-realtors

  ask realtors [
    set sales-sold [] ;; take sales as empty list
    set sales-rent [] ;; take sales as empty list

    set my-houses-sold houses with [member? myself local-realtors and myType = "mortgage"]
    set my-houses-rent houses with [member? myself local-realtors and myType = "rent"]

    set average-price median [ sale-price ] of my-houses-sold
    ;; consider average rent
    set average-rent median [ rent-price ] of my-houses-rent
  ]
end

to build-records
  ;; create records for each and every house
  ;; at the start, every house is assumed to be sold previously and has a record
  ;; the house's sale-price is the record's selling-price,
  ;; my-realtor is set randomly at the start, and this realtor will store the record into its sales list

  set-default-shape records "square"
  ask houses [ ;; loop each house

    let the-record nobody ;; `the-record` is nobody
    hatch-records 1 [  ;; hatch a record from a house
      hide-turtle  ;; hide the current record

      set the-house myself   ;; take the current house to be the-house of the current record
      set selling-price [ sale-price ] of myself  ;; take the sale-price of the house to be selling-price of the current record
      ;; consider renting prices
      set renting-price [ rent-price] of myself

      set the-record self                           ;; use the-record to carry the current record outside the hatch function into the house context
    ]

    set my-realtor one-of local-realtors  ;; randomly take one of the local-realtors to be my-realtor of the current house

    file-record my-realtor the-record  ;; ask my-realtor to save the current record (the-record) into sales of my-realtor

  ]

end

to file-record [ input-realtor the-record ]         ;; realtor procedure
  ; push this sales record onto the list of those I keep
  let A [the-house] of the-record

  ask input-realtor [
    ; consider both rent and mortgage
    if [myType] of A = "mortgage" [set sales-sold fput the-record sales-sold]
    if [myType] of A = "rent" [set sales-rent fput the-record sales-rent]
  ]

  if calculate-wealth? = true [
    ; find local houses and store which houses filed the-record
    ;let A-local-houses houses with [distance A <= locality and member? input-realtor local-realtors]
    let A-local-houses (turtle-set [locality-houses] of A) with [member? input-realtor local-realtors]
    ; create a list of the houses that will file the record
    ask the-record [set filed-at-houses [self] of A-local-houses]
    if any? A-local-houses [
      ask A-local-houses [
        let i position input-realtor local-realtors
        if [myType] of A = "mortgage" [
          let relevant-records item i local-sales
          set relevant-records remove nobody relevant-records
          set relevant-records fput the-record relevant-records
          set local-sales replace-item i local-sales relevant-records
        ]
        if [myType] of A = "rent" [
          let relevant-records item i local-rents
          set relevant-records remove nobody relevant-records
          set relevant-records fput the-record relevant-records
          set local-rents replace-item i local-rents relevant-records
        ]
      ]
    ]
  ]
end

to go
  if setup-a = 0 or setup-b = 0 [
    type "Error: Please make sure you press 'Setup step 1' then 'Setup step 2' before running the model\n"
    stop
  ]
  set nDiscouraged 0
  set nExit 0
  set nEntry 0
  set nForceOutRent 0
  set nForceOutSell 0
  set nForceInSell 0
  set nOwnersOffered 0
  set meanIncomeForceOutRent 0 ;; get mean income of owners who are forced out
  set meanIncomeForceOutSell 0 ;; get mean income of owners who are forced out
  set meanIncomeForceInSell 0

   if ticks = 200 [
    ; Sale market
     if scenario = "ltv"  [ set MaxLoanToValue 60 ]
     if scenario = "raterise 3" [ set InterestRate 3 ]
     if scenario = "raterise 10" [ set InterestRate 10 ]
    ; both
     if scenario = "influx" [ set EntryRate 10 ]
     if scenario = "influx-rev" [ set EXitRate 5 ]
     if scenario = "poorentrants" [ set MeanIncome 24000 ]
    ; rent market?


    if scenario != "base-line" [type "We are at middle of simulation duration, ticks = " type ticks type ", a shock event coming in := " type scenario  print ";"]
  ]
  if TicksPerYear > 0 [step]  ;; do one time step (a quarter of a year?)

  if not any? owners [ user-message(word "Finished: no remaining people" ) stop ] ;; stop if no owners or houses left
  if not any? houses [ user-message(word "Finished: no remaining houses" ) stop ]
  ;paint-houses
  ;do-plots
  tick
end

to step

  ; reset the count of upshocked and downshocked agents
  reset-globals

  update-visualisation

  let n-owners count owners  ;; take a count of total owners at the moment

  calculate-globals ; update interest rate and income
  ; owners living in houses
  let owner-occupiers owners with [ is-house? my-house ] ; all owners who are living
  ;type "calculate-globals | " type count owners with [length my-ownership > length repayment] type "\n"

  ; change in income due to income shock (all owners)
  ; shock related (possible) effort to change of house of owner occupiers
  shock-management owner-occupiers
  set n-owners count owners  ;; take a count of total owners at the moment
  set owner-occupiers owners with [ is-house? my-house ] ; all owners who are living
  ;type "shock-management | " type count owners with [length my-ownership > length repayment] type "\n"

  ; owners leaving naturally
  owners-leave n-owners
  set n-owners count owners  ;; take a count of total owners at the moment
  set owner-occupiers owners with [ is-house? my-house ] ; all owners who are living
  ;type "owners-leave | " type count owners with [length my-ownership > length repayment] type "\n"

  ; owners entering naturally
  new-owners n-owners
  set n-owners count owners  ;; take a count of total owners at the moment
  set owner-occupiers owners with [ is-house? my-house ] ; all owners who are living
  ;type "new-owners | " type count owners with [length my-ownership > length repayment] type "\n"

  ; owners leaving due to discouragement
  manage-discouraged
  set n-owners count owners  ;; take a count of total owners at the moment
  set owner-occupiers owners with [ is-house? my-house ] ; all owners who are living
  ;type "manage-discouraged | " type count owners with [length my-ownership > length repayment] type "\n"

  ; manage which market the agents enter to on the basis of their current occupation and budgets
  manage-market-participation owner-occupiers
  ;type "manage-market-participation | " type count owners with [length my-ownership > length repayment] type "\n"

  ; introduce new houses
  new-houses
  ;type "new-houses | " type count owners with [length my-ownership > length repayment] type "\n"

  ; trading and moving into houses
  trade-houses
  ;type "trade-houses | " type count owners with [length my-ownership > length repayment] type "\n"

  ;remove extras (this removes all the offers, but still keeps the houses on the market)
  remove-outdates
  ;type "remove-outdates | " type count owners with [length my-ownership > length repayment] type "\n"

  ; demolish old houses
  demolish-houses
  ;type "demolish-houses | " type count owners with [length my-ownership > length repayment] type "\n"
  ; decay the prices of houses
  update-prices
  ;type "update-prices | " type count owners with [length my-ownership > length repayment] type "\n"
  ; update the homeless owners and discourage those who exceed the maxhomelesslimit
  update-owners
  ;type "update-owners | " type count owners with [length my-ownership > length repayment] type "\n"
  update-globals

end

to calculate-globals
  ;;; Calculate Globals

  ;; calc interest per tick ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; add an exogenous cyclical interest rate, if required: varies around mean of
  ; the rate set by slider with a fixed period of 10 years
  set interestPerTick InterestRate / ( TicksPerYear * 100 )
  ;; add cyclical variation to interest ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if CycleStrength > 0 [
    set interestPerTick interestPerTick * (1 + (CycleStrength / 100 ) * sin ( 36 * ticks / TicksPerYear )) ]

  ;; inflation drive up income ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; add inflation to salary, at inflation rate / TicksPerYear
  if WageRise > 0 [
    ask owners [
      set income income * (1 + (WageRise / ( TicksPerYear * 100 ))) ;; every tick, income stay the same or varied by inflation, income per year
    ]
  ]
end

to shock-management [oo]
  set nupShocked 0
  set ndownShocked 0
  ; shock frequency is used to produce a random stock not every tick  but with a random frequency
  if random-float 1 < shock-frequency
  [
    ;; change in the income due to shock
    ;; introduce income rise and fall shock to owners ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    let shocked-owners n-of (Shocked / 100 * count owners ) owners ;; gather Shocked% of `owner-occupiers` under `shocked-owners`
    let upshocked n-of (count shocked-owners / 2) shocked-owners ;; gather half of `shocked-owners` under `upshocked`
    ask upshocked [ set income income * (1 + income-shock / 100) ] ;; ask each `upshocked` to increase income by 20%
    let downshocked shocked-owners with [ not member? self upshocked ] ;; gather the non-upshocked as down shocked owners under `downshocked`
    ask downshocked [ set income income * (1 - income-shock / 100 ) ]  ;; ask each downshocked to drop income by 20%

    ;; only make those calculations if the switch is off (to save computation time)
    if ActWhenShocked = false [
      set nupShocked mean [income] of upShocked
      set ndownShocked mean [income] of downshocked
      set nUpShockedSell count upshocked with [myType = "mortgage"]
      set nDownShockedSell count downshocked with [myType = "mortgage"]
      set nUpShockedRent count upshocked with [myType = "rent"]
      set nDownShockedRent count downshocked with [myType = "rent"]
    ]

    ;; income-shock intriges some owners to sell / rent houses ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; after income shock, which type of owners will sell houses due to income rise, and which type of owners sell houses due to income drop

    ;; only triggered if the "ActWhenShocked" is on, meaning the decision tree at shock is triggered
    if ActWhenShocked = true [
      set nupShocked mean [income] of upShocked
      set ndownShocked mean [income] of downshocked
      set nUpShockedSell 0  ;; initialize the number of upshocked owners sell
      set nDownShockedSell 0 ;; initialize the number of downshocked owners sell
      set nUpShockedRent 0   ;; rent
      set nDownShockedRent 0 ;; rent


      let owner-occupiers-owned oo with [myType = "mortgage" and is-house? my-house]
      if any? owner-occupiers-owned [
        ;; ask all home-owners whose house is not for sale (in setup, all home-owners don't sell houses)
        ask owner-occupiers-owned with [ [for-sale?] of my-house = false ][
          ;; put yearly-repayment / income  under `ratio`
          let ratio (sum repayment) * TicksPerYear / income
          ;; if ratio < half of Affordability %, meaning yearly-repayment is easy and owner is rich
          ; upshocked now go to buy-to-let market rather than upgrade their house
          ifelse  ratio <= Affordability / 200 [
            enter-market self "buy-to-let"
            set nUpShockedSell nUpShockedSell + 1   ;; add 1 to `nUpShocked`, meaning one more owner selling house due to income rise (not true now after adding buy-to-let, owners do not have to sell)
          ]
          [
            if ratio > Affordability / 50 [   ;; if ratio > 2 * Affordability % , meaning yearly-repayment is way to heavy for owners to bear, owner is poor
                                              ;; create a list of ownerships that are not my-house
              let my-ownership-temp my-ownership
              ask my-house [set my-ownership-temp other turtle-set my-ownership-temp]
              ;let my-ownership-temp remove my-house (list my-ownership)
              ;; if I have more than one house, evict the tenant and put the house on the mortgage market
              ifelse count turtle-set my-ownership > 1 [
                ;; find one of my ownerships that is not my-house (i.e., not where I live) and is not on the market for-sale
                ifelse any? my-ownership-temp with [for-sale? = false] [
                  ask one-of my-ownership-temp with [for-sale? = false] [
                    ; if there is an occupier, evict them
                    if is-owner? my-occupier [
                      let my-occupier-temp my-occupier
                      evict my-occupier-temp
                      enter-market my-occupier-temp "rent"
                    ]
                    ; put the house on the mortgage market
                    set myType "mortgage"
                    put-on-market
                  ]
                ]
                ;; if all my-ownership are on sale, then evict myself and join the rent market
                [
                  evict self
                  enter-market self "rent"
                ]
              ]
              ;; if I have only one house, I enter the rent market after the downshock
              [
                ; manage the ownership of my-house and put it on the market
                ask my-house [
                  set my-owner nobody
                  set my-occupier nobody
                  set rented-to nobody
                  set offered-to nobody
                  set myType "mortgage"
                  put-on-market
                ]  ;; ask owner's house to put on the market for sale
                   ; evict myself and enter the rent market
                evict self
                enter-market self "rent"
              ]
              set nDownShockedSell nDownShockedSell + 1  ;; add 1 to `nDownShocked`, meaning one more owner selling house due to income drop
                                                         ;set looking-for-transition true
            ]
          ]
        ]
      ]
      ;; find all tenants with a house
      let owner-occupiers-rented oo with [myType =  "rent" and is-house? my-house]
      if any? owner-occupiers-rented [
        ;; ask all the tenants to
        ask owner-occupiers-rented with [ [for-rent?] of my-house = false][ ;; ask all home-owners whose house is not for sale (in setup, all home-owners don't sell houses)
          let ratio my-rent / income ;; put yearly-repayment / income  under `ratio`
          ifelse  ratio <= Affordability / 200 [  ;; if ratio < half of Affordability %, meaning yearly-rent is easy and owner is rich
            ask my-house [
              set myType "rent"
              put-on-market
            ]
            ;; enter the mortgage market to buy a house
            ;; modified to mortgage REVISE AS THIS MAY CAUSE ERRORS
            enter-market self "mortgage"
            ;; The house will be put on the market later as soon as the tenant finds a house to buy
            ;ask my-house [ put-on-market ]  ;; ask owner's house to put on the market for rent
            set nUpShockedRent nUpShockedRent + 1   ;; add 1 to `nUpShocked`, meaning one more owner selling house due to income rise
                                                    ;set looking-for-transition true
          ]
          ;;  ;; if ratio > half of Affordability %
          [
            ;; if ratio > 2 * Affordability % , meaning yearly-rent is way to heavy for owners to bear, owner is poor
            if ratio > Affordability / 50 [
              ask my-house [
                set my-occupier nobody
                set rented-to nobody
                put-on-market
              ]  ;; ask owner's house to put on the market for rent
                 ;; evict myself and enter the rent market
              evict self
              enter-market self "rent"
              set nDownShockedRent nDownShockedRent + 1  ;; add 1 to `nDownShocked`, meaning one more owner selling house due to income drop
                                                         ;set looking-for-transition true
            ]
          ]
        ]
      ]
    ]
  ]
end

to owners-leave [n-owners]
  ;; owners die or leave naturally ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; every tick, a proportion of owners put their houses on the market and leave town
  let owners-rent owners with [ is-house? my-house and myType = "rent" ]
  let n min (list count owners-rent (ExitRate * n-owners / 200))
  ask n-of n owners-rent [
    ;; amange the tenancy of my-house
    ask my-house [
      set rented-to nobody
      set my-occupier nobody
      set offered-to nobody
      put-on-market
    ]
    set nExit nExit + 1
    die
  ]


  let owners-mortgage owners with [ is-house? my-house and myType = "mortgage" ]
  ask n-of (ExitRate * n-owners / 200) owners-mortgage [  ;; ask randomly select (ExitRate% of all owners) number of home-owners to do ...
    ;; Modified to consider cases where a landlord leaves, leading to the eviction of all the tenant
    ; find my-ownership excluding my-house
    let my-ownership-temp turtle-set my-ownership
    ask my-house [set my-ownership-temp other turtle-set my-ownership-temp]

    ask my-ownership-temp [
      ;; If someone is occupying one of my owned houses, evict them
      if is-owner? my-occupier [
        let my-occupier-temp my-occupier
        evict my-occupier-temp
        enter-market my-occupier-temp "rent"
      ]
      ;; manage the ownership of the house
      set my-owner nobody
      set my-occupier nobody
      set rented-to nobody
      set offered-to nobody
      ;; put the house on the morgage market (now without an owner as the owner left)
      set myType "mortgage"
      put-on-market
    ]
    ;; manage the ownership of my-house (i.e, the one I live in)
    ask my-house [
      set my-owner nobody
      set my-occupier nobody
      set rented-to nobody
      set offered-to nobody
      ;; put the house on the morgage market (now without an owner as the owner left)
      set myType "mortgage"
      put-on-market
    ]

    set nExit nExit + 1
    die
  ]
end

to new-owners [n-owners]

  ;; new comers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; a fixed number of new comers enter the city
  repeat EntryRate * n-owners / 100 [
    ;  create-owners EntryRate * n-owners / 100 [  ;; create a fixed proportion of new owners
    create-owners 1 [
      ;; assign type before assigning income
      if new-owner-type = "random" [
        let t random 2
        ifelse t = 0 [set myType "mortgage"] [set myType "rent"]
      ]
      if new-owner-type = "all-rent" [set myType "rent"]
      if new-owner-type = "all-owned" [set myType "mortgage"]
      if new-owner-type = "contextualized" [
        ;; Modified to my-occupier instead of my-owner for representing whether the house is vacant or not
        let x count houses with [myType = "mortgage" and my-occupier = nobody] ; count empty owned houses
        let xx count owners with [mytype = "mortgage" and my-house = nobody] ; owned owners no house
        let y count houses with [myType = "rent" and my-occupier = nobody] ; count empty rent houses
        let yy count owners with [mytype = "rent" and my-house = nobody] ; rent owners no house


        let diff1 x - xx ; if x = 3 and xx = 2, then diff is +ve, meaning owned houses are more than demand and vice versa
        let diff2 y - yy ; if y = 3 and yy = 2, then diff is +ve, meaning rent houses are more than demand and vice versa
        if diff1 <= 0 and diff2 >= 0 [set mytype "rent"] ; owned hosues are less and rent hosues are more/equal than demand, set type rent
        if diff1 <= 0 and diff2 <= 0 [
          let t random 2
          ifelse t = 0 [set myType "mortgage"] [set myType "rent"]
        ] ; owned houses are less and rent hosues are also less, random
        if diff1 >= 0 and diff2 >= 0 [
          let t random 2
          ifelse t = 0 [set myType "mortgage"] [set myType "rent"]
        ] ; both owned and rent houses are more than demand, random
        if diff1 >= 0 and diff2 <= 0 [set myType "mortgage"] ; owned houses are more/equal than demand and rent houses are less, set type owned
      ]

      set color gray  ;; gray
      set size 0.7  ;; make them visible but not too big
      assign-income  ;; initialize income and capital
      ;let rent income * Affordability / (ticksPerYear * 100 ) ;; create rent
      ;set my-rent rent
      ;set mortgage income * Affordability / ( interestPerTick * ticksPerYear * 100 ) ;; create mortgage
      ;let deposit mortgage * ( 100 /  MaxLoanToValue - 1 )  ;; create deposit
      ;set repayment mortgage * interestPerTick / (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear ))
      set mortgage (list)
      set mortgage-initial (list)
      set repayment (list)
      set income-rent (list)
      set surplus-rent (list)
      set rate (list)
      set rate-duration (list)
      set mortgage-duration (list)

      ;; assign the ownership and my-house of the new comer
      set my-ownership (list)
      set propensity random-float 1.0
      set my-house nobody
      set made-offer-on nobody


      ;; Enter the market on the absis of myType (i.e., either "mortgage" or "rent")
      enter-market self myType
      hide-turtle  ;; new comers have no houses, so they are nowhere to be seen
      set nEntry nEntry + 1

    ]
  ]

end

to manage-discouraged
  ;; discouraged-leave ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; if an owner without home for too long, it will move out of city
  if maxHomelessPeriod  > 0 [ ; meaning if this value is set
    ask owners with [ not is-house? my-house ] [  ;; ask each owner without a house
      set homeless homeless + 1  ;; count the owner's homeless duration
      if homeless > maxHomelessPeriod [ ;; if homeless duration is beyond limit, this owner will move out of the city (agent die)
        set nDiscouraged nDiscouraged + 1
        die
      ]
    ]
  ]

  ;; if an `owner` is trying to invest on the BTL market for too long, it gets discouraged
  ;; if maximumPeriodBTL is higher than 0 - meaning the variable is set
  if onMarketPeriodBTL > 0 [
    ask owners with [on-market-type = "buy-to-let"] [
      if time-on-market >= onMarketPeriodBTL [
        ;;type self type " | time-on-maket = " type time-on-market type "\n"
        set on-market? false
        set on-market-type nobody
        set time-on-market 0
        set on-cooldown? true
        set on-cooldown-type "buy-to-let"
        set time-on-cooldown 0
      ]
    ]
  ]

  ;; if maximumPeriodMortgage is higher than 0 - meaning the variable is set
  if onMarketPeriodMortgage > 0 [
    ask owners with [on-market-type = "mortgage"] [
      if time-on-market >= onMarketPeriodMortgage [
        ;;type self type " Mortgage | time-on-maket = " type time-on-market type "\n"
        set on-market? false
        set on-market-type nobody
        set time-on-market 0
        set on-cooldown? true
        set on-cooldown-type "mortgage"
        set time-on-cooldown 0
      ]
    ]
  ]

end

;; manage well-off and not well-off turtles of type 'owners'
to manage-market-participation [occupiers]
  ;;; manage not-well-off owners (i.e., those not being able to pay repayments or rent)
  ;; evict mortgage and rent
  ; poorer owners with myType = mortgage
  let not-well-off-mortgage occupiers with [on-market? = false and is-house? my-house and myType = "mortgage" and (sum (repayment) * TicksPerYear) > (eviction-threshold-mortgage * (income + (sum (income-rent) * TicksPerYear)) * Affordability / 100)]
  ; poorer owners with myType = mortgage and only one house (these will be evicted)
  let not-well-off-mortgage-evict not-well-off-mortgage with [count turtle-set my-ownership <= 1]
  ; poorer owners with myType = rent (these will always be evicted)
  let not-well-off-rent occupiers with [on-market? = false and is-house? my-house and myType = "rent" and (my-rent * TicksPerYear) > (eviction-threshold-rent * income * Affordability / 100)]
  ; create a set of all the owners that will be evicted
  let not-well-off-evict (turtle-set not-well-off-mortgage-evict not-well-off-rent)
  ; evict and enter rent market
  if any? not-well-off-evict [
    evict not-well-off-evict
    enter-market not-well-off-evict "rent"
  ]

  ;; force mortgage with more than one ownership to sell one of his ownership
  ; poorer owners with myType = mortgage and mare than one house (these will stay and will only sell one of their houses) and without any house already on sale (if a house is on sale, then this owner is waiting for the sale to happen to make profit and stop being not-well-off
  let not-well-off-mortgage-stay not-well-off-mortgage with [count turtle-set my-ownership > 1 and count ( (turtle-set my-ownership) with [for-sale? = true] ) = 0 and count ( (turtle-set my-ownership) with [for-rent? = true] ) = 0]
  ; force-sell, but do not go into any market (the seller is not trying to buy any house)
  if any? not-well-off-mortgage-stay [
    force-sell-rent not-well-off-mortgage-stay
  ]

  ;; well off mortgage and rent
  let well-off-mortgage occupiers with [
    on-market? = false and
    is-house? my-house and
    myType = "mortgage" and (capital >= (median (mortgage)) * ( 1 - (MaxLoanToValue / 100) )) and
    ( ((income + (sum(income-rent) * TicksPerYear) * Affordability / 100) - (sum repayment) * TicksPerYear) > (median(repayment) * TicksPerYear) )
  ]
  ;; sale price * MaxLTV / 100 --> the expected mortgage value
  ;; sale price * (1 - (MaxLTV / 100)) --> the expected deposit
  let well-off-rent occupiers with [
    on-market? = false and
    is-house? my-house and
    myType = "rent" and
    capital >= (savings-to-rent-threshold * [sale-price] of my-house * (1 - (MaxLoanToValue / 100)) ) and
    ( (income * Affordability / 100) > [sale-price] of my-house * (MaxLoanToValue / 100) * interestPerTick / (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear)) )
  ]
  ; assure no agent is counted twice as well-off and not-well-off
  ask not-well-off-mortgage [set well-off-mortgage other well-off-mortgage]
  ask not-well-off-rent [set well-off-rent other well-off-rent]
  if any? well-off-mortgage [
    ;; assure the ones joining the BTL market: (1) have the propensity to become investors; and (2) are not on-cooldown
    ask well-off-mortgage [
      if propensity > (1 - investors) and on-cooldown? = false [enter-market self "buy-to-let"]
    ]
  ]
  if any? well-off-rent [
    ask well-off-rent [
      if propensity > (1 - upgrade-tenancy) [enter-market self "rent"]
      if propensity <= (1 - upgrade-tenancy) and on-cooldown? = false [enter-market self "mortgage"]
    ]

  ]

  ;; manage globals
  ifelse any? not-well-off-mortgage [
    ;set nEvictedMortgageOneHouse count not-well-off-mortgage with [count my-ownership = 1]
    ;set nEvictedMortgageMoreHouses count not-well-off-mortgage with [count my-ownership > 1]
  ]
  [
    set nEvictedMortgageOneHouse 0
    set nEvictedMortgageMoreHouses 0
  ]
  ifelse any? not-well-off-mortgage-evict [set nEvictedMortgage count not-well-off-mortgage-evict] [set nEvictedMortgage 0]
  ifelse any? not-well-off-evict          [set nEnterMarketRent count not-well-off-evict    set nHomeless count not-well-off-evict] [set nEnterMarketRent 0     set nHomeless 0]
  ifelse any? well-off-rent               [set nEnterMarketMortgage count well-off-rent] [set nEnterMarketMortgage 0]
  ifelse any? well-off-mortgage           [set nEnterMarketBuyToLet count well-off-mortgage] [set nEnterMarketBuyToLet 0]
  ifelse any? not-well-off-mortgage-stay  [set nForceSell count not-well-off-mortgage-stay] [set nForceSell 0]
  ifelse any? not-well-off-mortgage-evict  [set meanIncomeEvictedMortgage mean [income] of not-well-off-mortgage-evict] [set meanIncomeEvictedMortgage 0]
  ifelse any? not-well-off-rent [
    set nEvictedRent count not-well-off-rent
    set meanIncomeEvictedRent mean [income] of not-well-off-rent
  ]
  [
    set nEvictedRent 0
    set meanIncomeEvictedRent 0
  ]
end

;; evict occupiers from their houses (rented or mortgaged)
to evict [occupiers]
  ask occupiers [
    ;; if I am occupying a "mortgage" house (i.e., I own my house and live in it)
    if [myType] of my-house = "mortgage" [
      ;; manage my-house ownership parameters
      ask my-house [
        set my-occupier nobody
        set my-owner nobody
        set rented-to nobody
        ;; put the house in the "mortgage" market, now without an owner as the owner is being evicted
        put-on-market
      ]
      ;; find all my-ownership without including my-house
      let my-ownership-temp turtle-set my-ownership
      ask my-house [set my-ownership-temp other turtle-set my-ownership-temp]
      ;; address my-ownership without addressing my-house
      ask turtle-set my-ownership-temp [
        ;; If the ownership is a rented property
        if myType = "rent" [
          ;; and the ownership has an occupier
          if is-owner? my-occupier [
            ;; evict the occupier
            let my-occupier-temp my-occupier
            evict my-occupier-temp
            enter-market my-occupier-temp "rent"
          ]
          ;; manage ownership parameters and put the house on the mortgage market (with no owner)
          set myType "mortgage"
          set my-occupier nobody
          set my-owner nobody
          set rented-to nobody
          put-on-market
        ]
        ;; if my-ownership is a mortgage house (meaning it is on-sale? on the mortgage market)
        if myType = "mortgage" [
          ;; address the ownership parameters
          set my-occupier nobody
          set my-owner nobody
          set rented-to nobody
          set offered-to nobody
          ;; put the ownership back on the market, but now without an owner
          put-on-market
        ]
      ]
      ;; assure the owner being evicted now has no house and no ownership
      set my-house nobody
      set my-ownership (list)
      set mortgage (list)
      set repayment (list)
      set income-rent (list)
      set surplus-rent (list)
      ;; assure the homeless count is set back to 0
      set homeless 0
      stop
    ]

    ;; if I am living in a rented house
    if [myType] of my-house = "rent" [
      ;; put my house back on the rented market without an occupier
      ask my-house [
        set my-occupier nobody
        set rented-to nobody
        put-on-market
      ]
      ;; assure the landlord decreases their income-rent due to the eviction of a tenant
      let landlord [my-owner] of my-house
      if is-owner? landlord [
        let index-temp position my-house [my-ownership] of landlord
        ask landlord [
          set income-rent replace-item index-temp income-rent 0
          set surplus-rent replace-item index-temp surplus-rent (0 - item index-temp repayment)
        ]
      ]
      ;; assure I now have no house and set homeless to 0
      set my-house nobody
      set homeless 0
    ]
    hide-turtle
  ]
end


to force-sell-rent [sellers]
  ask sellers [
    ;; find all the ownership that is not the house I live in (this is to avoid selling the house I occupy and becoming homeless)
    let my-ownership-temp turtle-set my-ownership
    let surplus-rent-temp remove-item 0 surplus-rent
    let house-to-sell nobody
    let house-to-rent nobody
    ask my-house [set my-ownership-temp other turtle-set my-ownership-temp]
    (ifelse
      any? my-ownership-temp with [for-rent? = true and on-market-period >= maxForRentPeriodPoorLandlord] [
        set house-to-sell one-of my-ownership-temp with [for-rent? = true and on-market-period >= maxForRentPeriodPoorLandlord]
      ]
      ;; if no houses are offered for rent (all occupied), offer the house with the lowest rent profit on the rent market again
      not any? my-ownership-temp with [for-rent? = true] [
        ;type self type " | surplus-rent = " type surplus-rent type " | my-ownership = " type my-ownership type "\n"
        let index-temp position (min surplus-rent-temp) surplus-rent
        set house-to-rent item index-temp my-ownership
      ]

    )

    if any? turtle-set house-to-sell [
      ;; manage house to sell
      ask house-to-sell [
        if is-owner? my-occupier [
          let my-occupier-temp my-occupier
          evict my-occupier-temp
          enter-market my-occupier-temp "rent"
        ]
        set myType "mortgage"
        put-on-market
      ]
    ]

    if any? turtle-set house-to-rent [
      ;; manage house to rent
      ask house-to-rent [
        if is-owner? my-occupier [
          let my-occupier-temp my-occupier
          evict my-occupier-temp
          enter-market my-occupier-temp "rent"
        ]
        set myType "rent"
        put-on-market
      ]
    ]
  ]

end


;; force seller to put one of their ownership on the amrket (only triggered when a landlord is not well-off and needs to sell)
to force-sell [sellers]
  ask sellers [
    ;; find all the ownership that is not the house I live in (this is to avoid selling the house I occupy and becoming homeless)
    let my-ownership-temp turtle-set my-ownership
    let house-to-sell nobody
    ask my-house [set my-ownership-temp other turtle-set my-ownership-temp]
    ;; if there is a house that is not for sale and is not rented, sell that house
    ifelse any? my-ownership-temp with [for-sale? = false and rented-to = nobody] [
      set house-to-sell one-of my-ownership-temp with [for-sale? = false and rented-to = nobody]
    ]
    ;; if all the houses are rented, check the one that will yield the highest capital and sell it
    [
      ;; start from index 1 as the first item in the list is always my-house
      let i 1
      ;; set a list with one element 0 (reflecting no benefit from selling own house)
      let surplus (list 0)
      ;; loop into the ownership to create a list of surplus values
      while [i < length my-ownership] [
        let mortgage-temp item i mortgage
        let price-temp [sale-price] of item i my-ownership
        set surplus lput (price-temp - mortgage-temp) surplus
        set i i + 1
      ]
      ;; select the ownership leading to the highest surplus
      let index-temp position max(surplus) surplus
      set house-to-sell item index-temp my-ownership
    ]

    if any? turtle-set house-to-sell [
      ;; amange
      ask house-to-sell [
        if is-owner? my-occupier [
          let my-occupier-temp my-occupier
          evict my-occupier-temp
          enter-market my-occupier-temp "rent"
        ]
        set myType "mortgage"
        put-on-market
      ]
    ]
  ]

end

;; enter the market for mortgage or rent
to enter-market [candidates market-type]
  ask candidates [
    set on-cooldown? false
    set time-on-cooldown 0
    set time-on-market 0
    set on-market? true
    set on-market-type market-type
  ]
end

to new-houses
   ;; some new houses are built, and put up for sale ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  repeat count houses * HouseConstructionRate / 100 [  ;; build a fixed proportion of new houses
    if any? patches with [ not any? houses-here ]  [build-house "mortgage"]
  ]
  reset-empty-houses ; set sale and rent price

  ask houses with [ quality = 0 ] [ ;; ask each house with quality = 0
      let houses-around-here other houses in-radius Locality
      ;; put ( the other houses which are within the radius circle where the current house is the center ) under `houses-around-here`
      set quality ifelse-value any? houses-around-here ;; if `houses-around-here` exist, then return first value to `quality`
        [ mean [ quality ] of houses-around-here ]
        [ 1 ]                                          ;; if `houses-around-here` exist, then return second value to `quality`
      if quality > 3 [set quality 3]  ;; quality has upper limit to be 3
      if quality < 0.3 [set quality 0.3]  ;; quality has lower limit to be 0.3
  ]

end

to trade-houses
  let houses-for-sale houses with [ for-sale? = true]                                  ;; find all the houses for sale
  ;; Consider for-rent?
  let houses-for-rent houses with [ for-rent? = true]
  value-hosues houses-for-sale houses-for-rent

  ;; we check here whether houses are on-market or not (as this is a decision that should have been premade by the owner)
  let buyers owners with [ on-market? = true ]  ;; put all owners who don't have a house or whose houses on sale under `buyers`


  make-offers buyers houses-for-sale houses-for-rent
  ;; if a deal is made, then households will move in and out of houses
  set moves 0                                                                        ;; the number of households moving in this step

  ;; Removed the condition --> not is-house? my-house (as in this version, traders are any buyers on the market that made an offer regardless of my-house)
  ask buyers with [ is-house? made-offer-on and on-market? = true] [           ;; ask buyers who have no houses and made offer on a house
                                                                               ;; self is buyer, and check whether the buy-sell chain is intact or not
    if follow-chain self self [
      ;move-house                                                          ;; if intact, deal is made, and households move out and into houses, count the number of moves
      move-house self
    ]
  ]


end


to value-hosues [houses-for-sale houses-for-rent]
  ;; value-houses ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; initially, house sale-price is added up by mortgage and deposit in setup
  ;; once a house put on sale, sale-price, my-realtor (house) , average-price (realtor), median price for all houses on sale, are to be updated.
  ;; because sellers will ask all local-realtors to value the house again and the seller will choose my-realtor again to update the sale-price

  if any? houses-for-sale [                                                      ;; if these houses exist
    ask houses-for-sale with [ date-for-sale = ticks ] [                         ;; ask each of those houses which are just on sale from now on
      set my-realtor max-one-of turtle-set local-realtors [ valuation myself ]               ;; set the realtor gives the current house the highest valuation to be my-realtor
      set sale-price [ valuation myself ] of my-realtor                           ;; take the highest value valuation price as sale-price of the current house
    ]                                                                                   ;; update the average-price of each realtor
    ask realtors [                                                                 ;; ask each realtor
      let my-houses-for-sale houses-for-sale with [ member? myself local-realtors and myType = "mortgage"] ;; get all houses under this realtor
      if any? my-houses-for-sale [ set average-price median [ sale-price ] of my-houses-for-sale ]
                                                        ;; if these houses exist, take their median price as the realtor's average-price for its all houses
    ]
    set medianPriceOfHousesForSale median [sale-price] of houses-for-sale
  ]

  if any? houses-for-rent [                                                      ;; if these houses exist
    ask houses-for-rent with [ date-for-rent = ticks ] [                         ;; ask each of those houses which are just on sale from now on
      set my-realtor max-one-of turtle-set local-realtors [ valuation myself ]               ;; set the realtor gives the current house the highest valuation to be my-realtor
      ;; Modified to rent-price
      set rent-price [ valuation myself ] of my-realtor                           ;; take the highest value valuation price as sale-price of the current house
    ]                                                                                  ;; update the average-price of each realtor
    ask realtors [                                                                 ;; ask each realtor
      let my-houses-for-rent houses-for-rent with [ member? myself local-realtors and myType = "rent"] ;; get all houses under this realtor
      ;; Modified to median of rent-price
      if any? my-houses-for-rent [ set average-rent median [ rent-price ] of my-houses-for-rent ] ;; if these houses exist, take their median price as the realtor's average-price for its all houses
    ]
    ;; Modified to rent-price
    set medianPriceOfHousesForRent median [rent-price] of houses-for-rent           ;; update median price of all houses on sale
  ]
end

to-report valuation [ property ]    ;; realtor procedure
  ;; valuation house price by realtor ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  let normalization 1  ;; create a local variable normalization
  let multiplier [ quality ] of property * (1 + RealtorOptimism / 100) * normalization         ;; create a multiplier for final finish of valuation price ;; component of multiplier include quality, optimism, normalization

  let old-price [sale-price] of property  ;; set the input house's sale-price as old price
  let old-rent [rent-price] of property
  let new-price 0  ;; create a new price variable with 0 value
  let new-rent 0
  let ptype [myType] of property

  ; if calculate-wealth? is true, use the saved lists of houses and records in houses (saves run time)
  ifelse calculate-wealth? = true [
    let i position self [local-realtors] of property
    let local-sales-sold item i [local-sales] of property
    let local-sales-rent item i [local-rents] of property
    let plocality [locality-houses] of property

    if ptype = "mortgage" [ ; owned
      ifelse any? turtle-set local-sales-sold  ;; if the local-sales exist
      [ set new-price median [ selling-price ] of turtle-set local-sales-sold ] ;; assign the median price of all record houses to new-price
      [ let local-houses turtle-set filter [h -> [myType] of h = "mortgage"] plocality ;; if no local-sales exist, take neighboring houses around the current realtor under `local-houses`
        ifelse any? local-houses  ;; if local-houses exist
        [set new-price median [sale-price] of local-houses  ;; set the median price of all local-houses to be new-price
        ]
        [set new-price average-price ] ;; otherwise set average-price of the realtor to be new-price (is realtor's average-price updated every tick?)
      ]
    ]

    ; not owned
    if ptype = "rent"[
      ifelse any? turtle-set local-sales-rent  ;; if the local-sales exist
                                               ;; modified to new-rent and rent-price
      [ set new-rent median [ renting-price ] of turtle-set local-sales-rent ] ;; assign the median price of all record houses to new-price
      [ let local-houses turtle-set filter [h -> [myType] of h = "rent"] plocality;; if no local-sales exist, take neighboring houses around the current realtor under `local-houses`
        ifelse any? local-houses  ;; if local-houses exist
        [set new-rent median [rent-price] of local-houses  ;; set the median price of all local-houses to be new-price
        ]
        [set new-rent average-rent ] ;; otherwise set average-price of the realtor to be new-price (is realtor's average-price updated every tick?)
      ]
    ]
  ]

  ; if calculate-wealth? = false, find the locality houses and the records while evaluating
  [
    let local-sales-sold (turtle-set sales-sold) with [ the-house != nobody and ( [distance property ] of the-house ) < Locality and selling-price > 0]  ;; new-version
                                                                                                                                                         ;; under realtor context, sales is a list of records, use `turtle-set` force list into an agentset to use with, each record has property of the-house
                                                                                                                                                         ;; get all the sales (lists of records) whose houses are sold and those sold-houses are neighboring to the input house under `local-sales`
    let local-sales-rent (turtle-set sales-rent) with [ the-house != nobody and ( [distance property ] of the-house ) < Locality and renting-price > 0]  ;; new-version

    if ptype = "mortgage" [ ; owned
      ifelse any? local-sales-sold  ;; if the local-sales exist
      [ set new-price median [ selling-price ] of local-sales-sold ] ;; assign the median price of all record houses to new-price
      [ let local-houses houses with [ distance myself <= Locality and myType = "mortagage" ];; if no local-sales exist, take neighboring houses around the current realtor under `local-houses`
        ifelse any? local-houses  ;; if local-houses exist
        [set new-price median [sale-price] of local-houses  ;; set the median price of all local-houses to be new-price
        ]
        [set new-price average-price ] ;; otherwise set average-price of the realtor to be new-price (is realtor's average-price updated every tick?)
      ]
    ]

    ; not owned
    if ptype = "rent"[
      ifelse any? local-sales-rent  ;; if the local-sales exist
                                    ;; modified to new-rent and rent-price
      [ set new-rent median [ renting-price ] of local-sales-rent ] ;; assign the median price of all record houses to new-price
      [ let local-houses houses with [ distance myself <= Locality and myType = "rent" ];; if no local-sales exist, take neighboring houses around the current realtor under `local-houses`
        ifelse any? local-houses  ;; if local-houses exist
        [set new-rent median [rent-price] of local-houses  ;; set the median price of all local-houses to be new-price
        ]
        [set new-rent average-rent ] ;; otherwise set average-price of the realtor to be new-price (is realtor's average-price updated every tick?)
      ]
    ]
  ]

  let ratio 0
  let threshold 2 ;; a base line for ratio
  if pType = "mortgage" [
    if old-price < 5000 [ report multiplier * new-price ]  ;; if current sale-price is too low, just accept multiplier * new-price  as valuation price
    set ratio new-price / old-price
    ifelse ratio > threshold  ;;
    [ set new-price threshold * old-price ] ;; if new-price is more than twice old-price,  make new-price twice of old-price. "
    [ if ratio < 1 / threshold [  set new-price old-price / threshold ] ]  ;;  if new-price is less than half of old-price, make new-price half of old-price.
    report  multiplier * new-price  ;; finally report multiplier * new-price" "."
  ]
  if pType = "rent" [
    if old-rent < 500 [ report multiplier * new-rent ]  ;; if current sale-price is too low, just accept multiplier * new-price  as valuation price
    set ratio new-rent / old-rent
    ifelse ratio > threshold  ;;
    [ set new-rent threshold * old-rent ] ;; if new-rent is more than twice old-rent,  make new-rent twice of old-rent. "
    [ if ratio < 1 / threshold [  set new-rent old-rent / threshold ] ]  ;;  if new-rent is less than half of old-rent, make new-rent half of old-rent.
    report  multiplier * new-rent  ;; finally report multiplier * new-rent" "."
  ]

end

to make-offers [buyers houses-for-sale houses-for-rent]
  ;; make an offer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Owners make an offer based on the market type they are in
  ; start with "mortgage" | these "owners" want to buy a house to reside in
  ask buyers with [ on-market? = true and on-market-type = "mortgage" ] [
    make-offer-mortgage houses-for-sale
  ]
  ; second, address "buy-to-let" | these buyers already have a house and they are well-off enough to buy another one
  ask buyers with [ on-market? = true and on-market-type = "buy-to-let" ] [
    make-offer-mortgage houses-for-sale
  ]
  ; third, address "rent" | these buyers do not own a house and want to become a tenant
  ask buyers with [ on-market? = true  and on-market-type = "rent" ] [
    make-offer-rent houses-for-rent
  ]
  set nOwnersOffered count owners with [is-house? made-offer-on ]

end

to make-offer-mortgage [ houses-for-sale ]
  ;; increment the time on market counter by 1 (applied for all market types)
  set time-on-market time-on-market + 1

  if on-market-type = "mortgage" [
    ;; use current income, Affordability, interestPerTick to calc new-mortgage
    let new-repayment (income * Affordability / (ticksPerYear * 100))
    let new-mortgage (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear )) * new-repayment / interestPerTick
    ;set deposit ( new-mortgage * ( 100 /  MaxLoanToValue - 1 ) )  ;; create deposit

    ;; use current income, Affordability, interestPerTick to calc new-mortgage
    ;let new-mortgage income * Affordability / ( interestPerTick * ticksPerYear * 100 )
    ;; actual budget for buying a house == new-mortgage - duty or tax we get back
    let budget new-mortgage - stamp-duty-land-tax new-mortgage
    ;; buyer use capital to pay for new deposit
    let deposit capital
    ;; under the context of owners, if it has a house, update new deposit with new deposit + sale-price of current house - current mortgage of my-house
    if is-house? my-house [
      let index-temp position my-house my-ownership
      if [for-sale?] of my-house = true [set deposit deposit + ([ sale-price ] of my-house - item index-temp mortgage) ]
    ]
    ;; upperbound = the maximum amount afford to offer on a house = new mortgage - duty-back + new deposit
    let upperbound budget + deposit
    ;; if mortgage is less than house value => (MaxLoanToValue/100 < 100/100 ) ;; update upperbound with the less between two similar values
    if MaxLoanToValue < 100 [set upperbound min ( list (budget + deposit) (deposit / ( 1 - MaxLoanToValue / 100 )) ) ]

    ;; if I cannot purchase, but I have a house, get out of the market for this round and assure any offers made to my house are removed
    if upperbound < 0 and is-house? my-house[
      set on-market? false
      set on-market-type nobody
      ask my-house [
        set for-sale? false
        set for-rent? false
        if is-owner? offered-to [ask offered-to [set made-offer-on nobody]]
        set offered-to nobody
        set rented-to nobody
      ]
      stop
    ]
    ;; if I cannot purchase and I do not have a house, stay on the market (i.e., do nothing)
    if upperbound < 0 and not is-house? my-house [stop]

    ;; set lowerbound to be 70% of upperbound
    let lowerbound upperbound * 0.7
    ;; get the current owner's my-house under `current-house`
    let current-house my-house
    let current-ownership turtle-set my-ownership
    ;; from all the houses on sale, get those
    ;; without offer
    ;; and sale-prices within upperbound
    ;; and sale-prices greater than lowerbound
    ;; and the house is not current house, assinged  into `interesting-houses`
    let interesting-houses houses-for-sale with [
      not is-owner? offered-to and
      sale-price <= upperbound and
      sale-price > lowerbound and
      self != current-house ]
    ;; assure buyers on mortgage market do not make offers on their own houses
    if any? current-ownership [ask current-ownership [set interesting-houses other interesting-houses]]
    ;; if number of interesting-houses > BuyerSearchLength (number of houses buyers willing to see)
    ;; then select randomly BuyerSearchLength number of interesting-houses
    if count interesting-houses > BuyerSearchLength [set interesting-houses n-of BuyerSearchLength interesting-houses with [sale-price < (budget + deposit)]]
    ;; if interesting-houses exist
    if any? interesting-houses [
      ;; find the house with the maximum sale-price of interesting-houses and assigned to `property` a local-var
      let property max-one-of interesting-houses [ sale-price ]
      ;; if the `property` is a house
      if is-house? property [
        ;; assign the current owner as `offered-to` under the context of `property`
        ;; set `ticks` to be `offer-date` (house property)
        ask property [
          set offered-to myself
          set offer-date ticks
        ]
        ;; assign `property` (a house ) to owner's property `made-offer-on`
        set made-offer-on property
      ]
    ]
  ]

  if on-market-type = "buy-to-let" [
    ;; use current income, Affordability, interestPerTick to calc new-mortgage
    let new-repayment (income * Affordability / (ticksPerYear * 100))
    let new-mortgage (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear )) * new-repayment / interestPerTick
    ;let new-mortgage income * Affordability / ( interestPerTick * ticksPerYear * 100 )
    ;; actual budget for buying a house == new-mortgage - duty or tax we get back
    let budget new-mortgage - stamp-duty-land-tax new-mortgage
    ;; buyer use capital to pay for new deposit
    let deposit capital
    ;; upperbound = the maximum amount afford to offer on a house = new mortgage - duty-back + new deposit
    let upperbound budget + deposit
    ;; if mortgage is less than house value => (MaxLoanToValue/100 < 100/100 ) ;; update upperbound with the less between two similar values
    if MaxLoanToValue < 100 [set upperbound min ( list (budget + deposit ) ( deposit / ( 1 - MaxLoanToValue / 100 ))) ]
    ;; under the context of owners, if it has a house, update new deposit with new deposit + sale-price of current house - current mortgage
    if upperbound < 0 [
      set on-market? false
      set on-market-type nobody
      stop
    ]
    ;; set lowerbound to be 70% of upperbound
    let lowerbound upperbound * 0.7
    ;; get the current owner's my-house under `current-house`
    let current-house my-house
    ;; get the current owner's my-ownership under 'current-ownership'
    let current-ownership turtle-set my-ownership
    ;; from all the houses on sale, get those
    ;; without offer
    ;; and sale-prices within upperbound
    ;; and sale-prices greater than lowerbound
    ;; and the house is not current house, assinged  into `interesting-houses`
    let interesting-houses houses-for-sale with [
      not is-owner? offered-to and
      sale-price <= upperbound and
      sale-price > lowerbound and
      self != current-house ]
    ;; assure buyers on buy-to let market do not make offers on their own houses
    if any? current-ownership [ask current-ownership [set interesting-houses other interesting-houses]]
    ;; if number of interesting-houses > BuyerSearchLength (number of houses buyers willing to see)
    ;; then select randomly BuyerSearchLength number of interesting-houses
    if count interesting-houses > BuyerSearchLength [set interesting-houses n-of BuyerSearchLength interesting-houses with [sale-price < (budget + deposit)]]
    ;; if interesting-houses exist
    if any? interesting-houses [
      ;; find the house with the maximum sale-price of interesting-houses and assigned to `property` a local-var
      let property max-one-of interesting-houses [ sale-price ]
      ;; if the `property` is a house
      if is-house? property [
        ;; assign the current owner as `offered-to` under the context of `property`
        ;; set `ticks` to be `offer-date` (house property)
        ask property [
          set offered-to myself
          set offer-date ticks
        ]
        ;; assign `property` (a house ) to owner's property `made-offer-on`
        set made-offer-on property
      ]
    ]
  ]

end

to make-offer-rent [ houses-for-rent ]
  ;; increment the time on market counter by 1
  set time-on-market time-on-market + 1

  let new-rent income * Affordability / ( ticksPerYear * 100 );; use current income, Affordability, interestPerTick to calc new-mortgage
  let budget new-rent
  let upperbound budget                                                    ;; upperbound = the maximum amount afford to offer on a house = new mortgage - duty-back + new deposit
;  if upperbound < 0 [                                                               ;; if upperbound is less than 0, meaning the owner has negative equity (how it is possible?)
;    ;; modified to for-rent
;    ask my-house [ set for-rent? false ]                                            ;; pull the house back from market, and stay in the house
;    stop                                                                            ;; this owner stop performing the rest action below
;    ]

  let lowerbound upperbound * 0.7                                                   ;; set lowerbound to be 70% of upperbound
  let current-house my-house                                                        ;; get the current owner's my-house under `current-house`
  let interesting-houses houses-for-rent with [                                     ;; from all the houses on sale, get those
                            not is-owner? offered-to and                            ;; without offer
                            rent-price <= upperbound and                            ;; and sale-prices within upperbound
                            rent-price > lowerbound and                             ;; and sale-prices greater than lowerbound
                            self != current-house ]                                 ;; and the house is not current house,            assinged  into `interesting-houses`


  if count interesting-houses > BuyerSearchLength [                                 ;; if number of interesting-houses > BuyerSearchLength (number of houses buyers willing to see)
    set interesting-houses n-of BuyerSearchLength interesting-houses                ;; then select randomly BuyerSearchLength number of interesting-houses
    ]

  if any? interesting-houses [                                                      ;; if interesting-houses exist
    let property max-one-of interesting-houses [ rent-price ]                       ;; find the house with the maximum sale-price of interesting-houses and assigned to `property` a local-var
      if is-house? property [                                                       ;; if the `property` is a house
      ask property [                                                                ;; ask this house
          set offered-to myself                                                     ;; assign the current owner as `offered-to` under the context of `property`
          set offer-date ticks                                                      ;; set `ticks` to be `offer-date` (house property)
        ]
      set made-offer-on property                                                  ;; assign `property` (a house ) to owner's property `made-offer-on`
    ]
  ]
end

to-report stamp-duty-land-tax [ cost ]
  ;; stamp duty land tax ('stamp duty') is 1% for sales over $150K, 3% over $250K, 4% over $500K,  (see http://www.hmrc.gov.uk/so/rates/index.htm )
  if StampDuty? [

    if cost > 500000 [ report 0.04 * cost ]

    if cost > 250000 [ report 0.02 * cost ]

    if cost > 150000 [ report 0.01 * cost ]
    ]

  report 0
end

;; function can now be called anywhere (not owner specific)
to-report follow-chain [buyer-tenant first-link]

  ;; If the buyer-tenant did not make any offer or is not on the market in the first place, report a false chain
  if not is-house? [made-offer-on] of buyer-tenant [report false]
  if [on-market?] of buyer-tenant = false [report false]
  ;; If the buyer is on the mortgage market
  if [on-market-type] of buyer-tenant = "mortgage" or [on-market-type] of buyer-tenant = "buy-to-let" [
    let buyer buyer-tenant
    let seller [my-owner] of made-offer-on
    ;; If there is no seller (i.e., house not owned), report a true chain
    if not is-owner? seller [report true]
    ;; If the seller has more than one house (i.e., seller does not need to find another house to buy before the transaction), report a true chain
    if count turtle-set [my-ownership] of seller > 1 [report true]
    if buyer = seller [report true]
    if seller = first-link [report true]
    ;; Else, meaning, if the seller has one house, check if the seller has a confirmed house to buy before making the transaction
    report follow-chain seller first-link
  ]

  if [on-market-type] of buyer-tenant = "rent" [
    let tenant buyer-tenant
    let house-made-offer-on [made-offer-on] of tenant
    let landlord [my-owner] of house-made-offer-on
    ;; If there is no occupier (i.e., the house is vacant and can be directly rented), report true chain
    if not is-owner? [my-occupier] of house-made-offer-on [report true]
    if first-link = [my-occupier] of house-made-offer-on [report true]
    ;; Else, meaning, if there is an occupier, check if that occupier found anouther house to rent or not before making the transaction
    report follow-chain [my-occupier] of house-made-offer-on first-link
  ]
end



to move-house [buyer-tenant]
  let new-house [made-offer-on] of buyer-tenant
  if not (is-house? new-house) [stop]

  if on-market-type = "mortgage" or on-market-type = "buy-to-let" [
    ;; define buyer and seller
    let buyer buyer-tenant
    let seller [my-owner] of new-house
    ;; address the surplus of the seller if they exist
    if is-owner? seller [manage-surplus-seller seller new-house]
    ;; address the surplus of the buyer (includes managing capital, mortgage and repayments
    ;; manage the budget/capital of buyer
    manage-surplus-buyer buyer
    ;; manage the ownership parameters of the buyer
    manage-ownership-buyer buyer
    ;; if there is a seller, manage their ownership parameters
    if is-owner? seller [
      manage-ownership-seller seller new-house
    ]

  ]

  if on-market-type = "rent"[
    ;; define tenant and landlord
    let tenant buyer-tenant
    let landlord [my-owner] of new-house
    ; manage the budget/income of the landlord
    manage-surplus-landlord landlord new-house
    ; manage the budget of the tenant
    manage-surplus-tenant tenant
    ; manage the ownership parameters of the tenant
    manage-ownership-tenant tenant
  ]

end

to manage-ownership-tenant [tenant]
  let new-house [made-offer-on] of tenant
  let house-temp my-house
  ask tenant [
    ;; if seller is an owner, calc the rent and assign.
    ;; record the rent transaction
    hatch-records 1 [
      hide-turtle
      move-to new-house
      set date ticks
      set date ticks
      set the-house new-house
      set selling-price 0
      set renting-price [rent-price] of new-house
      ;ask [ my-realtor ] of new-house [ file-record myself ]
      file-record ([my-realtor] of new-house) (self)
    ]
    ;; manage the parameters of the renter
    show-turtle
    move-to new-house
    set homeless 0
    set time-on-market 0
    set on-cooldown? false
    set time-on-cooldown 0
    set myType "rent"
    set my-house new-house
    set my-rent [ rent-price ] of new-house
    set my-ownership (list)
    set made-offer-on nobody
    set on-market? false
    set on-market-type nobody
    ; manage the parameters of the new-house
    ask new-house [
      ;; make sure the occupier unregisters the house from their my-house parameter
      ;; the occupier will later rent another house (this is checked within the follow-chain function)
      if is-owner? my-occupier [ask my-occupier [set my-house nobody]]
      set my-occupier myself
      set rented-to myself
      set for-sale? false
      set for-rent? false
    ]
    ; manage the parameters of the old house
    if is-house? house-temp [
      ask house-temp [
        set my-occupier nobody
        set rented-to nobody
        set for-sale? false
        set for-rent? true
      ]
    ]
  ]
end

to manage-ownership-buyer [buyer]
  let new-house [made-offer-on] of buyer
  ask buyer [
    let house-temp my-house
    if on-market-type = "mortgage" [
      ;; record the sale transaction
      hatch-records 1 [
        hide-turtle
        move-to new-house
        set date ticks
        set the-house new-house
        set selling-price [sale-price] of new-house
        set renting-price [rent-price] of new-house
        ;ask [ my-realtor ] of new-house [ file-record myself ]
        file-record ([my-realtor] of new-house) self
      ]

      ;; manage the situation when a renter is buying and moving from their current my-house
      if is-house? my-house [
        if [myType] of my-house = "rent" [
          ask my-house [
            set my-occupier nobody
            set rented-to nobody
            put-on-market
          ]
        ]
      ]

      ;; move to the new house
      show-turtle
      move-to new-house
      set homeless 0
      set time-on-market 0
      set on-cooldown? false
      set time-on-cooldown 0
      set myType "mortgage"
      set my-house new-house
      set date-of-acquire ticks
      ;; address the parameters of the new house, and take it off the market
      ask new-house [
        set myType "mortgage"
        set my-owner myself
        set my-occupier myself
        set rented-to nobody
        set offered-to nobody
        set for-sale? false
        set for-rent? false
      ]

      ;; manage the parameters of the buyer
      set my-ownership (list new-house)
      set made-offer-on nobody
      set on-market? false
      set on-market-type nobody
    ]


    if on-market-type = "buy-to-let" [
      ;; record the transaction
      hatch-records 1 [
        hide-turtle
        move-to new-house
        set date ticks
        set the-house new-house
        set selling-price [sale-price] of new-house
        set renting-price [rent-price] of new-house
        file-record ([my-realtor] of new-house) self
      ]
      ;; manage the parameters of the new house, and put it on the rent market (the buy-to-let buyers must directly put their new purchase on the "rent" market)
      ask new-house [
        set myType "rent"
        set my-owner myself
        set my-occupier nobody
        set rented-to nobody
        set offered-to nobody
        put-on-market
      ]
      ;; manage the parameters of the buyer
      set time-on-market 0
      set on-cooldown? false
      set time-on-cooldown 0
      set my-ownership (lput new-house my-ownership)
      set made-offer-on nobody
      set on-market? false
      set on-market-type nobody
    ]
  ]

end

to manage-ownership-seller [seller seller-house]
  ask seller [
    ;let my-ownership-temp my-ownership
    ;ask seller-house [set my-ownership-temp other turtle-set my-ownership-temp]
    ;set my-ownership my-ownership-temp
    set my-ownership remove seller-house my-ownership
  ]
end

;; manages the surplus from a trade for the seller of an input house
to manage-surplus-seller [seller seller-house]
  let new-house seller-house
  ;let surplus [sale-price] of seller-house - [mortgage] of seller
  ask seller [
    ;; find the index of the seller-house
    let index-temp position seller-house my-ownership
    ;; find the mortgage of the seller-house
    let mortgage-temp item index-temp mortgage
    ;; calculate the monetary surplus from selling the house (surplus should always be above or equal 0)
    let surplus [sale-price] of seller-house - mortgage-temp
    set capital capital + surplus
    set mortgage remove-item index-temp mortgage
    set mortgage-initial remove-item index-temp mortgage-initial
    set repayment remove-item index-temp repayment
    set income-rent remove-item index-temp income-rent
    set surplus-rent remove-item index-temp surplus-rent
    set rate remove-item index-temp rate
    set rate-duration remove-item index-temp rate-duration
    set mortgage-duration remove-item index-temp mortgage-duration


    ;; surplus is higher than 0, meaning the seller made a profit above their total mortgage
    ;ifelse surplus >= 0 [set mortgage 0 set capital capital + surplus]
    ;; surplus is lower than 0, meaning the seller still has to pay a mortgage (all sale-price covers part of the mortgage)
    ;[set mortgage abs(surplus)]
    ;; calc repayment to pay back mortgage again after selling the house
    ;set repayment mortgage * interestPerTick / (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear ))
  ]
end

;; owner function, manages capital, mortgage and repayment
to manage-surplus-buyer [buyer]
  let new-house [made-offer-on] of buyer
  ;; deduct the costs from the buyer (we are certain the owner has no my-ownership, else they will be on the buy-to-let market)
  let duty stamp-duty-land-tax [sale-price] of new-house
  let price-and-duty [sale-price] of new-house + duty
  ask buyer [
    ; if capital is not enough to pay for the house
    ifelse [sale-price] of new-house > capital [
      ; borrow as much as possible, given owner's income and value of house, choose the smaller value of two calc formula
      ; make sure the buyer adds to their current mortgage (to make sure if they are no buy-to-let their mortgage accounts for more than one house)
;      let mortgage-temp (min (list (income * Affordability / ( interestPerTick * ticksPerYear * 100 ))
;        ([ sale-price ] of new-house * MaxLoanToValue / 100 )))
      ;; after paying rest with capital, the remaining is still kept inside capital
;      set capital capital - int ([ sale-price ] of new-house - mortgage-temp) - duty

      let mortgage-temp (price-and-duty - capital)
      set capital 0

      ;; calc repayment to pay back mortgage
      let repayment-temp mortgage-temp * interestPerTick / (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * TicksPerYear ))
      ;; assign the repayment-temp and mortgage temp to their respective list for the owners
      set mortgage lput mortgage-temp mortgage
      set mortgage-initial lput mortgage-temp mortgage-initial
      set repayment lput repayment-temp repayment
      set income-rent lput 0 income-rent
      set surplus-rent lput (0 - repayment-temp) surplus-rent
      ;; assign the mortgage rate and rate duration
      set rate lput interestPerTick rate
      ifelse length my-ownership = 0
      [set rate-duration lput ((MinRateDurationM + random (MaxRateDurationM - MinRateDurationM)) * ticksPerYear) (rate-duration)]
      [set rate-duration lput ((MinRateDurationBTL + random (MaxRateDurationBTL - MinRateDurationBTL)) * ticksPerYear) (rate-duration)]
      set mortgage-duration lput (MortgageDuration * ticksPerYear) mortgage-duration
    ]
    ; or if the buyer is a cash buyer, capital pays all, mortgage, repayment both are 0, and remaining still kept in capital
    [
      ;; if the buyer is paying in cash, their mortgage and repayment do not change
      set capital capital - [sale-price] of new-house - duty
      if capital < 0 [set capital 0]
      set mortgage lput 0 mortgage
      set mortgage-initial lput 0 mortgage-initial
      set repayment lput 0 repayment
      set income-rent lput 0 income-rent
      set surplus-rent lput 0 surplus-rent
      set rate lput 0 rate
      ;; nobody in rate-duration is a dummy variable assuring that this mortgage is never checked
      set rate-duration lput nobody rate-duration
      set mortgage-duration lput nobody mortgage-duration
    ]
  ]
end

to manage-surplus-landlord [landlord landlord-house]
  let rent-temp [rent-price] of landlord-house
  let index-temp position landlord-house [my-ownership] of landlord
  let repayment-temp item index-temp [repayment] of landlord
  ;; add the rent to the yearly income of the landlord
  ask landlord [
    set income-rent replace-item index-temp income-rent rent-temp
    set surplus-rent replace-item index-temp surplus-rent (rent-temp - repayment-temp)
  ]

end

to manage-surplus-tenant [tenant]
  ;; assign the rent parameter of the tenant
  let new-house [made-offer-on] of tenant
  ask tenant [
    set my-rent [ rent-price ] of new-house
  ]
end

to remove-outdates

  ;; remove old record ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; after certain period, all old records should be removed, realtors will remove all their sales
  ask records [ if date < (ticks - RealtorMemory) [ die ] ] ;; for each record, after RealtorMemory duration, it has to be removed
  ask realtors [ set sales-rent remove nobody sales-rent ] ;; ask realtors to remove dead records from the sales list
  ask realtors [ set sales-sold remove nobody sales-sold ] ;; ask realtors to remove dead records from the sales list


  ;; remove offers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; remove the offer information upon a house
  ask houses with [ is-owner? offered-to ] [  ;; for each of the houses which have owners/buyer to make offer on
    ask offered-to [ set made-offer-on nobody ] ;; ask each buyer to set property `made-offer-on` as nobody
    set offered-to nobody  ;; set the house's buyer property `offered-to` to be nobody
    set offer-date 0  ;; set house property `offer-date` to 0
    ;set for-sale? false
    ;set for-rent? false
  ]
end

to demolish-houses
   ;; demolish houses ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;demolish old houses or houses with below minimum price
   set nDemolished 0  ;; record the number of demolished houses at each tick

   if any? records [  ;; if there are records left

    let minimum-price-sold min-price-fraction * medianPriceOfHousesForSale ;; set minimum-price to be 10% of all sold-houses median price
    let minimum-price-rent min-price-fraction * medianPriceOfHousesForRent ;; set minimum-price to be 10% of all sold-houses median price
    let houses-rent houses with [myType = "rent"]
    let houses-sell houses with [myType = "mortgage"]

    ;; ask all houses, if its life is over its life limit or if the house is for sale and sale-price < minimum-price
    let houses-to-demolish (turtle-set
      houses-sell with [ (ticks > end-of-life) or  (for-sale? and sale-price <  minimum-price-sold )]
      houses-rent with [ (ticks > end-of-life) or  (for-rent? and rent-price <  minimum-price-rent )]
    )

    ask houses-to-demolish [
      ;ask realtors [ unfile-record myself ] ;; delete any record that mentions the house inside the sales of a realtor
      ask realtors [unfile-record self myself]
      ; remove the house from the locality of its surrounding houses
      if calculate-wealth? = true [ask turtle-set locality-houses [set locality-houses remove myself locality-houses]]
      ;; if the house is for mortgage and not on sale (i.e., the owner should be the occupier of the house)
      if myType = "mortgage" and for-sale? = false [
        ;; add the sale-price to the capital (this is applied as per the previous model without considering mortgage)
        ask my-owner [
          set capital capital + [sale-price] of myself
        ]
        ;; evict the current occupier
        let my-occupier-temp my-occupier
        evict my-occupier-temp
        enter-market my-occupier-temp "mortgage"
        ;; demolish the house
        die
      ]
      ;; if the house is for mortgage and for sale (i.e., there are two options: (1) the owner put a rent house on the market as a type mortgage; (2) the owner put his/her own my-house on the market)
      if myType = "mortgage" and (for-sale? = true or for-rent? = true) [
        ; If the house is offered to an agent
        if is-owner? offered-to [
          ask offered-to [set made-offer-on nobody]
        ]
        ; if the house has an owner and an occupier (these must always be the same unless there is a bug)
        if is-owner? my-owner and is-owner? my-occupier [
          ask my-owner [
            set capital capital + [sale-price] of myself
          ]

          let my-occupier-temp my-occupier
          evict my-occupier-temp
          enter-market my-occupier-temp "mortgage"

          die

        ]
        ; if the house has an owner but there is nobody occupying it (can happen if it was for rent and is now put on the mortgage market due to a downshock or low income for the owner)
        if is-owner? my-owner and not is-owner? my-occupier [
          ;; remove the house from the owner's current my-ownership
          ;let my-owner-temp my-owner
          ask my-owner [
            ;let my-ownership-temp turtle-set my-ownership
            ;ask myself [set my-ownership-temp other turtle-set my-ownership-temp]
            ;set my-ownership my-ownership-temp

            ;; remove all the items associated to the demolished house from the owner's list
            let index-temp position myself my-ownership
            set my-ownership remove-item index-temp my-ownership
            set mortgage remove-item index-temp mortgage
            set repayment remove-item index-temp repayment
            set income-rent remove-item index-temp income-rent
            set surplus-rent remove-item index-temp surplus-rent
          ]

          die
        ]

        ;; demolish the house
        ;; this is a safety net for mortgage houses (should never be reached in the code)
        die
      ]

      if myType = "rent" [
        ;; manage ownership (landlord)
        if is-owner? my-occupier [
          ;; manage occupier (tenant)
          ;; evict the occupier
          let my-occupier-temp my-occupier
          evict my-occupier-temp
          ;; enter the rent market
          enter-market my-occupier-temp "rent"
        ]
        ;let my-owner-temp my-owner
        ask my-owner [
          ;; add the capital to the landlord of the house
          set capital capital + [sale-price] of myself
          ;; remove the house from the ownership of the landlord
          ;let my-ownership-temp my-ownership
          ;ask myself [set my-ownership-temp other turtle-set my-ownership-temp]
          ;set my-ownership my-ownership-temp

          let index-temp position myself my-ownership
          set my-ownership remove-item index-temp my-ownership
          set mortgage remove-item index-temp mortgage
          set repayment remove-item index-temp repayment
          set income-rent remove-item index-temp income-rent
          set surplus-rent remove-item index-temp surplus-rent
        ]
        ;; make sure that any made offer for this house are cancelled
        if is-owner? offered-to [
          ask offered-to [set made-offer-on nobody]
        ]
        ;; demolish house
        die
      ]
      ;; safety net to assure demolishing happens (in case different types of houses are added to the model in the future)
      die
    ]
  ]
end

to unfile-record [ input-realtors a-house ]          ;; realtor procedure
  ifelse calculate-wealth? = true [
    let A a-house
    let relevant-records records with [the-house = A]

    ask input-realtors [
      ; find all the records that must be unfiled (will be used for houses)
      let sales-to-remove filter [ s -> [the-house] of s = A ] sales-sold
      let rents-to-remove filter [ s -> [the-house] of s = A ] sales-rent

      ; delete any record that mentions the house
      if [myType] of A = "mortgage" [set sales-sold filter [ s -> [the-house] of s != A ] sales-sold]   ;; new-version]

      if [myType] of A = "rent" [set sales-rent filter [ s -> [the-house] of s != A ] sales-rent]   ;; new-version]

      ; loop through all the records sales that need to be removed
      ask turtle-set sales-to-remove [
        ; loop through all the houses that files the record sale in the current iteration
        ask turtle-set filed-at-houses [
          ; loop through all the local-sales list (each corresponding to one of the `local-realtors` of the house that filed the record in the current iteration)
          foreach local-sales [
            ; remove the record in the current iteration from the local-sales list in the current iteration
            records-list ->
            let index position records-list local-sales
            let filtered-at-index filter [a-record -> not member? a-record sales-to-remove] records-list
            set local-sales replace-item index local-sales filtered-at-index
          ]
        ]
      ]

      ask turtle-set rents-to-remove [
        ask turtle-set filed-at-houses [
          foreach local-rents [
            records-list ->
            let index position records-list local-rents
            let filtered-at-index filter [a-record -> not member? a-record rents-to-remove] records-list
            set local-rents replace-item index local-rents filtered-at-index
          ]
        ]
      ]
    ]
  ]
  ; if calculate-wealth? = false
  [
    ask input-realtors [
      ; delete any record that mentions the house
      if [myType] of a-house = "mortgage" [set sales-sold filter [ s -> [the-house] of s != a-house ] sales-sold]   ;; new-version]
      if [myType] of a-house = "rent" [set sales-rent filter [ s -> [the-house] of s != a-house ] sales-rent]   ;; new-version]
    ]
  ]
end

to update-prices
  ;; reduce or update sale-prices of unsold houses ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; reduce sale-price is a house is not sold in each tick
  ask houses with [ for-sale? = true and mytype = "mortgage"] [  ;; ask all houses which still are for sale
    set sale-price sale-price * (1 - PriceDropRate / 100 );; to reduce its sale-price by certain amount
    set rent-price rent-price * (1 - RentDropRate / 100 )
    set on-market-period on-market-period + 1
  ]

  ask houses with [ for-rent? = true and mytype = "rent"] [  ;; ask all houses which still are for sale
    set sale-price sale-price * (1 - PriceDropRate / 100 )
    set rent-price rent-price * (1 - RentDropRate / 100 );; to reduce its sale-price by certain amount
    set on-market-period on-market-period + 1
  ]
end

to update-owners
  ;; update owners' mortgage and repayment in each tick  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; manage rents
  ask owners with [is-house? my-house and count turtle-set my-ownership > 1 and sum (mortgage) > 0] [
    foreach my-ownership [ house-temp ->
      let i position house-temp my-ownership
      let mortgage-temp item i mortgage
      let repayment-temp item i repayment
      let income-rent-temp item i income-rent

      ;; replace the mortgage at index i with the new mortgage after repayment
      ;set mortgage replace-item i mortgage ( mortgage-temp - (repayment-temp - (interestPerTick * mortgage-temp)) )
      set mortgage replace-item i mortgage ( mortgage-temp - repayment-temp )
      ;; if the owner paid the full mortgage of the house, set the mortgage and repayments back to zero
      if item i mortgage <= 0 [
        set mortgage replace-item i mortgage 0
        set repayment replace-item i repayment 0
      ]
      ;; calculate capital while adding income rent to the base income every tick
      set capital capital + ( (Savings / 100) * income-surplus )
    ]
  ]

  ;; myType condition was considered againist the value 1. Modified to "mortgage" to align with the new model.
  ask owners with [ is-house? my-house and myType = "mortgage" and sum (mortgage) > 0 and count turtle-set my-ownership = 1] [  ;; ask all owners who do have one house and mortgage to pay
    set mortgage replace-item 0 mortgage ( (item 0 mortgage) - (item 0 repayment) )  ;; mortgage will be reduced due to repayment
                                                                                                             ;; add income rent to the base income every tick
    set capital capital + ( (Savings / 100) * income-surplus )
    if item 0 mortgage <= 0 [  ;; if mortgage is fully repaid, then set both mortgage and repayment to 0
      set mortgage replace-item 0 mortgage 0
      set repayment replace-item 0 repayment 0
    ]
  ]

  ;; update renters' capital in each tick  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; myType condition was considered againist the value 0, Modified to "rent" to align with the new model.
  ask owners with [ is-house? my-house and myType = "rent" ] [  ;; ask all owners who do have houses and mortgage to pay
    set capital capital + ( (SavingsRent / 100) * income-surplus )
    if capital < 0 [
      set capital 0
    ]
  ]

  ;; address the rate duration
  ask owners with [length my-ownership > 0] [
    let i 0
    let l length my-ownership
    while [i < l] [
      ;; if the rate duration reached 0,
      if item i rate-duration = 0 and item i repayment > 0 [
        ;; if there is a change in the interest rate, recalculate the mortgage and the repayment
        if item i rate != interestPerTick [
          ;; find old and new interest rates
          let old-interest (item i rate)
          let new-interest interestPerTick
          ;; find remaining mortgage
          let total-mortgage item i mortgage-initial
          ;; calculate new repayment
          let old-repayment item i repayment
          let new-repayment total-mortgage * interestPerTick / (1 - ( 1 + interestPerTick ) ^ ( - MortgageDuration * ticksPerYear ))
          set repayment replace-item i repayment new-repayment
        ]
        ;; update the owner's rate and rate-duration parameters
        set rate replace-item i rate interestPerTick
        ; if this is the first house in my-ownership list (i.e., my-house)
        ifelse i = 0
        [set rate-duration replace-item i rate-duration ((MinRateDurationM + random (MaxRateDurationM - MinRateDurationM)) * ticksPerYear)]
        [set rate-duration replace-item i rate-duration ((MinRateDurationBTL + random (MaxRateDurationBTL - MinRateDurationBTL)) * ticksPerYear)]
      ]
      let duration-temp 0
      ;; subtract 1 tick from the rate duration
      if item i rate-duration != nobody [
        set duration-temp (item i rate-duration) - 1
        set rate-duration replace-item i rate-duration duration-temp
      ]
      if item i mortgage-duration != nobody [
        set duration-temp (item i mortgage-duration) - 1
        set mortgage-duration replace-item i mortgage-duration duration-temp
      ]
      ;; increment the index in the while loop
      set i i + 1
    ]
  ]

  ;; update the surplus income of all owners
  ask owners [
    update-surplus-income
    update-cooldown
  ]
  ;; update the wealth of
  if calculate-wealth? = true [ask owners [update-wealth]]
end

to reset-globals
  set nupShocked 0
  set ndownShocked 0
  set nUpShockedSell 0
  set nDownShockedSell 0
  set nUpShockedRent 0
  set nDownShockedRent 0
  set nForceSell 0
  set nHomeless 0
  set medianPriceOfHousesForSale 0
  set medianPRiceOfHousesForRent 0
  set medianSalePriceHouses 0
  set medianRentPriceRentHouses 0
  set investors investorsPercentage / 100
end

to update-globals
  set medianSalePriceHouses median ([sale-price] of houses with [myType = "mortgage" and sale-price > 0])
  set medianRentPriceRentHouses median ([rent-price] of houses with [myType = "rent" and rent-price > 0])
end

to update-visualisation
  if visualiseModeCurrent != VisualiseMode [
    if visualiseMode = "Prices" [
      ask houses with [myType = "mortgage"] [set size 0.9 set color scale-color red sale-price (max [sale-price] of houses with [mytype = "mortgage"]) (min [sale-price] of houses with [mytype = "mortgage"])]
      ask houses with [myType = "rent"] [set size 0.9 set color scale-color blue rent-price (max [rent-price] of houses with [mytype = "rent"]) (min [rent-price] of houses with [mytype = "rent"])]
      set visualiseModeCurrent "Prices"
    ]
    if visualiseMode = "Types" [
      ask houses with [myType = "mortgage"] [set size 0.9 set color red]
      ask houses with [myType = "rent"] [set size 0.9 set color sky]
      set visualiseModeCurrent "Types"
    ]
  ]
  ;; these modes have to be called every step (computationally demanding)
  if visualiseMode = "Diversity by prices" [
    ask houses [calculate-diversity]
    ask houses [set color scale-color red diversity (max [diversity] of houses) (min [diversity] of houses)]
    set visualiseModeCurrent "Diversity by prices"
  ]
  if visualiseMode = "Hotspot prices (Getis-Ord)" [
    calculate-G
    ask houses [set color palette:scale-gradient [[0 0 255] [255 255 255] [255 0 0]] G -5 5]
    set visualiseModeCurrent "Hotspot prices (Getis-Ord)"
  ]
end

to colour-house
  if visualiseMode = "Prices" [
    if myType = "mortgage" [set size 0.9 set color scale-color red sale-price (max [sale-price] of houses with [mytype = "mortgage"]) (min [sale-price] of houses with [mytype = "mortgage"])]
    if myType = "rent" [set size 0.9 set color scale-color blue rent-price (max [rent-price] of houses with [mytype = "rent"]) (min [rent-price] of houses with [mytype = "rent"])]
    stop
  ]
  if visualiseMode = "Types" [
    if myType = "mortgage" [set size 0.9 set color red]
    if myType = "rent" [set size 0.9 set color sky]
    stop
  ]
  if visualiseMode = "Diversity by prices" [
    set color scale-color red diversity (max [diversity] of houses) (min [diversity] of houses)
  ]
end

to calculate-diversity
  set diversity 0
  let my-neighbours houses-on neighbors
  let min-price min [sale-price] of houses with [myType = "mortgage"]
  let max-price max [sale-price] of houses with [myType = "mortgage"]
  let min-rent min [rent-price] of houses with [myType = "rent"]
  let max-rent max [rent-price] of houses with [myType = "rent"]
  let intervals 3
  let increment-price (max-price - min-price) / intervals
  let increment-rent (max-rent - min-rent) / intervals
  ifelse any? my-neighbours [
    if myType = "mortgage" [
      let threshold min-price
      while [threshold < max-price] [
        let increment-start threshold
        let increment-end threshold + increment-price
        ;; calculate diversity index
        let composite count houses-here with [(sale-price > increment-start) and (sale-price < increment-end)] + count my-neighbours with [sale-price > increment-start and sale-price < increment-end]
        let composite-total count houses-here with [sale-price > increment-start and sale-price < increment-end] + count my-neighbours
        if composite > 0 [set diversity diversity + ( (composite / composite-total) + ln(composite / composite-total) )]
        ;; add to the threshold
        set threshold threshold + increment-price
      ]
    ]
    if myType = "rent" [
      let threshold min-rent
      while [threshold < max-rent] [
        let increment-start threshold
        let increment-end threshold + increment-rent
        ;; calculate diversity index
        let composite count houses-here with [rent-price > increment-start and rent-price < increment-end]  + count my-neighbours with [rent-price > increment-start and rent-price < increment-end]
        let composite-total count houses-here with [rent-price > increment-start and rent-price < increment-end] + count my-neighbours
        if composite > 0 [set diversity diversity + ( (composite / composite-total) + ln(composite / composite-total) )]
        ;; add to the threshold
        set threshold threshold + increment-rent
      ]
    ]
  ]
  [set diversity 0]
  set diversity diversity * -1
end

to calculate-G
  let sum-price-sqrd 0
  ask houses with [myType = "mortgage" and sale-price > 0] [set sum-price-sqrd sum-price-sqrd + (sale-price * sale-price)]
  ask houses with [myType = "mortgage"] [
    let n count houses with [myType = "mortgage" and sale-price > 0]
    ifelse any? (houses-on neighbors) with [myType = "mortgage" and sale-price > 0] [
      let w 1 / 8
      let sum-w-sqrd 0
      let sum-w w * count (houses-on neighbors) with [myType = "mortgage" and sale-price > 0]
      ask (houses-on neighbors) with [myType = "mortgage" and sale-price > 0] [set sum-w-sqrd sum-w-sqrd + (w * w)]
      let X sum [sale-price] of houses with [myType = "mortgage" and sale-price > 0] / n
      let S sqrt ( (sum-price-sqrd / n) - (X ^ 2) )
      ;type "X = " type X type "| S = " type S type " | sum-state-sqrd = " type sum-state-sqrd type " | sum-w-sqrd = " type sum-w-sqrd type "| denemonator = " type S * sqrt( (n * sum-w-sqrd) - (w * count neighbors) ^ 2) type "\n"
      set G ( (w * sum [sale-price] of (houses-on neighbors) with [myType = "mortgage" and sale-price > 0]) - (X * sum-w) ) /
            ( S * sqrt( ( (n * sum-w-sqrd) - (sum-w) ^ 2 ) / (n - 1) ) )
    ]
    [set G 0]
  ]
  let sum-rent-sqrd 0
  ask houses with [myType = "rent" and rent-price > 0] [set sum-rent-sqrd sum-rent-sqrd + (rent-price * rent-price)]
  ask houses with [myType = "rent"] [
    let n count houses with [myType = "rent" and rent-price > 0]
    ifelse any? (houses-on neighbors) with [myType = "rent" and rent-price > 0] [
      let w 1 / 8
      let sum-w-sqrd 0
      let sum-w w * count (houses-on neighbors) with [myType = "rent" and rent-price > 0]
      ask (houses-on neighbors) with [myType = "rent" and rent-price > 0] [set sum-w-sqrd sum-w-sqrd + (w * w)]
      let X sum [rent-price] of houses with [myType = "rent" and rent-price > 0] / n
      let S sqrt ( (sum-rent-sqrd / n) - (X ^ 2) )
      ;type "X = " type X type "| S = " type S type " | sum-state-sqrd = " type sum-state-sqrd type " | sum-w-sqrd = " type sum-w-sqrd type "| denemonator = " type S * sqrt( (n * sum-w-sqrd) - (w * count neighbors) ^ 2) type "\n"
      set G ( (w * sum [rent-price] of (houses-on neighbors) with [myType = "rent" and rent-price > 0]) - (X * sum-w) ) /
            ( S * sqrt( ( (n * sum-w-sqrd) - (sum-w) ^ 2 ) / (n - 1) ) )
    ]
    [set G 0]
  ]


end
@#$#@#$#@
GRAPHICS-WINDOW
223
13
614
405
-1
-1
5.9
1
10
1
1
1
0
1
1
1
-32
32
-32
32
1
1
1
ticks
30.0

SLIDER
12
39
197
72
InterestRate
InterestRate
0
15
3.7
0.01
1
% annually
HORIZONTAL

SLIDER
13
73
198
106
MaxLoanToValue
MaxLoanToValue
0
100
90.0
1
1
%
HORIZONTAL

SLIDER
13
107
198
140
MortgageDuration
MortgageDuration
0
100
25.0
1
1
years
HORIZONTAL

SLIDER
12
159
197
192
MeanIncome
MeanIncome
0
90000
30000.0
1000
1
yearly
HORIZONTAL

SLIDER
13
193
198
226
WageRise
WageRise
0
50
0.0
0.01
1
%
HORIZONTAL

BUTTON
226
498
326
537
Setup step 1
simplified-setup-step-1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1178
303
1710
570
Income histogram
£
Number of households
0.0
150000.0
0.0
1.0
true
true
"" ""
PENS
"Owners" 1.0 1 -2674135 true "" "histogram ([income] of owners with [myType = \"mortgage\"])\nset-histogram-num-bars 100"
"Tenants" 1.0 1 -13791810 true "" "histogram ([income] of owners with [myType = \"rent\"])\nset-histogram-num-bars 100"

PLOT
629
15
1173
305
Houses
Ticks
Number of households/houses
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Population" 1.0 0 -5987164 true "" "plot count owners with [is-house? my-house]"
"Total houses" 1.0 0 -16777216 true "" "plot count houses"
"Mortgage houses" 1.0 0 -1184463 true "" "plot count houses with [myType = \"mortgage\"]"
"Rent houses" 1.0 0 -13791810 true "" "plot count houses with [myType = \"rent\"]"
"Owner households" 1.0 0 -955883 true "" "plot count owners with [myType = \"mortgage\" and is-house? my-house]"
"Tenant housheolds" 1.0 0 -8630108 true "" "plot count owners with [myType = \"rent\" and is-house? my-house]"

SWITCH
13
301
197
334
StampDuty?
StampDuty?
1
1
-1000

PLOT
629
570
1173
825
Prices (median)
Ticks
£
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Houses for sale" 1.0 2 -2674135 true "" "plot medianPriceOfHousesForSale"
"All houses" 1.0 0 -7500403 true "" "plot medianSalePriceHouses"

PLOT
629
825
1173
1109
Annual rents (median)
Ticks
£
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Houses for rent" 1.0 2 -13345367 true "" "plot medianPRiceOfHousesForRent * TicksPerYear"
"All houses" 1.0 0 -7500403 true "" "plot medianRentPriceRentHouses * TicksPerYear"

PLOT
629
305
1173
570
Households on the market
Ticks
Number of households
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Mortgage" 1.0 0 -10141563 true "" "plot count owners with [on-market-type = \"mortgage\"]"
"Buy-to-let" 1.0 0 -11881837 true "" "plot count owners with [on-market-type = \"buy-to-let\"]"
"Rent" 1.0 0 -5298144 true "" "plot count owners with [on-market-type = \"rent\"]"

BUTTON
225
580
325
616
go nYears
go\nif (ticks / TicksPerYear) >= nYears [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
330
498
407
617
nYears
300.0
1
0
Number

BUTTON
417
544
599
616
Update visualisation
update-visualisation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
417
498
599
543
VisualiseMode
VisualiseMode
"Types" "Prices" "Hotspot prices (Getis-Ord)"
1

TEXTBOX
284
418
613
436
Saturated colours indicate higher prices and lower diversity
10
0.0
1

TEXTBOX
233
404
272
423
Types |
10
0.0
1

TEXTBOX
233
418
275
436
Prices |
10
0.0
1

TEXTBOX
284
405
389
423
Red: Mortgage house
10
14.0
1

TEXTBOX
449
405
537
423
Blue: Rent house
10
94.0
1

BUTTON
224
685
312
745
go nYears
go\nif (ticks / TicksPerYear) = mYear [set InterestRate mInterest]\nif (ticks / TicksPerYear) >= nYears [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
417
685
516
745
mYear
10.0
1
0
Number

INPUTBOX
315
685
416
745
mInterest
8.0
1
0
Number

TEXTBOX
228
754
672
772
Change Loan-To-Value (LTV) during the run (use go button below)
12
0.0
1

BUTTON
223
794
312
852
go nYears
go\nif (ticks / TicksPerYear) = mYear [set MaxLoanToValue pLTV]\nif (ticks / TicksPerYear) >= nYears [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
315
794
418
854
pLTV
90.0
1
0
Number

PLOT
1178
15
1710
304
Wealth histogram
£
Number of households
10000.0
2000000.0
0.0
10.0
true
false
"" ""
PENS
"Wealth" 1.0 1 -16777216 true "" "histogram ([wealth] of owners)\nset-histogram-num-bars 100"

TEXTBOX
228
645
604
663
Change interest rate during the run (use go button below)
12
0.0
1

TEXTBOX
15
24
165
42
Mortgage parameters
9
0.0
1

TEXTBOX
16
145
166
163
Households' income
9
0.0
1

TEXTBOX
19
232
196
250
Investors in housing
9
0.0
1

TEXTBOX
229
774
615
792
At mYear, MaxLoanToValue = mLTV
10
0.0
1

TEXTBOX
19
283
196
301
Taxes
9
0.0
1

TEXTBOX
229
668
597
686
At mYear, InterestRate = mInterest
10
0.0
1

SLIDER
14
246
198
279
InvestorsPercentage
InvestorsPercentage
0
100
20.0
1
1
%
HORIZONTAL

BUTTON
13
348
199
383
Reset parameters
reset
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
419
794
518
854
mYear
10.0
1
0
Number

BUTTON
225
539
325
577
Setup step 2
simplified-setup-step-2
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1178
569
1710
828
House prices histogram
£
Number of houses
0.0
800000.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram ([sale-price] of houses with [myType = \"mortgage\"])\nset-histogram-num-bars 100"

PLOT
1178
827
1710
1111
Annual rents histogram
£
Number of houses
0.0
40000.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 1 -16777216 true "" "histogram ([rent-price * ticksPerYear] of houses with [myType = \"rent\"])\nset-histogram-num-bars 100"

TEXTBOX
225
450
438
500
Initialise the model\n\"Setup step 1\" loads the world\n\"Setup step 2\" prepares the plots
10
0.0
1

TEXTBOX
419
455
619
494
Change visaulisation mode (\"Types\" or \"Prices\" recommended during runs)
10
0.0
1

@#$#@#$#@
## Model updates

Versions "[xx].[xx]" has a full user interface (e.g., 18.4)
Versions "A[xx].[xx]" has a simplified user interface (e.g., A18.4)

Version 18.4.2 (YG)

1. Added a maximum time  for households to spend on the "mortgage" or "buy-to-let" market as long as they are not homeless (homeless hosueholds follow the normal discouragement periods)
	- Added `onMarketPeriodBTL` and `onMarketPeriodMortgage` sliders to input the maximum number of ticks households can spend on the buy-to-let and mortgage markets respectively
	- Added `time-on-market` parameter to `owners` to monitor the number of ticks a household has been on the market
2. Added a cooldown time before households can rejoing the "mortgage" or "buy-to-let" market
	- Added `cooldownPeriodBTL` and `cooldownPeriodMortgage` sliders to input the number of ticks households spend on cooldown before they can rejoin the buy-to-let and mortgage market respectively
	- Added `on-cooldown?` parameter to `owners` to monitor whether the household is on cooldown or not
	- Added `on-cooldown-type` parameter to `owners` to track which market the household left before going into the cooldown state
	- Added `time-on-cooldown` parameter to `owners` to monitor the number of tick the households has been on cooldown

Note: This version rarely creates a stable state for prices at 50% investors with `onMarketPeriodBTL` is set to lower than 1 (once every 1000 runs as per early investigations). 


Version 18.4.1 (YG)

1. Modified the decision tree of not-well-off households with more than one house (landlords). These households now try to rent the house yielding the lowest profit with a higher rent instead of selling it. To achieve this, the following parameters and functions were added:
	- Added `surplus-rent` parameter for `owners` to keep track of the rent of each house compared to its repayment. This represents the profit an `owner` makes from each `my-ownership`.
	- Added `on-market-period` parameter for `houses` to keep track of the number of ticks each house has been on the market.
	- Added `MaxForRentPeriodPoorLandlord` input slider to represent the maximum number of ticks a poor (`not-well-off`) `owner` can wait for a house offered for rent to be rented.
	- `force-sell-rent` replaces the `force-sell` function. `force-sell-rent` goes through the following decision tree for the `not-well-off` `owners`:
		- Check if one of the houses has offered `for-rent?` for longer than the `MaxForRentPeriodPoorLandlord`. If so, put that house on the "mortgage" market for sale to gain capital.
		- Check if there are no houses offered for rent from `my-ownership`; meaning all the houses are occupied. If so, select the house with the lowest respective `surplus-rent`, `evict` the `my-occupier` of the `house` and put the `house` on the "mortgage" market for sale. 
2. Added the calculation of wealth from versions 19.0.4 and 19.0.6

	- `wealth` parameter was added to owners
	- `wealth` indicates the capital of an owner in addition to the prices of all its houses after deducing the mortgages (For every house in `my-ownership` with a mortgage in `mortgage`, `wealth += capital + sale-price - mortgage`)
	- Added a `calculate-wealth?` switch to give the option of not calculating wealth to save up run time (wealth leads to 3 to 4 times longer runs)
	- House parameters
		- Transformed the `local-realtors` to a list. The order of this list aligns with the order of the `local-sales` and `local-rents` parameters.
		- Added `local-sales` and `local-rents` to store a list of all the relevant sale and rent records for the house when the `valuation` function is called. `local-sales` and `local-rents` include a number of lists of records, each list corresponding to records of a realtor in `local-realtors`. For instance, consider a list of realtors `[Realtor 0 Realtor 1]`, the `local-sales` parameter must be a list including two lists `[ [] [Record 1 Record 2] ]`. In this case, `Realtor 0` has no sale records relevant to this `house` while `Realtor 2` has two records.
		- Added `locality-houses` to store the houses in the `locality` of the `house`.
	- Record paraemters
		- Added `filed-at-houses` as a list corresponding to all the houses at which this record is filed either in `local-sales` or `local-rents`
	- Functions were modified to use the added parameters for a more efficient valuation function execusion. All the function modifications are only executed if `calulcate-wealth?` is set to `true`. Otherwise, the algorithm in version 19.0.4 is used as it is more efficient when wealth is not relevant (due to low number of `valulation` function executions in the first place). The modified functions are:
		- `build-house`
			- The `locality-houses` are identified while constructing houses
			- The houses in the `locality-houses` append the contructed `house` to their own `locality-houses` parameter
		- `demolish-houses`
			- The houses in the `locality-houses` remove the demolished `house` from their own `locality-houses` parameter
		- `file-records`
			- The relevant `record` is added to the `local-sales` and `local-rents` of the houses where the record is. The location of the `record` in the `local-sales` and `local-rents` is dictated based on the `realtor` filing the record.
			- The `nobody` elements in the `local-sales` and `local-rents` are removed when filing. `nobody` is a placeholder for dead records that age beyond their `RealtorMemory`. The `nobody` elements are not removed in the `unfile-records` function as it requires looping through all lists in the lists `local-rents` and `local-sales` for all the houses; and this is computationally demanding. Removing the records in `file-records` embeds it in the executed loop of the houses that will file a record, which leads to periodical cleaning of the lists. The `nobody` values do not cause any errors, but they are taxing in terms of memory so periodic cleaning is sufficient.
			- The `filed-at-houses` of the record stores the houses that updated their `local-sales` or `local-rents`
		- `unfile-records`
			- All the records pointing to the input `house` are removed from the `local-sales` and `local-rents` parameters of the houses in the `filed-at-houses` of the record.


Version 18.4 (YG)

1. Added behaviour space for experiments with LTVs and interest rates based on UK data


Version 18.3 (YG)

1. Added a switch labelled "Override-Income-Capital"
	- when turned on, the capital and income of agents is set based on the house prices and rents
2. The prices of houses are based on both the income and capital (capital was not considered in the previous versions)

Version 18.2 (YG)

1. Added a go button allowing for changing LTV during the runs
2. Added a visualisation method through the diversity index based on prices. This is computationally demanding as every step, the diversity index of all the houses must be recalculated.

Version 18.1 (YG)

1. Fixed an issue overriding go nYears at tick number 400
2. Added experiments in the behaviour space to introduce changes at 75 years

Version 18.0 (YG)

1. The following parameters were added to the owners
	- income-surplus --> the residual income for an agent per tick
2. The following input parameters were added
	- CapitalMortgage --> the portion of the total income assigned to a mortgage owner at initialisation
	- CapitalRent --> the portion of the total income assigned to a rent owner at initialisation
3. The savings are taken from the residual income instead of from the total income

Version 17.9 (YG)

1. The following parameters were added to the owners as lists
	- mortgage-initial --> the initially full mortgage agreed to acquire the house
	- mortgage-duration --> the ticks remaining for a mortgage to end
	- rate --> the interest per tick
	- rate-duration --> the remaining ticks before updating the interest per tick
2. The following input parameters were added to the interface
	- MaxRateDurationM --> the maximum duration for fixing interest rate on the "mortgage" market
	- MinRateDurationM --> the minimum duration for fixing interest rate on the "mortgage" market
	- MaxRateDurationBTL --> the maximum duration for fixing interest rate on the "buy-to-let" market
	- MinRateDurationBTL --> the minimum duration for fixing interest rate on the "buy-to-let" market
2. The interest per tick is updated for each house in my-ownership when its respective rate-duration ends
3. The repayments are updated in case of changes in the agreed interest per tick
4. The agreed interest duration is addressed separately for "buy-to-let" and "mortgage" markets
5. Visualisation can now be applied based on types or prices
	- If the VisualiseMode is changed during the run, it is only updated in the next tick
	- The visualisation can be updated without runing the model through the button "update visualisation"
6. Homeless now indicates owners who have been evicted from their houses and are currently on the market looking for a house
7. When making trade offers, owners only consider houses that they can afford in terms of mortgage repayments

Version 17.8 (YG)

1. Added a condition for being well-off for both owners of type "rent" and "mortgage" based on income
2. Addressed an issue that caused setting the "income-rent" of a house with a tenant to 0 during specific transaction conditions
3. Added an "upgrade-tenancy" input parameter representing the ratio of owners of type rent that will upgrade their houses rather than going into a mortgage market
4. Modified the "propensity-threshold" to "investors" so that it represents the portion of investors in the housing market
5. Changed the initialisation process as follows:
	- The owners calculate their maximum repayment based on their income
	- The mortgage is calculated based on the repayment
	- The price is assigned as the mortgage + deposit

This assures the repayments remain within the owners' incomes at initialisation. In the previous versions, initialising with low interest rates allowed owners to borrow more which led to extremely high prices at initialisation. This led to cases where many owners were evicted during the first ticks due to high prices that are associated with high repayments (beyond what the owner's incomes can pay for).

Version 17.7 (YG)

1. Addressed an issue where upshocked renters enterd the "rent" market instead of the "mortgage" market
2. Fixed an issue with "contextualised" mode that led to the generation of owners with myType = 0
3. Added an "nYears" input to control the number of years for a run
4. The following parameters are now of type list (not agentsets):
	- my-ownership
	- mortgage
	- repayment
	- income-rent
5. Not-well-off owners with more than one house now select the house to sell as follows:
	- First, prioritise a house that is not rented, if any (meaning the house does not provide revenue and only adds to the repayment
	- Second, prioritise the house that would yield the highest revenue (i.e. highest SalePrice - Mortgage)
6. Added a "propensity" parameter for owners representing their likelihood to invest into housing (this propensity is randomly generated within [0.0, 1.0] for each owner and remains the same for each owner during the run in this version)
7. Added a "propensity-threshold" slider representing the propensity an owner must exceed to enter the buy-to-let market if they are well off
8. Modified the condition for selling a house if not-well-off; now owners with a house (A) already on the market are not forced to sell another house (B) until house (A) is sold
9. "Inflation" renamed to "WageRise"
10. The house colours are now updated during the ticks to represent their type

Version 17.6 (YG)

1. Added a toggle "ActWhenShocked" to control whether the owners evict or enter the market directly when they experience a downshock or an upshock

Note: Toggling "ActWhenShocked" on leads to a trend of a decreasing number of agents during the 25 year runs (100 ticks). This is due to the assumption that any downshocked agents will either sell one of their my-ownership, or evict if they have no houses to sell further. Toggling "ActWhenShocked" off still keeps the income shock adjustments, and that implicitly leads to evictions or joining markets when checking the financial conditions of the owners in the "manage-market-participation" function.

Version 17.5 (YG KZ)

1. Addressed an issue with low rent prices leading to demolishing rent houses (occurs when a house is bought on a buy-to-let market, put on the rent market and then not having an offer during the tick. This leads to not calling the valuation function, and rent value remains 0)

Version 17.4 (YG)

1. Addressed an issue with reporting the median rent value = 0 in the valuation function
2. Addressed an issue leading to considering a house on the rent market as rented when assigning income-rent to house owners


Version 17.3 (YG)

1. added the first-link to the follow chain function to address rare situations where deep recursions occur


Version 17.2 (YG)

1. addressed an error when a downshocked owner has no more my-ownership that are not for sale. This situation leads the owner to evict and enter the rent market.
2. addressed an error due to not removing my-ownership from the agentset of interesting houses when making offers on a buy-to-let market
3. addressed some cases where landlords did not decrease their income-rent when evicting a tenant
4. addressed some bugs with addressing income-rent during transactions and at the end of each tick
5. added evict-threshold-mortgage and evict-threshold-rent parameters to separately control the eviction conditions for "owners" with myType = rent and myType = mortgage
6. addressed an issue with referring to sale-price instead of rent-price in the valuation function in case of houses with myType = "rent" and for-sale? = true

Version 17.1 (YG)

General modifications at setup

1. Rented houses and renting 'owners' are now added
2. Rented houses now have actual owners (an 'owner' agent that rents the house to another 'owner' agent)
3. Rented houses have their sale price set based on the mortgage and deposit of their owner
4. Owners now get their income increase by the rent amount they receive at setup (this is planned to be modified to add rent every tick, rather than assigning it at the point of creating the agents)
5. The owner's mortgage, capital and repayment are set while considering potential multiple ownerships

General modifications during runs

1. "owner" agents can now join three types of market "mortgage", "rent" and "buy-to-let"
	a. mortgage: joined when tenants have enough money to buy their own house or when a new buyer comes in with the intent of byuing their house
	b. rent: joined when a home owner is not well-off (downshocked) and they own only one house, or when a new tenant comes in the system
	c. buy-to-let: joined when a home owner is well-off (e.g., upshocked) that they can buy another house
2. "house" agents can now be put on the "mortgage" marekt or "rent" market
	a. mortgage: includes all the houses for sale, these can be purchased as a buy-to-let or for a normal mortgage
	b. rent: includes all the houses for rent
	N.B. the owners decide when to put the house on the market based on their budgets. However, any house without an occupier my be put on a market.
3. rents are now added to the "income" of the landlord (to save run time, this is used rather than addressing all landlords every tick to add to their capital from rent separately)


Owners

1. Differenciated between owner and occupier
2. Added my-ownership to owner agents
	a. ownership is an agentset (can be more than one house)
3. Added assign-income-rent
	a. add the rent of my-ownership to the owner's income
4. No longer calculate the mortgage if they are staying on the basis of paying rent
5. No longer calculate rent paid for a mortgage owner
6. added income-rent (separate from normal income)
	a. rent taken from ownership
7. added on-market?
8. added on-market-type
	a. represents the market on which the 'owners' is using to buy/rent (can be "buy-to-let", "mortgage", "rent")	

Houses

1. Added for-rent?
2. Added rent-price
3. added date-for-rent

Records

1. Addded renting prices to the records

Functions

1. manage-market-participation [turtleset of owners]
	- manage evictions --> entering rent market
	- manage well-off --> entering mortgage market
	- This function is a majorly modified version of force-out (force-out is now not used in the model)

2. put-on-market
	- a house function
	- put a house on the market

3. evict [turtleset of owners]
	- remove agents from mortgaged or rented house
	- assure all ownership is also evicted and put on the market

4. force-sell [turtleset of owners]
	- forces the 'owners' to put one of their ownership on the market
	- it is necessary to separate this from the enter-market function as an owner with more than one house can now sell without wanting to buy (i.e., be on the market)

5. enter-market [turtleset + string]
	- put agents on the mortgage or rent market

6. move-houses
	- Significant changes to function to accomodate renting market
	- now assures for the house that myType, my-owner, my-occupier, rented-to are properly addressed

7. assign-income-rent
	- Adds rent at setup to the owners
	- Adds mortgage at setup to the owners
8. manage-surplus
	- Generally addresses the monetary exchange during trade
	- Separate functions are available for each exchange party
9. manage-ownership
	- Generally addresses the house ownership during trade
	- Separate functions are available for each exchange party

Globals

eviction-threshold        --> proportion of (income * Affordability%) that triggers eviction
nEvictedMortgage          --> number of evicted owners of type mortgage
nEvictedRent              --> number of evicted owners of type rent
nEnterMarketMortgage      --> number of owners entering the mortgage market
nEnterMarketRent          --> number of owners entering the rent market
meanIncomeEvictedMortgage --> mean income of evicted owners of type mortgage
meanIncomeEvictedRent     --> mean income of evicted owners of type rent


## Model Structure

1. setup
1.1. build-realtors
1.2. build-owners
__1.2.1. assign-income
__1.2.2. assign-income-rent
1.3. reset-empty-houses
1.4. reset-houses-quality
1.5. reset-realtors
2. Step
2.1. calculate-globals
2.2. shock-management
__2.2.1. put-on-market
2.3. owners-leave
2.4. new-owners
2.5. manage-discouraged
2.6. manage-market-participation
__2.6.1. evict
__2.6.2. enter-market
2.7. new-houses
2.8. trade-house
__2.8.1. value-houses
____2.8.1.1. valuation
__2.8.2. make-offers
____2.8.2.1. make-offer-mortgage
____2.8.2.2. make-offer-rent
__2.8.3. move-house
2.9 remove-outdates
2.10. demolish-houses
2.11. update-prices
2.12. update-owners

## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.4.0
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