package Picasa::User;

use Moose;
use Picasa::Album;

extends 'Picasa::Base';

our $VERSION = '0.06';

=head1 SYNOPSIS

    use Picasa::User;
    my $pi_user = Picasa::User->new( id => 'username' );

=head2 Attributes from Picasa::Base

=over

=item $pi_user->id

The userID.

=item $pi_user->uri

Here build the user uri.

=item $pi_user->xml_atom_feed

=back

=head2 $pi_user->author

=head2 $pi_user->updated

Feed last update date (in DateTime).

=head2 $pi_user->thumb

=head2 $pi_user->generator

=cut
has 'author' => ( is => 'ro', isa => 'Str', lazy_build => 1 );
sub _build_author {
    my $self = shift;
    # $self->xml_atom_feed->author is XML::Atom::Person
    return $self->xml_atom_feed->author->name;
}
has 'updated' => ( is => 'ro', isa => 'My::DateTime', coerce => 1, lazy_build => 1 );
sub _build_updated {
    return shift->xml_atom_feed->updated;
}
has 'thumb'    => ( is => 'ro', isa => 'My::URI', coerce => 1, lazy_build => 1 );
sub _build_thumb {
    my $self = shift;
    return $self->xml_atom_feed->get( $self->_ns_gphoto ,'thumbnail' );
}
has 'generator' => ( is => 'ro', isa => 'Str', lazy_build => 1 );
sub _build_generator {
    return shift->xml_atom_feed->generator;
}
has 'numalbums' => ( is => 'ro', isa => 'Int', lazy_build => 1 );
sub _build_numalbums {
    my $self = shift;
    return $self->xml_atom_feed->get( $self->_ns_openSearch, 'totalResults' );
}

=head2 $pi_user->album( $album_id );

=cut
sub album {
    my ($self,$album_id) = @_;
    return Picasa::Album->new( id => $album_id , userid => $self->id );
}

=head2 $pi_user->albums

=cut
has 'albums' => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );
sub _build_albums {
    my $self = shift;
    my @array_of_albums;

    # Look for a cleaner solution with XML::LibXML + XPath.
    foreach my $e ( $self->xml_atom_feed->entries ) {
	my $entry = $e->elem;

	# album_id is the only required info to make a Picasa::Album
	my $album_id = $entry->getElementsByTagNameNS( $self->_ns_gphoto, 'id' )->[0]->textContent;
	my $album = $self->album( $album_id );

	# Other data that are in User's xml and could to be useful in album 
	# (if there aren't, the album is not populated)
	my @optional_tags = (qw{ title summary published updated });
	foreach my $tag (@optional_tags) {
	    $album->$tag( $entry->getElementsByTagName($tag)->[0]->textContent ) if ($entry->getElementsByTagName($tag)->[0]);
	}
	# If exists, get album thumbnail
	if ( $entry->getElementsByTagNameNS( $self->_ns_media, 'thumbnail' )->[0]->hasAttribute('url') ) {
	    my $cover = $entry->getElementsByTagNameNS( $self->_ns_media, 'thumbnail' )->[0];
	    $album->icon( $cover->getAttribute('url') );
        }
	# If exists, get album numphotos
	if ( $entry->getElementsByTagNameNS( $self->_ns_gphoto, 'numphotos' )->[0] ) {
	    $album->numphotos( $entry->getElementsByTagNameNS( $self->_ns_gphoto, 'numphotos' )->[0]->textContent );
        }

	# So, array push with current data.
	push @array_of_albums, $album;
    }

    return \@array_of_albums;
}

__PACKAGE__->meta->make_immutable;
1; # End of Picasa::User
__END__
=head2 Namespaces attributes from Picasa::Base

=over

=item $pi_user->_url_api

=item $pi_user->_ns_gphoto

=item $pi_user->_ns_media

=back

=head1 AUTHOR

Simone Tampieri, C<< <simotrone at gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Simone Tampieri.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
