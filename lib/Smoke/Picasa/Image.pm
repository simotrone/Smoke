package Picasa::Image;

use Moose;
use Moose::Util::TypeConstraints;
use URI;
use DateTime;

our $VERSION = '0.02';

=head2

Picasa::Image populated by Picasa::Album->photos.

=cut

subtype 'Img::URI' => as class_type('URI');
coerce  'Img::URI' => from 'Str' => via { URI->new( $_, 'http' ) };
subtype 'Img::DateTime' => as class_type('DateTime');
coerce  'Img::DateTime'
    => from 'Num' => via { DateTime->from_epoch( epoch => $_ ) }
    => from 'Str' => via {
	my ($Y,$M,$D,$h,$m,$s) = uc($_) =~ m/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.\d+Z$/ ;
	return DateTime->new( year => $Y, month => $M,  day => $D, hour => $h, minute => $m, second => $s, time_zone => 'UTC' );
    };

has 'title'	  => ( is => 'rw', isa => 'Str' );
has 'description' => ( is => 'rw', isa => 'Str' );
has 'published'   => ( is => 'rw', isa => 'Img::DateTime', coerce => 1 );

has 'original'	  => ( is => 'rw', isa => 'Img::URI', coerce => 1 );
has 'height'	  => ( is => 'rw', isa => 'Int' );
has 'width'	  => ( is => 'rw', isa => 'Int' );

has 'thumbnail'	  => ( is => 'rw', isa => 'Img::URI', coerce => 1 );
has 'thumb_height' => ( is => 'rw', isa => 'Int' );
has 'thumb_width' => ( is => 'rw', isa => 'Int' );


__PACKAGE__->meta->make_immutable;
1;
__END__
