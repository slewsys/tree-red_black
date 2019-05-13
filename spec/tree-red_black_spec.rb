require 'tree/red_black'
require 'spec_helper'

RSpec.describe Tree::RedBlack do
  context 'new' do
    it 'instantiates a Red-Black tree' do
      rbt = Tree::RedBlack.new
      expect(rbt.root).to eq(nil)
      expect(rbt.size).to eq(0)
    end

    it 'accepts allow_duplicates option' do
      rbt = Tree::RedBlack.new(false)
      expect(rbt.allow_duplicates?).to eq(false)
    end
  end

  context 'insert' do
    it 'inserts values in the tree' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)

      expect(rbt.root.key).to eq(1)
      expect(rbt.root.right.key).to eq(2)
      expect(rbt.root.left.key).to eq(0)

      expect(rbt.size).to eq(3)
    end

    it 'inserts repeated values in the tree by default' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(1)
      rbt.insert(1)

      expect(rbt.allow_duplicates?).to eq(true)
      expect(rbt.size).to eq(3)
    end

    it 'inserts unique values in the tree if allow_duplicates? is false' do
      rbt = Tree::RedBlack.new(false)
      rbt.insert(1)
      rbt.insert(1)

      expect(rbt.allow_duplicates?).to eq(false)
      expect(rbt.size).to eq(1)
    end

    it 'orders values with each' do
      max = rand(1000..10_000)
      values = [*0..max].shuffle
      rbt = values.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      expect(rbt.each.map(&:key)).to eq([*0..max])
    end

    it 'produces an Enumerable collection' do
      max = rand(1000..10_000)
      values = [*0..max].shuffle
      rbt = values.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      expect(rbt.map(&:key)).to eq([*0..max])
      expect(rbt.sort.last.key).to eq(max)
      expect(rbt.find { |node| node.key > 100}.key).to eq(101)
    end

    it 'balances the tree' do
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

    it 'colors each node :RED or :BLACK' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)

      expect(rbt.root.color).to eq(:BLACK)
      expect(rbt.root.right.color).to eq(:RED)
      expect(rbt.root.left.color).to eq(:RED)
    end

    it 'colors the root node black' do
      values = [*0..rand(1000..10_000)].shuffle
      rbt = values.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      expect(rbt.root.color).to eq(:BLACK)
    end

    it 'colors children of red nodes black' do
      values = [*0..rand(1000..10_000)].shuffle
      rbt = values.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

      paths = {}
      rbt.pre_order do |node; path, count, ancestor|
        if node.color == :RED
          expect(node.left.color).to eq(:BLACK) if node.left
          expect(node.right.color).to eq(:BLACK) if node.right
        end
      end
    end

    it 'colors each path from a given node with same number of black nodes' do
      values = [*0..rand(1000..10_000)].shuffle
      rbt = values.reduce(Tree::RedBlack.new) do |acc, v|
        acc.insert(v)
      end

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

  context 'delete' do
    it 'delete values from the tree' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(2)
      rbt.insert(0)
      rbt.delete(1)

      expect(rbt.root.key).to eq(2)
      expect(rbt.root.left.key).to eq(0)

      expect(rbt.size).to eq(2)
    end
  end

end
