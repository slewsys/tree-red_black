require 'tree/red_black'
require 'spec_helper'

RSpec.describe Tree::RedBlack do
  context 'new' do
    it 'instantiates a Red-Black tree' do
      rbt = Tree::RedBlack.new
      expect(rbt.root).to eq(nil)
      expect(rbt.size).to eq(0)
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

    it 'inserts values in the tree only once' do
      rbt = Tree::RedBlack.new
      rbt.insert(1)
      rbt.insert(1)

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

  # context 'files' do
  #   it 'transfers files' do
  #     File.write('1', Time.now)
  #     expect { trash '1' }.to output_nothing
  #     expect(File.exists?("1")).to eq(false)
  #   end

  #   it 'lists trashcan contents' do
  #     expect { trash '-l' }.to output_matching(/[rwx-]+\s+1\s.*\s1/)
  #   end

  #   it 'versions transferred files' do
  #     File.write('1', Time.now)
  #     expect { trash '1' }.to output_nothing
  #     expect { trash '-l' }.to output_matching(/[rwx-]+\s+1\s.*\s1.#.*#-\d{3}/)
  #   end

  #   it 'restores transferred files' do
  #     expect { trash '-W', '1'}.to output_nothing
  #     expect(File.exists?("1")).to eq(true)
  #   end
  # end

  # context 'dot.files' do
  #   it 'transfers dot.files' do
  #     File.write('.1', Time.now)
  #     expect { trash '.1' }.to output_nothing
  #     expect(File.exists?(".1")).to eq(false)
  #   end

  #   it 'lists trashcan contents' do
  #     expect { trash '-l' }.to output_matching(/[rwx-]+\s+1\s.*\s.1/)
  #   end

  #   it 'versions transferred files' do
  #     File.write('.1', Time.now)
  #     expect { trash '.1' }.to output_nothing
  #     expect { trash '-l' }.to output_matching(/[rwx-]+\s+1\s.*\s.1.#.*#-\d{3}/)
  #   end

  #   it 'restores transferred files' do
  #     expect { trash '-W', '.1'}.to output_nothing
  #     expect(File.exists?(".1")).to eq(true)
  #   end
  # end

  # context 'directories' do
  #   it 'complains about transfering directories' do
  #     Dir.mkdir('2') if ! Dir.exists?('2')
  #     expect { trash '2' }.to output_stderr_contents_of('use-r-for-dirs.txt')
  #   end

  #   it 'transfers directories with option -d' do
  #     expect { trash '-d', '2' }.to output_nothing
  #     expect(Dir.exists?("2")).to eq(false)
  #   end

  #   it 'complains about non-empty directories with option -d' do
  #     Dir.mkdir('2') if ! Dir.exists?('2')
  #     File.write('2/1', Time.now)
  #     expect { trash '-d', '2' }.to output_stderr_contents_of('dir-not-empty.txt')
  #     expect(Dir.exists?("2")).to eq(true)
  #   end

  #   it 'transfers non-empty directories with option -r' do
  #     Dir.mkdir('2') if ! Dir.exists?('2')
  #     File.write('2/1', Time.now)
  #     expect { trash '-r', '2' }.to output_nothing
  #     expect(Dir.exists?("2")).to eq(false)
  #   end
  # end

  # context 'symlinks' do
  #   before {
  #     trash '-ef'
  #   }

  #   it 'transfers symlinks' do
  #     File.symlink('foobar', 'link-to-foobar')
  #     expect { trash 'link-to-foobar' }.to output_nothing
  #     expect(File.symlink?('link-to-foobar')).to eq(false)
  #   end

  #   it 'versions transferred symlinks' do
  #     File.symlink('barfoo', 'link-to-foobar')
  #     expect { trash 'link-to-foobar' }.to output_nothing
  #     File.symlink('foobar', 'link-to-foobar')
  #     expect { trash 'link-to-foobar' }.to output_nothing
  #     expect { trash '-l' }.to output_matching(/[rwx-]+\s+1\s.*\slink-to-foobar.#.*#-\d{3} ->/)
  #   end

  #   it 'restores transferred symlinks' do
  #     File.symlink('foobar', 'link-to-foobar')
  #     expect { trash 'link-to-foobar' }.to output_nothing
  #     expect { trash '-W', 'link-to-foobar'}.to output_nothing
  #     expect(File.symlink?('link-to-foobar')).to eq(true)
  #   end
  # end

  # context 'restoring versions' do
  #   before {
  #     trash '-ef'
  #     @dates = 3.times.map { |n| (Time.now + n).to_s }
  #     @dates.each do |date|
  #       File.write('1', date)
  #       trash '1'
  #       File.symlink(date, 'link-to-date')
  #       trash 'link-to-date'
  #     end
  #   }

  #   it 'restores files in reverse order of transfer' do
  #     @dates.reverse.each do |date|
  #       trash '-W', '1'
  #       expect(File.read('1')).to eq(date)
  #       File.delete('1')
  #     end
  #   end

  #   it 'restores symlinks in reverse order of transfer' do
  #     @dates.reverse.each do |date|
  #       trash '-W', 'link-to-date'
  #       expect(File.readlink('link-to-date')).to eq(date)
  #       File.delete('link-to-date')
  #     end
  #   end

  #   it 'files overwritten by restore are versioned' do
  #     @dates.reverse.each do |date|
  #       trash '-Wf', '1'
  #       expect(File.read('1')).to eq(date)
  #     end
  #     @dates.reverse.each do |date|
  #       trash '-Wf', '1'
  #       expect(File.read('1')).to eq(date)
  #     end
  #   end
  # end

  # context 'file patterns' do
  #   it 'recognizes file patterns' do
  #     File.write('testing 123', '')
  #     expect { trash '*123*' }.to output_nothing
  #     expect(File.exists?('testing 123')).to eq(false)
  #   end

  #   it 'recognizes files containing patterns' do
  #     File.write('*[123]*{}', '')
  #     expect { trash '*123*' }.to output_nothing
  #     expect(File.exists?('*[123]*{}')).to eq(false)
  #   end
  # end
end
