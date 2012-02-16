package Smoke::Controller::Gallery;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Smoke::Controller::Gallery - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub base : Chained('/') : PathPart('gallery') : CaptureArgs(0) {
    my ($self, $c) = @_;
    $c->stash( picasa => $c->model('Gallery::Picasa') );
}
sub show : Chained('base') : PathPart('') : Args(0) {
    my ($self, $c) = @_;
    my $picasa = $c->stash->{'picasa'};
    $c->stash(
	albums => $picasa->albums ,
	template => 'gallery/index.tt',
    );
}
sub album : Chained('base') : PathPart('album') : Args(1) {
    my ($self, $c, $album_id) = @_;
    my $picasa = $c->stash->{'picasa'};
    my $album = $picasa->album( $album_id );
    $c->stash(
	album    => $album,
	photos   => $album->photos,
	template => 'gallery/album.tt',
    );
}


=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
