package Siva::Schema::Result::CaseCommandMap;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("case_command_map");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('case_command_map_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "test_case_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "test_command_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "map_order",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("case_command_map_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "test_case_id",
  "Siva::Schema::Result::TestCase",
  { id => "test_case_id" },
);
__PACKAGE__->belongs_to(
  "test_command_id",
  "Siva::Schema::Result::TestCommand",
  { id => "test_command_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-03-07 11:33:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fIXdYQQk4D6/e28LnbJKvg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
