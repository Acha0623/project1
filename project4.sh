########## Linux ##########
cd /home/personal/groupdirs/SCIENCE-BIO-popgen_course-project/Gorilla/data

mkdir allsample   
cd GorgorStudent
## change Family ID as subspecies name, and rename other files
awk '{$1 = substr($1,1,3);print $0}' GorgorWholeGen.ped > GorgorWholeGenFID.ped
cp GorgorWholeGen.map > GorgorWholeGenFID.map
cp GorgorWholeGen.log > GorgorWholeGenFID.log
plink --file GorgorWholeGenFID --make-bed --out GorgorWholeGenFID 
## filter data, for 45 samples including human
plink --bfile GorgorWholeGenFID  --hwe .001 --geno 0.02 --thin 0.05 --maf 0.15 --make-bed --out ../allsample/allsample.clean
nano GorillaID.txt  ## create a file including family ID and sample ID of all samples
## filter data, for 44 gorilla samples
plink --bfile GorgorWholeGenFID --noweb --keep GorillaID.txt --hwe .001 --geno 0.02 --thin 0.05 --maf 0.15 --make-bed --out ../allsample/Gsample.clean

cd ../allsample
mkdir PCA admixture Heter Ne LD_21 treemix FST Inbreeding

###PCA###
cd PCA
##separate west and east Gorilla
nano western_pop.txt  ## create a file including all western samples
nano eastern_pop.txt  ## create a file including all eastern samples
## remove all pairs in LD with an R2 correlation coefficient of 0.5 or greater
plink --bfile ../Gsample.clean --noweb --keep western_pop.txt --indep-pairwise 50 10 0.5 --recode --out west
plink --bfile ../Gsample.clean --noweb --keep western_pop.txt --extract west.prune.in --make-bed --out westpurned.clean
plink --bfile ../Gsample.clean --noweb --keep eastern_pop.txt --indep-pairwise 50 10 0.5 --recode --out east
plink --bfile ../Gsample.clean --noweb --keep eastern_pop.txt --extract east.prune.in --make-bed --out eastpurned.clean
plink --bfile ../Gsample.clean  --pca 10 --out Gsample.pca10
plink --bfile eastpurned.clean  --pca 10 --out east.pca10
plink --bfile westpurned.clean  --pca 10 --out west.pca10
Rscript do_PCA.r

###admixture###
cd ../admixture
#filter LD 
plink --bfile ../Gsample.clean --indep-pairwise 50 10 0.5
plink --bfile ../Gsample.clean --extract plink.prune.in --make-bed --out prunedData
for i in 2 3 4 5 6; do admixture --cv prunedData.bed $i; done > cvoutput
grep -i 'CV error' ./cvoutput
Rscirpt do_Admixture.r
nano CVerror.txt
Rscript do_CVerrorplot.r

###FST###
cd ../FST
Rscript do_FST.r

###Heterozygosity###
cd ../Heter 
plink --bfile ../../Gorgorstudent/GorgorWholeGenFID --noweb --keep ../../Gorgorstudent/GorillaID.txt --recode --out gorilla 
plink --file gorilla --make-bed --out gorilla
#no filter
plink --bfile gorilla --chr 21  --family --keep-cluster-names Gbb --recode --out Gbb
plink --bfile gorilla --chr 21  --family --keep-cluster-names Gbg --recode --out Gbg
plink --bfile gorilla --chr 21  --family --keep-cluster-names Ggd --recode --out Ggd
plink --bfile gorilla --chr 21  --family --keep-cluster-names Ggg --recode --out Ggg

plink --noweb --file Gbb --freq --out Gbb
plink --noweb --file Gbg --freq --out Gbg
plink --noweb --file Ggd --freq --out Ggd
plink --noweb --file Ggg --freq --out Ggg

cat Gbb.frq |grep -v NA > Gbb_noNA.frq
cat Gbg.frq |grep -v NA > Gbg_noNA.frq
cat Ggd.frq |grep -v NA > Ggd_noNA.frq
cat Ggg.frq |grep -v NA > Ggg_noNA.frq
#with pi along chromosome
Rscript do_het.r

####inbreeding coefficient###
plink --file Gbb --het --out ../Inbreeding/Gbb
plink --file Ggg --het --out ../Inbreeding/Ggg
plink --file Gbg --het --out ../Inbreeding/Gbg
plink --file Ggd --het --out ../Inbreeding/Ggd
cd ../Inbreeding
nano inbreeding.txt ## create a file including all results based on above code
Rscript do_Inbreedingplot.r

