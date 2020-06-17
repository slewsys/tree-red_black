[![Build Status](https://travis-ci.com/slewsys/tree-red_black.svg?branch=master)](https://travis-ci.com/slewsys/tree-red_black)

# Tree::RedBlack

- [Description](#description)
- [Installation](#installation)
- [Tree::RedBlack API](#treeredblack-api)
    - [new(allow_duplicates = true) &#8594; red_black_tree](#newallow_duplicates--true--red_black_tree)
    - [insert(value, ...) &#8594; red_black_tree](#insertvalue---red_black_tree)
    - [delete(value, ...) &#8594; red_black_tree](#deletevalue---red_black_tree)
    - [search(value, ifnone = nil) &#8594; red_black_node](#searchvalue-ifnone--nil--red_black_node)
    - [bsearch { |node| block } &#8594; red_black_node](#bsearch--node-block---red_black_node)
    - [pre_order &#8594; node_enumerator](#pre_order--node_enumerator)
    - [in_order &#8594; node_enumerator](#in_order--node_enumerator)
    - [dup &#8594; red_black_tree](#dup--red_black_tree)
- [Tree::RedBlackNode API](#treeredblacknode-api)
    - [new(value = nil, color = :RED) &#8594; red_black_node](#newvalue--nil-color--red--red_black_node)
    - [insert_red_black(value, allow_duplicates = true) &#8594; red_black_node](#insert_red_blackvalue-allow_duplicates--true--red_black_node)
    - [delete_red_black(value) &#8594; red_black_node](#delete_red_blackvalue--red_black_node)
    - [search(value, ifnone = nil) &#8594; red_black_node](#searchvalue-ifnone--nil--red_black_node-1)
    - [bsearch(&block) &#8594; red_black_node](#bsearchblock--red_black_node)
    - [min() &#8594; red_black_node](#min--red_black_node)
    - [max() &#8594; red_black_node](#max--red_black_node)
    - [pred() &#8594; red_black_node](#pred--red_black_node)
    - [succ() &#8594; red_black_node](#succ--red_black_node)
    - [pre_order(&block) &#8594; red_black_node](#pre_orderblock--red_black_node)
    - [in_order(&block) &#8594; red_black_node](#in_orderblock--red_black_node)
    - [dup() &#8594; red_black_node](#dup--red_black_node)
- [Contributing](#contributing)
- [License](#license)

## Description

The __Tree::RedBlack__ library is a pure-Ruby implementation of
a [Red-Black tree](https://en.wikipedia.org/wiki/Red–black_tree) --
i.e., a self-balancing binary tree
with [O(log n)](https://en.wikipedia.org/wiki/Big-O_notation) search,
insert and delete operations. It is appropriate for maintaining a
sorted collection where insertion and deletion are desired at
arbitrary positions.

This implementation differs slightly from the Wikipedia description
referenced above. In particular, leaf nodes are `nil`, which affects the
details of node deletion.

## Installation
With a recent version of the [Ruby](https://www.ruby-lang.org/en/)
interpreter installed (e.g., ruby 2.5), run the following commands
from a Unix shell:

```bash
git clone git@github.com:slewsys/tree-red_black.git
cd tree-red_black
sudo gem update --system
bundle
rake build
sudo gem install pkg/tree-red_black*.gem
```

The RSpec test suite can be run with:

```bash
bundle exec rspec spec
```

To build RDoc documentation, use:

```bash
rake rdoc
```

## Tree::RedBlack API

Once a Red-Black tree has been instantiated
(see
[new](#newallow_duplicates--true--red_black_tree)),
any [Comparable](https://docs.ruby-lang.org/en/2.7.0/Comparable.html)
value can be stored, provided that every value in the tree is
comparable with every other. Values are stored in nodes and referenced
by the `key` attribute of the node. Nodes are added to a Red-Black
tree by inserting values
(see
[insert](#insertvalue---red_black_tree)),
and nodes are removed by deleting values
(see
[delete](#deletevalue---red_black_tree)).

A Red-Black tree's nodes can be enumerated in ascending order by value
with the tree's [each](#in_order--node_enumerator) method. Additional
enumeration methods are described
in [Enumerable](https://ruby-doc.org/core-2.7.0/Enumerable.html).

### new(allow_duplicates = true) &#8594; red_black_tree

Returns a new, empty Red-Black tree. If option `allow_duplicates` is
`false`, then only unique values are inserted in a Red-Black tree.

The `root` attribute references the root node of the tree.
The `size` attribute indicates the number of nodes in the tree.
When `size` is `0`, `root` is always `nil`.

Example:

```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
p rbt.root                #=> nil
p rbt.size                #=> 0
p rbt.allow_duplicates?   #=> true
```

### insert(value, ...) &#8594; red_black_tree

Inserts a value or sequence of values in a Red-Black tree and
increments the `size` attribute by the number of values inserted.

Since a Red-Black tree maintains a sorted, [Enumerable](https://ruby-doc.org/core-2.7.0/Enumerable.html) collection,
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
rbt.insert(*1..10)        # #<Tree::RedBlack:0x00...>
p rbt.size                #=> 10
rbt.map(&:key)            #=> [1, 2, ..., 10]
rbt.select { |node| node.key % 2 == 0 }.map(&:key)
                          #=> [2, 4, ..., 10]
```

### delete(value, ...) &#8594; red_black_tree

Deletes a value or sequence of values from a Red-Black tree.

Example:

```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
rbt.insert(*1..10)        # #<Tree::RedBlack:0x00...>
p rbt.size                #=> 10
rbt.delete(*4..8)         # #<Tree::RedBlack:0x00...>
p rbt.size                #=> 5
rbt.map(&:key)            #=> [1, 2, 3, 9, 10]
```

### search(value, ifnone = nil) &#8594; red_black_node

Returns a Red-Black tree node whose `key` matches `value` by binary
search. If no match is found, calls non-nil `ifnone`, otherwise
returns `nil`.

Example:

```ruby
require 'tree/red_black'

shuffled_values = [*1..10].shuffle
rbt = shuffled_values.reduce(Tree::RedBlack.new) do |acc, v|
  acc.insert(v)
end
rbt.search(7)             #=> <Tree::RedBlackNode:0x00..., @key=7, ...>
```

### bsearch { |node| block } &#8594; red_black_node

Returns a Red-Black tree node satisfying a criterion defined in
`block` by binary search.

If `block` evaluates to `true` or `false`, returns the first node for
which the `block` evaluates to `true`. In this case, the criterion is
expected to return `false` for nodes preceding the matching node and
`true` for subsequent nodes.

Example:

```ruby
require 'tree/red_black'

shuffled_values = [*1..10].shuffle
rbt = shuffled_values.reduce(Tree::RedBlack.new) do |acc, v|
  acc.insert(v)
end
rbt.bsearch { |node| node.key >= 7 }
                          #=> <Tree::RedBlackNode:0x00..., @key=7, ...>
```

If `block` evaluates to `<0`, `0` or `>0`, returns first node for
which `block` evaluates to `0`. Otherwise returns `nil`. In this case,
the criterion is expected to return `<0` for nodes preceding the
matching node, `0` for some subsequent nodes and `>0` for nodes beyond
that.

Example:

```ruby
require 'tree/red_black'

shuffled_values = [*1..10].shuffle
rbt = shuffled_values.reduce(Tree::RedBlack.new) do |acc, v|
  acc.insert(v)
end
rbt.bsearch { |node| 7 <=> node.key }
                          #=> <Tree::RedBlackNode:0x00..., @key=7, ...>
```

If `block` is not given, returns an enumerator.

### pre_order &#8594; node_enumerator

Returns an enumerator for nodes in a Red-Black tree by pre-order
traversal.

Example:

```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
shuffled_values = [*1..10].shuffle  #=> [5, 9, 10, 8, 7, 6, 1, 2, 4, 3]
rbt.insert(*shuffled_values)        #=> #<Tree::RedBlack:0x00...>
rbt.pre_order.map(&:key)            #=> [7, 5, 2, 1, 4, 3, 6, 9, 8, 10]
```

### in_order &#8594; node_enumerator

Returns an enumerator for nodes in a Red-Black tree by in-order
traversal. The `each` method is aliased to `in_order`.

Example:

```ruby
require 'tree/red_black'

rbt = Tree::RedBlack.new
shuffled_values = [*1..10].shuffle
rbt.insert(*shuffled_values)
rbt.in_order.map(&:key)             #=> [1, 2, ... 9, 10]
```

### dup &#8594; red_black_tree

Returns a deep copy of a Red-Black tree, provided that the `dup`
method for the `key` attribute of a tree node is also a deep copy.

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

### Tree::RedBlackNode API

A Red-Black tree is a collection of nodes arranged as a binary tree.
In addition to the binary node attributes `left` and `right`, which
reference the left and right sub-trees of a given node, and the
attribute `key` which stores a node's data, a Red-Black tree node
also has attributes `color` and `parent`.

The `color` attribute is used internally to balance the tree after a
node is inserted or deleted. The `parent` attribute references a
node's parent node, or `nil` in the case of the root node of a tree.

Not all implementations of Red-Black trees have nodes with `parent`
attributes, but it's generally recognized as the most efficient way
of balancing and re-coloring a Red-Black tree.

Since the data in a binary tree can be thought of as a sorted
collection, it's convenient to be able to refer to a node's
predecessor and successor (i.e., the node whose `key` is the
predecessor or successor in the sorted ascending order. In general,
this differs from parent or child node). This is provided as the node
methods `pred` and `succ`. And for a given sub-tree, its convenient to
be able to refer to its min and max nodes (i.e., the node whose `key`
is a minimum or maximum in the sub-tree). This is provided as the node
methods `min` and `max`.

While a Red-Black tree can be constructed from nodes alone, the
[Tree::RedBlack API](#treeredblack-api)
provides a cleaner way of working with Red-Black trees. Start
there if only using the Red-Black tree as a container.

### new(value = nil, color = :RED) &#8594; red_black_node

Returns a new node with `key` parameter set to option `value`. The
`color` option, if given, must be be either `:RED` or `:BLACK`.

Example:

```ruby
require 'tree/red_black'

root = Tree::RedBlackNode.new(10)
p root.key              #=> 10
p root.color            #=> :RED
p root.parent           #=> nil
p root.left             #=> nil
p root.right            #=> nil
```

### insert_red_black(value, allow_duplicates = true) &#8594; red_black_node

Inserts the given `value` in a tree whose root node is `self`. If the
`key` attribute of the root node is `nil`, then `value` is assigned to
`key`. Otherwise, `value` is used to instantiate Tree::RedBlackNode,
and the node is inserted in the tree; the tree is then re-balanced as
needed, and the root of the balanced tree returned.

Since a Red-Black tree maintains an ordered, Enumerable collection,
every value inserted must be Comparable with every other value.
Methods `each`, `map`, `select`, `find`, `sort`, etc., can be applied
to a Red-Black tree's root node to iterate over all nodes in the tree.

Each node yielded by enumeration has a `key` attribute to
retrieve the value stored in that node. Method `each`, in particular,
is aliased to `in_order`, so that nodes are sorted in ascending order
by `key` value. Nodes can also be traversed by method `pre_order`,
e.g., to generate paths in the tree.

Example:

```ruby
require 'tree/red_black'

root = Tree::RedBlackNode.new
p root.key                      #=> nil
root = root.insert_red_black(0)
p root.key                      #=> 0
root = root.insert_red_black(1)
p root.key                      #=> 0
p root.left                     #=> nil
p root.right.key                #=> 1
root = root.insert_red_black(2)
p root.key                      #=> 1
p root.left.key                 #=> 0
p root.right.key                #=> 2
```

### delete_red_black(value) &#8594; red_black_node

Deletes the given `value` from a tree whose root node is `self`.
If the tree has only one remaining node and its `key` attribute
matches `value`, then the remaining node's `key` attribute is set to
`nil` but the node itself is not removed. Otherwise, the first node
found whose `key` matches `value` is removed from the tree, and the
tree is re-balanced. The root of the balanced tree is returned.

Example:

```ruby
require 'tree/red_black'

root = [*1..10].reduce(Tree::RedBlackNode.new) do |acc, v|
  acc.insert_red_black(v)
end
root = [*4..8].reduce(root) do |acc, v|
  acc.delete_red_black(v)
end
root.map(&:key)                 #=> [1, 2, 3, 9, 10]
```

### search(value, ifnone = nil) &#8594; red_black_node

Returns a node whose `key` matches `value` by binary search. If no
match is found, calls non-nil `ifnone`, otherwise returns `nil`.

Example:

```ruby
require 'tree/red_black'

shuffled_values = [*1..10].shuffle
root = shuffled_values.reduce(Tree::RedBlackNode.new) do |acc, v|
  acc.insert_red_black(v)
end
root.search(7)        #=> <Tree::RedBlackNode:0x00..., @key=7, ...>
```

### bsearch(&block) &#8594; red_black_node

Returns a node satisfying a criterion defined in `block` by binary
search.

If `block` evaluates to `true` or `false`, returns the first node for
which the `block` evaluates to `true`. In this case, the criterion is
expected to return `false` for nodes preceding the matching node and
`true` for subsequent nodes.

Example:

```ruby
require 'tree/red_black'

shuffled_values = [*1..10].shuffle
rbt = shuffled_values.reduce(Tree::RedBlack.new) do |acc, v|
  acc.insert(v)
end
rbt.bsearch { |node| node.key >= 7 }
                      #=> <Tree::RedBlackNode:0x00..., @key=7, ...>
```

If `block` evaluates to `<0`, `0` or `>0`, returns first node for
which `block` evaluates to `0`. Otherwise returns `nil`. In this case,
the criterion is expected to return `<0` for nodes preceding the
matching node, `0` for some subsequent nodes and `>0` for nodes beyond
that.

Example:

```ruby
require 'tree/red_black'

shuffled_values = [*1..10].shuffle
rbt = shuffled_values.reduce(Tree::RedBlack.new) do |acc, v|
  acc.insert(v)
end
rbt.bsearch { |node| 7 <=> node.key }
                      #=> <Tree::RedBlackNode:0x00..., @key=7, ...>
```

If `block` is not given, returns an enumerator.

### min() &#8594; red_black_node

Returns the node whose `key` is a minimum in the sub-tree with root `self`.

Example:

```ruby
require 'tree/red_black'

root = [*0..10].reduce(Tree::RedBlackNode.new) do |acc, v|
  acc.insert_red_black(v)
end
root                  #=> <Tree::RedBlackNode:0x00..., @key=4, ...>
root.min              #=> <Tree::RedBlackNode:0x00..., @key=0, ...>
root.right            #=> <Tree::RedBlackNode:0x00..., @key=6, ...>
root.right.min        #=> <Tree::RedBlackNode:0x00..., @key=5, ...>
```
### max() &#8594; red_black_node

Returns the node whose `key` is a maximum in the sub-tree with
root `self`.

Example:

```ruby
require 'tree/red_black'

root = [*0..10].reduce(Tree::RedBlackNode.new) do |acc, v|
  acc.insert_red_black(v)
end
root                  #=> <Tree::RedBlackNode:0x00..., @key=4, ...>
root.max              #=> <Tree::RedBlackNode:0x00..., @key=10, ...>
root.left             #=> <Tree::RedBlackNode:0x00..., @key=2, ...>
root.left.max         #=> <Tree::RedBlackNode:0x00..., @key=3, ...>
```

### pred() &#8594; red_black_node

Returns the node preceding `self`, or `nil` if no predecessor exists.
If duplicate keys are allowed, it's possible that `pred.key == key`.

Example:

```ruby
require 'tree/red_black'

root = [*1..10].reduce(Tree::RedBlackNode.new) do |acc, v|
  acc.insert_red_black(v)
end
root.right.right.key            #=> 8
root.right.right.pred.key       #=> 7
```

### succ() &#8594; red_black_node

Returns the node succeeding `self`, or `nil` if no successor exists.
If duplicate keys are allowed, it's possible that `succ.key == key`.

Example:

```ruby
require 'tree/red_black'

root = [*1..10].reduce(Tree::RedBlackNode.new) do |acc, v|
  acc.insert_red_black(v)
end
root.right.right.key            #=> 8
root.right.right.succ.key       #=> 9
```

### pre_order(&block) &#8594; red_black_node

Returns an enumerator for nodes in the tree with root `self` by
pre-order traversal.

Example:

```ruby
require 'tree/red_black'

root = [*1..10].reduce(Tree::RedBlackNode.new) do |acc, v|
  acc.insert_red_black(v)
end
root.pre_order.map(&:key)       #=> [4, 2, 1, 3, 6, 5, 8, 7, 9, 10]
```

### in_order(&block) &#8594; red_black_node

Returns an enumerator for nodes in the tree with root `self` by
in-order traversal.

Example:

```ruby
require 'tree/red_black'

root = [*1..10].reduce(Tree::RedBlackNode.new) do |acc, v|
  acc.insert_red_black(v)
end
root.in_order.map(&:key)        #=> [1, 2, ..., 10]
```

### dup() &#8594; red_black_node

Returns a deep copy of the tree with root `self`, provided that
the `dup` method for the `key` attribute of a node is also a
deep copy.

Example:

```ruby
require 'tree/red_black'

root = Tree::RedBlackNode.new({a: 1, b: 2})
root_copy = root.dup
p root.key                      #=> {:a=>1, :b=>2}
p root.key.delete(:a)           #=> 1
p root.key                      #=> {:b=>2}
p root_copy.key                 #=> {:a=>1, :b=>2}
```

## Contributing

Bug reports and pull requests can be sent to
[GitHub tree-red_black](https://github.com/slewsys/tree-red_black).

## License

This Rubygem is free software. It can be used and redistributed under
the terms of the [MIT License](http://opensource.org/licenses/MIT).
