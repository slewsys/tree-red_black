# frozen_string_literal: true

require 'tree/red_black'
require_relative 'spec_helper'

RSpec.describe Tree::RedBlackNode do
  context 'new' do
    it 'instantiates a Red-Black node with nil key by default' do
      rbn = Tree::RedBlackNode.new

      expect(rbn.key).to eq(nil)
    end

    it 'instantiates a node with color :RED by default' do
      rbn = Tree::RedBlackNode.new

      expect(rbn.color).to eq(:RED)
    end

    it 'accepts any Comparable key' do
      rbn = Tree::RedBlackNode.new(0)

      expect(rbn.key).to eq(0)

      rbn = Tree::RedBlackNode.new("hello")

      expect(rbn.key).to eq("hello")

      rbn = Tree::RedBlackNode.new([1])

      expect(rbn.key).to eq([1])

      rbn = Tree::RedBlackNode.new({a: 1})

      expect(rbn.key).to eq({a: 1})
    end

    it 'accepts a :RED or :BLACK color after  a key value' do
      rbn = Tree::RedBlackNode.new(0, :RED)

      expect(rbn.color).to eq(:RED)

      rbn = Tree::RedBlackNode.new(0, :BLACK)

      expect(rbn.color).to eq(:BLACK)
    end

    it 'raises RuntimeError if color not :RED or :BLACK' do
      expect { Tree::RedBlackNode.new(0, :GREEN) }.to raise_error("color must be :RED or :BLACK")
    end
  end

  context '#insert_red_black' do
    it 'assigns value to node with nil key; returns node' do
      rbn = Tree::RedBlackNode.new

      expect(rbn.key).to eq(nil)

      rbn = rbn.insert_red_black(0)

      expect(rbn.key).to eq(0)
    end

    it 'creates new node from value and inserts into existing tree; returns root of the tree' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(2)
      rbn = rbn.insert_red_black(0)

      expect(rbn.key).to eq(1)
      expect(rbn.right.key).to eq(2)
      expect(rbn.left.key).to eq(0)
    end

    it 'inserts repeated values in the tree by default' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(1)

      expect(rbn.key).to eq(1)
      expect(rbn.right.key).to eq(1)
      expect(rbn.left.key).to eq(1)
    end

    it 'accepts allow_duplicates option and, if false, returns nil when value already in tree' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(1, false)

      expect(rbn.key).to eq(1)

      new_root = rbn.insert_red_black(1, false)

      expect(new_root).to eq(nil)

      expect(rbn.key).to eq(1)
      expect(rbn.left).to eq(nil)
      expect(rbn.right).to eq(nil)
    end

    it 'colors each node :RED or :BLACK, and balances the tree' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(0)
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(2)

      expect(rbn.key).to eq(1)
      expect(rbn.color).to eq(:BLACK)
      expect(rbn.right.key).to eq(2)
      expect(rbn.right.color).to eq(:RED)
      expect(rbn.left.key).to eq(0)
      expect(rbn.left.color).to eq(:RED)
    end

    it 'colors the root node black' do
      rbn = Tree::RedBlackNode.new
      [*0..rand(100..200)].shuffle.each do |v|
        rbn = rbn.insert_red_black(v)

        expect(rbn.color).to eq(:BLACK)
      end
    end

    it 'orders values with each' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      expect(rbn.each.map(&:key)).to eq([*0..max])
    end

    it 'produces an Enumerable collection' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      expect(rbn.map(&:key)).to eq([*0..max])
      expect(rbn.sort { |x, y| y <=> x }.last.key).to eq(0)
      expect(rbn.find { |node| node.key > 100}.key).to eq(101)
    end

    it 'colors children of red nodes black' do
      rbn = Tree::RedBlackNode.new
      [*0..rand(100..200)].shuffle.each do |v|
        rbn = rbn.insert_red_black(v)

        paths = {}
        rbn.pre_order do |node; path, count, ancestor|
          if node.color == :RED
            expect(node.left.color).to eq(:BLACK) if node.left
            expect(node.right.color).to eq(:BLACK) if node.right
          end
        end
      end
    end

    it 'colors each path from a given node with same number of black nodes' do
      rbn = Tree::RedBlackNode.new
      [*0..rand(100..200)].shuffle.each do |v|
        rbn = rbn.insert_red_black(v)

        paths = {}
        rbn.pre_order do |node; path, count, ancestor|
          if node.left.nil? || node.right.nil?
            path = []
            count = 0
            ancestor = node
            loop do
              path.unshift ancestor.key
              count += 1 if ancestor.color == :BLACK
              break if (ancestor = ancestor.parent).nil?
            end
            paths[path] = count
          end
        end

        expect(paths.values.uniq.size).to eq(1)
      end
    end
  end

  context '#delete_red_black' do
    it 'deletes values from the tree; returns root of the tree' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(2)
      rbn = rbn.insert_red_black(0)
      rbn = rbn.delete_red_black(1)

      expect(rbn.key).to eq(2)
      expect(rbn.left.key).to eq(0)
      expect(rbn.right).to eq(nil)
    end

    it 'sets root key to nil after all values in the tree are deleted' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(2)
      rbn = rbn.insert_red_black(0)
      rbn = rbn.delete_red_black(1)
      rbn = rbn.delete_red_black(2)
      rbn = rbn.delete_red_black(0)

      expect(rbn.key).to eq(nil)
    end

    it 'returns nil if attempting to delete value not in the tree' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(0)
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(2)
      rbn = rbn.delete_red_black(3)

      expect(rbn).to eq(nil)
    end

    it 'colors each node :RED or :BLACK, and balances the tree' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(0)
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(2)
      rbn = rbn.insert_red_black(3)
      rbn = rbn.insert_red_black(4)
      rbn = rbn.delete_red_black(0)

      expect(rbn.key).to eq(3)
      expect(rbn.color).to eq(:BLACK)
      expect(rbn.right.key).to eq(4)
      expect(rbn.right.color).to eq(:BLACK)
      expect(rbn.left.key).to eq(1)
      expect(rbn.left.color).to eq(:BLACK)
      expect(rbn.left.right.key).to eq(2)
      expect(rbn.left.right.color).to eq(:RED)
    end

    it 'colors the root node black' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      max.times do
        rbn = rbn.delete_red_black(rbn.key)

        expect(rbn.color).to eq(:BLACK)
      end
    end

    it 'colors children of red nodes black' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      max.times do
        rbn = rbn.delete_red_black(rbn.key)

        paths = {}
        rbn.pre_order do |node; path, count, ancestor|
          if node.color == :RED
            expect(node.left.color).to eq(:BLACK) if node.left
            expect(node.right.color).to eq(:BLACK) if node.right
          end
        end
      end
    end

    it 'colors each path from a given node with same number of black nodes' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      max.times do
        rbn = rbn.delete_red_black(rbn.key)

        paths = {}
        rbn.pre_order do |node; path, count, ancestor|
          if node.left.nil? || node.right.nil?
            path = []
            count = 0
            ancestor = node
            loop do
              path.unshift ancestor.key
              count += 1 if ancestor.color == :BLACK
              break if (ancestor = ancestor.parent).nil?
            end
            paths[path] = count
          end
        end

        expect(paths.values.uniq.size).to eq(1)
      end
    end
  end

  context '#search' do
    it 'returns a node whose key matches a given value' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      (max + 1).times do |i|
        expect(rbn.search(i).key).to eq(i)
      end
    end
  end

  context '#bsearch' do
    it 'returns a node satisfying a binary criterion in a block' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      (max + 1).times do |i; rbnode|
        rbnode = rbn.bsearch { |node| node.key >= i }
        expect(rbnode.key).to eq(i)
      end
    end

    it 'returns a node satisfying a ternary criterion in a block' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      (max + 1).times do |i; rbnode|
        rbnode = rbn.bsearch { |node| i <=> node.key }
        expect(rbnode.key).to eq(i)
      end
    end
  end

  context '#pred' do
    it 'returns a node whose key is the predecessor of a given node' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      rbn.each do |node|
        expect(node.key).to eq(node.pred.key + 1) if node.key > 0
      end

      expect(rbn.min.pred).to eq(nil)
    end
  end

  context '#succ' do
    it 'returns a node whose key is the successor of a given node' do
      max = rand(100..200)
      rbn = [*0..max].shuffle.reduce(Tree::RedBlackNode.new) do |acc, v|
        acc.insert_red_black(v)
      end

      rbn.each do |node|
        expect(node.key).to eq(node.succ.key - 1) if node.key < max
      end

      expect(rbn.max.succ).to eq(nil)
    end
  end

  context '#dup' do
    it 'duplicates an existing tree (node)' do
      rbn = Tree::RedBlackNode.new
      rbn = rbn.insert_red_black(1)
      rbn = rbn.insert_red_black(2)
      rbn = rbn.insert_red_black(0)
      rbn_copy = rbn.dup

      expect(rbn_copy).not_to eq(rbn)

      expect(rbn_copy.key).to eq(rbn.key)
      expect(rbn_copy.color).to eq(rbn.color)

      expect(rbn_copy.right).not_to eq(rbn.right)
      expect(rbn_copy.right.key).to eq(rbn.right.key)
      expect(rbn_copy.right.color).to eq(rbn.right.color)

      expect(rbn_copy.left).not_to eq(rbn.left)
      expect(rbn_copy.left.key).to eq(rbn.left.key)
      expect(rbn_copy.left.color).to eq(rbn.left.color)
    end
  end
end
