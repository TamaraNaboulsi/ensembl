#!/bin/bash

ENSDIR="${ENSDIR:-$PWD}"

export PERL5LIB=$ENSDIR/bioperl-live:$ENSDIR/ensembl-test/modules:$PWD/modules:$ENSDIR/ensembl-io/modules:$ENSDIR/ensembl-variation/modules:$ENSDIR/ensembl-compara/modules:$PWD/misc-scripts/xref_mapping
export TEST_AUTHOR=$USER

if [ "$DB" = 'mysql' ]; then
    (cd modules/t && ln -sf MultiTestDB.conf.mysql MultiTestDB.conf)
    ln -sf testdb.conf.mysql testdb.conf
    SKIP_TESTS="--skip gene.t"
#     SKIP_TESTS="--skip MultiTestDB.t,altAlleleGroup.t,analysis.t,archiveStableId.t,argument.t,assemblyException.t,assemblyExceptionFeature.t,assemblyMapper.t,associated_xref.t,attribute.t,attributeAdaptor.t,baseAdaptor.t,baseAlignFeature.t,biotype.t,canonicalDBAdaptor.t,cds.t,chainedAssemblyMapper.t,circularSlice.t,cliHelper.t,compara.t,coordSystem.t,coordSystemAdaptor.t,dataFile.t,dbConnection.t,dbEntries.t,densityFeature.t,densityFeatureAdaptor.t,densityType.t,densityTypeAdaptor.t,dependencies.t,ditag.t,ditagAdaptor.t,ditagFeature.t,ditagFeatureAdaptor.t,dnaAlignFeatureAdaptor.t,dnaDnaAlignFeature.t,dnaPepAlignFeature.t,easyargv.t,exception.t,exon.t,exonTranscript.pm,externalFeatureAdaptor.t,fastaSequenceAdaptor.t,feature.t,featurePair.t,fullIdCaching.t,geneview.t,genomeContainer.t,getNearestFeature.t,housekeeping_apache2.t,housekeeping_perlCritic.t,interval_tree_immutable.t,interval_tree_mutable.t,intron.t,intronSupportingEvidence.t,iterator.t,karyotypeBand.t,karyotypeBandAdaptor.t,lruIdCaching.t,mapLocation.t,mappedSliceContainer.t,mapper.t,marker.t,markerAdaptor.t,markerFeature.t,markerFeatureAdaptor.t,markerSynonym.t,metaContainer.t,metaCoordContainer.t,miscFeature.t,miscFeatureAdaptor.t,miscSet.t,miscSetAdaptor.t,objectLoad.t,ontologyTerm.t,operon.t,operon_fetch.t,operon_transcript.t,paddedSlice.t,predictionTranscript.t,proteinAlignFeatureAdaptor.t,proteinFeature.t,proteinFeatureAdaptor.t,rangeRegistry.t,registry.t,registry_public_cores.t,regression_baseFeatureAdaptorMultiQuery.t,regression_featureAdaptorCache.t,regression_multiMappingContig.t,regression_transcriptProjectionAttributeDuplication.t,repeatConsensus.t,repeatConsensusAdaptor.t,repeatFeature.t,repeatFeatureAdaptor.t,repeatMaskedSlice.t,rnaProduct.t,schema.t,schemaPatches.t,seqDumper.t,seqEdit.t,sequenceAdaptor.t,simpleFeature.t,slice.t,sliceAdaptor.t,sliceVariation.t,sqlHelper.t,strainSlice.t,subSliceFeature.t,switchableAdaptors.t,topLevelAssemblyMapper.t,transcript.t,transcriptSelector.t,transcriptSupportingFeatureAdaptor.t,translation.t,unmappedObject.t,unmappedObjectAdaptor.t,utilsIo.t,utilsNet.t,utilsScalar.t,utilsUri.t,utr.t,xref_parser.t,xrefs.t"
elif [ "$DB" = 'sqlite' ]; then
    (cd modules/t && ln -sf MultiTestDB.conf.SQLite MultiTestDB.conf)
    ln -sf testdb.conf.SQLite testdb.conf
    SKIP_TESTS="--skip dbConnection.t,schema.t,schemaPatches.t,strainSlice.t,sliceVariation.t,mappedSliceContainer.t"
else
    echo "Don't know about DB '$DB'"
    exit 1;
fi
ln -sf ../../../modules/t/MultiTestDB.conf misc-scripts/xref_mapping/t/

echo "Running test suite"
rt=0
if [ "$COVERALLS" = 'true' ]; then
  PERL5OPT='-MDevel::Cover=+ignore,bioperl,+ignore,ensembl-test,+ignore,ensembl-variation,ensembl-compara' perl $ENSDIR/ensembl-test/scripts/runtests.pl --verbose modules/t $SKIP_TESTS
  rt=$?
  if [ "$DB" = 'mysql' ]; then
    PERL5OPT='-MDevel::Cover=+ignore,bioperl,+ignore,ensembl-test,+ignore,ensembl-variation,ensembl-compara' perl $ENSDIR/ensembl-test/scripts/runtests.pl --verbose misc-scripts/xref_mapping/t
    rt=$(($rt+$?))
  fi
else
  perl $ENSDIR/ensembl-test/scripts/runtests.pl --verbose modules/t $SKIP_TESTS
  rt=$?
  if [ "$DB" = 'mysql' ]; then
    perl $ENSDIR/ensembl-test/scripts/runtests.pl --verbose misc-scripts/xref_mapping/t
    rt=$(($rt+$?))
  fi
fi

if [ $rt -eq 0 ]; then
  if [ "$COVERALLS" = 'true' ]; then
    echo "Running Devel::Cover coveralls report"
    cover --nosummary -report coveralls
  fi
  exit $?
else
  exit 255
fi
