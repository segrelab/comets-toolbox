function m = emptyCbModel()
%EMPTYCBMODEL Creates a struct with the same fields as a COBRA model and
%empty values
m=struct();
m.modelVersion=struct();
m.rxns={};
m.mets={};
m.S=[];
m.rev=[];
m.c=[];
m.metNames={};
m.metFormulas={};
m.lb=[];
m.ub=[];
m.metCharge=[];
m.rules={};
m.genes={};
m.rxnGeneMat=[];
m.grRules={};
m.subSystems={};
m.confidenceScores={};
m.rxnReferences={};
m.rxnECNumbers={};
m.metChEBIID={};
m.metKEGGID={};
m.metInChIString={};
m.b=[];
m.description='';

end

