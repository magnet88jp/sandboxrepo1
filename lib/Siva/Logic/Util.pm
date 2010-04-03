package Siva::Logic::Util;

sub getSchemaClassName {
    my ($self, $pname) = @_;

    #replace from "Siva::Controller::ClassName" to "DBIC::ClassName"
    #$pname =~ s/Siva::Controller/DBIC/;
    my @aname = split(/::/, $pname);
    my $cname = "DBIC::".$aname[$#aname];

    return $cname;
}

sub getControllerLCName {
    my ($self, $pname) = @_;

    #make string from "Siva::Controller::ClassName" to "classname"
    $pname =~ s/Siva::Controller:://;
    $pname =~ s/::/\//;
    #my @aname = split(/::/, $pname);
    #my $cname = lc($aname[$#aname]);
    my $cname = lc($pname);

    return $cname;
}

sub getControllerPathName {
    my ($self, $pname, $parent_id) = @_;

    $pname =~ s/Siva::Controller:://;
    my $cname;
    my @aname = split(/::/, $pname);
    if($parent_id) {
      $cname = lc('/'.$aname[0].'/'.$parent_id.'/'.$aname[1]);
    } else {
      $cname = lc('/'.$aname[$#aname]);
    } 

    return $cname;
}

1;
