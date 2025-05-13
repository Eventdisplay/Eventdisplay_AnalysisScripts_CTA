#!/bin/sh
#
# simple script to step through different TMVA training options
#
# can be used with the run scripts
#     analysis/CTA.DISPTRAINING.sub_analyse.sh
#     will step through all parameter lines
#

# NTrees=2000:BoostType=Grad:IgnoreNegWeightsInTraining:Shrinkage=0.1:UseBaggedBoost:GradBaggingFraction=0.5:nCuts=20:MaxDepth=6:PruneMethod=ExpectedError
# NTrees=200:MaxDepth=10:Shrinkage=0.1:NegWeightTreatment=IgnoreNegWeightsInTraining:SkipNormalization=False:VarTransform=N

# DEFAULT Options
echo "NTrees=200:MaxDepth=10:Shrinkage=0.1:NegWeightTreatment=IgnoreNegWeightsInTraining:SkipNormalization=False:VarTransform=N"
# Minimal Options
echo "NTrees=200"

BOOST1="BoostType=Grad:Shrinkage=0.1:UseBaggedBoost:GradBaggingFraction=0.5"
BOOST2="BoostType=Grad:Shrinkage=1.0:UseBaggedBoost:GradBaggingFraction=0.5"
BOOST3="BoostType=AdaBoostR2:AdaBoostR2Loss=Linear"
BOOST4="BoostType=AdaBoostR2:AdaBoostR2Loss=Quadratic"
BOOST5="BoostType=AdaBoostR2:AdaBoostR2Loss=Exponential"

PRUNEMETHOD1="PruneMethod=ExpectedError"
PRUNEMETHOD2="PruneMethod=NoPruning"

REGLOSSFUNCTION1="RegressionLossFunctionBDTG=Huber"
REGLOSSFUNCTION2="RegressionLossFunctionBDTG=AbsoluteDeviation"
REGLOSSFUNCTION3="RegressionLossFunctionBDTG=LeastSquares"

MINNODE1="MinNodeSize=0.02"
MINNODE2="MinNodeSize=0.002"

VARTRANS1="VarTransform=I"
VARTRANS2="VarTransform=N"
VARTRANS3="VarTransform=D"

# depth
for D in 4 10
do
   # number of trees
   for T in 200
   do
      for B in $BOOST1 $BOOST2 $BOOST3 $BOOST4 $BOOST5
      do
         for P in $PRUNEMETHOD1 $PRUNEMETHOD2
         do
             for R in $REGLOSSFUNCTION1 $REGLOSSFUNCTION2 $REGLOSSFUNCTION3
             do
                for M in $MINNODE1 $MINNODE2
                do
                   for V in $VARTRANS1 $VARTRANS2 $VARTRANS3
                   do
                       MVA="NTrees=$T:$B:nCuts=20:MaxDepth=$D:$P:$R:$M:$V"
                       echo $MVA
                   done
                done
             done
         done
      done
   done
done
