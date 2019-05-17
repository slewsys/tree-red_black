# -*- coding: utf-8 -*-
# coding: UTF-8

require 'tree/red_black/red_black_node'

module Tree

  ##
  # Tree::RedBlack is a pure-Ruby implementation of a
  # {Red-Black tree}[https://en.wikipedia.org/wiki/Red–black_tree] --
  # i.e., a self-balancing binary search tree with
  # {O(log n)}[https://en.wikipedia.org/wiki/Big-O_notation]
  # search, insert and delete operations. It is appropriate for
  # maintaining an ordered collection where insertion and deletion
  # are desired at arbitrary positions.
  #
  # The implementation differs slightly from the Wikipedia description
  # referenced above. In particular, leaf nodes are +nil+, which
  # affects the details of node deletion.

  class RedBlack
    include Enumerable

    attr_accessor :root, :size, :allow_duplicates

    ##
    # Returns a new, empty Red-Black tree. If option +allow_duplicates+ is
    # +false+, then only unique values are inserted in a Red-Black tree.
    #
    # A Red-Black tree exposes parameters +root+, the root node of a
    # tree, and +size+, the number of nodes in the tree.
    #
    # === Example
    #
    #     require 'tree/red_black'
    #
    #     rbt = Tree::RedBlack.new
    #     p rbt.root              -> nil
    #     p rbt.size              -> 0
    #     p rbt.allow_duplicates? -> true

    def initialize(allow_duplicates = true)
      @root = nil
      @size = 0
      @allow_duplicates = allow_duplicates
    end

    def allow_duplicates?
      @allow_duplicates
    end

    ##
    # Inserts a value or sequence of values in a Red-Black tree and
    # increments the +size+ attribute by the number of values
    # inserted.
    #
    # Since a Red-Black tree maintains an ordered, Enumerable
    # collection, every value inserted must be comparable with every
    # other value. Methods +each+, +map+, +select+, +find+, +sort+,
    # etc., can be applied directly to the tree.
    #
    # The individual nodes yielded by enumeration respond to method
    # +key+ to retrieve the value stored in that node. Method +each+,
    # in particular, is aliased to +in_order+, so that nodes are
    # sorted in ascending order by +key+ value. Nodes can also be
    # traversed by method +pre_order+, e.g., to generate paths in the
    # tree.
    #
    # === Example
    #
    #     require 'tree/red_black'
    #
    #     rbt = Tree::RedBlack.new
    #     rbt.insert(*1..10)      -> #<Tree::RedBlack:0x00...>
    #     p rbt.size              -> 10
    #     rbt.map(&:key)          -> [1, 2, ..., 10]
    #     rbt.select { |node| node.key % 2 == 0 }.map(&:key)
    #                             -> [2, 4, ..., 10]

    def insert(*values)
      values.each do |value; new_root|
        new_root = (root.nil? ? RedBlackNode.new(value, :BLACK) :
                    root.insert_red_black(value, @allow_duplicates))
        unless new_root.nil?
          @root = new_root
          @size += 1
        end
      end
      self
    end

    ##
    # Deletes a value or sequence of values from a Red-Black tree.
    #
    # === Example
    #
    #     require 'tree/red_black'
    #
    #     rbt = Tree::RedBlack.new
    #     rbt.insert(*1..10)      -> #<Tree::RedBlack:0x00...>
    #     p rbt.size              -> 10
    #     rbt.delete(*4..8)       -> #<Tree::RedBlack:0x00...>
    #     p rbt.size              -> 5
    #     rbt.map(&:key)          -> [1, 2, 3, 9, 10]

    def delete(*values)
      values.each do |value; new_root|
        new_root = root.nil? ? nil : root.delete_red_black(value)
        unless new_root.nil?
          @root = new_root
          @size -= 1
        end
        @root = nil if size == 0
      end
      self
    end

    ##
    # Returns an enumerator for nodes in a Red-Black tree by pre-order
    # traversal.
    #
    # === Example
    #     require 'tree/red_black'
    #
    #     rbt = Tree::RedBlack.new
    #     rbt.insert(*1..10)              -> #<Tree::RedBlack:0x00...>
    #     rbt.pre_order.map(&:key)        -> [4, 2, 1, 3, 6, 5, 8, 7, 9, 10]

    def pre_order(&block)
      return enum_for(:pre_order) unless block_given?
      return if root.nil?

      root.pre_order(&block)
    end

    ##
    # Returns an enumerator for nodes in a Red-Black tree by in-order
    # traversal. The +each+ method is aliased to +in_order+
    #
    # === Example
    #     require 'tree/red_black'
    #
    #     rbt = Tree::RedBlack.new
    #     shuffled_values = [*1..10].shuffle
    #     rbt.insert(*shuffled_values)
    #     rbt.in_order.map(&:key)        -> [1, 2, ..., 10]

    def in_order(&block)
      return enum_for(:in_order) unless block_given?
      return if root.nil?

      root.in_order(&block)
    end

    ##
    # Returns a deep copy of a Red-Black tree, provided that the
    # +dup+ method for values in the tree is also a deep copy.
    #
    # === Example
    #
    #     require 'tree/red_black'
    #
    #     rbt = Tree::RedBlack.new
    #     rbt.insert({a: 1, b: 2})
    #     rbt_copy = rbt.dup
    #     p rbt.root.key            -> {:a=>1, :b=>2}
    #     p rbt.root.key.delete(:a) -> 1
    #     p rbt.root.key            -> {:b=>2}
    #     p rbt_copy.root.key       -> {:a=>1, :b=>2}

    def dup
      copy = RedBlack.new
      copy.size = size
      copy.allow_duplicates = allow_duplicates
      copy.root = root.dup
      copy
    end

    alias each in_order
  end
end
