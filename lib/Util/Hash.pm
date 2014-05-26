package Util::Hash;
use 5.014;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(&merge_deep);

sub merge_deep {
  my ($merge, $new, @cycle) = @_;

  # This checks for reference cycles using a standard method:
  # Traverse the list using two pointers, one advancing one step,
  # the other advancing two. If there are cycles in the list,
  # eventually both pointers will point to the same node.
  my ($history_node, $check);
  if ($check = shift @cycle) { # check is done every second level
    # if we are doing the cycle test, advance the history node one key
    $history_node = $check->{ shift @cycle };
  } else { # a false flag prevented the check
    $history_node = shift @cycle || $new;
  }
  die 'Cycle detected!'
    if $check && $new eq $check;

  for my $key (keys %{ $new }) {
    if (ref $new->{$key} eq 'HASH') {
      if (exists $merge->{$key}) {
        die 'Attempted to merge hash with non-hash!'
          if ref $merge->{$key} ne 'HASH';
        merge_deep($merge->{$key}, $new->{$key},
          ($check
            ? (0)
            : ()
          ),
          $history_node,
          @cycle, $key); # history of past nodes in chain
        next;
      }
    }
    $merge->{$key} = $new->{$key};
  }
}

1;

