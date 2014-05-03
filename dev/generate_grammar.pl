#!/usr/bin/env perl
use strict;
use warnings;
use Parse::RecDescent 1.967009;
my $grammar;
open my $IN, '<', 'tree_query_grammar.txt';
{
    local $/ = undef;
    $grammar = <$IN>;
}
Parse::RecDescent->Precompile(
    { -standalone => 1, }
    , $grammar
    , "PMLTQ::Grammar"
);

