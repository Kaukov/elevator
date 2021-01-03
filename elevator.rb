# frozen_string_literal: true

require 'pry'

# Elevator path and floor history calculation
class Elevator
  def initialize(queues, capacity, debug: false)
    @debug = debug
    @floor_history = [0]
    @capacity = capacity
    @queues = hash_queues queues
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
    while @queues.keys.length.positive?
      go_up
      go_down
    end

    # Return to ground floor
    @floor_history.push 0
  end

  def go_up
    # Process elevator going up
  end

  def go_down
    # Process elevator going down
  end

  def history
    @floor_history
  end
end
