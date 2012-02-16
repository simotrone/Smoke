package Picasa::Album;

use Moose;
use Picasa::Image;
use Encode;

extends 'Picasa::Base';

our $VERSION = '0.06';

=head1 SYNOPSIS

    use Picasa::Album;
    my $pi_album = Picasa::Album->new( id => 'albumid' , userid => 'username' );

=head2 Attributes from Picasa::Base

=over

=item $pi_album->id

The albumID.

=item $pi_user->uri

Here build the album uri.

=item $pi_user->xml_atom_feed

=back

=head2 $pi_album->userid

The userID.

=cut
has 'userid' => ( is => 'ro', isa => 'Str' , required => 1 );

has '+uri' => ( builder => '_build_album_uri' );
sub _build_album_uri {
    my $self = shift;
    return $self->_url_api . $self->userid . '/albumid/' . $self->id ;
}

=head2 $pi_album->title

=head2 $pi_album->icon

=head2 $pi_album->updated

=head2 $pi_album->numphotos

=head2 $pi_album->photos

Return a reference to Array of Picasa::Image. 
C<photos> find all the images from album.

=cut
has 'title' => ( is => 'rw', isa => 'Str' , lazy_build => 1 );
sub _build_title {
    my $self = shift;
    return $self->xml_atom_feed->title ;
};
has 'summary' => ( is => 'rw', isa => 'Str' , lazy_build => 1 );
sub _build_summary {
    my $self = shift;
    return $self->xml_atom_feed->subtitle ;
    # In the Album atom the (User) summary become subtitle.
};
has 'published' => ( is => 'rw', isa => 'My::DateTime', coerce => 1, lazy_build => 1 );
sub _build_published {
    my $self = shift;
    return $self->xml_atom_feed->published;
}
has 'updated' => ( is => 'rw', isa => 'My::DateTime', coerce => 1, lazy_build => 1 );
sub _build_updated {
    my $self = shift;
    return $self->xml_atom_feed->updated;
}
has 'icon' => ( is => 'rw', isa => 'My::URI', coerce => 1, lazy_build => 1 );
sub _build_icon {
    my $self = shift;
    return $self->xml_atom_feed->icon;
}
has 'numphotos' => ( is => 'rw', isa => 'Int', lazy_build => 1 );
sub _build_numphotos {
    my $self = shift;
    return $self->xml_atom_feed->get($self->_ns_gphoto , 'numphotos');
};

has 'photos' => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );
sub _build_photos {
    my $self = shift;
    my @array_of_photos;

    # album entries (Entry are XML::LibXML::Element item)
    foreach my $entry ( $self->xml_atom_feed->entries) {
	my $photo = Picasa::Image->new();
	$photo->title( $entry->title );
	$photo->published( $entry->published );

	## WARNING ##
	# here Atom methods are not enough
	# atom dismembered with 'elem' XML::LibXML method
	# probably unstable..
	# first version: my $img_content = $entry->elem->getElementsByTagName('content')->[0];
	my $img_content = $entry->elem->getElementsByTagNameNS($self->_ns_media,'content')->[0];
	$photo->original( $img_content->getAttribute('url') );
	$photo->height( $img_content->getAttribute('height') );
	$photo->width( $img_content->getAttribute('width') );
	
	# encoding ad hoc, per ora.
	$photo->description(
	    encode('utf-8', $entry->elem->getElementsByTagNameNS($self->_ns_media,'description')->[0]->textContent )
	);
	my @thumb_nodes = $entry->elem->getElementsByTagNameNS($self->_ns_media,'thumbnail');
	# Select thumbs with width = 144.
	my $thumb_node;
	for (@thumb_nodes) {
	    if ($_->getAttribute('width') == 144 || $_->getAttribute('height') == 144) {
		$photo->thumbnail( $_->getAttribute('url') );
		$photo->thumb_height( $_->getAttribute('height') );
		$photo->thumb_width( $_->getAttribute('width') );
	    }
	}
	
	## END BAD THINGS ##

	push @array_of_photos, $photo;
    }

    return \@array_of_photos;
}

__PACKAGE__->meta->make_immutable;
1; # End of Picasa::Album
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
