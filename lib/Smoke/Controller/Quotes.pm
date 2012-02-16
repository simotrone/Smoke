package Smoke::Controller::Quotes;
use Moose;
use namespace::autoclean;
use XML::Feed;
use JSON;
use Encode;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Smoke::Controller::Admin::Quote - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


#sub index :Path :Args(0) {
#    my ( $self, $c ) = @_;
#    $c->response->body('Matched Smoke::Controller::Admin::Quote in Admin::Quote.');
#}

sub base : Chained('/') : PathPart('quotes') : CaptureArgs(0) {
    my ($self,$c) = @_;
    $c->stash(
	genre => $c->model('Quoting')->genres,
	results  => $c->model('Quoting')->get_all ,
    );
}
sub show : Chained('base') : PathPart('') : Args(0) {
    my ($self,$c) = @_;
    $c->stash(
	template => 'quotes/index.tt',
    );
}

sub rss : Chained('base') : PathPart('rss') : Args(0) {
    my ($self, $c) = @_;
    my $feed = XML::Feed->new('RSS');
    $feed->title( $c->config->{name} .' RSS Feed' );
    $feed->link( $c->req->base );
    $feed->description('Quotes RSS Feed');

    my $quote = $c->stash->{'results'};
    foreach my $id ( reverse sort keys %$quote ) {  # id, test, source
	my $feed_entry = XML::Feed::Entry->new('RSS');
	$feed_entry->id( $quote->{$id}->{'id'} );
	$feed_entry->title( $quote->{$id}->{'id'} .' - '. decode('utf-8',$quote->{$id}->{'source'}) );
	$feed_entry->content( decode('utf-8',$quote->{$id}->{'text'}) );
	$feed_entry->author( decode('utf-8',$quote->{$id}->{'source'}) );

	$feed->add_entry($feed_entry);
    }

    $c->res->content_type('application/rss+xml');
    $c->res->body( $feed->as_xml );
}

sub json : Chained('base') : PathParth('json') : Args(0) {
    my ($self, $c) = @_;
    my $quote = $c->stash->{'results'};
    my $json = to_json($quote);
    $c->res->content_type('application/json');
    $c->res->content_length( length($json) );
    $c->res->content_encoding('utf-8');
    $c->res->header('Content-Disposition' => 'attachment; filename=smoke_quotes.json' );
    $c->res->body( $json );
}
=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
