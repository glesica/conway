# Conway for Playdate

Experimental game for the Playdate handheld console.

## Design

Inspired by Space Invaders, there is a sparse array of aliens. The aliens
move independently of one another, from cell to cell within an invisible
grid. Movement between grid cells is smooth, but the aliens always stop
aligned to the grid.

Certain kinds of aliens can interact with one another to produce new kinds
of alien with different capabilities and attributes. In some cases the
interaction occurs when the aliens are near one another. For example, a
new alien might appear in the empty grid cell between three aliens located
to the N, W, and E of an empty cell. In other cases, aliens might merge
together when they enter the same cell and produce a more powerful alien.

The player has various weapons that can destroy the aliens, but generally
limited ammunition (or, in some cases, the weapons wear out). However, the
player also has a tractor beam, operated with the crank, that can push,
pull, or trap (to move sideways) one or more aliens in its path. This way,
the player is able to prevent aliens from merging in detrimental ways.
