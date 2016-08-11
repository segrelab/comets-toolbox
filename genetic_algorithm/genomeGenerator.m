% Uday Tripathi 7/2016

% Function that was used in beginning for testing, Unnecessary now

% models={K1,K1A,K2,K3,K4,K5,K6,K7,K8,K9,K9A,K10,K11,K12,K13,K14,K15,K16,K17,K18,K19,K20,K21,K22}
% mets={'EX D-Glucose e0','EX Sucrose e0','EX Maltose e0', 'EX D-Fructose e0', 'EX D-Mannose e0','EX Dulcose e0'}
% metsCOMETS={'Amylotriose_e0','D-Fructose_e0','D-Glucose_e0','D-Mannose_e0','D-Ribose_e0','Dulcose_e0','L-Arabinose_e0','Maltohexaose_e0','Maltose_e0','Sucrose_e0','Thyminose_e0'}
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