# frozen_string_literal: true

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
  #
  class RedBlack
    include Enumerable

    attr_accessor :root, :size, :allow_duplicates

    ##
    # Returns a new, empty Red-Black tree. If option +allow_duplicates+ is
    # +false+, then only unique values are inserted in a Red-Black tree.
    #
    # The +root+ attribute references the root node of the tree.
    # The +size+ attribute indicates the number of nodes in the tree.
    # When +size+ is +0+, +root+ is always +nil+.
    #
    # === Example
    #
    #     require 'tree/red_black'
    #
    #     rbt = Tree::RedBlack.new
    #     p rbt.root              #=> nil
    #     p rbt.size              #=> 0
    #     p rbt.allow_duplicates? #=> true

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
    #     rbt.insert(*1..10)      #=> #<Tree::RedBlack:0x00...>
    #     p rbt.size              #=> 10
    #     rbt.map(&:key)          #=> [1, 2, ..., 10]
    #     rbt.select { |node| node.key % 2 == 0 }.map(&:key)
    #                             #=> [2, 4, ..., 10]

    def insert(*values)
      values.each do |value; new_root|
        new_root = if root.nil?
                     RedBlackNode.new(value, :BLACK)
                   else
                     root.insert_red_black(value, @allow_duplicates)
                   end
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
    #     rbt.insert(*1..10)      #=> #<Tree::RedBlack:0x00...>
    #     p rbt.size              #=> 10
    #     rbt.delete(*4..8)       #=> #<Tree::RedBlack:0x00...>
    #     p rbt.size              #=> 5
    #     rbt.map(&:key)          #=> [1, 2, 3, 9, 10]

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
    # Returns a Red-Black tree node whose +key+ matches +value+ by
    # binary search. If no match is found, calls non-nil +ifnone+,
    # otherwise returns +nil+.
    #
    # === Example
    #     require 'tree/red_black'
    #
    #     shuffled_values = [*1..10].shuffle
    #     rbt = shuffled_values.reduce(Tree::RedBlack.new) do |acc, v|
    #       acc.insert(v)
    #     end
    #     rbt.search(7)        #=> <Tree::RedBlackNode:0x00..., @key=7, ...>

    def search(value, ifnone = nil)
      root ? root.search(value, ifnone) : nil
    end

    ##
    # Returns a Red-Black tree node satisfying a criterion defined in
    # +block+ by binary search.
    #
    # If +block+ evaluates to +true+ or +false+, returns the first node
    # for which the +block+ evaluates to +true+. In this case, the
    # criterion is expected to return +false+ for nodes preceding
    # the matching node and +true+ for subsequent nodes.
    #
    # === Example
    #     require 'tree/red_black'
    #
    #     shuffled_values = [*1..10].shuffle
    #     rbt = shuffled_values.reduce(Tree::RedBlack.new) do |acc, v|
    #       acc.insert(v)
    #     end
    #     rbt.bsearch { |node| node.key >= 7 }
    #                           #=> <Tree::RedBlackNode:0x00... @key=7 ...>
    #
    # If +block+ evaluates to <tt><0</tt>, +0+ or <tt>>0</tt>, returns
    # first node for which +block+ evaluates to +0+. Otherwise returns
    # +nil+. In this case, the criterion is expected to return
    # <tt><0</tt> for nodes preceding the matching node, +0+ for some
    # subsequent nodes and <tt>>0</tt> for nodes beyond that.
    #
    # === Example
    #     require 'tree/red_black'
    #
    #     shuffled_values = [*1..10].shuffle
    #     rbt = shuffled_values.reduce(Tree::RedBlack.new) do |acc, v|
    #       acc.insert(v)
    #     end
    #     rbt.bsearch { |node| 7 <=> node.key }
    #                           #=> <Tree::RedBlackNode:0x00... @key=7 ...>
    #
    # If +block++ is not given, returns an enumerator.

    def bsearch(&block)
      return enum_for(:bsearch) unless block_given?

      root ? root.bsearch(&block) : nil
    end

    ##
    # Returns an enumerator for nodes in a Red-Black tree by pre-order
    # traversal.
    #
    # === Example
    #     require 'tree/red_black'
    #
    #     rbt = Tree::RedBlack.new
    #     rbt.insert(*1..10)              #=> #<Tree::RedBlack:0x00...>
    #     rbt.pre_order.map(&:key)        #=> [4, 2, 1, 3, 6, 5, 8, 7, 9, 10]

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
    #     rbt.in_order.map(&:key)        #=> [1, 2, ..., 10]

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
    #     p rbt.root.key            #=> {:a=>1, :b=>2}
    #     p rbt.root.key.delete(:a) #=> 1
    #     p rbt.root.key            #=> {:b=>2}
    #     p rbt_copy.root.key       #=> {:a=>1, :b=>2}

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
