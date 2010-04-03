package Siva::Schema::Result::TestCommand;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("test_command");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('test_command_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "command",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "target",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "value",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("test_command_pkey", ["id"]);
__PACKAGE__->has_many(
  "case_command_maps",
  "Siva::Schema::Result::CaseCommandMap",
  { "foreign.test_command_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-03-07 11:33:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yD1kixya2d2Y388Eij0WnA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
