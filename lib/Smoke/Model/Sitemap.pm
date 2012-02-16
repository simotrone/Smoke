package Smoke::Model::Sitemap;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

has 'menu_links' => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

sub _build_menu_links {
    my $self = shift;
    my $items = [
#	[ name , controller-action ]	
	[ 'smoke'   , '/index' ],
	[ 'news'    , '/news/index' ],
	[ 'quotes'  , '/quotes/show' ],
	[ 'gallery' , '/gallery/show' ],
	[ 'links'   , '/links/index' ],
    ];
    my $AoH;
    push @$AoH, map{ { label => $_->[0], action => $_->[1] } } @$items;
    return $AoH;
}

=head1 NAME

Smoke::Model::Sitemap - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
