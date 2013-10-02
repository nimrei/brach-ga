brach-ga
========

Genetic Algorithm to solve the Brachistochrone Problem (find the quickest path between 2 points) 

The converged solution is the cycloid known as the Brachistochrone curve
http://en.wikipedia.org/wiki/Brachistochrone\_curve


# Algorithm Parameters #

  
### START\_Y\_COORD, END\_X\_COORD ###
Marks the ranges of our points i.e.  
  <ul>
    <li>start point:  [0,START_Y_COORD] </li>
    <li>end point:    [END_X_COORD,0]</li>
  </ul>
 
### POPULATION\_SIZE ###
<p>Genetic algorithm's population pool size</p>
  
### ITERATIONS (generations) ###
<p>No. iterations the genetic algorithm will run for (generations produced & evolved)</p> 

### NUM\_INTERVALS ###
<p>No. intervals between the start and endpoints (not inclusive)</p>
 
  
### GENERATION\_SLOPE\_PERCENT ###
<p>Percentage [0,1] that each generation will include 
  interval heights from start to end point which form a
  straight line</p>

  
### GENERATION\_ORDERED\_RANDOM\_PERCENT ###
  <p>Percentage [0,1] that each generation will include 
  random interval heights which will be ordered from 
  start to end point in descending order</p>


### DEFAULT\_KEEP\_PERCENT ###
<p>Percentage [0,1] that each generation will include
  members from the previous generation (tends to work best when &lt; 0.5)</p>

 
### NUM\_CROSSOVER\_POINTS ###
<p>No. crossover points to randomly pick when applying 
  our breed splice and interleave methods when producing 
  offspring for the next generation</p>


### NUM\_MUTATIONS ###
<p>No. times to mutate each time the mutate function is called on the Individual
  (increase/decrease a point in the y array and adjust its neighbours) in each generation</p>

  
### PROBABILITY\_OF\_MUTATION ###
<p>Probability of each individual of the population being mutated when selected for mutation</p>

  
### PROPORTION\_TO\_MUTATE ###
<p>Proportion of the population to select for mutatation when evolving the next generation</p>

  
### START\_SMART ###
<p>Changes the main evolving algorithm to start with a low-resolution version
  of the problem (i.e. less intervals) and evolve as normal, progressively increasing
  the resolution until its the full size in the last 25% of generations</p>
  
  + Note: This makes bigger problems (i.e. many intervals) converge A LOT quicker
  



