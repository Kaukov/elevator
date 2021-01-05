# frozen_string_literal: true

require 'pry'

# Elevator
class Elevator
  attr_reader :history

  def initialize(queues, capacity, debug: false)
    @current_floor = 0
    @history = [0]
    @queues = hash_queues queues
    @capacity = capacity
    @debug = debug
    @elevator = []

    @direction = 1

    @last_floor = queues.length - 1

    @technician_inside = -1
  end

  def process
    until @queues.keys.length.zero? && @elevator.length.zero?
      process_current_floor

      change_floor

      check_for_direction_change
    end

    add_historical_floor 0
  end

  private

  def hash_queues(queues)
    queues_hash = {}

    queues.each_with_index do |queue, floor|
      queues_hash[floor.to_s] = queue if queue.length.positive?
    end

    queues_hash
  end

  def process_current_floor
    # Delete each person in the elevator queued for the current floor
    @elevator.each do |item|
      next unless item.abs == @current_floor

      @elevator.delete item

      add_historical_floor @current_floor
    end

    return unless @queues[@current_floor.to_s]

    queue_items_delete = []

    @queues[@current_floor.to_s].each_with_index do |item, index|
      next unless item.abs > @current_floor && @direction == 1 || item.abs < @current_floor && @direction.zero?

      add_historical_floor @current_floor

      break unless @elevator.length < @capacity

      @elevator << item

      @technician_inside = item.abs if item.negative?

      queue_items_delete << index
    end

    queue_items_delete.reverse.each { |index| @queues[@current_floor.to_s].delete_at index }

    @queues.delete @current_floor.to_s unless @queues[@current_floor.to_s].length.positive?
  end

  def change_floor
    unless @technician_inside.negative?
      @current_floor = @technician_inside
      @technician_inside = -1

      return
    end

    @current_floor += 1 if @direction.positive?
    @current_floor -= 1 if @direction.zero?
  end

  def check_for_direction_change
    @direction = 0 if @current_floor == @last_floor
    @direction = 1 if @current_floor.zero?
  end

  def add_historical_floor(floor)
    @history.push floor unless @history.last.eql? floor
  end
end
