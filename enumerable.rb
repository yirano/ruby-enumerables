#!/usr/bin/env ruby
# frozen_string_literal: true

module Enumerable

  def my_each
    if block_given?
      to_a.size.times { |x| yield(to_a[x]) }
      self
    else
      to_enum(:my_each)
    end
  end

  def my_each_with_index
    if block_given?
      self.length.times { |x| yield(self[x], x) }
      self
    else
      to_enum(:my_each_with_index)
    end
  end

  def my_select
    arr = []
    if block_given?
      my_each { |x| yield(x) ? arr << x : arr }
      arr
    else
      enum_for(:my_select)
    end
  end

  def my_count (argument = nil)
    count = 0
    if block_given?
      my_each do |x|
        count += 1 if yield(x)
      end
    elsif argument.nil?
      count = size
    else
      my_each do |x|
        count += 1 if x == argument
      end
    end
    count
  end

  def my_all?(pattern = nil)
    if block_given?
      my_each { |x| return false if !yield(x) }
    elsif pattern
      if pattern.is_a?(Regexp)
      my_each { |x| return false if !x.match?(pattern) }
      elsif pattern.is_a?(Class)
        my_each { |x| return false if !x.is_a?(pattern) }
      else
        return false if my_count {|x| x == pattern} != size
      end
    else
      my_each { |x| return false if x.is_a?(NilClass) || x.is_a?(FalseClass) }
    end
    true
  end

  def my_any?(pattern = nil)
    if block_given?
      my_each { |x| return true if yield(x) }
    elsif pattern.is_a?(Regexp)
      my_each { |x| return true if x.match?(pattern) }
    elsif pattern.is_a?(Class)
      my_each { |x| return true if x.is_a?(pattern) }
    else
      return true if self.include?(pattern) || size.positive?
    end
    false
  end

  def my_none?(pattern = nil)
    if block_given?
      my_each { |x| return false if yield(x) }
    elsif pattern
      if pattern.is_a?(Regexp)
        my_each { |x| return false if x.match?(pattern) }
      elsif pattern.is_a?(Class)
        my_each { |x| return false if x.is_a?(pattern) }
      else
        return false if self.include?(pattern) || size.positive?
      end
    else
      my_each { |x| return false if x.is_a?(TrueClass) }
    end

    true
  end

  def my_map
    arr = []
    if block_given?
      if is_a?(Range)
        temp_array = [*self]
        temp_array.my_each do |x|
          arr << yield(x)
        end
      else
        my_each do |x|
          arr << yield(x)
        end
      end
      arr
    else
      enum_for(:my_map)
    end
  end

  def my_inject(*args)
    if !args.empty?
      args_found(*args)
    end
    arr = []
    (min..max).my_each { |x| arr << x }
    if block_given?
      initial = 1
      arr.my_each { |item| initial = yield(initial, item) }
    elsif sym
      arr.my_each { |item| initial = initial.public_send(sym, item) }
    end
    initial
  end

  def args_found(*args)
    puts "something here"
    # initial, sym = nil
    puts args
    # [initial, sym]
  end

end
# puts (5..10).reduce(:+)                             #=> 45
# puts (5..10).inject { |sum, n| sum + n }            #=> 45
# puts (5..10).reduce(1, :*)                          #=> 151200
# puts (5..10).inject(1) { |product, n| product * n } #=> 151200
# longest = %w{ cat sheep bear }.inject do |memo, word|
#    memo.length > word.length ? memo : word
# end
# puts longest
puts
puts (5..10).my_inject(:+)                             #=> 45
# puts (5..10).my_inject { |sum, n| sum + n }            #=> 45
# puts (5..10).my_inject(1, :*)                          #=> 151200
# puts (5..10).my_inject(1) { |product, n| product * n } #=> 151200
# longest = %w{ cat sheep bear }.my_inject do |memo, word|
  #  memo.length > word.length ? memo : word
# end
# puts longest





# # Below are the test cases used
# a=[11,22,31,224,44].my_each_with_index { |val,index| puts "index: #{index} for #{val}" if val < 30}
# p a
# puts

# p [1,2,3,4,5].my_select { |num|  num.even?  }   #=> [2, 4]
# a = %w{ a b c d e f }
# p a.my_select { |v| v =~ /[aeiou]/ }  #=> ["a", "e"]
# puts


# p %w[ant bear cat].my_all? { |word| word.length >= 3 } #=> true
# p %w[ant bear cat].my_all? { |word| word.length >= 4 } #=> false
# p %w[ant bear cat].my_all?(/t/)                        #=> false
# p %w[ant bear cat].my_all?(/a/)                        #=> true
# p [1, 2i, 3.14].my_all?(Numeric)                       #=> true
# p [1, 2i, 3.14].my_all?(String)                        #=> false
# p [nil, true, 99].my_all?                              #=> false
# p [].my_all?                                           #=> true
# p [3, 3, 3].my_all?(3)                        # false
# p [3, 3, 3].all?(3)                        # false
# puts

# p %w[ant bear cat].my_any? { |word| word.length >= 3 } #=> true
# p %w[ant bear cat].my_any? { |word| word.length >= 4 } #=> true
# p %w[ant bear cat].my_any?(/z/)                        #=> true
# p [nil, true, 99].my_any?(Integer)                     #=> true
# p [nil, true, 99].my_any?                              #=> true
# p [].my_any?                                           #=> false
# puts

# p %w{ant bear cat}.my_none? { |word| word.length == 5 } #=> true
# p %w{ant bear cat}.my_none? { |word| word.length >= 4 } #=> false
# p %w{ant bear cat}.my_none?(/d/)                        #=> true
# p [1, 3.14, 42].my_none?(Float)                         #=> false
# p [].my_none?                                           #=> true
# p [nil].my_none?                                        #=> true
# p [nil, false].my_none?                                 #=> true
# p [nil, false, true].my_none?                           #=> false
# puts

# ary = [1, 2, 4, 2]
# p ary.my_count               #=> 4
# p ary.my_count(2)            #=> 2
# p ary.my_count{ |x| x%2==0 } #=> 3
# puts

# p (1..4).my_map { |i| i*i }      #=> [1, 4, 9, 16]
# p (1..4).my_map { "cat"  }   #=> ["cat", "cat", "cat", "cat"]
# puts

# # Sum some numbers
# p (5..10).my_inject(:+)                             #=> 45
# p # Same using a block and inject
# p (5..10).my_inject { |sum, n| sum + n }            #=> 45
# p # Multiply some numbers
# p (5..10).my_inject(1, :*)                          #=> 151200
# p # Same using a block
# p (5..10).my_inject(1) { |product, n| product * n } #=> 151200
# # find the longest word