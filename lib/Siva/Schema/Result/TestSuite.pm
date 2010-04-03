package Siva::Schema::Result::TestSuite;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("test_suite");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('test_suite_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "filename",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "tags",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "explanation",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("test_suite_pkey", ["id"]);
__PACKAGE__->has_many(
  "suite_case_maps",
  "Siva::Schema::Result::SuiteCaseMap",
  { "foreign.test_suite_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-03-07 11:33:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JgjXOJeFGPsRXaJkM7C9WA

#__PACKAGE__->many_to_many( test_case => 'suite_case_maps', 'test_case_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
