## Bioperl Test Harness Script for Modules
##
# CVS Version
# $Id$


# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

#-----------------------------------------------------------------------
## perl test harness expects the following output syntax only!
## 1..3
## ok 1  [not ok 1 (if test fails)]
## 2..3
## ok 2  [not ok 2 (if test fails)]
## 3..3
## ok 3  [not ok 3 (if test fails)]
##
## etc. etc. etc. (continue on for each tested function in the .t file)
#-----------------------------------------------------------------------


## We start with some black magic to print on failure.
BEGIN { $| = 1; print "1..7\n"; 
	use vars qw($loaded); }
END {print "not ok 1\n" unless $loaded;}


use Bio::EnsEMBL::DBLoader;
use Bio::SeqIO;

use lib 't';
use EnsTestDB;
$loaded = 1;
print "ok 1\n";    # 1st test passes.
    
my $ens_test = EnsTestDB->new();
    
# Load some data into the db
$ens_test->do_sql_file("t/db.dump");
    
# Get an EnsEMBL db object for the test db
my $db = $ens_test->get_DBSQL_Obj;
print "ok 2\n";    

# $db->contig_overlap_source(\&ret_one);


@cloneids =  $db->get_all_Clone_id();
my $clone  = $db->get_Clone($cloneids[0]);

# check clone stuff.
$discard = $clone->htg_phase();
$discard = $clone->embl_id();
$discard = $clone->version();
$discard = $clone->embl_version();
$vc = $clone->virtualcontig();
$vc = undef;
print "ok 3\n";




my @contigs = $clone->get_all_Contigs();
my $contig = $db->get_Contig($contigs[0]->id);
print "ok 4\n";

@repeats = $contig->get_all_RepeatFeatures();
@repeats = ();
print "ok 5\n";

@simil   = $contig->get_all_SimilarityFeatures();
@simil = ();
print "ok 6\n";

foreach $gene ( $clone->get_all_Genes() ) {
    if( ! $gene->isa("Bio::EnsEMBL::Gene") ) {
      print "not ok 7\n";
      exit(1);
    }
}

print "ok 7\n";

$seqout = Bio::SeqIO->new( -Format => 'embl',-file => ">t/DB.embl" );
$seqout->write_seq($contig);

eval {
    $contig = $db->get_Contig('AC021078.00017');
};



sub ret_one {
    return 1;
}
    





