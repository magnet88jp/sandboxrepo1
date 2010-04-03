package Siva::Controller::TestSuite;

use strict;
use warnings;
use base 'Siva::Controller::Base';

use Data::Page::Navigation;
use XML::LibXML;
use File::Path qw(make_path remove_tree);
use File::Temp qw(tempdir);
use IO::File;
use Archive::Zip;


=head1 NAME

Siva::Controller::TestSuite - Catalyst Collection Resource Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

__PACKAGE__->config(
    collection => {
        import => 'get',
        importdata => 'post',
        search => 'post',
    },
    member => {
        export => 'get',
    }
);

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
    my %data = (name => $c->request->parameters->{name});
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
    my %data = (name => $c->request->parameters->{name});
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

sub import {
    my ($self, $c) = @_;
    my $package = __PACKAGE__;
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    $c->stash->{template} = $cname.'/import.tt2';
}

sub importdata {
    my ($self, $c) = @_;
    my $package = __PACKAGE__;

    my $upload;
    unless ($upload = $c->req->upload('filename') ) {
      $c->detach('index');
    }
    my $parser = XML::LibXML->new();
    $parser->recover_silently(1);
    my $doc = $parser->parse_html_file($upload->tempname);

    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my %data = (
      name => $c->request->parameters->{name},
      filename => $upload->filename,
      tags => $c->request->parameters->{tags},
      explanation => $c->request->parameters->{explanation},
    );
    my $model = $c->model($sname)->create({%data});
    my $parent_id = $model->id;

    # get node to array
    my $xpath = '//table[@id="suiteTable"]/tbody/tr/td';
    my @nodes = $doc->findnodes( $xpath );
    my $i = 0;
    foreach my $node (@nodes) {
      my @a_node = $node->findnodes('a');
      if(@a_node) {
        $i++;
        my %data_child = (
          name        => $node->findvalue('a'),
          filename    => $a_node[0]->findvalue('@href'),
          tags        => '',
          explanation => '',
        );
        my $model_child = $c->model("DBIC::TestCase")->create({%data_child});
        my $child_id = $model_child->id;

        my %data_map = (
          test_suite_id   => $parent_id,
          test_case_id    => $child_id,
          map_order       => $i,
        );
        $c->model("DBIC::SuiteCaseMap")->create({%data_map});
      }
    }
    my $path = Siva::Logic::Util->getControllerPathName($package);
    $c->res->redirect($path.'/'.$parent_id, 303);
}

sub export {
    my ($self, $c, $id) = @_;
    my $package = __PACKAGE__;

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
          }
          else {
              $c->log->debug("problem unlinking $file: $message");
          }
      }
    }
    else {
      $c->log->debug("No error encountered");
    }

    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my $model = $c->model($sname)->find($id);

    # create testsuite file
    my $parentfilename = $model->filename || "suite.html";
    my $parentfile = $parentdir."/".$parentfilename;
    my $parentname = $model->name || "no name";
    
    # make testsuite string;
    my $dom = XML::LibXML::Document->new('1.0', 'UTF-8');
    $dom->createInternalSubset("html", "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd");
    my $html = $dom->createElement('html');
    $html->setAttribute("xmlns", "http://www.w3.org/1999/xhtml");
    $html->setAttribute("xml:lang", "en");
    $html->setAttribute("lang", "en");
    my $head = $dom->createElement('head');
    my $meta = $dom->createElement('meta');
    $meta->setAttribute("http-equiv", "Content-Type");
    $meta->setAttribute("content", "text/html; charset=UTF-8");
    my $title = $dom->createElement('title');
    $title->appendText($parentname);
    $head->appendChild($meta); 
    $head->appendChild($title); 

    my $body = $dom->createElement('body');
    my $table = $dom->createElement('table');
    $table->setAttribute("id", "suiteTable");
    $table->setAttribute("cellpadding", "1");
    $table->setAttribute("cellspacing", "1");
    $table->setAttribute("border", "1");
    $table->setAttribute("class", "selenium");

    my $tbody = $dom->createElement('tbody');
    my $tr = $dom->createElement('tr');
    my $td = $dom->createElement('td');
    my $b = $dom->createElement('b');
    $b->appendText("Test Suite");
    $td->appendChild($b);
    $tr->appendChild($td);
    $tbody->appendChild($tr);

    # add test command.

    foreach my $data ( $model->suite_case_maps ) {
      my $tr_b = $dom->createElement('tr');
      my $td_b1 = $dom->createElement('td');
      my $a = $dom->createElement('a');
      $a->setAttribute("href", $data->test_case_id->filename);
      $a->appendText($data->test_case_id->name);
      $td_b1->appendChild($a);
      $tr_b->appendChild($td_b1);
      $tbody->appendChild($tr_b);
    }

    $table->appendChild($tbody);
    $body->appendChild($table);

    $html->appendChild($head);
    $html->appendChild($body);
    $dom->setDocumentElement($html);
    my $text = $dom->toString();
    $c->log->debug("text=".$text);

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
    my ($self, $c, $id, $model) = @_;

    # create testsuite file
    my $parentname = $model->name || "no name";

    # make testsuite string;
    my $dom = XML::LibXML::Document->new('1.0', 'UTF-8');
    $dom->createInternalSubset("html", "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd");
    my $html = $dom->createElement('html');
    $html->setAttribute("xmlns", "http://www.w3.org/1999/xhtml");
    $html->setAttribute("xml:lang", "en");
    $html->setAttribute("lang", "en");
    my $head = $dom->createElement('head');
    my $meta = $dom->createElement('meta');
    $meta->setAttribute("http-equiv", "Content-Type");
    $meta->setAttribute("content", "text/html; charset=UTF-8");
    my $title = $dom->createElement('title');
    $title->appendText($parentname);
    $head->appendChild($meta); 
    $head->appendChild($title); 

    my $body = $dom->createElement('body');
    my $table = $dom->createElement('table');
    $table->setAttribute("id", "suiteTable");
    $table->setAttribute("cellpadding", "1");
    $table->setAttribute("cellspacing", "1");
    $table->setAttribute("border", "1");
    $table->setAttribute("class", "selenium");

    my $tbody = $dom->createElement('tbody');
    my $tr = $dom->createElement('tr');
    my $td = $dom->createElement('td');
    my $b = $dom->createElement('b');
    $b->appendText("Test Suite");
    $td->appendChild($b);
    $tr->appendChild($td);
    $tbody->appendChild($tr);

    # add test command.

    foreach my $data ( $model->suite_case_maps ) {
      my $tr_b = $dom->createElement('tr');
      my $td_b1 = $dom->createElement('td');
      my $a = $dom->createElement('a');
      $a->setAttribute("href", $data->test_case_id->filename);
      $a->appendText($data->test_case_id->name);
      $td_b1->appendChild($a);
      $tr_b->appendChild($td_b1);
      $tbody->appendChild($tr_b);
    }

    $table->appendChild($tbody);
    $body->appendChild($table);

    $html->appendChild($head);
    $html->appendChild($body);
    $dom->setDocumentElement($html);

    return $dom;
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

