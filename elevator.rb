# frozen_string_literal: true

require 'pry'

# Elevator path and floor history calculation
class Elevator
  def initialize(queues, capacity, debug: false)
    @debug = debug
    @floor_history = [0]
    @capacity = capacity
    @queues = hash_queues queues
    @direction = 1
    @current_floor = 0
    @elevator = {}
    @max_floor = queues.length
  end

  def hash_queues(queues)
    queues_hash = {}

    queues.each_with_index do |queue, index|
      queues_hash[index.to_s] = queue if queue.length.positive?
    end

    queues_hash
  end

  def process
    print_debug 'Processing queue...'

    while @queues.keys.length.positive?
      go_up
      go_down
    end

    # Return to ground floor
    add_to_floor_history 0
  end

  # Process elevator going up from the ground floor to the @max_floor
  # and process each floor on the way if a queue is waiting on a floor,
  # or a person on the elevator is waiting to get off on that floor
  # @return [void]
  def go_up
    # Exit the method if no @queues keys are left to process
    return unless @queues.keys.length.positive?

    # Set the @direction to be "going up" (1)
    @direction = 1

    # Go through each floor until the @max_floor is reached
    until @current_floor == @max_floor
      # Process current floor
      process_floor

      # Increase the @current_floor so the next floor is checked
      @current_floor += 1
    end

    # In the above loop the @current_floor has a value of @max_floor,
    # which is 1 higher than the index of the last queue.
    # Decrease the @current_floor by 1 so the algorithm can process going down
    # without producing wrong results
    @current_floor = @max_floor - 1 unless @current_floor < @max_floor
  end

  def go_down
    # Exit the method if no @queues keys are left to process
    return unless @queues.keys.length.positive?

    # Set the @direction to be "going down" (0)
    @direction = 0

    # Go through each floor until the ground floor is reached
    until @current_floor.zero?
      # Process current floor
      process_floor

      # Reduce the @current_floor so the next floor is checked
      @current_floor -= 1
    end
  end

  # Process @current_floor and check if there's someone who can leave the elevator
  # on the @current_floor, and check if there's a queue and if so - how many people
  # can enter the elevator
  # @return [void]
  def process_floor
    print_debug "Current floor: #{@current_floor}"

    # Check if there's someone who can leave the elevator at the @current_floor
    can_leave_elevator

    # Exit the method if no @queues key exists for the current floor (no queue on current floor)
    return unless @queues[@current_floor.to_s]

    # Array to keep track of which queue members enter the elevator
    # so they can be removed from the @queues[@current_floor] later
    indexes_to_delete = []

    # Go through each element in the @queues[@current_floor] array and check if
    # it can enter the elevator
    @queues[@current_floor.to_s].each_with_index do |item, index|
      # Skip the item if it can't enter the elevator
      next unless enter_elevator? item

      # Add the index to the indexes_to_delete array
      indexes_to_delete.push index

      print_debug 'After queueing valid item', @queues[@current_floor.to_s]
    end

    # Delete items from the @queues[@current_floor] if indexes_to_delete is not empty
    delete_items_from_floor @current_floor, indexes_to_delete unless indexes_to_delete.length.zero?
  end

  def can_leave_elevator
    # Return false unless there are items waiting to get off on the @current_floor
    return false unless @elevator[@current_floor.to_s]

    # Add the @current_floor to the @floor_history
    add_to_floor_history @current_floor

    print_debug "At least 1 person can leave on current floor (#{@current_floor})"

    # Increase the capacity of the elevator by the number of people who got off
    # the elevator on the @current_floor
    @capacity += @elevator[@current_floor.to_s]

    print_debug "Elevator capacity: #{@capacity}"

    # Delete the @current_floor key from @elevator since no people are
    # now queued for that floor
    @elevator.delete @current_floor.to_s
  end

  # Check if an item can enter the @elevator
  # If so, process it
  # @param [Numeric] item - The item to check if it can enter the @elevator
  # @return [Boolean]
  def enter_elevator?(item)
    # Check if the item is at all valid to enter on the @current_floor
    # by checking if the direction is up and the item is larger than the @current_floor,
    # or if the direction is down and the item is smaller than the @current_floor
    return false unless @direction.positive? && item > @current_floor || @direction.zero? && item < @current_floor

    # Add the @current_floor to the @floor_history
    add_to_floor_history @current_floor

    # Return false if the elevator's capacity is reached (0) and the item can't enter the @elevator
    return false unless @capacity.positive?

    add_to_elevator item

    true
  end

  # Add someone to the @elevator queue for a floor
  # @param [Numeric] floor - The @elevator floor to add someone for
  # @return [void]
  def add_to_elevator(floor)
    print_debug "#{floor} entered the elevator"

    # Increase the floor count of the @elevator[floor] if there's already someone queued for the floor
    @elevator[floor.to_s] += 1 if @elevator[floor.to_s]

    # Set the floor count of the @elevator[floor] if there's no one queued for that floor
    @elevator[floor.to_s] = 1 unless @elevator[floor.to_s]

    # Reduce the available @capacity by 1
    @capacity -= 1

    print_debug "Remaining elevator capacity: #{@capacity}"
  end

  # Delete the specified indexes from a given floor
  # @param [Numeric] floor - The floor to delete indexes from
  # @param [Enumerable] indexes - The indexes to delete from the specified floor
  # @return [void]
  def delete_items_from_floor(floor, indexes)
    # Go through a reversed indexes array so all indexes are deleted correctly
    # and delete each index from @queues[floor]
    indexes.reverse.each { |index| @queues[floor.to_s]&.delete_at index }

    print_debug 'After queueing valid item', @queues[@current_floor.to_s]

    # Delete the @current_floor key from @queues if the queue length is zero
    # after index deletion
    @queues.delete @current_floor.to_s if @queues[@current_floor.to_s].length.zero?
  end

  # Add the specified floor to the @floor_history
  # unless the last floor in the @floor_history is the same as floor
  # @param [Numeric] floor - The floor to add to the @floor_history
  # @return [void]
  def add_to_floor_history(floor)
    print_debug "Adding #{floor} to floor history if it's not already there (as last inserted)"

    @floor_history.push floor unless @floor_history.last == floor
  end

  def history
    @floor_history
  end

  def print_debug(*items)
    return unless @debug

    items.each { |item| p item }
  end
end
