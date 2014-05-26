Util-Hash
=========

Test wrapper for merge_deep function

Used for a private patch to Dancer::Config to allow deep merges of configuration file
hashes. Only hashrefs are merged; other values are copied verbatim.

This function, unlike other available CPAN modules (that I know of), detects cycles at it
follows the right-hand hash. Also, this function mutates it's first argument to perform
the merge.
