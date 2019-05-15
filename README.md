[![Build Status](https://travis-ci.com/slewsys/tree-red_black.svg?branch=master)](https://travis-ci.com/slewsys/tree-red_black)

# Tree::RedBlack

__Tree::RedBlack__ is a pure-Ruby implementation of a
[Red-Black tree](https://en.wikipedia.org/wiki/Red–black_tree) --
i.e., a self-balancing binary search tree with
[O(log n)](https://en.wikipedia.org/wiki/Big-O_notation)
search, insert and delete operations. It is appropriate for
maintaining an ordered collection where insertion and deletion
are desired at arbitrary positions.

The implementation differs slightly from the referenced Wikipedia
description.  In particular, leaf nodes in this implementation are
nil, which affects details of node deletion.

According to our own tests,
the Red-Black tree insertion implementation described on
[www.cs.auckland.ac.nz](https://www.cs.auckland.ac.nz/software/AlgAnim/red_black.html)
is less efficient and should be avoided.

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

Example:
```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
p rbt.root              #=> nil
p rbt.size              #=> 0
p rbt.allow_duplicates? #=> true
```

### insert(value, ...) --> red_black_tree

Inserts a value or sequence of values in a Red-Black tree. Since
values are ordered, every value in a Red-Black tree must be comparable
with every other value. The resulting tree is an ordered Enumberable
collection of nodes, so that methods `each`, `map`, `select`,
`find`, `sort`, etc., can be applied to it directly. The individual nodes
respond to method `key` to retrieve the value stored in that node.
Method `each`, in particular, is aliased to `in_order`, so that nodes
are sorted in ascending order by key.  Nodes can also be traversed by
method `pre_order`, e.g., to generate paths in the tree.

Example:
```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
rbt.insert(*1..10)      # #<Tree::RedBlack:0x00...>
p rbt.size              #=> 10
rbt.map(&:key)          #=> [1, 2, ..., 10]
rbt.reverse_each.map(&:key)
                        #=> [10, 9, ..., 1]
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
### in_order --> node_enumerator

Returns an enumerator for nodes in a Red-Black tree by in-order
traversal. The `each` method is aliased to `in_order`.

### pre_order --> node_enumerator

Returns an enumerator for nodes in a Red-Black tree by pre-order traversal.

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
p rbt.root.key.delete(:a) #=> {:b=>2}
p rbt_copy.root.key       #=> {:a=>1, :b=>2}
```

## Contributing

Bug reports and pull requests can be sent to
[GitHub tree-red_black](https://github.com/slewsys/tree-red_black).

## License

This Rubygem is free software. It can be used and redistributed under
the terms of the [MIT License](http://opensource.org/licenses/MIT).
