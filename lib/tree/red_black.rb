require 'tree/red_black/red_black_node'

module Tree
  class RedBlack
    include Enumerable

    attr_accessor :root, :size

    def initialize(value = nil)
      if value.nil?
        @root = nil
        @size = 0
      else
        @root = RedBlackNode.new(value, :BLACK)
        @size = 1
      end
    end

    def insert(value)
      new_root = root.nil? ? RedBlackNode.new(value, :BLACK) : root.insert_red_black(value)
      unless new_root.nil?
        @root = new_root
        @size += 1
      end
      self
    end

    def delete(value)
      new_root = root.nil? ? nil : root.delete_red_black(value)
      unless new_root.nil?
        @root = new_root
        @size -= 1
      end
      @root = nil if size == 0
      self
    end

    def find(value)
      root.nil? ? nil : root.find(value)
    end

    def pre_order(&block)
      return enum_for(:pre_order) unless block_given?
      return if root.nil?

      root.pre_order(&block)
    end

    def in_order(&block)
      return enum_for(:in_order) unless block_given?
      return if root.nil?

      root.in_order(&block)
    end

    def dup
      copy = RedBlack.new
      copy.size = size
      copy.root = root.dup
      copy
    end

    alias each in_order
  end
end
