require_relative 'individual'

class Pool

  NUM_CROSSOVERS = 1


  attr_accessor :population, :sanity
  attr_reader :population_size, :relative_fitness

  def initialize(size)

    @population_size = size
    @sanity = false

    @slope_percent = 0.0
    @ordered_random_percent = 0.0

    if(@slope_percent + @ordered_random_percent > 1.0)
      @slope_percent = @slope_percent/(@slope_percent + @ordered_random_percent)
      @ordered_random_percent = @slope_percent/(@slope_percent + @ordered_random_percent)
    end

    #mutations to save between sets
    @mutations_to_save = 1

    #probability modifiers
    @mutation_probality = 1.0
    @proportion_to_mutate = 0.3 

    #initialise random
    srand(Time.new.usec)

    @population = []

    #do we need to keep track of relative fitness?
    @relative_fitness = Array.new(@population_size,0.0)
  end



  # =======================================================
  # Pool (i.e. batch of Individuals) create/modify methods
  # =======================================================

  def create_initial_population

    #determine our slope and ordered-random proportions
    num_ordered_random = (@population_size * @ordered_random_percent).ceil
    num_slope = (@population_size * @slope_percent).ceil
   
    #create individuals randomly whilst keeping our proportion constraints
    @population_size.times do 
      
      ind = nil

      case (rand*2).round.to_i
       
        when 2 then
          if num_ordered_random > 0
            ind = create_random_individual.sort

            random_order_population -= 1
          else
            ind = create_random_individual
          end
       
        when 1 then
          if num_slope > 0
            ind = create_slope_individual
            ind.mutate(num_intervals) if slope_population > 1
            slope_population -= 1
          else
            ind = create_random_individual
          end
       
        else
          ind = create_random_individual

      end

      add(ind)
    end

  end

  def modify_interval_size(new_size)
    @population_size.times do |i|
      @population[i].create_bigger_individual(new_size)
    end
    Individual.current_intervals = new_size
  end

  # ============================================
  # Helper methods for creating Individuals
  # ============================================

  def create_random_individual
    ind = Individual.new()
    ind.reset_to_random_heights
    return ind  
  end

  def create_slope_individual
     ind = Individual.new() 
     ind.reset_to_slope
     return ind
  end


  # ============================================
  # Selection methods for Individuals
  # ============================================

  def roulette_wheel_selection(father,mother)
    
    father_index = get_index_worst_individual_above(rand)
    father = @population[father_index]

    #get worst individual above that isn't the father
    mother_index = get_index_worst_individual_above(rand, father_index)
    mother = @population[mother_index]

    return father, mother
  end

  #get the least relative fit individual that is above 'threshold'
  def get_index_worst_individual_above(relative_threshold, exclusion_index = -1)

    #correct array s/t individuals are in descending order (i.e. best is population[0])
    self.sanitise

    #calculate relative fitness vector
    calc_relative_fitness

    #get minimum index 
    indexes_greater_than = (0...@relative_fitness.size).select{|i| @relative_fitness[i] > relative_threshold && i != exclusion_index }

    #return individual at that index  
    if indexes_greater_than.length > 0
      indexes_greater_than[0]
    else
      0
    end
  end




  # ============================================
  # Breeding methods
  # ============================================

  def breed_mean(father,mother)

    fm = [father,mother]
    crossover_indexes = get_crossover_points(fm)

    #randomly select first (base) parent
    index = (0..1).to_a.sample
    
    #copy first parent in
    offspring = fm[index].clone

    #copy the average of the father and mother at each crossover index
    crossover_indexes.each do |x|
      offspring.y[x] = (fm[0].y[x] + fm[1].y[x]).to_f * 0.5
    end

    return offspring
  end

  def breed_splice(father,mother)
    
    fm = [father,mother]
    crossover_indexes = get_crossover_points(fm)
    
    #randomly select first (base) parent
    index = (0..1).to_a.sample

    #copy first parent in
    offspring = fm[index].clone 

    crossover_indexes.each_index do |i|
        current_index = (crossover_indexes[i])
        next_index = (crossover_indexes[i+1]).nil? ? fm[0].size-1 : (crossover_indexes[i+1])

        #copy everything from this index to the next from the current random parent
        (current_index...next_index).each do |j|
          offspring.y[j] = fm[index].y[j]
        end

        #select the other parent
        index = 1 - index        
  
    end

    return offspring
  end

  def breed_interleave(father,mother)
    
    fm = [father,mother]
    crossover_indexes = get_crossover_points(fm)
      
    #randomly select first (base) parent
    index = (0..1).to_a.sample

    #copy first parent in
    offspring = fm[index].clone 

    #select the other parent
    index = 1 - index        

    #copy the other parent's vales over at each crossover index
    crossover_indexes.each do |x|
      offspring.y[x] = fm[index].y[x]
    end

    return offspring
  end


  def get_crossover_points(fm)
    crossover_count = NUM_CROSSOVERS < fm[0].size ? NUM_CROSSOVERS : (fm[0].size/2)
    return (0...fm[0].size).to_a.shuffle.slice(0,crossover_count).sort
  end



  # ============================================
  # Individual modification methods
  # ============================================

  def mutate_population
      
    if rand <= @mutation_probality
      
      #the operations below have the potential to make the population pool out of order
      @sanity = false  

      #lets mutate our proportion_to_mutate of the population
      num_mutations = (@population_size * @proportion_to_mutate).floor

      num_mutations.times do 

        random_index = rand(0...(@population_size-1))

        #mutate this individual
        population[random_index].mutate()

        #recalculate fitness
        population[random_index].calc_fitness()
    
      end
    end
  end



  def add(new_individual)
    @population.push(new_individual)
  end

  def [](index)
    return @population[index]
  end

  def get_best
    self.sanitise

    return @population[0]
  end

  #sort by fitness descending
  def sort
    @population.sort! { |a,b| b.fitness <=> a.fitness }
  end

  def calc_relative_fitness
    sum = 0.0
    @population.each {|val| sum += val.fitness} 
    @relative_fitness = population.collect {|x| x.fitness/sum }  
  end

  #do we need sanitise after some crafty refactoring?
  def sanitise
    if @sanity == false

      #correct array s/t individuals are in descending order (i.e. best is population[0])
      self.sort

      #calculate relative fitness vector
      calc_relative_fitness

      #set our state variable
      @sanity = true

    end
  end

  # def to_s
  #   puts "--------------------------"
  #   puts "-Pool-"
  #   puts "population: %f" % [@population]
  #   puts "current_population: %f" % [@current_population]
  #   puts "sanity: %s" % [@sanity ? "true" : "false"]
  #   puts "relative_fitness: %s" % [@relative_fitness.to_s]
  #   puts "persons:"
  #   puts @population.to_s
  #   puts "--------------------------"
  # end

end