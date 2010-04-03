package Siva::Controller::TestSuite::SuiteCaseMap;

use strict;
use warnings;
use base 'Siva::Controller::Base';

use Data::Page::Navigation;

__PACKAGE__->config(belongs_to => 'TestSuite');

=head1 NAME

Siva::Controller::SuiteCaseMap - Catalyst Collection Resource Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 list

called by GET Collection Resource

=cut

sub list {
    my ($self, $c, $parent_id) = @_;
    my %cnd = (test_suite_id => $parent_id);
    my %opt = (order_by => 'map_order');
    $self->base_relation_list( $c, $parent_id, __PACKAGE__, \%cnd, \%opt);
}

=head2 create

called by POST Collection Resource

=cut

sub create {
    my ($self, $c, $parent_id) = @_;
    my %data = (
      test_suite_id => $c->request->parameters->{test_suite_id},
      test_case_id => $c->request->parameters->{test_case_id},
      map_order => $c->request->parameters->{map_order},
    );
    $self->base_relation_create( $c, $parent_id, __PACKAGE__, \%data);
}

=head2 show

called by GET Member Resource

=cut

sub show {
    my ($self, $c, $parent_id, $id) = @_;
    $self->base_relation_show( $c, $parent_id, $id, __PACKAGE__);
}

=head2 update

called by PUT Member Resource

=cut

sub update {
    my ($self, $c, $parent_id, $id) = @_;
    my %data = (
      test_suite_id => $c->request->parameters->{test_suite_id},
      test_case_id => $c->request->parameters->{test_case_id},
      map_order => $c->request->parameters->{map_order},
    );
    $self->base_relation_update( $c, $parent_id, $id, __PACKAGE__, \%data);
}

=head2 destroy

called by DELETE Member Resource

=cut

sub delete {
    my ($self, $c, $parent_id, $id) = @_;
    $self->base_relation_delete( $c, $parent_id, $id, __PACKAGE__);
}

sub destroy {
    my ($self, $c, $parent_id, $id) = @_;
    $self->base_relation_destroy( $c, $parent_id, $id, __PACKAGE__);
}

=head2 post

called by GET form for describing a new Resource

=cut

sub post {
    my ($self, $c, $parent_id) = @_;
    $self->base_relation_post( $c, $parent_id, __PACKAGE__);
}

=head2 edit

called by GET form for describing a Member Resource

=cut

sub edit {
    my ($self, $c, $parent_id, $id) = @_;
    $self->base_relation_edit( $c, $parent_id, $id, __PACKAGE__);
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

