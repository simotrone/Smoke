package Smoke::View::Web;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    WRAPPER => 'templates/wrapper',
    render_die => 1,
);

=head1 NAME

Smoke::View::Web - TT View for Smoke

=head1 DESCRIPTION

TT View for Smoke.

=head1 SEE ALSO

L<Smoke>

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
