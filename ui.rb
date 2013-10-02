#!/usr/bin/ruby -w
require "./ga"

if __FILE__ == $0

  # marks the ranges of our points i.e.  
  # start point:  [0,START_Y_COORD] 
  # end point:    [END_X_COORD,0]
  END_X_COORD = 100.0
  START_Y_COORD = 2.0

  
  # genetic algorithm's population pool size
  POPULATION_SIZE = 200

  # no. iterations the genetic algorithm will run for (generations produced & evolved) 
  ITERATIONS = 100 #250

  # no. intervals between the start and endpoints (not incl.) 
  NUM_INTERVALS = 50 #100#200  


  # Percentage [0,1] that each generation will include 
  # interval heights from start to end point which form a
  # straight line
  GENERATION_SLOPE_PERCENT = 0.0
  
  # Percentage [0,1] that each generation will include 
  # random interval heights which will be ordered from 
  # start to end point in descending order
  GENERATION_ORDERED_RANDOM_PERCENT = 0.0


  # Percentage [0,1] that each generation will include
  # members from the previous generation (tends to work best when < 0.5)
  DEFAULT_KEEP_PERCENT = 0.4

  # no. crossover points to randomly pick when applying 
  # our breed splice and interleave methods when producing 
  # offspring for the next generation
  NUM_CROSSOVER_POINTS = 1



  # No. times to mutate each time the mutate function is called on the Individual
  # (increase/decrease a point in the y array and adjust its neighbours) in each generation
  NUM_MUTATIONS = 1

  # Probability of each individual of the population being mutated when selected for mutation
  PROBABILITY_OF_MUTATION = 0.3

  # Proportion of the population to select for mutatation when evolving the next generation
  PROPORTION_TO_MUTATE = 0.3


  # Changes the main evolving algorithm to start with a low-resolution version
  # of the problem (i.e. less intervals) and evolve as normal, progressively increasing
  # the resolution until its the full size in the last 25% of generations
  # Note: This makes bigger problems (i.e. many intervals) converge A LOT quicker
  START_SMART = true


  #seed the random number generator off the system time
  srand(Time.new.usec)

  # create our Ga object...
  genentic_algorithm = Ga.new()
  genentic_algorithm.set_parameters( END_X_COORD, START_Y_COORD, ITERATIONS, POPULATION_SIZE, NUM_INTERVALS,
                            GENERATION_SLOPE_PERCENT, GENERATION_ORDERED_RANDOM_PERCENT,
                            DEFAULT_KEEP_PERCENT,
                            NUM_CROSSOVER_POINTS,
                            NUM_MUTATIONS,PROBABILITY_OF_MUTATION,PROPORTION_TO_MUTATE,
                            START_SMART)



  genentic_algorithm.run_simulation

  genentic_algorithm.p.get_best.plot

end