###LD block###
cd ../LD_21
plink --bfile ../../Gorgorstudent/GorgorWholeGenFID --chr 21 --family --keep-cluster-names Gbb --recode --out Gbb_LD
plink --bfile ../../Gorgorstudent/GorgorWholeGenFID --chr 21 --family --keep-cluster-names Gbg --recode --out Gbg_LD
plink --bfile ../../Gorgorstudent/GorgorWholeGenFID --chr 21 --family --keep-cluster-names Ggg --recode --out Ggg_LD
plink --file Gbb_LD --maf 0.15 --geno 0 --thin 0.20 --from 21:3016639 --to 21:8024075 --make-bed --out Gbb_block
plink --file Gbg_LD --maf 0.15 --geno 0 --thin 0.20 --from 21:3016639 --to 21:8024075 --make-bed --out Gbg_block
plink --file Ggg_LD --maf 0.15 --geno 0 --thin 0.20 --from 21:3016639 --to 21:8024075 --make-bed --out Ggg_block
Rscript do_LDblock.r

###LD decay###
plink --bfile ../../GorgorStudent/GorgorWholeGenFID --noweb --keep ../../GorgorStudent/GorillaID.txt --chr 21 --hwe .001 --maf 0.15 --geno 0 --thin 0.20 --make-bed --out ./Gsample21.clean
plink --bfile ./Gsample21.clean --family --keep-cluster-names Gbb --recode --out Gbb
plink --bfile ./Gsample21.clean --family --keep-cluster-names Gbg --recode --out Gbg
plink --bfile ./Gsample21.clean --family --keep-cluster-names Ggg --recode --out Ggg
# remove '21:'
awk '{$2 = substr($2,4);print $0}' Gbb.map > Gbb2.map
rm Gbb.map 
mv Gbb2.map Gbb.map 
plink --file Gbb --make-bed --out Gbb
awk '{$2 = substr($2,4);print $0}' Gbg.map > Gbg2.map
rm Gbg.map
mv Gbg2.map Gbg.map 
plink --file Gbg --make-bed --out Gbg
awk '{$2 = substr($2,4);print $0}' Ggg.map > Ggg2.map
rm Ggg.map 
mv Ggg2.map Ggg.map 
plink --file Ggg --make-bed --out Ggg
Rscript do_LDdecay.r

###Ne###
cd ../Ne
plink --bfile ../Heter/gorilla --not-chr xy --make-bed --out gorilla.clean
nano GbgsampleID.txt  ## choose 7 individuals from Gbg individuals
nano GggsampleID.txt  ## choose 7 individuals from Ggg individuals
plink --bfile gorilla.clean --family --keep-cluster-names Gbg --keep GbgsampleID.txt --hwe 0.001 --geno 0.02 --maf 0.05 --make-bed --out Gbg
plink --bfile gorilla.clean --family --keep-cluster-names Ggg --keep GggsampleID.txt --hwe 0.001 --geno 0.02 --maf 0.05 --make-bed --out Ggg
plink --bfile gorilla.clean --family --keep-cluster-names Gbb --hwe 0.001 --geno 0.02 --maf 0.05 --make-bed --out Gbb

plink --bfile Ggg --thin 0.001 --make-bed --out Ggg.clean
plink --bfile Gbg --thin 0.002 --make-bed --out Gbg.clean
plink --bfile Gbb --thin 0.002 --make-bed --out Gbb.clean
plink --bfile Gbb.clean --r2 square --out Gbb.clean
plink --bfile Gbg.clean --r2 square --out Gbg.clean
plink --bfile Ggg.clean --r2 square --out Ggg.clean
Rscript do_NEestimate.r

###Ne/Nc###
Rscript do_Ne_Nc_plot.r

###TreeMix###
cd../Treemix
awk '{print $1,$2,$2}' ../../Gorgorstudent/GorgorWholeGenFID.ped > allsample.clean.clust  #individual list
awk '{print $1,$2,$1}' ../../Gorgorstudent/GorgorWholeGenFID.ped > allfamily.clean.clust  #popualtion list
awk '{print $2}' ../../Gorgorstudent/GorgorWholeGenFID.ped > sample_order.txt #use for res pic
awk '{print $1}' allfamily.clean.clust |uniq> family_order.txt
#individual
plink --bfile ../allsample.clean --freq --missing --within ./allsample.clean.clust --out allsample
gzip allsample.frq.strat 
python ./treemix-1.13/plink2treemix.py  allsample.frq.strat.gz  tree_allsample.gz
treemix -i tree_allsample.gz  -root HG19 -o tree_allsample  
#population
plink --bfile ../allsample.clean --freq --missing --within ./allfamily.clean.clust --out allfamily
gzip allfamily.frq.strat 
python ./treemix-1.13/plink2treemix.py  allfamily.frq.strat.gz  tree_allfamily.gz
treemix -i tree_allfamily.gz -root HG19 -m 2 -o tree_allfamily # we tried m 1-5
Rscript do_treemix.r


print("Finish!:D")
