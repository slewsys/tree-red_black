# -*- coding: utf-8 -*-
module Tree
  ##
  # Tree::RedBlackNode is a pure-Ruby implementation of a
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
  # While it's possible to use class Tree::RedBlackNode independently
  # of Tree::RedBlack, it's strongly recommended that Tree::RedBlack
  # be used instead.


  class RedBlackNode
    include Enumerable

    attr_accessor :left, :right, :key, :parent, :color

    ##
    # Returns a new Red-Black tree node with +key+ parameter set to
    # option +value+, if given, otherwise +nil+. Option +color+, if
    # specified, must be either <tt>:RED</tt> or <tt>:BLACK</tt>.
    #
    # In addition to the +key+ parameter, a Red-Black tree node exposes
    # parameters +color+, the node's color, +parent+, the node's
    # parent, and +left+ and +right+, the node's left and right
    # children, respectively.
    #
    # === Example
    #
    #     require 'tree/red_black'
    #
    #     root = Tree::RedBlackNode.new(10)
    #     p root.key              -> 10
    #     p root.color            -> :RED
    #     p root.parent           -> nil
    #     p root.left             -> nil
    #     p root.right            -> nil

    def initialize(value = nil, color = :RED)
      raise "color must be :RED or :BLACK" unless [:RED, :BLACK].include?(color)

      @left = @right = @parent = nil
      @key = value
      @color = color
    end

    def <=>(other) # :nodoc:
      key <=> other.key
    end

    def sibling # :nodoc:
      self == parent&.left ? parent&.right : parent&.left
    end

    def grandparent # :nodoc:
      parent&.parent
    end

    def parent_sibling # :nodoc:
      parent&.sibling
    end

    ##
    # Inserts the given value in a Red-Black tree whose root node is
    # self. If the +key+ parameter of the root node is nil, then value
    # is assigned to +key+. Otherwise, value is stored in new
    # Tree::RedBlackNode which is then inserted in the tree; the tree
    # is then re-balanced as needed, and the root of the balanced tree
    # returned.

    # Since a Red-Black tree maintains an ordered, Enumerable
    # collection, every value inserted must be comparable with every
    # other value. Methods +each+, +map+, +select+, +find+, +sort+,
    # etc., can be applied to a Red-Black tree's root node to iterate
    # over all nodes in the tree.
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
    #     root = Tree::RedBlackNode.new
    #     p root.key                      -> nil
    #     root = root.insert_red_black(0)
    #     p root.key                      -> 0
    #     root = root.insert_red_black(1)
    #     p root.key                      -> 0
    #     p root.left                     -> nil
    #     p root.right.key                -> 1
    #     root = root.insert_red_black(2)
    #     p root.key                      -> 1
    #     p root.left.key                 -> 0
    #     p root.right.key                -> 2

    def insert_red_black(value, allow_duplicates = true)
      node = allow_duplicates ? insert_key(value) : insert_unique_key(value)

      return nil if node.nil?

      node.color_insert

      while node.parent
        node = node.parent
      end
      node
    end

    ##
    # Deletes the given value from a Red-Black tree whose root node is
    # self. If the tree has only one node and its +key+ parameter
    # matches value, then that node's +key+ parameter is set to nil.
    # Otherwise, the first node found whose +key+ matches value is
    # removed from the tree, and the tree is re-balanced. The root of
    # the balanced tree is returned.
    #
    # === Example
    #
    #     require 'tree/red_black'
    #
    #     root = [*1..10].reduce(Tree::RedBlackNode.new) do |acc, v|
    #       acc.insert_red_black(v)
    #     end
    #     root = [*4..8].reduce(root) do |acc, v|
    #       acc.delete_red_black(v)
    #     end
    #     root.map(&:key)                 -> [1, 2, 3, 9, 10]

    def delete_red_black(value)
      if key.nil?
        nil
      elsif value > key
        right ? right.delete_red_black(value) : nil
      elsif value < key
        left ? left.delete_red_black(value) : nil
      else
        if left && right
          node = right.minimum
          @key = node.key
          node.substitute_with_child
        else
          substitute_with_child
        end
      end
    end

    def minimum # :nodoc:
      node = self
      while node.left
        node = node.left
      end
      node
    end

    def maximum # :nodoc:
      node = self
      while node.right
        node = node.right
      end
      node
    end

    ##
    # Returns an enumerator for nodes in a Red-Black tree by pre-order
    # traversal.
    #
    # === Example
    #     require 'tree/red_black'
    #
    #     root = [*1..10].reduce(Tree::RedBlackNode.new) do |acc, v|
    #       acc.insert_red_black(v)
    #     end
    #     root.pre_order.map(&:key)        -> [4, 2, 1, 3, 6, 5, 8, 7, 9, 10]

    def pre_order(&block)
      return enum_for(:pre_order) unless block_given?

      yield self
      left.pre_order(&block) if left
      right.pre_order(&block) if right
    end

    ##
    # Returns an enumerator for nodes in a Red-Black tree by in-order
    # traversal. The +each+ method is aliased to +in_order+
    #
    # === Example
    #     require 'tree/red_black'
    #
    #     shuffled_values = [*1..10].shuffle
    #     root = shuffled_values.reduce(Tree::RedBlackNode.new) do |acc, v|
    #       acc.insert_red_black(v)
    #     end
    #     root.pre_order.map(&:key)        -> [1, 2, ..., 10]

    def in_order(&block)
      return enum_for(:in_order) unless block_given?

      left.in_order(&block) if left
      yield self
      right.in_order(&block) if right
    end

    # Returns a deep copy of a Red-Black tree, provided that the
    # +dup+ method for values in the tree is also a deep copy.
    #
    # === Example
    #
    #     require 'tree/red_black'
    #
    #     root = Tree::RedBlackNode.new({a: 1, b: 2})
    #     root_copy = root.dup
    #     p root.key                       -> {:a=>1, :b=>2}
    #     p root.key.delete(:a)            -> 1
    #     p root.key                       -> {:b=>2}
    #     p root_copy.key                  -> {:a=>1, :b=>2}

    def dup
      copy = RedBlackNode.new(key.dup, color)
      if left
        copy.left = left.dup
        copy.left.parent = copy
      end
      if right
        copy.right = right.dup
        copy.right.parent = copy
      end
      copy
    end

    def insert_key(value) # :nodoc:
      if key.nil?
        @key = value
        self
      elsif value >= key
        if right
          right.insert_key(value)
        else
          @right = RedBlackNode.new(value)
          @right.parent = self
          right
        end
      else
        if left
          left.insert_key(value)
        else
          @left = RedBlackNode.new(value)
          @left.parent = self
          left
        end
      end
    end

    def insert_unique_key(value) # :nodoc:
      if key.nil?
        @key = value
        self
      elsif value > key
        if right
          right.insert_unique_key(value)
        else
          @right = RedBlackNode.new(value)
          @right.parent = self
          right
        end
      elsif value < key
        if left
          left.insert_unique_key(value)
        else
          @left = RedBlackNode.new(value)
          @left.parent = self
          left
        end
      else
        nil
      end
    end

    def color_insert # :nodoc:
      if parent.nil?
        @color = :BLACK
      elsif parent.color == :BLACK
        return
      elsif parent_sibling&.color == :RED
        parent.color = parent_sibling.color = :BLACK
        grandparent.color = :RED
        grandparent.color_insert
      else
        node = if self == parent.right && parent == grandparent&.left
                 parent.rotate_left.left
               elsif self == parent.left && parent == grandparent&.right
                 parent.rotate_right.right
               else
                 self
               end
        node.parent.color = :BLACK
        if node.grandparent
          node.grandparent.color = :RED
          if node == node.parent.left
            node.grandparent.rotate_right
          else
            node.grandparent.rotate_left
          end
        end
      end
    end

    def substitute_with_child # :nodoc:
      if (child = right.nil? ? left : right)
        child.parent = parent
        child.color = :BLACK if color == :BLACK
      end

      if self == parent&.left
        parent.left = child
        parent.color_delete_left if (color == :BLACK && child.nil?)
      elsif self == parent&.right
        parent.right = child
        parent.color_delete_right if (color == :BLACK && child.nil?)
      end

      node = parent ? parent : child
      if node.nil?
        @key = nil
        self
      else
        while node.parent
          node = node.parent
        end
        node
      end
    end

    def color_delete_right # :nodoc:
      child_sibling = left

      if child_sibling.color == :RED
        @color = :RED
        child_sibling.color = :BLACK
        rotate_right
        child_sibling = left
      end

      if (color == :BLACK &&
          child_sibling.color == :BLACK &&
          (child_sibling.left.nil? || child_sibling.left.color   == :BLACK) &&
          (child_sibling.right.nil? || child_sibling.right.color == :BLACK))
        child_sibling.color = :RED
        if self == parent&.left
          parent.color_delete_left
        elsif self == parent&.right
          parent.color_delete_right
        end
      elsif (color == :RED &&
             child_sibling.color == :BLACK &&
             (child_sibling.left.nil? || child_sibling.left.color   == :BLACK) &&
             (child_sibling.right.nil? || child_sibling.right.color == :BLACK))
        child_sibling.color = :RED
        @color = :BLACK
      else
        if child_sibling.color == :BLACK
          if (child_sibling.right&.color == :RED &&
              (child_sibling.left.nil? || child_sibling.left&.color == :BLACK))
            child_sibling.color = :RED
            child_sibling.right.color = :BLACK
            child_sibling.rotate_left
            child_sibling = left
          end
        end

        child_sibling.color = color
        @color = :BLACK
        child_sibling.left.color = :BLACK # if child_sibling.left
        rotate_right
      end
    end

    def color_delete_left # :nodoc:
      child_sibling = right

      if child_sibling.color == :RED
        @color = :RED
        child_sibling.color = :BLACK
        rotate_left
        child_sibling = right
      end

      if (color == :BLACK &&
          child_sibling.color == :BLACK &&
          (child_sibling.left.nil? || child_sibling.left.color   == :BLACK) &&
          (child_sibling.right.nil? || child_sibling.right.color == :BLACK))
        child_sibling.color = :RED
        if self == parent&.left
          parent.color_delete_left
        elsif self == parent&.right
          parent.color_delete_right
        end
      elsif (color == :RED &&
             child_sibling.color == :BLACK &&
             (child_sibling.left.nil? || child_sibling.left.color   == :BLACK) &&
             (child_sibling.right.nil? || child_sibling.right.color == :BLACK))
        child_sibling.color = :RED
        @color = :BLACK
      else
        if child_sibling.color == :BLACK
          if ((child_sibling.right.nil? || child_sibling.right.color == :BLACK) &&
              child_sibling.left&.color  == :RED)
            child_sibling.color = :RED
            child_sibling.left.color = :BLACK
            child_sibling.rotate_right
            child_sibling = right
          end
        end

        child_sibling.color = color
        @color = :BLACK
        child_sibling.right.color = :BLACK # if child_sibling.right
        rotate_left
      end
    end

    def rotate_right # :nodoc:
      return self if left.nil?

      root = left
      root.right.parent = self unless (@left = root.right).nil?
      if (root.parent = parent)
        if self == parent.left
          @parent.left = root
        else
          @parent.right = root
        end
      end
      root.right = self
      @parent = root
      root
    end

    def rotate_left # :nodoc:
      return self if right.nil?

      root = right
      root.left.parent = self unless (@right = root.left).nil?
      if (root.parent = parent)
        if self == parent.left
          @parent.left = root
        else
          @parent.right = root
        end
      end
      root.left = self
      @parent = root
      root
    end

    alias each in_order
  end
end
