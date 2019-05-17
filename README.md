[![Build Status](https://travis-ci.com/slewsys/tree-red_black.svg?branch=master)](https://travis-ci.com/slewsys/tree-red_black)

# Tree::RedBlack

__Tree::RedBlack__ is a pure-Ruby implementation of a
[Red-Black tree](https://en.wikipedia.org/wiki/Red–black_tree) --
i.e., a self-balancing binary search tree with
[O(log n)](https://en.wikipedia.org/wiki/Big-O_notation)
search, insert and delete operations. It is appropriate for
maintaining an ordered collection where insertion and deletion
are desired at arbitrary positions.

The implementation differs slightly from the Wikipedia description
referenced above. In particular, leaf nodes are nil, which affects the
details of node deletion.

## Installation
With a recent very of the
[Ruby](https://www.ruby-lang.org/en/)
interpreter installed, run the following commands from a Unix shell:
```bash
git clone https://github.com/slewsys/tree-red_black
cd tree-red_black
bundle
rake build
gem install pkg/tree-red_black*.gem
```

The RSpec test suite can be run with:
```bash
bundle exec rspec spec
```

## API

### new(allow_duplicates = true) --> red_black_tree

Returns a new, empty Red-Black tree. If option `allow_duplicates` is
`false`, then only unique values are inserted in a Red-Black tree.

A Red-Black tree exposes parameters `root`, the root node of a tree, and
`size`, the number of nodes in the tree.

Example:
```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
p rbt.root              #=> nil
p rbt.size              #=> 0
p rbt.allow_duplicates? #=> true
```

### insert(value, ...) --> red_black_tree

Inserts a value or sequence of values in a Red-Black tree and
increments the `size` attribute by the number of values inserted.

Since a Red-Black tree maintains an ordered, Enumerable collection,
every value inserted must be comparable with every other value.
Methods `each`, `map`, `select`, `find`, `sort`, etc., can be applied
directly to the tree.

The individual nodes yielded by enumeration respond to method `key` to
retrieve the value stored in that node. Method `each`, in particular,
is aliased to `in_order`, so that nodes are sorted in ascending order
by `key` value. Nodes can also be traversed by method `pre_order`,
e.g., to generate paths in the tree.

Example:
```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
rbt.insert(*1..10)      # #<Tree::RedBlack:0x00...>
p rbt.size              #=> 10
rbt.map(&:key)          #=> [1, 2, ..., 10]
rbt.select { |node| node.key % 2 == 0 }.map(&:key)
                        #=> [2, 4, ..., 10]
```

### delete(value, ...) --> red_black_tree

Deletes a value or sequence of values from a Red-Black tree.

Example:
```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
rbt.insert(*1..10)      # #<Tree::RedBlack:0x00...>
p rbt.size              #=> 10
rbt.delete(*4..8)       # #<Tree::RedBlack:0x00...>
p rbt.size              #=> 5
rbt.map(&:key)          #=> [1, 2, 3, 9, 10]
```
### pre_order --> node_enumerator

Returns an enumerator for nodes in a Red-Black tree by pre-order traversal.

Example:
```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
shuffled_values = [*1..10].shuffle  #=> [5, 9, 10, 8, 7, 6, 1, 2, 4, 3]
rbt.insert(*shuffled_values)        #=> #<Tree::RedBlack:0x00...>
rbt.pre_order.map(&:key)            #=> [7, 5, 2, 1, 4, 3, 6, 9, 8, 10]
```

### in_order --> node_enumerator

Returns an enumerator for nodes in a Red-Black tree by in-order
traversal. The `each` method is aliased to `in_order`.

Example:
```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
shuffled_values = [*1..10].shuffle
rbt.insert(*shuffled_values)
rbt.in_order.map(&:key)  #=> [1, 2, ... 9, 10]
```

### dup --> red_black_tree

Returns a deep copy of a Red-Black tree, provided that the
`dup` method for values in the tree is also a deep copy.

Example:
```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
rbt.insert({a: 1, b: 2})
rbt_copy = rbt.dup
p rbt.root.key            #=> {:a=>1, :b=>2}
p rbt.root.key.delete(:a) #=> 1
p rbt.root.key            #=> {:b=>2}
p rbt_copy.root.key       #=> {:a=>1, :b=>2}
```

## Contributing

Bug reports and pull requests can be sent to
[GitHub tree-red_black](https://github.com/slewsys/tree-red_black).

## License

This Rubygem is free software. It can be used and redistributed under
the terms of the [MIT License](http://opensource.org/licenses/MIT).
