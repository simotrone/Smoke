package Smoke::Model::Gallery::Picasa;

use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';
use lib "$FindBin::Bin/../lib/Smoke";

__PACKAGE__->config(
    class => 'Picasa::User',
);
#use Moose;
#use namespace::autoclean;
#extends 'Catalyst::Model';

=head1 NAME

Smoke::Model::Gallery::Picasa - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#__PACKAGE__->meta->make_immutable;

1;
