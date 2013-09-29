#!/usr/bin/ruby -w
#require "./genetic_algorithm"
require "./ga"
#require "./genotype"



if __FILE__ == $0

  DEFAULT_POPULATION = 200

  DEFAULT_ITERATIONS = 250

  DEFAULT_CROSSOVERS = 33
  
  DEFAULT_MUTATIONS = 1
  
  DEFAULT_MUTE_PROP = 0.3

  DEFAULT_SLOPE_PERCENT = 0.0
  DEFAULT_RANDOM_PERCENT = 0.0
 
  DEFAULT_MUTATION_PROB = 0.3

  DEFAULT_START_SMART = true


  #seed the random number generator off the system time
  srand(Time.new.usec)

  # create our Ga object...
  ga_actual = Ga.new()
  ga_actual.set_parameters(DEFAULT_ITERATIONS,DEFAULT_POPULATION,DEFAULT_SLOPE_PERCENT,
                            DEFAULT_RANDOM_PERCENT,DEFAULT_MUTATION_PROB,DEFAULT_MUTE_PROP,
                            DEFAULT_START_SMART)

  ga_actual.run_simulation(DEFAULT_ITERATIONS)

  # puts ga_actual.p.get_best.y.to_s

  ga_actual.p.get_best.plot

end
