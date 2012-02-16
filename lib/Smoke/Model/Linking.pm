package Smoke::Model::Linking;

use strict;
use warnings;
use parent 'Catalyst::Model::DBI';

__PACKAGE__->config(
#    dsn           => 'dbi:Pg:database=Linking',
#    user          => 'username',
#    password      => 'password',
#    options       => {},
);

sub tags {
    my $self = shift;
    my $dbh = $self->dbh;
    my $sql = q{SELECT DISTINCT tag_id FROM links};
    return $dbh->selectcol_arrayref($sql);
}

sub get_all {
    my $self = shift;
    my $dbh = $self->dbh;
    my $sql = q{SELECT name, href, tag_id, comment FROM links ORDER BY create_time DESC, name ASC};
    my $sth = $dbh->prepare($sql) or die $dbh->errstr;
    $sth->execute or die $sth->errstr;
    my $result;
    while( my $h = $sth->fetchrow_hashref ) {
	push @{ $result->{$h->{'tag_id'}} } , { name => $h->{'name'} , href  => $h->{'href'} , title => $h->{'comment'} };
    }
    return $result;
}

=head1 NAME

Smoke::Model::Linking - DBI Model Class

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
