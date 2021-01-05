# frozen_string_literal: true

require 'rspec'
require 'pry'
require_relative 'elevator'

describe Elevator do
  let(:capacity) { 5 }

  [
    { queues: [[], [], [5, 5, 5], [], [], [], []],
      answer: [0, 2, 5, 0],
      debug: false },
    { queues: [[], [], [1, 1], [], [], [], []],
      answer: [0, 2, 1, 0],
      debug: false },
    { queues: [[], [3], [4], [], [5], [], []],
      answer: [0, 1, 2, 3, 4, 5, 0],
      debug: false },
    { queues: [[], [0], [], [], [2], [3], []],
      answer: [0, 5, 4, 3, 2, 1, 0],
      debug: false },
    { queues: [[], [0, 3, 3, 5, 5, 5], [], [0, 0, 2, 2, 5, 5, 5], [2], [3], [0, 0, 0, 4, 4, 4]],
      answer: [0, 1, 3, 5, 6, 5, 4, 3, 2, 1, 0, 3, 5, 6, 5, 4, 3, 2, 0],
      debug: false },
    { queues: [[], [2, 2], [1, 0, -5], [1, 4, 4], [2], []],
      answer: [0, 1, 2, 5, 4, 3, 2, 1, 0, 3, 4, 0],
      debug: false }
  ].each do |example|
    it "solves #{example[:queues]} with #{example[:answer]}" do
      e = Elevator.new example[:queues], capacity, debug: example[:debug]
      e.process

      e.history.should eq example[:answer]
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :should
  end
end
