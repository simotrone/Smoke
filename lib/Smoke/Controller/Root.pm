package Smoke::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Smoke::Controller::Root - Root Controller for Smoke

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut
=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub begin : Private {
    my ( $self, $c ) = @_;
    $c->stash( section => lc($c->namespace || $c->config->{name}) );
}

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->forward('genera_menu');
    $c->forward('genera_quote');

    # foolish experimental feature to insert data in left_sidebar
    #    push @{$c->stash->{'left_sidebar'}}, {title => 'Quotes', path => $c->uri_for('/quote')} unless ($c->req->path =~ /quote/);
    #    push @{$c->stash->{'left_sidebar'}}, {title => 'My Links', path => $c->uri_for('/links')} unless ($c->req->path =~ /links/);
}

sub genera_menu : Private {
    my ( $self, $c ) = @_;
    my $links = $c->model('Sitemap')->menu_links;
    my $main_menu;
    push @$main_menu, map{ { name => $_->{'label'} , path => $c->uri_for_action($_->{'action'}) } } @$links;

    $c->stash(
      	main_menu => $main_menu, 
    );
}

sub genera_quote : Private {
    my ($self, $c) = @_;
    my $quote = $c->model('Quoting')->rand_one();    # to take specific quote I have to insert arg in rand_one

    if ($quote) {
	my $quote_element = {
	    text   => $quote->{'text'},
	    source => $quote->{'source'},
	};
	$c->stash( 'wise_quotes' => $quote_element );
    }
}

=head2 welcome

The "Hello World" page, with welcome_message.

=cut

sub welcome :Local :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->status(404);
    $c->stash( template => '404.tt' );
}

=head2 end

Attempt to render a view, if needed.

=cut

# end standard method:
# sub end : ActionClass('RenderView') {}

sub end : ActionClass('RenderView') {
    my ($self, $c) = @_;
    my $uptime = `uptime`;
    $c->stash( uptime => $uptime );
    $c->res->headers->header( 'Last-Modified' => scalar localtime(), );
}

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
