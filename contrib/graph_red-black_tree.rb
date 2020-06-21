#!/usr/bin/env ruby

require 'tree/red_black'
require 'benchmark'

OPEN = case RbConfig::CONFIG['target_os']
       when /darwin/
         '/usr/bin/open'
       else
         '/usr/bin/xdg-open'
       end

def red_black_tree_paths(rbt)
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
  paths
end


# To graph duplicate values, generate a unique ID for each instance of
# a given value. For example, if there are multiple 10s, then the
# first instance is assigned ID 10_0, the second instance 10_1, etc.
#
# To calculate the index of a given value, note that during in-order
# traversal, a left child node is visited before its parent. So when a
# left child node is visited, its instance index must be incremented.
#
# On the other hand, since a graph is described as a sequence of arcs
# from parent nodes to their child nodes, e.g.,
#
#     parent_1 -- left_child_of_parent_1
#     parent_1 -- right_child_of_parent_2
#     parent_2 -- left_child_of_parent_2
#     parent_2 -- right_child_of_parent_2
#     ...
#
# a right child node is referenced in an arc before it's visited via
# in-order traversal. So a right child node's instance index must be
# incremented when the right child is referenced in an arc.
#
# Finally, use the node itself (or perhaps a string containing its
# oject ID) as the key of a hash of instance values.
#

def graph_red_black_tree(rbt, filename, title)
  count = {}
  instance = {}

  rbt.each { |node| count[node.key] ||= 0; count[node.key] += 1 }

  File.open(filename, 'w') do |file|
    file.write "graph \"\"\n{\n  label=\"#{title}\"\n"

    i = 0
    rbt.in_order do |node|
      parent = if count[node.key] > 1

                 # left child...
                 if node == node.parent&.left

                   # so increment node.key instance index.
                   instance[node.key] ||= -1
                   instance[node.key] += 1
                   instance[node] = instance[node.key]
                 end
                 "#{node.key}_#{instance[node]}"
               else
                 node.key
               end

      left_child = if node.left
                     if  count[node.left.key] > 1
                       "#{node.left.key}_#{instance[node.left]}"
                     else
                       node.left.key
                     end
                   else
                     'NIL' + (i += 1).to_s
                   end

      right_child = if node.right

                      # right child...
                      if  count[node.right.key] > 1

                        # so increment node.right.key instance index.
                        instance[node.right.key] ||= -1
                        instance[node.right.key] += 1
                        instance[node.right] = instance[node.right.key]
                        "#{node.right.key}_#{instance[node.right]}"
                      else
                        node.right.key
                      end
                    else
                      'NIL' + (i += 1).to_s
                    end

      file.write("  \"#{parent}\" [style=filled,color=#{node.color.to_s.downcase},fontcolor=white,label=#{node.key}];\n")
      file.write("  \"#{parent}\" -- \"#{left_child}\";\n")
      file.write("  \"#{parent}\" -- \"#{right_child}\";\n")
    end

    i.times do |n|
      file.write("  NIL#{n + 1} [fontsize=6,shape=box,width=0.2,height=0.2,style=filled,color=black,fontcolor=white,label=\"NIL\"];\n")
    end

    file.write("}\n")
  end
end

def delete_keys_of_interest(rbt, deleted, log)
  paths = red_black_tree_paths(rbt)

  raise "Unbalanced tree after deleting: #{deleted}" if paths.values.uniq.size > 1

  koi = rbt.select do |node|
    node.color == :BLACK && node.left.nil? && node.right.nil?
  end.map(&:key)

  v = koi.size > 0 ? koi.shuffle.first : rbt.root&.key

  return log if v.nil?

  log << "key of interest: #{v}"
  deleted << v
  rbt.delete(v)

  delete_keys_of_interest(rbt, deleted, log)
end

values = [*0..20].shuffle
# values = [2, 10, 4, 5, 6, 3, 1, 0, 9, 8, 7]
# values = [0, 2, 6, 4, 5, 3, 7, 1, 9, 8, 10]
puts "values: #{values.inspect}"

rbt = nil
Benchmark.bm do |benchmark|
  benchmark.report("insert:") do
    rbt = Tree::RedBlack.new(true)
    rbt.insert(*values)
  end
end

puts "root.key: #{rbt.root.key}"
puts "tree size: #{rbt.size}"
puts "sorted values: #{rbt.map(&:key).inspect}"
paths = red_black_tree_paths(rbt)
puts "black-node counts: #{paths.values.uniq}"
graph_red_black_tree(rbt, 'dot.txt', 'Red-Black Tree')
system "dot -Tpng -odot.png dot.txt && #{OPEN} dot.png"

deleted = []

rbt_copy = rbt.dup
log = []
Benchmark.bm do |benchmark|
  benchmark.report("koi:") do
    log = delete_keys_of_interest(rbt_copy, deleted, log)
  end
end

puts log

trap("SIGINT") { print "\n"; exit! }


toggle = insert_n = delete_n = 0
while insert_n || delete_n
  print "Integer to insert [Enter for none, Ctrl+C to exit]? "
  ans = gets
  insert_n = ans == "\n" ? nil : ans.to_i
  print "Integer to delete [Enter for none, Ctrl+C to exit]? "
  ans = gets
  delete_n = ans == "\n" ? nil : ans.to_i
  print "Inserting: #{insert_n}\n" if insert_n
  print "Deleting: #{delete_n}\n" if delete_n

  rbt.insert(insert_n) if insert_n
  rbt.delete(delete_n) if delete_n

  name = toggle == 0  ? 'dot2' : 'dot'
  title = 'Red-Black Tree '
  title += insert_n ? "+ #{insert_n} " : ''
  title += delete_n ? "- #{delete_n} " : ''
  graph_red_black_tree(rbt, name + '.txt', title)

  system  'dot -Tpng -o' + name + '.png ' + name + '.txt'
  system "#{OPEN} " + name + '.png'

  toggle ^= 1
end
