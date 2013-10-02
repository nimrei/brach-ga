#!/usr/bin/ruby -w

require_relative 'pool'


class Ga
  
  #Number of children in our 'breeding program' for current generation
  LOCAL_CHILDREN = 15

  attr_accessor :p, :simulation_begun, :crossovers, :mutations, :intervals, :max_it, :smart_start

  def initialize
    @simulation_began = false    
  end

  def set_parameters(endpoint_x, endpoint_y, iterations, population_size, intervals,
                     slope_percent, random_order_percent, 
                     keep_percent, 
                     num_crossovers,
                     num_mutations, mutation_prob, mute_prop,
                     smart_start)
    
    @endpoint_x = endpoint_x
    @endpoint_y = endpoint_y

    @max_it = iterations
    @p = Pool.new(population_size, intervals,num_mutations, num_crossovers, @endpoint_x, @endpoint_y)
    
    @intervals = intervals

    @slope_percent = slope_percent
    @random_order_percent = random_order_percent
    
    @keep_percent = keep_percent > 0.5 ? 0.5 : keep_percent

    @num_crossovers = num_crossovers

    @num_mutations = num_mutations
    @mutation_prob = mutation_prob
    
    @mute_prop = mute_prop
    
    @smart_start = smart_start
    
    @simulation_begun = false
  
  end

  def copy(intervals)
    ga_clone = Ga.new()
    ga_clone.set_parameters(@max_it,@p.population_size,@slope_percent,@random_order_percent,@mutation_prob,@mute_prop,false)
    
    return ga
  end

  def run_simulation
    #initalise random
    srand(Time.new.usec)

    #only allow run_simulation_smart for 70 iterations
    if @smart_start && @max_it > 70 && @intervals > 10
      run_simulation_smart
    else
      run_simulation_dumb
    end
  end


  def report_time_simple(i,best)
     printf "(%d): %.40f\n" % [i, 1.0/best.fitness]
  end


  #private

  def run_simulation_dumb
    #create initial population
    @p.create_initial_population

    @simulation_begun = true
    (0...(@max_it)).each do |i|

      evolve_next_generation
      @p.mutate_population
      report_time_simple(i+1,@p.get_best)

    end
  end

  def run_simulation_smart

    original_intervals = @intervals
    
    #set the no. intervals in the Individual class so that every Individual created has only 10 'y' values
    @p.intervals = 10

    # create initial population
    @p.create_initial_population

    # with a quarter of our intended iterations always use 10 intervals
    sub_iteration = @max_it/4 
    (sub_iteration).times do |i| 

      # run our simulation as normal
      evolve_next_generation
      @p.mutate_population
      report_time_simple(i+1,@p.get_best)
    
    end

    # for the rest increase our interval size when needed
    # i.e. every time we're in a new quadrant of iterations, 
    # increase our interval size until we're the full size in the 4th

    # so first lets get our generations to increment and the intervals to increase to
    generations_to_increase_intervals = (1..3).map {|i| (sub_iteration*i)+1}
    intervals_to_increase_to = (1..2).map {|i| 10+(i*(original_intervals-10)/3)}.push(original_intervals)

    # # for the remainder of our iterations...
    (sub_iteration).upto(@max_it) do |i|

      if generations_to_increase_intervals.include?(i)
        
        index = generations_to_increase_intervals.index(i) 

        # ok let's increase the no. intervals
        @p.modify_interval_size(intervals_to_increase_to[index])

      end 

      # run our simulation as normal
      evolve_next_generation
      @p.mutate_population
      report_time_simple(i+1,@p.get_best)

    end

  end  



  #evolution code

  def evolve_next_generation
   
    #Create a new generation and 'merge' the old and newpools together
    next_generation = create_population_pool 
    @p = merge(@p,next_generation)
  
  end

  def create_population_pool
    
    newborn = Array.new(LOCAL_CHILDREN, Individual.new(@intervals,@endpoint_x,@endpoint_y))

    #create a new pool of the same size population
    next_generation = Pool.new(@p.population_size, @intervals, @num_mutations, @num_crossovers, @endpoint_x, @endpoint_y)

    #force its sanity to be false
    @p.sanity = false

    #puts "pool creation start"
    @p.population_size.times do
    
      father, mother = @p.roulette_wheel_selection(father, mother)
      
      #we breed these two
      newborn[0] = @p.breed_interleave(father,mother)
      newborn[1] = @p.breed_splice(father,mother)
      newborn[2] = @p.breed_mean(father,mother)

      #we create heuristic mutations and see whats better
      (3...LOCAL_CHILDREN).each do |k|
        newborn[k] = newborn[k%3].clone
        case k
          when 3...6 then newborn[k].locally_improve(1)
          when 6...9 then newborn[k].locally_improve(2)
          when 9...12 then newborn[k].locally_improve_constant(1.5)
          when 12...15 then newborn[k].locally_improve_constant(2.0)
          else nil
        end
      end

      #mutate and measure fitness
      (0...LOCAL_CHILDREN).each do |k|
        newborn[k].mutate(@num_mutations) if rand <= @mutation_prob          
        
        newborn[k].calc_fitness
      end

      #determine fittest individual
      offspring = newborn.max_by {|x| x.fitness}
      
      next_generation.add(offspring)
    end
  
    return next_generation
  
  end

  #Merge 2 populations by a threshold given by @keep_percent
  def merge(p,p2)
    p.sanitise
    p2.sanitise

    #Create a new Pool
    new_pool = Pool.new(p.population_size, p.intervals, @num_mutations, @num_crossovers, @endpoint_x, @endpoint_y)

    #work out no. Individuals from p & p2 to keep
    amount_to_keep = (p.population_size.to_f * @keep_percent).floor

    #copy those into the new pool
    amount_to_keep.times do |i|
      new_pool.add(p[i-1].clone)
      new_pool.add(p2[i-1].clone)
    end

    #for the rest of the available spots, swap random individuals from p or p2 until we're full
    until new_pool.population.size == new_pool.population_size
      case (0..1).to_a.sample
      when 0 
        #find a random Individual in p
        new_pool.add(p[(0...p.population_size).to_a.sample].clone)
      else
        #find a random Individual in p2
        new_pool.add(p2[(0...p2.population_size).to_a.sample].clone)
      end
    end

    return new_pool

  end



end