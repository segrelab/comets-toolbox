% models={e_coli_core,iAB_RBC_283,iAF1260,iAF1260b,iAF692,iAF987,ic_1306,iIT341,iJN746,iECB_1328,iEC55989_1330,iEC042_1314}
% mets={'CO2','O2','Nitrate','Phosphate','Orotate','Nitric oxide','Ca2_c0','H2O_e0','fe3_e0','Sucrose_e0','Maltose_e0','Na_c0'}
function genomes=genomeGenerator(models, mets)
    genomes=[Genome() Genome() Genome() Genome() Genome() Genome()];
    mets1=(mets(1:3));
    models1=(models(1:3));
    mets2=(mets(4:6));
    models2=(models(4:6));
    mets3=(mets(7:9));
    models3=(models(7:9));
    mets4=(mets(10:12));
    models4=(models(10:12));
    genomes(1)=genomes(1).addMetsAndModels(mets1,models1);
    genomes(2)=genomes(2).addMetsAndModels(mets2,models2);
    genomes(3)=genomes(3).addMetsAndModels(mets3,models3);
    genomes(4)=genomes(4).addMetsAndModels(mets4,models4);
    genomes(5)=genomes(5).addMetsAndModels(mets2,models4);
    genomes(6)=genomes(6).addMetsAndModels(mets1,models2);
    
    genomes(1)=genomes(1).getScore();
    genomes(2)=genomes(2).getScore();
    genomes(3)=genomes(3).getScore();
    genomes(4)=genomes(4).getScore();
    genomes(5)=genomes(5).getScore();
    genomes(6)=genomes(6).getScore();
    
end