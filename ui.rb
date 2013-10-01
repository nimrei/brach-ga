#!/usr/bin/ruby -w
#require "./genetic_algorithm"
require "./ga"
#require "./genotype"



if __FILE__ == $0

  # marks the ranges of our points i.e.  
  # start point:  [0,DEFAULT_Y_COORD] 
  # end point:    [DEFAULT_X_COORD,0]
  END_X_COORD = 100.0
  START_Y_COORD = 2.0

  
  # genetic algorithm's population pool size
  POPULATION_SIZE = 200

  # no. iterations the genetic algorithm will run for
  ITERATIONS = 10 #250

  # no. intervals between the start and endpoints (not incl.) 
  NUM_INTERVALS = 50 #100#20#0  


  # Percentage [0,1] that each generation will include 
  # interval heights from start to end point which form a
  # straight line
  GENERATION_SLOPE_PERCENT = 0.0
  
  # Percentage [0,1] that each generation will include 
  # random interval heights which will be ordered from 
  # start to end point in descending order
  GENERATION_ORDERED_RANDOM_PERCENT = 0.0



  CROSSOVER_DEFAULT = 1

  DEFAULT_KEEP_PERCENT = 0.4


  DEFAULT_CROSSOVERS = 33
  
  NUM_CROSSOVERS = 1


  DEFAULT_MUTATIONS = 1
  
  DEFAULT_MUTE_PROP = 0.3

  #No. times to mutate each time the mutate function is called on the Individual
  #(increase/decrease a point in the y array and adjust its neighbours)
  MUTATION_DEFAULT = 1



 
  DEFAULT_MUTATION_PROB = 0.3

  DEFAULT_START_SMART = true


  #seed the random number generator off the system time
  srand(Time.new.usec)

  # create our Ga object...
  ga_actual = Ga.new()
  ga_actual.set_parameters( END_X_COORD, START_Y_COORD, ITERATIONS, POPULATION_SIZE, NUM_INTERVALS,
                            GENERATION_SLOPE_PERCENT, GENERATION_ORDERED_RANDOM_PERCENT,
                            DEFAULT_KEEP_PERCENT,
                            CROSSOVER_DEFAULT,
                            MUTATION_DEFAULT,DEFAULT_MUTATION_PROB,DEFAULT_MUTE_PROP,
                            DEFAULT_START_SMART)



  ga_actual.run_simulation

  # puts ga_actual.p.get_best.y.to_s

  ga_actual.p.get_best.plot

end
