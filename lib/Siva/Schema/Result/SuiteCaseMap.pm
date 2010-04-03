package Siva::Schema::Result::SuiteCaseMap;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("suite_case_map");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('suite_case_map_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "test_suite_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "test_case_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "map_order",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("suite_case_map_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "test_suite_id",
  "Siva::Schema::Result::TestSuite",
  { id => "test_suite_id" },
);
__PACKAGE__->belongs_to(
  "test_case_id",
  "Siva::Schema::Result::TestCase",
  { id => "test_case_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-03-07 11:33:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IaDuekMFvUp3Wx0CzLdQ0A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
