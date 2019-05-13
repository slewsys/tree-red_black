module Tree
  class RedBlackNode
    include Enumerable

    attr_accessor :left, :right, :key, :parent, :color

    def initialize(value = nil, color = :RED)
      raise "color must be :RED or :BLACK" unless [:RED, :BLACK].include?(color)

      @left = @right = @parent = nil
      @key = value
      @color = color
    end

    def <=>(other)
      key <=> other.key
    end

    def sibling
      self == parent&.left ? parent&.right : parent&.left
    end

    def grandparent
      parent&.parent
    end

    def parent_sibling
      parent&.sibling
    end

    def insert_red_black(value, allow_duplicates = true)
      node = allow_duplicates ? insert_key(value) : insert_unique_key(value)

      return nil if node.nil?

      node.color_insert

      while node.parent
        node = node.parent
      end
      node
    end

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

    def minimum
      node = self
      while node.left
        node = node.left
      end
      node
    end

    def maximum
      node = self
      while node.right
        node = node.right
      end
      node
    end

    def pre_order(&block)
      return enum_for(:pre_order) unless block_given?

      yield self
      left.pre_order(&block) if left
      right.pre_order(&block) if right
    end

    def in_order(&block)
      return enum_for(:in_order) unless block_given?

      left.in_order(&block) if left
      yield self
      right.in_order(&block) if right
    end

    def dup
      copy = RedBlackNode.new(key, color)
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

    def insert_key(value)
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

    def insert_unique_key(value)
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

    def color_insert
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

    def substitute_with_child
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

    def color_delete_right
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

    def color_delete_left
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

    def rotate_right
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

    def rotate_left
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
