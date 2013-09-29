require "gnuplot"

class Individual

  #marks the ranges of our points i.e.  
  # start point:  [0,DEFAULT_Y_COORD] 
  # end point:    [DEFAULT_X_COORD,0]
  DEFAULT_HEIGHT =  2.0
  DEFAULT_X_COORD = 100.0
  DEFAULT_Y_COORD = DEFAULT_HEIGHT

  #no. intervals between (not incl.) 
  DEFAULT_NINTERVAL = 50#100#20#0  
  @@current_intervals = DEFAULT_NINTERVAL

  #Fitness function constants
  GRAVITY = -9.8

  #Tiny non-zero value to give to undesirable fitnesses
  MIN_FLOAT = 1e-37

  #No. times to mutate each time the mutate function is called on the Individual
  #(increase/decrease a point in the y array and adjust its neighbours)
  MUTATIONS = 1

  attr_reader :DEFAULT_NINTERVAL
  attr_accessor :y, :size, :fitness, :interval_x_distance

  def initialize(size=@@current_intervals)
    @size = size.to_i
    @fitness = 0
    @y = Array.new(size, 0.0)

    @endpoint_x = DEFAULT_X_COORD
    @endpoint_y = DEFAULT_Y_COORD

    @interval_x_distance = DEFAULT_X_COORD/(@size+1)

    @total_y_displacement = DEFAULT_Y_COORD

  end

  def self.current_intervals
    @@current_intervals
  end

  def self.current_intervals=(value)
    @@current_intervals = value
  end


  # =========================
  # Create / modify methods
  # =========================

  #reset to random heights for all points other than our boundaries (1...size-1)
  def reset_to_random_heights
    if rand <= 0.2
      @y.collect! {|x| -1*rand*0.1*(@endpoint_y+1).to_f}    
    else
      @y.collect! {|x| rand*0.1*(@endpoint_y+1).to_f}    
    end
    
  end

  def reset_to_slope

    total_x_displacement = (@size+1)*interval_x_distance

    # using y=mx+c, mark each interval's y co-ordinate for a line 
    # between [0,DEFAULT_HEIGHT] and [total_x_displacement,0] 
    c = DEFAULT_HEIGHT
    m = DEFAULT_HEIGHT/total_x_displacement

    @y.collect!.with_index {|x,i| (-1*m) * (interval_x_distance*(i+1)) + c}

  end

  #sort heights in descending order
  def sort!
    @y.sort! { |a,b| b <=> a }
  end

  #amplify heights by a random amount [1,2]*out_factor
  def locally_improve(out_factor)
    factor = (rand + 1.0) * out_factor
    @y.collect!{|height| height*factor}
    #@y.collect!{|height| (height*factor) > @endpoint_y ? height/factor : height*factor}
  end

  #amplify heights by factor 
  def locally_improve_constant(factor)  
    @y.collect!{|height| height*factor}
    #@y.collect!{|height| (height*factor) > @endpoint_y ? height/factor : height*factor}
  end

  # Mutation method
  # randomly add or subtract an amount proportionate to our y array's index
  # we then (to preserve the curve of the expected solution, adjust its 
  # neighbours accordingly) -> makes things converge A LOT faster
  def mutate
    number_intervals = @size - 1

    radius = (number_intervals + 1).to_f / 20.0

    MUTATIONS.times do
      
      #get random point from 1...size-1
      index = rand(0...number_intervals).to_i

      #make our mutations small
      r = rand * 0.5

      #pick how far to the left and right our neighbour correction will go
      j_max = index + (radius/2.0).floor.to_i + 1
      j = index - (radius/2.0).floor.to_i

      #bounds consistency
      j < 0 ? j = 0 : j 
      j_max > @size-1 ? j_max = @size-1 : j

      case (0..1).to_a.sample
        
        #adding our amount
        when 0
          (j...j_max).each do |k|
            @y[k] += (@endpoint_y - @y[k]) * r
          end

        #subtracting our amount
        else
          (j...j_max).each do |k|
            @y[k] -= (@endpoint_y - @y[k]) * r
          end
      end

    end

  end

  def clone 
    ind = Individual.new()
    ind.y = @y.collect{|height| height}  
    ind.fitness = @fitness
    return ind
  end




  # ===========================
  # Interval size manipulation
  # ===========================

  #TODO: revisit this code and see if the original version does a better, more readable job
  def create_bigger_individual(new_size)
    
    current_subinterval_size = DEFAULT_X_COORD/(@size+1)
    new_sub_interval_size = DEFAULT_X_COORD/(new_size+1)
    current_size = @y.size

    #We include the endpoints as it simplifies things
    y = [@endpoint_y,@y.clone,0].flatten
    new_y = Array.new(new_size, 0.0)

    #initially we're in the interval [0, simple.sub_int]
    lower = 0
    upper = current_subinterval_size

    #initial x value of the larger gene
    x = new_sub_interval_size
    i = 0
    j = 0
    while ((i < new_size) and (j <= (current_size+1))) do
      if (x >= lower && x <= upper)
        new_y[i] = get_value(lower,y[j],upper,y[j+1],x)
        x += new_sub_interval_size
        i += 1
      else
        lower = upper
        upper += current_subinterval_size
        j += 1
      end
    end

    @y = new_y
    @size = new_size
    calc_fitness

  end
    
  # Helper method to get y value on line between 2 points
  def get_value(x1,y1,x2,y2,x)
    if y2.nil? || y1.nil? || x2.nil? || x1.nil? || x.nil?
      return 0.0
    end
    return ((y2-y1)/(x2-x1))*(x-x1) + y1
  end

  





  # =========================
  # Fitness function methods
  # =========================

  def calc_fitness
    @fitness = self.fitness_function  
  end
  
  def fitness_function 
    
    #initially the velocity is zero
    velocity = 0.0

    #get the x & y distance between each point
    delta_x = @endpoint_x/(@size+1)
    delta_y = @y[0]-@endpoint_y
   
    #this is our 2-norm which defines the distance between this point and the last
    delta = calc_delta(delta_x,delta_y)

    acceleration = calc_acceleration(delta,delta_y)
    time = calc_time(acceleration, velocity, delta)

    #initially our cumulative time is the same as the current interval
    cumulative_time = time


    #our last step, we examine separately
    (1...@size).each do |i|
  
      velocity = calc_velocity(time,acceleration,velocity)

      delta_y = calc_delta_y(i)
      delta = calc_delta(delta_x,delta_y)

      acceleration = calc_acceleration(delta,delta_y)
      time = calc_time(acceleration, velocity, delta)

      #our total time so far
      cumulative_time += time

    end
    
    velocity = calc_velocity(time,acceleration,velocity)
    # velocity now contains the velocity to compute the i+1th step
    
    delta_y = 0.0 - @y[@size-1] 
    delta = calc_delta(delta_x,delta_y)

    acceleration = calc_acceleration(delta,delta_y)
    time = calc_time(acceleration, velocity, delta)
    
    cumulative_time += time
    
    #Should never happen given we cater for negative discriminants in the time fn
    return MIN_FLOAT if cumulative_time.nan?

    #since we want to maximise fitness...
    return 1.0/cumulative_time
   
  end

  def calc_delta_y(i)
    return @y[i] - @y[i-1]
  end

  def calc_delta(delta_x, delta_y)
    return Math.sqrt((delta_x**2)+(delta_y**2))
  end

  def calc_time (acceleration, velocity, delta)

    val = 0.0;

    val = velocity**2
    val += (2 * acceleration * delta)
    
    if(val > 0)
      val = Math.sqrt(val) 
    else
      return 1e16
    end    

    val += (-1*velocity)
    val /= acceleration

    return val.abs
  end

  def calc_acceleration(delta,delta_y)
    return GRAVITY * (delta_y / delta)
  end

  def calc_velocity(time,acceleration,velocity)
    return acceleration*time + velocity
  end



  # =========================
  # Gnuplot Plotting methods
  # =========================

  #plot x & y axis to gnu plot
  def plot(name='plot.png')

    x,y = self.get_point_arrays

    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title "Descent Time : %.8f" % [(1/@fitness.to_f)]
        x = (x.collect {|v| v.to_f})
        y = (y.collect {|v| v.to_f})
        plot.xlabel 'Run Length'
        plot.ylabel 'Height'
        plot.term 'png'
        plot.output name
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "linespoints"
        end
      end
    end

  end

  def get_point_arrays

    y_axis = ([@total_y_displacement, @y, 0.0]).flatten
    x_axis = (0..@size+1).collect{|x| x*(DEFAULT_X_COORD/(@size+1))}
    
    return x_axis,y_axis

  end


  def to_s
    puts "--------------------------"
    puts "-Individual-"
    puts "fitness: %f" % [@fitness]
    puts "size: %d" % [@size]
    puts "y: #{@y.to_s}"
    puts "--------------------------"
  end



end