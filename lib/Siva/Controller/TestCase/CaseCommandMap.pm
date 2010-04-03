package Siva::Controller::TestCase::CaseCommandMap;

use strict;
use warnings;
use base 'Siva::Controller::Base';

use Data::Page::Navigation;

__PACKAGE__->config(belongs_to => 'TestCase');

=head1 NAME

Siva::Controller::CaseCommandMap - Catalyst Collection Resource Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

__PACKAGE__->config(
    collection => {
        convert => 'get'
    },
    member => {
    }
);

=head2 list

called by GET Collection Resource

=cut

sub list {
    my ($self, $c, $parent_id) = @_;
    my %cnd = (test_case_id => $parent_id);
    my %opt = (order_by => 'map_order');
    $self->base_relation_list( $c, $parent_id, __PACKAGE__, \%cnd, \%opt);
}

=head2 create

called by POST Collection Resource

=cut

sub create {
    my ($self, $c, $parent_id) = @_;
    my %data = (
      test_case_id => $c->request->parameters->{test_case_id},
      test_command_id => $c->request->parameters->{test_command_id},
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
      test_case_id => $c->request->parameters->{test_case_id},
      test_command_id => $c->request->parameters->{test_command_id},
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

sub convert {
    my ($self, $c, $parent_id) = @_;
    my $package = __PACKAGE__;
    # get TestCommand
    my $model = $c->model("DBIC::TestCase")->find($parent_id);
    # もし、入力コマンドがあったらTestCommand追加
    foreach my $data ( $model->case_command_maps ) {
      if ($data->test_command_id->command =~ /^(type|select|checked)$/) {
        $c->log->debug("convert=".$data->test_command_id->command);
        $c->log->debug("convert=".$data->test_command_id->value);
        # もしvalueが既に変数だったら処理しない
        next if ($data->test_command_id->value =~ /^\$/);
        my %child_data = (
          command => "glovalStore",
          target  => "i_testcase_id_".$data->test_command_id->id,
          value   => $data->test_command_id->value
        );
        my $child_model = $c->model("DBIC::TestCommand")->create({%child_data});
        my $child_id = $child_model->id;
        # CaseCommandMap追加
        my %map_data = (
          test_case_id => $parent_id,
          test_command_id => $child_id,
          map_order => 1
        );
        my $map_model = $c->model("DBIC::CaseCommandMap")->create({%map_data});
        my $map_id = $map_model->id;

        # テストケースのvalueを変数に変換
        my %child_data2 = (
          value   => "\$i_testcase_id_".$data->test_command_id->id
        );
        my $child_model2 = $c->model("DBIC::TestCommand")->find($data->test_command_id->id)->update({%child_data2});


        # テストコマンドのソート順を並び替え
      }
    }
    my $path = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    $c->res->redirect($path, 303);
}
=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

