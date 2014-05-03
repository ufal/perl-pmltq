package PMLTQ::Relation::OrderIterator;

use 5.006;
use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use constant SOURCE_ORD_ATTR => PMLTQ::Relation::SimpleListIterator::FIRST_FREE;
use constant TARGET_ORD_ATTR => PMLTQ::Relation::SimpleListIterator::FIRST_FREE+1;
use constant DIR => PMLTQ::Relation::SimpleListIterator::FIRST_FREE+2;
use constant MIN => PMLTQ::Relation::SimpleListIterator::FIRST_FREE+3;
use constant MAX => PMLTQ::Relation::SimpleListIterator::FIRST_FREE+4;
use constant SPAN_INIT => PMLTQ::Relation::SimpleListIterator::FIRST_FREE+5;
use Carp;

=head1 NAME

PMLTQ::Relation::OrderIterator 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS

=cut

  sub new {
    my ($class,$conditions,$s_ord_attr,$t_ord_attr,$dir,$min,$max,$span_init)=@_;
    croak "usage: $class->new(sub{...},\$source_ord_attr,\$target_ord_attr)"
      unless (ref($conditions) eq 'CODE' and defined($s_ord_attr) and defined($t_ord_attr));
    my $self = PMLTQ::Relation::SimpleListIterator->new($conditions);
    $self->[SOURCE_ORD_ATTR]=$s_ord_attr;
    $self->[TARGET_ORD_ATTR]=$t_ord_attr;
    $self->[DIR]=$dir; # dir should be 1 or -1
    $self->[MIN]=$min if defined($min) and length($min);
    $self->[MAX]=$max if defined($max) and length($max);
    $self->[SPAN_INIT]=$span_init if defined($span_init) and ref($span_init);
    bless $self, $class; # reblessing
    return $self;
  }
  sub clone {
    my ($self)=@_;
    my $clone = $self->PMLTQ::Relation::SimpleListIterator::clone();
    $clone->[SOURCE_ORD_ATTR]=$self->[SOURCE_ORD_ATTR];
    $clone->[TARGET_ORD_ATTR]=$self->[TARGET_ORD_ATTR];
    $clone->[DIR]=$self->[DIR];
    $clone->[MIN]=$self->[MIN];
    $clone->[MAX]=$self->[MAX];
    $clone->[SPAN_INIT]=$self->[SPAN_INIT];
    return $clone;
  }
  sub get_node_list  {
    my ($self,$node)=@_;
    my $fsfile = $self->[PMLTQ::Relation::SimpleListIterator::FILE];
    my $dir = $self->[DIR];
    my $s_ord_attr = $self->[SOURCE_ORD_ATTR];
    my $t_ord_attr = $self->[TARGET_ORD_ATTR];
    my $min = $self->[MIN];
    my $max = $self->[MAX];
    $min = 0 if !defined($min);
    my $root = $node->root;
    if ((!$s_ord_attr or !$t_ord_attr) and $self->[SPAN_INIT]) {
      $self->[SPAN_INIT]->($root)
    }
    my $s_ord = $s_ord_attr ?
      $node->{$s_ord_attr} :
      $self->[SPAN_INIT]->($node)->[ ($dir>0) ? 0 : 1 ];
    return [] unless defined $s_ord;
    return [map [$_,$fsfile],
            grep {
              my $t_ord = $t_ord_attr ? $_->{$t_ord_attr} : $self->[SPAN_INIT]->($_)->[ ($dir>0) ? 1 : 0 ];
              if (defined $t_ord) {
                my $dist = $dir*($s_ord - $t_ord);
                $_!=$node and (!defined($min) or $dist>=$min) and (!defined($max) or $dist<=$max)
              }
            }
            $root->descendants];
  }

=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::OrderIterator


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PMLTQ-PML2BASE>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PMLTQ-PML2BASE>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PMLTQ-PML2BASE>

=item * Search CPAN

L<http://search.cpan.org/dist/PMLTQ-PML2BASE/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 AUTHOR.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of PMLTQ::Relation::OrderIterator
