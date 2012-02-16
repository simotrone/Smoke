package Smoke::Model::Quoting;

use strict;
use warnings;
use parent 'Catalyst::Model::DBI';

# Table "public.citations":
# cite_id     | integer                     | not null default nextval('serial'::regclass)
# source      | character varying(512)      | 
# text        | text                        | not null
# genre_id    | integer                     | not null default 1
# create_time | timestamp without time zone | not null default now()
# active      | boolean                     | not null default true
# Indexes: 
#	"citations_pkey" PRIMARY KEY, btree (cite_id)
# Foreign-key constraints: 
#	"citations_genre_id_fkey" FOREIGN KEY (genre_id) REFERENCES genres(genre_id)


# return an hash (id => genere).
sub genres {
    my $self = shift;
    my $dbh = $self->dbh;
    my $sql = q{SELECT genre_id, name FROM genres};
    my %genre = @{ $dbh->selectcol_arrayref($sql, { Columns => [1,2] }) };
    return \%genre;
}


# select a random quote.
sub rand_one {
    my ($self, $genre) = @_;
    my $quotes = (defined $genre) ? $self->get_all($genre) : $self->get_all() ;
    my @selection = keys %$quotes;
    my $id = $selection[int(rand(@selection))];
    return $quotes->{ $id };
}


# take all quotes and create an hashref with 'id'
sub get_all {
    my ($self, $genre) = @_;
    # check $genre in db:
    if (defined $genre) {
	die "Can't use [$genre] to search in table." unless( grep { $_ eq $genre } values(%{$self->genres}) );
    }
    my $dbh = $self->dbh;
    my $query = 'SELECT id,text,source,genre FROM citations_view';
    $query .= ' WHERE genre = ?' if (defined $genre);
    my $sth = $dbh->prepare($query);
    $sth->execute( defined($genre) ? $genre : () );
    return $sth->fetchall_hashref('id');
}

# take single record by id
sub find {
    my ($self, $id) = @_;
    my $dbh = $self->dbh;
    my $sth = $dbh->prepare( 'SELECT cite_id, text, source, genre_id  FROM citations WHERE cite_id = ?' );
    $sth->execute( $id );
    return $sth->fetchrow_hashref;
}

# last_insert_id = insert($text,$source,$genre_id)
sub insert {
    my ($self, $text, $source, $genre_id) = @_;
    my $dbh = $self->dbh;
    # checks:
    $text = strip_blanks($text);
    $source = strip_blanks($source);
    die "Can't use $genre_id as genre." unless( grep{ $_ == $genre_id } keys(%{$self->genres}) );
    die "The `text' cannot be empty."	unless( defined($text) or (length($text) > 0) );
    $dbh->do(q{INSERT INTO citations (source,text,genre_id) VALUES (?,?,?)}, undef, $source, $text, $genre_id) or die $dbh->errstr;
    return $dbh->last_insert_id(undef, undef, 'citations','cite_id');
}

sub update {
    my ($self, $cite_id, $text, $source, $genre_id) = @_;
    my $dbh = $self->dbh;
    # checks:
    $text = strip_blanks($text);
    $source = strip_blanks($source);
    die "Can't use $genre_id as genre." unless( grep{ $_ == $genre_id } keys(%{$self->genres}) );
    die "The `text' cannot be empty."	unless( defined($text) or (length($text) > 0) );
    $dbh->do(q{UPDATE citations SET source = ?, text = ?, genre_id = ? WHERE cite_id = ?}, undef, $source, $text, $genre_id , $cite_id) or die $dbh->errstr;
    return $dbh->last_insert_id(undef, undef, 'citations','cite_id');
}

# helper func: strip blank space.
sub strip_blanks {
    my $string = shift;
    $string =~ s/^\s+|\s+$//g;
    return $string;
}

sub delete {
    my ($self, $id_to_delete) = @_;
    my $dbh = $self->dbh;
    my $ret = $dbh->do(q{UPDATE citations SET active = 'false' WHERE cite_id = ?}, undef, $id_to_delete);
    # TODO: Change deleted records without errors. Maybe I could put AND active = 'true'... (to test!).
    return ($ret > 0 ) 
	? { style => 'successful', text => "The record [$id_to_delete] was been deleted." } 
	: { style => 'error' , text => "Something goes wrong." };
}
=head1 NAME

Smoke::Model::Quoting - DBI Model Class

=head1 SYNOPSIS

See L<Smoke>

=head1 DESCRIPTION

DBI Model Class.

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
