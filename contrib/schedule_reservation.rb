#!/usr/bin/env ruby
require 'tree/red_black'

module IntegerTime
  interval_in_seconds = {
    second: 1,
    minute: 60,
    hour: 60 * 60,
    day: 24 * 60 * 60,
    week: 7 * 24 * 60 * 60,
    year: 365 * 24 * 60 * 60
  }

  refine Integer do
    interval_in_seconds.keys.each do |key|
      define_method(key) { self * interval_in_seconds[key] }
      define_method((key.to_s + 's').to_sym) { self * interval_in_seconds[key] }
    end
  end
end

class BusyFreeEvent
  include Comparable

  attr_reader :time, :owner

  def initialize(time, owner)
    @time = time
    @owner = owner
  end

  def <=>(other)
    time <=> other.time
  end

  def inspect
    { time => owner }
  end
end

class Reservation
  attr_reader :from, :to, :owner

  def initialize(from, to, owner)
    @from = from
    @to = to
    @owner = owner
  end

  def inspect
    { [from, to] => owner }
  end
end

class Schedule
  using IntegerTime

  attr_accessor :events

  def initialize
    @events = Tree::RedBlack.new(false)
  end

  def reserve(from:, to: from + 1.hour,  owner:)
    return nil if owner == :FREE

    next_owner = :FREE
    total_events = events.size

    rsv_from = BusyFreeEvent.new(from, owner)
    rsv_to = BusyFreeEvent.new(to, next_owner)

    if total_events.zero?
      events.insert(rsv_from, rsv_to)
    else
      succ_event = events.bsearch { |event| event.key > rsv_from }
      if succ_event.nil?
        pred_event = events.root.max

        # Assert: pred_event.key.owner == :FREE
        if pred_event.key == rsv_from
          events.delete(pred_event.key)
          total_events -= 1
        end
        events.insert(rsv_from, rsv_to)
      elsif succ_event.key >= rsv_to
        pred_event = succ_event.pred
        if pred_event.nil? || pred_event.key.owner == :FREE
          events.delete(pred_event.key) if pred_event&.key == rsv_from
          events.insert(rsv_from)
          if succ_event.key != rsv_to

            # Assert: succ_event.key.owner != :FREE
            events.insert(rsv_to)
          else
            next_owner = succ_event.key.owner
            total_events -= 1
          end
        end
      end
    end

    # Assert: inserts/deletes successful
    events.size == total_events + 2 ? Reservation.new(from, to, owner) : nil
  end

  def unreserve(reservation)
    event = events.bsearch { |ev| ev.key.time >= reservation.from }

    return false if (event.nil? || event.key.time != reservation.from || event.key.owner != reservation.owner)

    # Assert: event.key.owner != :FREE
    pred_event = event.pred
    succ_event = event.succ

    # Assert: ! succ_event.nil?

    events.delete(event.key)
    events.delete(succ_event.key) if succ_event.key.owner == :FREE
    events.insert(BusyFreeEvent.new(reservation.from, :FREE)) if pred_event && pred_event.key.owner != :FREE
    true
  end

  def is_consistent?
    count = 0
    prev = nil
    event = events.root&.min
    return false if event && event.key.owner == :FREE
    while event
      return false if prev&.key&.owner == :FREE && event.key.owner == :FREE
      prev = event
      event = event.succ
      count += 1
    end
    return false if prev && prev.key.owner != :FREE
    count == events.size && prev&.key&.owner == :FREE
  end
end

if $0 == __FILE__
  using IntegerTime

  sched = Schedule.new
  reserve_time = Time.now

  puts "Before:"
  sched.events.each do |event|
    puts "key: #{event.key}"
  end

  puts "First reservation:"
  reservation1 = sched.reserve(from: reserve_time, owner: :BUSY3)
  puts "reservation: #{reservation1.inspect}"

  puts "After first reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Second reservation:"
  reservation2 = sched.reserve(from: reserve_time - 1.hour, owner: :BUSY2)
  puts "reservation: #{reservation2.inspect}"

  puts "After second reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Third reservation:"
  reservation3 = sched.reserve(from: reserve_time + 1.hour, owner: :BUSY4)
  puts "reservation: #{reservation3.inspect}"

  puts "After third reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Fourth reservation:"
  reservation4 = sched.reserve(from: reserve_time - 4.hours, owner: :BUSY0)
  puts "reservation: #{reservation4.inspect}"

  puts "After fourth reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Fifth reservation:"
  reservation5 = sched.reserve(from: reserve_time - 2.hours, to: reserve_time - 90.minutes, owner: :BUSY1)
  puts "reservation: #{reservation5.inspect}"

  puts "After fifth reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Schedule is consistent?: #{sched.is_consistent?}"

  puts "Delete fifth reservation:"
  result = sched.unreserve(reservation5)
  puts "result: #{result}"

  puts "After deleting fifth reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Delete fourth reservation:"
  result = sched.unreserve(reservation4)
  puts "result: #{result}"

  puts "After deleting fourth reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Delete third reservation:"
  result = sched.unreserve(reservation3)
  puts "result: #{result}"

  puts "After deleting third reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Delete second reservation:"
  result = sched.unreserve(reservation2)
  puts "result: #{result}"

  puts "After deleting second reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end

  puts "Delete first reservation:"
  result = sched.unreserve(reservation1)
  puts "result: #{result}"

  puts "After deleting first reservation:"
  sched.events.each do |event|
    puts "key: #{event.key.inspect}"
  end
end
