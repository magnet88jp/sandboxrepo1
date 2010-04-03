package Siva::Controller::CaseCommandMap;

use strict;
use warnings;
use base 'Siva::Controller::Base';

use Data::Page::Navigation;

=head1 NAME

Siva::Controller::CaseCommandMap - Catalyst Collection Resource Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 list

called by GET Collection Resource

=cut

sub list {
    my ($self, $c) = @_;
    $self->base_list( $c, __PACKAGE__);
}

=head2 create

called by POST Collection Resource

=cut

sub create {
    my ($self, $c) = @_;
    my %data = (
      test_case_id => $c->request->parameters->{test_case_id},
      test_command_id => $c->request->parameters->{test_comman_id},
      map_order => $c->request->parameters->{map_order},
    );
    $self->base_create( $c, __PACKAGE__, \%data);
}

=head2 show

called by GET Member Resource

=cut

sub show {
    my ($self, $c, $id) = @_;
    $self->base_show( $c, $id, __PACKAGE__);
}

=head2 update

called by PUT Member Resource

=cut

sub update {
    my ($self, $c, $id) = @_;
    my %data = (
      test_case_id => $c->request->parameters->{test_case_id},
      test_command_id => $c->request->parameters->{test_command_id},
      map_order => $c->request->parameters->{map_order},
    );
    $self->base_update( $c, $id, __PACKAGE__, \%data);
}

=head2 destroy

called by DELETE Member Resource

=cut

sub delete {
    my ($self, $c, $id) = @_;
    $self->base_delete( $c, $id, __PACKAGE__);
}

sub destroy {
    my ($self, $c, $id) = @_;
    $self->base_destroy( $c, $id, __PACKAGE__);
}

=head2 post

called by GET form for describing a new Resource

=cut

sub post {
    my ($self, $c) = @_;
    $self->base_post( $c, __PACKAGE__);
}

=head2 edit

called by GET form for describing a Member Resource

=cut

sub edit {
    my ($self, $c, $id) = @_;
    $self->base_edit( $c, $id, __PACKAGE__);
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

