package Siva::Controller::TestCase;

use strict;
use warnings;
use base 'Siva::Controller::Base';

use Data::Page::Navigation;

use Data::Dumper;
use XML::LibXML;
use File::Path qw(make_path remove_tree);
use File::Temp qw(tempdir);
use IO::File;
use Archive::Zip;
use Encode;

use constant CASE1_BASE => 10000;
use constant CASE2_BASE => 20000;
use constant CMND1_BASE => 30000;


=head1 NAME

Siva::Controller::TestCase - Catalyst Collection Resource Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

__PACKAGE__->config(
    collection => {
        import => 'get',
        importdata => 'post',
        searchdata => 'post',
    },
    member => {
        export => 'get',
        convert => 'get',
    }
);


=head2 list

called by GET Collection Resource

=cut

sub list {
    my ($self, $c) = @_;
#    my %cnd = ();
#    my %opt = (order_by => 'name');
#while ( my ($key, $value) = each(%opt) ){
#$c->log->debug("key:$key, value:$value\n");
#}
#    $self->base_list( $c, __PACKAGE__, \%cnd, \%opt);
    $self->base_list( $c, __PACKAGE__);
}

sub searchdata{
    my ($self, $c) = @_;

    my $package = __PACKAGE__;
    my %search_cnd = (
      tags => '%'.$c->request->parameters->{tags}.'%',
      explanation => '%'.$c->request->parameters->{explanation}.'%',
    );
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package);
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my $cname = Siva::Logic::Util->getControllerLCName($package);
    $c->stash->{template} = $cname.'/list.tt2';
#    my %search_cnd = keys(%$cnd) ? %$cnd : ();
#    my %search_opt = keys(%$opt) ? %$opt : ();
    my %search_opt = ();
    $search_opt{page} = $search_opt{page} || $c->req->param('page') || 1;
    $search_opt{rows} = $search_opt{rows} || $c->req->param('rows') || 10;
    $search_opt{order_by} = $search_opt{order_by} || 'id';
    $c->stash->{model} = $c->model($sname)->search_like({%search_cnd}, {%search_opt});
    $c->stash->{search_cnd} = {(
      tags => $c->request->parameters->{tags},
      explanation => $c->request->parameters->{explanation},
    )};

}

=head2 create

called by POST Collection Resource

=cut

