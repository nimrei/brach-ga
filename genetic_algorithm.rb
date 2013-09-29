#require_relative 'ga'
require_relative 'pool'

module GeneticAlgorithm

  #Breeding function constants

  CROSSOVERS = 1
  MUTATIONS = 1

  KEEP_PERCENT = 0.4

  #GeneticAlgorithm helper methods

  def self.run_simulation_smart(g)

    original_intervals = Individual.current_intervals 

    #set the no. intervals in the Individual class so that every Individual created has only 10 'y' values
    Individual.current_intervals = 10

    # create initial population
    g.p.create_initial_population

    # with a quarter of our intended iterations always use 10 intervals
    sub_iteration = g.max_it/4 
    (sub_iteration).times do |i| 

      # run our simulation as normal
      g.evolve_next_generation
      g.p.mutate_population
      report_time_simple(i+1,g.p.get_best)
    
    end

    # for the rest increase our interval size when needed
    # i.e. every time we're in a new quadrant of iterations, 
    # increase our interval size until we're the full size in the 4th

    # so first lets get our generations to increment and the intervals to increase to
    generations_to_increase_intervals = (1..3).map {|i| (sub_iteration*i)+1}
    intervals_to_increase_to = (1..2).map {|i| 10+(i*(original_intervals-10)/3)}.push(original_intervals)

    # # for the remainder of our iterations...
    (sub_iteration).upto(g.max_it) do |i|

      if generations_to_increase_intervals.include?(i)
        
        index = generations_to_increase_intervals.index(i)  # print intervals_to_increase_to[index]

        # ok let's increase the no. intervals
        g.p.modify_interval_size(intervals_to_increase_to[index])

      end 

      # run our simulation as normal
      g.evolve_next_generation
      g.p.mutate_population
      report_time_simple(i+1,g.p.get_best)

    end

  end  

  def self.run_simulation_dumb(g)
    #create initial population
    g.p.create_initial_population

    #call fitness report function for initial value
    #report_time_simple(0,g.p.get_best)
    g.simulation_begun = true
    (0...(g.max_it)).each do |i|
      g.evolve_next_generation
      g.p.mutate_population
      report_time_simple(i+1,g.p.get_best)
    end
  end

  def self.report_time_simple(i,best)
     printf "(%d): %.40f\n" % [i, 1.0/best.fitness]
  end

end