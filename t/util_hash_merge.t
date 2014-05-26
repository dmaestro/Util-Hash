use 5.014;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;
use Test::Exception;

use Util::Hash;
use Data::Dumper;

my $method = Util::Hash->can('merge_deep');
ok($method,                                             'method exists');

use Storable qw(dclone);
my %new_config_clean  = (
    A =>  1,
    B =>  {},
    C =>  { Q =>  42},
);

my %new_config_linked = %{ dclone(\%new_config_clean) };
$new_config_linked{B}->{D} = $new_config_linked{C};

my %new_config_cycle  = %{ dclone(\%new_config_clean) };
$new_config_cycle{B}->{D} = $new_config_cycle{C};
$new_config_cycle{C}->{E} = $new_config_cycle{B};

my $config_init = {
    G =>  2,
    B =>  {
      D =>  {
        Z =>  -1,
        E =>  {},
      },
      F =>  3,
    },
    C =>  {
      E =>  {
        Y =>  -2,
      },
      H =>  4,
    },
};

my %new_config_ident_cycle;
$new_config_ident_cycle{B} = \%new_config_ident_cycle;

my %new_config_short_cycle = (
    C =>  {}
  );
$new_config_short_cycle{C}->{H} = $new_config_short_cycle{C};

{
  my $config = dclone $config_init;
  lives_ok( sub { $method->($config, \%new_config_clean); },
                                                        'Merge a simple configuration');
# warn Dumper($config);
  ok($config->{A},                                      'Added a simple value');
  is_deeply($config->{B},       $config_init->{B},      'No change to empty hash key');
  is($config->{C}->{Q},         42,                     'Merged a key');
  is($config->{C}->{H},         $config_init->{C}->{H}, 'Original key still exists');
}

{
  my $config = dclone $config_init;
  lives_ok( sub { $method->($config, \%new_config_linked); },
                                                        'Merge a simple configuration');
# warn Dumper($config);
  ok($config->{A},                                      'Added a simple value');
  is($config->{C}->{Q},         42,                     'Merged a key');
  is($config->{C}->{H},         $config_init->{C}->{H}, 'Original key still exists');
  is($config->{B}->{D}->{Q},    $config->{C}->{Q},      'Cross link merged');
}

{
  my $config = dclone $config_init;
  dies_ok( sub { $method->($config, \%new_config_cycle); },
                                                        'Throw if ref cycles found');
# warn Dumper($config);
# is_deeply($config,            $config_init,           'No change - just a fluke');
}

{
  my $config = dclone $config_init;
  dies_ok( sub { $method->($config, \%new_config_ident_cycle); },
                                                        '0-length cycle');
  $config = dclone $config_init;
  dies_ok( sub { $method->($config, \%new_config_short_cycle); },
                                                        '1-length cycle');
}

done_testing();