sub create {
    my ($self, $c) = @_;
    my %data = (
      name => $c->request->parameters->{name},
      filename => $c->request->parameters->{filename},
      tags => $c->request->parameters->{tags},
      explanation => $c->request->parameters->{explanation},
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

sub export {
    my ($self, $c, $id) = @_;
    my $package = __PACKAGE__;

    # make directory for testcase
    my $tmpdir = tempdir( CLEANUP => 1 );
    $c->log->debug("tempdirname=".$tmpdir);

    my $casedir = $tmpdir.'/case';
    make_path ($casedir, {error => \my $err});
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

    # create testcase file
    my $casefilename = $model->filename || "case.html";
    my $casefile = $casedir."/".$casefilename;
    my $casename = $model->name || "no name";
    
    # make testcase string;
    my $dom = XML::LibXML::Document->new('1.0', 'UTF-8');
    $dom->createInternalSubset("html", "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd");
    my $html = $dom->createElement('html');
    $html->setAttribute("xmlns", "http://www.w3.org/1999/xhtml");
    $html->setAttribute("xml:lang", "en");
    $html->setAttribute("lang", "en");
    my $head = $dom->createElement('head');
    $head->setAttribute("profile", "http://selenium-ide.openqa.org/profiles/test-case");
    my $meta = $dom->createElement('meta');
    $meta->setAttribute("http-equiv", "Content-Type");
    $meta->setAttribute("content", "text/html; charset=UTF-8");
    my $title = $dom->createElement('title');
    $title->appendText($casename);
    $head->appendChild($meta); 
    $head->appendChild($title); 

    my $body = $dom->createElement('body');
    my $table = $dom->createElement('table');
    $table->setAttribute("cellpadding", "1");
    $table->setAttribute("cellspacing", "1");
    $table->setAttribute("border", "1");
    my $thead = $dom->createElement('thead');
    my $tr = $dom->createElement('tr');
    my $td = $dom->createElement('td');
    $td->setAttribute("rowspan", "1");
    $td->setAttribute("colspan", "3");
    $td->appendText($casename);
    $tr->appendChild($td);
    $thead->appendChild($tr);
    my $tbody = $dom->createElement('tbody');
    # add test command.

    my %cond_command = ( 'case_command_maps.test_case_id' => $id );
    my %opt_command = ( 
        join      => ['case_command_maps'],
#        '+select' => ['case_command_maps.test_case_id', 'case_command_maps.map_order'],
        order_by  => 'case_command_maps.map_order'
    );

    my @model_command = $c->model("DBIC::TestCommand")->search({%cond_command}, {%opt_command});

#    foreach my $data ( $model->case_command_maps->all ) {
#    foreach my $data ( $model->case_command_maps ) {
    foreach my $data ( @model_command ) {
      my $tr_b = $dom->createElement('tr');
      my $td_b1 = $dom->createElement('td');
      my $td_b2 = $dom->createElement('td');
      my $td_b3 = $dom->createElement('td');
#      $td_b1->appendText($data->test_command_id->command);
#      $td_b2->appendText($data->test_command_id->target);
#      $td_b3->appendText($data->test_command_id->value);
      $td_b1->appendText($data->command);
      $td_b2->appendText($data->target);
      $td_b3->appendText($data->value);
      $tr_b->appendChild($td_b1);
      $tr_b->appendChild($td_b2);
      $tr_b->appendChild($td_b3);
      $tbody->appendChild($tr_b);
#      $c->log->debug("data=".$data->test_command_id->command);
    }

    $table->appendChild($thead);
    $table->appendChild($tbody);
    $body->appendChild($table);

    $html->appendChild($head);
    $html->appendChild($body);
    $dom->setDocumentElement($html);
#    my $text = encode('utf-8', $dom->toString());
    my $text = $dom->toString();
    $c->log->debug("text=".$text);

    my $fh = new IO::File;
    if($fh->open("> $casefile")) {
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
    my $filename = 'Important ABC.zip';
    $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);

    my $fh2 = new IO::File;
    if($fh2->open("< $zipfile")) {
      $fh2->binmode(); 
      my @list = <$fh2>;
      my $body_text = join('', @list);
#      $c->log->debug("body_text=".$body_text);
      $c->res->body($body_text);
      $fh2->close;
    }

    #delete temp dir
    if( -d $tmpdir ) {
      remove_tree( $tmpdir );
    }
}

=head2 update

called by PUT Member Resource

=cut

sub update {
    my ($self, $c, $id) = @_;
    my %data = (
      name => $c->request->parameters->{name},
      filename => $c->request->parameters->{filename},
      tags => $c->request->parameters->{tags},
      explanation => $c->request->parameters->{explanation},
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

=head2 imort 

called by GET form for describing a Member Resource

=cut

sub import {
    my ($self, $c) = @_;
    my $package = __PACKAGE__;
    $c->stash->{path} = Siva::Logic::Util->getControllerPathName($package);
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
#    $c->stash->{model} = $c->model($sname)->find($id);
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
#    $c->log->debug("nishino-tmp:".$upload->tempname);
    my $parser = XML::LibXML->new();
    $parser->recover_silently(1);
    my $doc = $parser->parse_html_file($upload->tempname);
#    $c->log->debug("nishino-doc:".$doc->toString);

    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my %data = (
      name => $c->request->parameters->{name},
      filename => $upload->filename,
      tags => $c->request->parameters->{tags},
      explanation => $c->request->parameters->{explanation},
    );
    my $model = $c->model($sname)->create({%data});
    my $case_id = $model->id;

    # get node to array
    my $xpath = "//tbody/tr";
    my @nodes = $doc->findnodes( $xpath );
    my $i = 0;
    foreach my $node (@nodes) {
      $i++;
      my %data_command = (
        command      => $node->findvalue( "td[1]" ),
        target       => $node->findvalue( "td[2]" ),
        value        => $node->findvalue( "td[3]" ),
      );
      my $model_command = $c->model("DBIC::TestCommand")->create({%data_command});
      my $command_id = $model_command->id;

      my %data_map = (
        test_case_id    => $case_id,
        test_command_id => $command_id,
        map_order       => $i,
      );
      my $model_map = $c->model("DBIC::CaseCommandMap")->create({%data_map});
      my $map_id = $model_map->id;
    }

    my $path = Siva::Logic::Util->getControllerPathName($package);
    $c->res->redirect($path.'/'.$case_id, 303);
}

sub convert {
    my ($self, $c, $id) = @_;
    my $package = __PACKAGE__;

    # get TestCommand
    my $sname = Siva::Logic::Util->getSchemaClassName($package);
    my $model = $c->model($sname)->find($id);

    my $casename = $model->name;

    my @order_bef = ();
    my %order_hash;
        
    # もし、入力コマンドがあったらTestCommand追加
    my $cnt = 0; 
    foreach my $data ( $model->case_command_maps ) {
      my $base_num;
      if ($data->test_command_id->command =~ /^(type|select|checked)$/) {
#        $c->log->debug("convert=".$data->test_command_id->command);
#        $c->log->debug("convert=".$data->test_command_id->value);
        # もしvalueが既に変数だったら処理しない
#        next if ($data->test_command_id->value =~ /^\$/);
        next if ($data->test_command_id->value =~ /^\$\{\w\.\w\}/);

        my %child_data_new = (
          command => "setCaseValue",
          target  => $casename.'.'.$data->test_command_id->id,
          value   => $data->test_command_id->value
        );
        my $child_model_new = $c->model("DBIC::TestCommand")->create({%child_data_new});
        my $child_id_new = $child_model_new->id;

        $cnt++;
        my $num_new = CASE1_BASE + $cnt;
        push(@order_bef, $num_new);

        # CaseCommandMap追加
        my %map_data_new = (
          test_case_id => $id,
          test_command_id => $child_id_new,
          map_order => $num_new
        );
        my $map_model_new = $c->model("DBIC::CaseCommandMap")->create({%map_data_new});
        my $map_id_new = $map_model_new->id;
        $c->log->debug("num_new=$num_new;map_id_new=$map_id_new");

        # テストコマンドのソート順を並び替え
        # testcase_idで絞り込んだcase_command_mapをmap_order順に取得
        # 仮オーダーのcommand_idハッシュ作成
        #$order_hash{$num_new} = $map_id_new;
        $order_hash{$num_new} = $child_id_new;

        # テストケースのvalueを変数に変換
        my %child_data_cur = (
          value   => '${'.$casename.'.'.$data->test_command_id->id.'}'
        );
        my $child_model_cur = $c->model("DBIC::TestCommand")->find($data->test_command_id->id)->update({%child_data_cur});
        $base_num = CMND1_BASE;
      } elsif ($data->test_command_id->command =~ /^(setCaseValue)$/) {
        $base_num = CASE1_BASE;
      } elsif ($data->test_command_id->command =~ /^(bindValue)$/) {
        $base_num = CASE2_BASE;
      } else {
        $base_num = CMND1_BASE;
      }
      # sort_orderと、command_idの配列作成
      # testcase_idで絞り込んだcase_command_mapをmap_order順に取得
      $cnt++;
      #数字は重複しないようにインクリメント（before は 10000 台、 bind は20000台、 その他は 30000台）
      # command のタイプから、仮のオーダーを設定する。
      my $num_cur = $base_num + $cnt;
      push(@order_bef, $num_cur);
      # 仮オーダーのcommand_idハッシュ作成
      $order_hash{$num_cur} = $data->test_command_id->id;
    }

    # ソートする
    my @order_aft = sort {$a <=> $b} @order_bef;

    # 番号の振り直しを行う
    my %order_hash_aft;
    my $length = @order_aft;
    $c->log->debug("length=".$length);
    for( my $i = 0; $i < $length; $i++) {
      my $iii = $i+1;
      $c->log->debug("i+1=$iii;order_aft[i]=".$order_aft[$i].";" );
      $order_hash_aft{ $order_hash{ $order_aft[$i] } } = ($i + 1);
    }

    # case_command_map のソート順変更
    my $model_sort = $c->model($sname)->find($id);
    my $ii = 0;
    foreach my $data_sort ( $model_sort->case_command_maps ) {
      $c->log->debug("ii=$ii;command_id=".$data_sort->test_command_id->id.";value=".$data_sort->test_command_id->value );
      $c->log->debug("map_order=".$order_hash_aft{ $data_sort->test_command_id->id });
      # テストケースのvalueを変数に変換
      my %child_data_sort = (
        map_order   => $order_hash_aft{ $data_sort->test_command_id->id }
      );
#      my $child_model_sort = $c->model("DBIC::CaseCommandMap")->find($data_sort->id)->update({%child_data_sort});
      my $child_model_sort = $data_sort->update({%child_data_sort});
    }

    my $path = Siva::Logic::Util->getControllerPathName($package);
    $c->res->redirect($path.'/'.$id, 303);
}
=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

