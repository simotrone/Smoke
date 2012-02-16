package Picasa::Base;

use Moose;
use Moose::Util::TypeConstraints;
use URI;
use File::stat;
use Storable;
use DateTime;
use XML::Atom::Feed;
our $VERSION = '0.05';

subtype 'My::URI'  => as class_type('URI');
coerce  'My::URI'  => from 'Str' => via { URI->new( $_, 'http' ) };
subtype 'My::File' => as class_type('URI');
coerce  'My::File' => from 'Str' => via { URI->new( $_, 'file' ) };
subtype 'My::DateTime' => as class_type('DateTime');
coerce  'My::DateTime'
    => from 'Num' => via { DateTime->from_epoch( epoch => $_ ) }
    => from 'Str' => via {
	my ($Y,$M,$D,$h,$m,$s) = uc($_) =~ m/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.\d+Z$/ ;
	return DateTime->new( year => $Y, month => $M,  day => $D, hour => $h, minute => $m, second => $s, time_zone => 'UTC' );
    };
subtype 'My::Atom::Feed' => as class_type('XML::Atom::Feed');

=head2 Picasa::Base->new( id => $something )

C<id> attribute is required.
I<$something> can be userID or albumID.
=cut
has 'id' => ( is => 'ro', isa => 'Str' , required => 1 );

has 'uri' => ( is => 'ro', isa => 'My::URI', coerce => 1, builder => '_build_uri' );
sub _build_uri {
    my $self = shift;
    return $self->_url_api . $self->id;
}

=head2 $pi->xml_atom_feed

Return an C<XML::Atom::Feed> based on C<$pi->id>.

The method get from cached results.
If cache is old or doesn't exists, it cache the feed.
=cut
has 'xml_atom_feed' => ( is => 'ro', isa => 'My::Atom::Feed', lazy_build => 1 );
sub _build_xml_atom_feed {
    my $self = shift;
    $self->_do_cache if ( $self->_is_cache_old );
    return XML::Atom::Feed->new( $self->_cached_xml );
}

sub _do_cache {
    my $self = shift;
    $self->_clear_cache_file_mtime;
    my $feed = XML::Atom::Feed->new( $self->uri );
    my $xml = $feed->as_xml;
    store \$xml, $self->_cache_file_name;
    $self->_cached_xml( \$xml );    # Useless? I hope to avoid a retrieve at first caching instance.
    return $self;
}

sub _is_cache_old {
    my $self = shift;
    my $mtime = $self->_cache_file_mtime;
    return 1 if ( DateTime->now(time_zone => 'UTC')->delta_ms( $mtime )->in_units('minutes') > $self->_cache_timeout );
    return 0;
}

=head2 Private attributes and methods

=head3 $pi->_cached_xml

Return the xml string.
=cut
has '_cached_xml' => ( is => 'rw', isa => 'ScalarRef[Str]', lazy_build => 1 );
sub _build__cached_xml {
    my $self = shift;

    # Do I need this test ?
    # $self->_do_cache if ( $self->_is_cache_old );
    # done in xml_atom_feed,
    # but if _cached_xml is called?

    my $filename = $self->_cache_file_name;
    $self->_do_cache unless ( -e $filename && -s $filename );
    return retrieve( $filename );
}

has '_cache_file_mtime' => ( is => 'rw', isa => 'My::DateTime' , coerce => 1, lazy_build => 1 ); 
sub _build__cache_file_mtime {
    my $self = shift;
    my $filename = $self->_cache_file_name;
    $self->_do_cache unless ( -e $filename && -s $filename );	# Need to make stat()
    return (stat($filename)->mtime);
}


# Follow useful params:
has '_cache_file_name' => ( is => 'rw', isa => 'My::File', coerce => 1, lazy_build => 1 );
sub _build__cache_file_name {
    my $self = shift;
    return '/tmp/picasa_'.$self->id;
}
has '_cache_timeout' => ( is => 'ro', isa => 'Int', default => 30 , required => 1 ); # minutes to refresh cache.
has '_url_api'   => ( is => 'ro', isa => 'My::URI', coerce => 1, default => 'http://picasaweb.google.com/data/feed/api/user/' );
has '_ns_gphoto' => ( is => 'ro', isa => 'My::URI', coerce => 1, default => 'http://schemas.google.com/photos/2007' );
has '_ns_media'  => ( is => 'ro', isa => 'My::URI', coerce => 1, default => 'http://search.yahoo.com/mrss/' );
has '_ns_openSearch' => ( is => 'ro', isa => 'My::URI', coerce => 1, default => 'http://a9.com/-/spec/opensearchrss/1.0/' );

has '_ns_georss' => ( is => 'ro', isa => 'My::URI', coerce => 1, default => 'http://www.georss.org/georss' ); # actually not used

__PACKAGE__->meta->make_immutable;
1; # End of Picasa::Base
__END__
=head1 Notes

The Picasa::Base module is the Base upon I builded the User and Album objects.

The Picasa Web Albums Data API:
http://code.google.com/intl/it/apis/picasaweb/docs/2.0/developers_guide_protocol.html#ListAlbums

The xml that I download from Picasa follow this reference: 
http://code.google.com/intl/it/apis/gdata/docs/2.0/reference.html

=head1 AUTHOR

Simone Tampieri, C<< <simotrone at gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Simone Tampieri.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
