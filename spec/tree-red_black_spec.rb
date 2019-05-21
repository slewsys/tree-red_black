require 'tree/red_black'
require 'spec_helper'

RSpec.describe Tree::RedBlack do
  context 'new' do
    it 'instantiates a Red-Black tree with nil root' do
      rbt = Tree::RedBlack.new

      expect(rbt.root).to eq(nil)
      expect(rbt.size).to eq(0)
    end

    it 'accepts allow_duplicates option' do
      rbt = Tree::RedBlack.new(false)

      expect(rbt.allow_duplicates?).to eq(false)
    end
  end

  context '#insert' do
    it 'inserts values in the tree' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)

      expect(rbt.root.key).to eq(1)
      expect(rbt.root.right.key).to eq(2)
      expect(rbt.root.left.key).to eq(0)
    end

    it 'increments tree size as values are inserted in the tree' do
      rbt = Tree::RedBlack.new

      expect(rbt.size).to eq(0)

      rbt.insert(1)

      expect(rbt.size).to eq(1)

      rbt.insert(2)

      expect(rbt.size).to eq(2)

      rbt.insert(0)

      expect(rbt.size).to eq(3)
    end

    it 'inserts repeated values in the tree by default' do
      rbt = Tree::RedBlack.new

      expect(rbt.allow_duplicates?).to eq(true)

      rbt.insert(1)
      rbt.insert(1)
      rbt.insert(1)

      expect(rbt.size).to eq(3)
    end

    it 'inserts unique values in the tree if allow_duplicates? is false' do
      rbt = Tree::RedBlack.new(false)

      expect(rbt.allow_duplicates?).to eq(false)

      rbt.insert(1)
      rbt.insert(1)

      expect(rbt.size).to eq(1)
    end

    it 'colors each node :RED or :BLACK, and balances the tree' do
      rbt = Tree::RedBlack.new
      rbt.insert(0)
      rbt.insert(1)
      rbt.insert(2)

      expect(rbt.root.key).to eq(1)
      expect(rbt.root.color).to eq(:BLACK)
      expect(rbt.root.right.key).to eq(2)
      expect(rbt.root.right.color).to eq(:RED)
      expect(rbt.root.left.key).to eq(0)
      expect(rbt.root.left.color).to eq(:RED)
      expect(rbt.size).to eq(3)
    end

    it 'colors the root node black' do
      rbt = Tree::RedBlack.new
      [*0..rand(100..200)].shuffle.each do |v|
        rbt.insert(v)

        expect(rbt.root.color).to eq(:BLACK)
      end
    end

    it 'orders values with each' do
      max = rand(100..200)
      rbt = [*0..max].shuffle.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      expect(rbt.each.map(&:key)).to eq([*0..max])
    end

    it 'produces an Enumerable collection' do
      max = rand(100..200)
      rbt = [*0..max].shuffle.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      expect(rbt.map(&:key)).to eq([*0..max])
      expect(rbt.sort { |x, y| y <=> x }.last.key).to eq(0)
      expect(rbt.find { |node| node.key > 100}.key).to eq(101)
    end


    it 'colors children of red nodes black' do
      rbt = Tree::RedBlack.new
      [*0..rand(100..200)].shuffle.each do |v|
        rbt.insert(v)

        paths = {}
        rbt.pre_order do |node; path, count, ancestor|
          if node.color == :RED
            expect(node.left.color).to eq(:BLACK) if node.left
            expect(node.right.color).to eq(:BLACK) if node.right
          end
        end
      end
    end

    it 'colors each path from a given node with same number of black nodes' do
      rbt = Tree::RedBlack.new
      [*0..rand(100..200)].shuffle.each do |v|
        rbt.insert(v)

        paths = {}
        rbt.pre_order do |node; path, count, ancestor|
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

  context '#delete' do
    it 'deletes values from the tree' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)
      rbt.delete(1)

      expect(rbt.root.key).to eq(2)
      expect(rbt.root.left.key).to eq(0)

      expect(rbt.size).to eq(2)
    end

    it 'decrements tree size as values are deleted from the tree' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)

      expect(rbt.size).to eq(3)

      rbt.delete(1)

      expect(rbt.size).to eq(2)

      rbt.delete(2)

      expect(rbt.size).to eq(1)
    end

    it 'sets root to nil after all values in the tree are deleted' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)
      rbt.delete(1)
      rbt.delete(2)
      rbt.delete(0)

      expect(rbt.root).to eq(nil)
      expect(rbt.size).to eq(0)
    end

    it 'does not delete values not in the tree' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)
      rbt.delete(3)

      expect(rbt.size).to eq(3)
    end

    it 'colors each node :RED or :BLACK, and balances the tree' do
      rbt = Tree::RedBlack.new
      rbt.insert(0)
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(3)
      rbt.insert(4)
      rbt.delete(0)

      expect(rbt.root.key).to eq(3)
      expect(rbt.root.color).to eq(:BLACK)
      expect(rbt.root.right.key).to eq(4)
      expect(rbt.root.right.color).to eq(:BLACK)
      expect(rbt.root.left.key).to eq(1)
      expect(rbt.root.left.color).to eq(:BLACK)
      expect(rbt.root.left.right.key).to eq(2)
      expect(rbt.root.left.right.color).to eq(:RED)
    end

    it 'colors the root node black' do
      max = rand(100..200)
      rbt = [*0..max].shuffle.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      max.times do
        rbt.delete(rbt.root.key)

        expect(rbt.root.color).to eq(:BLACK)
      end
    end

    it 'colors children of red nodes black' do
      max = rand(100..200)
      rbt = [*0..max].shuffle.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      max.times do
        rbt.delete(rbt.root.key)

        paths = {}
        rbt.pre_order do |node; path, count, ancestor|
          if node.color == :RED
            expect(node.left.color).to eq(:BLACK) if node.left
            expect(node.right.color).to eq(:BLACK) if node.right
          end
        end
      end
    end

    it 'colors each path from a given node with same number of black nodes' do
      max = rand(100..200)
      rbt = [*0..max].shuffle.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      max.times do
        rbt.delete(rbt.root.key)

        paths = {}
        rbt.pre_order do |node; path, count, ancestor|
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
      rbt = [*0..max].shuffle.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      (max + 1).times do |i|
        expect(rbt.search(i).key).to eq(i)
      end
    end
  end

  context '#bsearch' do
    it 'returns a node satisfying a binary criterion in a block' do
      max = rand(100..200)
      rbt = [*0..max].shuffle.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      (max + 1).times do |i; rbnode|
        rbnode = rbt.bsearch { |node| node.key >= i }
        expect(rbnode.key).to eq(i)
      end
    end

    it 'returns a node satisfying a ternary criterion in a block' do
      max = rand(100..200)
      rbt = [*0..max].shuffle.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      (max + 1).times do |i; rbnode|
        rbnode = rbt.bsearch { |node| i <=> node.key }
        expect(rbnode.key).to eq(i)
      end
    end
  end

  context '#dup' do
    it 'duplicates an existing tree' do
      rbt = Tree::RedBlack.new(false)
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)
      rbt_copy = rbt.dup

      expect(rbt_copy.root).not_to eq(rbt.root)

      expect(rbt_copy.size).to eq(rbt.size)
      expect(rbt_copy.allow_duplicates).to eq(rbt.allow_duplicates)

      expect(rbt_copy.root.key).to eq(rbt.root.key)
      expect(rbt_copy.root.color).to eq(rbt.root.color)

      expect(rbt_copy.root.right).not_to eq(rbt.root.right)
      expect(rbt_copy.root.right.key).to eq(rbt.root.right.key)
      expect(rbt_copy.root.right.color).to eq(rbt.root.right.color)

      expect(rbt_copy.root.left).not_to eq(rbt.root.left)
      expect(rbt_copy.root.left.key).to eq(rbt.root.left.key)
      expect(rbt_copy.root.left.color).to eq(rbt.root.left.color)
    end
  end
end
