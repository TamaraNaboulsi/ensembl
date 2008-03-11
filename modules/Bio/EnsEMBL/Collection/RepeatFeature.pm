# $Id$

package Bio::EnsEMBL::Collection::RepeatFeature;

use strict;
use warnings;

use Bio::EnsEMBL::Utils::Argument  ('rearrange');
use Bio::EnsEMBL::Utils::Exception ('throw');

use base( 'Bio::EnsEMBL::Collection',
          'Bio::EnsEMBL::DBSQL::RepeatFeatureAdaptor' );

sub _create_feature {
  my ( $this, $feature_type, $args ) = @_;

  my $feature = $this->SUPER::_create_feature( $feature_type, $args );

  if ( !$this->_lightweight() ) {
    my ( $hstart, $hend, $score, $repeat_consensus, $analysis ) =
      rearrange( [ 'HSTART', 'HEND',
                   'SCORE',  'REPEAT_CONSENSUS',
                   'ANALYSIS'
                 ],
                 @{$args} );

    push( @{$feature},
          $hstart, $hend, $score, $repeat_consensus->dbID(),
          $analysis->dbID() );
  }

  return $feature;
}

sub _create_feature_fast {
  my ( $this, $feature_type, $args ) = @_;

  my $feature =
    $this->SUPER::_create_feature_fast( $feature_type, $args );

  if ( !$this->_lightweight() ) {
    push( @{$feature},
          $args->{'hstart'}, $args->{'hend'}, $args->{'score'},
          $args->{'repeat_consensus'}->dbID(),
          $args->{'analysis'}->dbID() );
  }

  return $feature;
}

sub _tables {
  my ($this) = @_;

  my @tables = $this->SUPER::_tables();

  if ( $this->_lightweight() ) {
    return ( $tables[0] );
  }

  return @tables;
}

sub _columns {
  my ($this) = @_;

  my @columns = $this->SUPER::_columns();

  if ( $this->_lightweight() ) {
    @columns[ 5 .. $#columns ] = map( 1, 5 .. $#columns );
  }

  return @columns;
}

sub _default_where_clause {
  my ($this) = @_;

  if ( $this->_lightweight() ) {
    return '';
  }

  return $this->SUPER::_default_where_clause();
}

1;
