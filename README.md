brach-ga
========

Genetic Algorithm to solve the Brachistochrone Problem (find the quickest path between 2 points) 

The converged solution is the cycloid known as the Brachistochrone curve
http://en.wikipedia.org/wiki/Brachistochrone_curve


Algorithm Parameters:

  
START_Y_COORD, END_X_COORD
  Marks the ranges of our points i.e.  
  start point:  [0,START_Y_COORD] 
  end point:    [END_X_COORD,0]

 
POPULATION_SIZE  
  Genetic algorithm's population pool size
  
ITERATIONS (generations)
  No. iterations the genetic algorithm will run for (generations produced & evolved) 

NUM_INTERVALS
  No. intervals between the start and endpoints (not inclusive) 
  
GENERATION_SLOPE_PERCENT
  Percentage [0,1] that each generation will include 
  interval heights from start to end point which form a
  straight line
  
GENERATION_ORDERED_RANDOM_PERCENT  
  Percentage [0,1] that each generation will include 
  random interval heights which will be ordered from 
  start to end point in descending order

DEFAULT_KEEP_PERCENT
  Percentage [0,1] that each generation will include
  members from the previous generation (tends to work best when < 0.5)
 
NUM_CROSSOVER_POINTS
  No. crossover points to randomly pick when applying 
  our breed splice and interleave methods when producing 
  offspring for the next generation

NUM_MUTATIONS
  No. times to mutate each time the mutate function is called on the Individual
  (increase/decrease a point in the y array and adjust its neighbours) in each generation
  
PROBABILITY_OF_MUTATION
  Probability of each individual of the population being mutated when selected for mutation
  
PROPORTION_TO_MUTATE
  Proportion of the population to select for mutatation when evolving the next generation
  
START_SMART
  Changes the main evolving algorithm to start with a low-resolution version
  of the problem (i.e. less intervals) and evolve as normal, progressively increasing
  the resolution until its the full size in the last 25% of generations
  
  Note: This makes bigger problems (i.e. many intervals) converge A LOT quicker
  



