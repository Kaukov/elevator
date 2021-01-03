# frozen_string_literal: true

require 'pry'

# Elevator path and floor history calculation
class Elevator
  def initialize(queues, capacity, debug: false)
    @debug = debug
    @floor_history = [0]
    @capacity = capacity
    @max_floor = queues.length
  end

  def process
    # Process all queues
  end

  def history
    []
  end
end
