package Siva::Controller::Base;

use strict;
use warnings;
use base 'Catalyst::Controller::Resources';

use Data::Page::Navigation;

=head1 NAME

Siva::Controller::Base - Catalyst Collection Resource Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 base_list

called by GET Collection Resource

=cut

sub base_list {
    my ($self, $c, $package, $cnd, $opt) = @_;
    &base_relation_list($self, $c, undef, $package, $cnd, $opt);
}

sub base_relation_list {
    my ($self, $c, $parent_id, $package, $cnd, $opt) = @_;
    $c->stash->{parent_id} = $parent_id;
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    $c->stash->{template} = $cname.'/list.tt2';
    my %search_cnd = keys(%$cnd) ? %$cnd : ();
    my %search_opt = keys(%$opt) ? %$opt : ();
    $search_opt{page} = $search_opt{page} || $c->req->param('page') || 1;
    $search_opt{rows} = $search_opt{rows} || $c->req->param('rows') || 10;
    $search_opt{order_by} = $search_opt{order_by} || 'id';
    $c->stash->{model} = $c->model($sname)->search({%search_cnd}, {%search_opt});
}

=head2 base_create

called by POST Collection Resource

=cut

sub base_create {
    my ($self, $c, $package, $data) = @_;
    &base_relation_create($self, $c, undef, $package, $data);
}

sub base_relation_create {
    my ($self, $c, $parent_id, $package, $data) = @_;
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    my $path = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    my %model_data = keys(%$data) ? %$data : ();
    my $model = $c->model($sname)->create({%model_data});
    $c->res->redirect($path.'/'.$model->id, 303);
}

=head2 base_show

called by GET Member Resource

=cut

sub base_show {
    my ($self, $c, $id, $package) = @_;
    &base_relation_show($self, $c, undef, $id, $package);
}

sub base_relation_show {
    my ($self, $c, $parent_id, $id, $package) = @_;
    $c->stash->{parent_id} = $parent_id;
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    $c->stash->{model} = $c->model($sname)->find($id);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    $c->stash->{template} = $cname.'/show.tt2';
}

=head2 base_update

called by PUT Member Resource

=cut

sub base_update {
    my ($self, $c, $id, $package, $data) = @_;
    &base_relation_update($self, $c, undef, $id, $package, $data);
}

sub base_relation_update {
    my ($self, $c, $parent_id, $id, $package, $data) = @_;
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    my %model_data = keys(%$data) ? %$data : ();
    $c->model($sname)->find($id)->update({%model_data});
    $c->stash->{model} = $c->model($sname)->find($id);
    my $path = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    $c->res->redirect($path.'/'.$id, 303);
}

=head2 base_destroy

called by DELETE Member Resource

=cut

sub base_delete {
    my ($self, $c, $id, $package) = @_;
    &base_relation_delete($self, $c, undef, $id, $package);
}

sub base_relation_delete {
    my ($self, $c, $parent_id, $id, $package) = @_;
    $c->stash->{parent_id} = $parent_id;
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    $c->stash->{model} = $c->model($sname)->find($id);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    $c->stash->{template} = $cname.'/show.tt2';
}

sub base_destroy {
    my ($self, $c, $id, $package) = @_;
    &base_relation_destroy($self, $c, undef, $id, $package);
}

sub base_relation_destroy {
    my ($self, $c, $parent_id, $id, $package) = @_;
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    $c->model($sname)->find($id)->delete;
    my $path = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    $c->res->redirect($path, 303);
}

=head2 post

called by GET form for describing a new Resource

=cut

sub base_post {
    my ($self, $c, $package) = @_;
    &base_relation_post($self, $c, undef, $package);
}

sub base_relation_post {
    my ($self, $c, $parent_id, $package) = @_;
    $c->stash->{parent_id} = $parent_id;
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    $c->stash->{template} = $cname.'/post.tt2';
}

=head2 edit

called by GET form for describing a Member Resource

=cut

sub base_edit {
    my ($self, $c, $id, $package) = @_;
    &base_relation_edit($self, $c, undef, $id, $package);
}

sub base_relation_edit {
    my ($self, $c, $parent_id, $id, $package) = @_;
    $c->stash->{parent_id} = $parent_id;
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package, $parent_id);
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    $c->stash->{model} = $c->model($sname)->find($id);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    $c->stash->{template} = $cname.'/edit.tt2';
}

sub base_export {
    my ($self, $c, $id, $package) = @_;

    # make directory for testcase
    my $tmpdir = tempdir( CLEANUP => 1 );
    $c->log->debug("tempdirname=".$tmpdir);

    my $parentdir = $tmpdir.'/suite';
    make_path ($parentdir, {error => \my $err});
    if (@$err) {
      for my $diag (@$err) {
        my ($file, $message) = %$diag;
        if ($file eq '') {
          $c->log->debug("general error: $message");
        } else {
          $c->log->debug("problem unlinking $file: $message");
        }
      }
    } else {
      $c->log->debug("No error encountered");
    }

    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my $model = $c->model($sname)->find($id);

    # create testsuite file
    my $parentfilename = $model->filename || "suite.html";
    my $parentfile = $parentdir."/".$parentfilename;

    my $dom = &makeDom($self, $c, $id, $model);
    my $text = $dom->toString();

    my $fh = new IO::File;
    if($fh->open("> $parentfile")) {
      $fh->binmode(); 
      print $fh $text;
      $fh->close;
    }

    # create zip
    my $zip = Archive::Zip->new();
    $zip->addTree( $tmpdir );
    my $zipfile = $tmpdir.'/temp.zip';
    $zip->writeToFileNamed($zipfile);

    $c->res->content_type('application/octet-stream');
    my $filename = 'Download suite.zip';
    $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);

    my $fh2 = new IO::File;
    if($fh2->open("< $zipfile")) {
      $fh2->binmode(); 
      my @list = <$fh2>;
      my $body_text = join('', @list);
      $c->res->body($body_text);
      $fh2->close;
    }

    #delete temp dir
    if( -d $tmpdir ) {
      remove_tree( $tmpdir );
    }
}

sub makeDom {
    my ($self, $c, $parent_id, $id, $model) = @_;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

