#!/usr/bin/env ruby

require 'tree/red_black'
require 'benchmark'

values = [*0..0]
# values = [2, 10, 4, 5, 6, 3, 1, 0, 9, 8, 7]
# values = [0, 2, 6, 4, 5, 3, 7, 1, 9, 8, 10]
puts "values.size: #{values.size}"

# rbt = Tree::RedBlack.new
# values.each do |v|
#   # rbt = rbt.insert_red_black(v)
#   rbt.insert(v)
# end


rbt = rbt_copy = nil
Benchmark.bm do |benchmark|
  benchmark.report("insert:") do
    # rbt = values.reduce(Tree::RedBlackNode.new) do |acc, v|
    #   acc.insert_red_black(v)
    # end
    rbt = values.reduce(Tree::RedBlack.new) do |acc, v|
      acc.insert(v)
    end
  end

  # benchmark.report("dup:") do
  #   rbt_copy = rbt.dup
  # end
end


# rbt = rbt.insert_red_black(values.size)
# rbt_copy = rbt_copy.insert_red_black(values.size).delete_red_black(rbt_copy.key)
# rbt.insert(values.size)
# rbt_copy.insert(values.size)


File.open('dot.txt', 'w') do |file|
  file.write "graph \"\"\n{\n  label=\"Red-Black Tree\"\n"

  i = 0
  rbt.each do |node|
    file.write("  #{node.key} [style=filled,color=#{node.color.to_s.downcase},fontcolor=white];\n")
    file.write("  #{node.key} -- %s;\n" % [node.left ? "#{node.left.key}" :   'NULL' + (i += 1).to_s])
    file.write("  #{node.key} -- %s;\n" % [node.right ? "#{node.right.key}" : 'NULL' + (i += 1).to_s])
  end
  i.times do |n|
    file.write("  NULL#{n + 1} [fontsize=6,shape=box,width=0.2,height=0.2,style=filled,color=gray,label=\"NULL\"];\n")
  end
  file.write("}\n")
end

system 'dot -Tpng -odot.png dot.txt'
system 'open dot.png'

# puts "root: #{rbt_copy.key}"
puts "root: #{rbt.root.key}"
puts "size: #{rbt.size}"

p rbt.each.map(&:key)

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

# puts "paths from root (#{paths.size}):"
# paths.each do |path, count|
#   p path
# end

puts "black-node counts: #{paths.values.uniq}"


def delete_keys_of_interest(rbt, deleted)
  # puts "root: #{rbt.root.key}"
  # puts "size: #{rbt.size}"

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

  # puts "paths from root (#{paths.size}):"
  # paths.each do |path, count|
  #   p path
  # end

  # puts "black-node counts: #{paths.values.uniq}"

  raise "Unbalanced tree after deleting: #{deleted}" if paths.values.uniq.size > 1

  koi = rbt.each.select do |node|
    node.color == :BLACK && node.left.nil? && node.right.nil?
  end.map(&:key)
  # puts "keys of interest: #{koi}"

  v = koi.size > 0 ? koi.shuffle.first : rbt.root&.key

  return if v.nil?

  deleted << v
  # rbt = rbt.delete_red_black(v)
  rbt.delete(v)

  delete_keys_of_interest(rbt, deleted)
end

# deleted = []

# Benchmark.bm do |benchmark|
#   # benchmark.report("koi:") do
#   #   delete_keys_of_interest(rbt_copy, deleted)
#   # end
#   # rbt_copy = rbt.dup
#   benchmark.report("delete:") do
#     # values.each { |v| rbt_copy = rbt_copy.delete_red_black(v) }
#     values.each { |v| rbt.delete(v) }
#   end
# end

# # p "deleted: #{deleted}"
# p rbt.inspect

print "Value to insert? "
n = gets.to_i

toggle = 0
while n >= 0
  # rbt_copy = rbt.delete_red_black(n)
  rbt.insert(n)

  name = toggle == 0  ? 'dot2' : 'dot'
  File.open(name + '.txt', 'w') do |file|
    file.write "graph \"\"\n{\n  label=\"Red-Black Tree - #{n}\"\n"
    # file.write "  labelfontsize=8.0\n"

    i = 0
    rbt.each do |node|
      file.write("  #{node.key} [style=filled,color=#{node.color.to_s.downcase},fontcolor=white];\n")
      file.write("  #{node.key} -- %s;\n" % [node.left ? "#{node.left.key}" :   'NULL' + (i += 1).to_s])
      file.write("  #{node.key} -- %s;\n" % [node.right ? "#{node.right.key}" : 'NULL' + (i += 1).to_s])
    end
    i.times do |n|
      file.write("  NULL#{n + 1} [fontsize=6,shape=box,width=0.2,height=0.2,style=filled,color=gray,label=\"NULL\"];\n")
    end
    file.write("}\n")
  end

  system  'dot -Tpng -o' + name + '.png ' + name + '.txt'
  system 'open ' + name + '.png'

  print "Value to insert? "
  n = gets.to_i
  toggle ^= 1
end

# values.delete(n)
# values.each do |v|
#   puts "deleting #{v}"
#   rbt = rbt.delete_red_black(v)
# end

# puts "empty rbt: #{rbt.inspect}"


# name = 'dot2'
# File.open(name + '.txt', 'w') do |file|
#   file.write "graph \"\"\n{\n  label=\"Red-Black Tree Copy\"\n"
#   # file.write "  labelfontsize=8.0\n"

#   i = 0
#   rbt_copy.each do |node|
#     file.write("  #{node.key} [style=filled,color=#{node.color.to_s.downcase},fontcolor=white];\n")
#     file.write("  #{node.key} -- %s;\n" % [node.left ? "#{node.left.key}" :   'NULL' + (i += 1).to_s])
#     file.write("  #{node.key} -- %s;\n" % [node.right ? "#{node.right.key}" : 'NULL' + (i += 1).to_s])
#   end
#   i.times do |n|
#     file.write("  NULL#{n + 1} [fontsize=6,shape=box,width=0.2,height=0.2,style=filled,color=gray,label=\"NULL\"];\n")
#   end
#   file.write("}\n")
# end

# system  'dot -Tpng -o' + name + '.png ' + name + '.txt'
# system 'open ' + name + '.png'
