#!/usr/bin/ruby -w


require_relative 'genetic_algorithm'
require_relative 'pool'


class Ga
  
  LOCAL_CHILDREN = 15
  CROSSOVER_DEFAULT = 1

  MUTATION_DEFAULT = 1

  DEFAULT_KEEP_PERCENT = 0.4


  attr_reader :max_it, :slope_percent, :random_order_percent, :keep_percent, 
              :mutation_prob, :mute_prop, :smart_start
  attr_accessor :p, :simulation_begun, :crossovers, :mutations

  def initialize
    @crossovers=CROSSOVER_DEFAULT
    @mutations=MUTATION_DEFAULT
    @simulation_began = false    
  end

  def set_parameters(max_it,population_size,slope_percent,random_order_percent,
                    mutation_prob,mute_prop,smart_start)
    @max_it = max_it
    @p = Pool.new(population_size)
    
    @slope_percent = slope_percent
    @random_order_percent = random_order_percent
    
    @keep_percent = DEFAULT_KEEP_PERCENT > 0.5 ? 0.5 : DEFAULT_KEEP_PERCENT

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

  def run_simulation(simulation_iterations)
    #initalise random
    srand(Time.new.usec)

    #@p.create_initial_population

    #only allow run_simulation_smart for 70 iterations
    if @smart_start && simulation_iterations > 70 && Individual.current_intervals > 10
      GeneticAlgorithm::run_simulation_smart(self)
    else
      GeneticAlgorithm::run_simulation_dumb(self)
    end
  end




  #private



  #evolution code

  def evolve_next_generation
   
    #Create a new generation and 'merge' the old and newpools together
    next_generation = create_population_pool 
    @p = merge(@p,next_generation)
  
  end

  def create_population_pool
    
    newborn = Array.new(LOCAL_CHILDREN, Individual.new())

    #create a new pool of the same size population
    next_generation = Pool.new(@p.population_size)

    father = Individual.new()
    mother = Individual.new()

    #force its sanity to be false
    @p.sanity = false

    #puts "pool creation start"
    (0...(@p.population_size)).each do
    
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
        newborn[k].mutate if rand <= @mutation_prob          
        
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
    new_pool = Pool.new(p.population_size)

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