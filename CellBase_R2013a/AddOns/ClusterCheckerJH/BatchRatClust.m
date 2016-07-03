function BatchRatClust

% PDFs for session cluster data are saved in each session dir

[animalpath]=uigetdir ('specify an animal path');
LIST=dir([animalpath]);
SessionNames=char(LIST.name);
rSessionNames=[];

for i=1:size(SessionNames,1); 
if sum(strfind(SessionNames(i, :), '.'))>0
else
 rSessionNames =[rSessionNames; SessionNames(i, :)];
end
end


for is=1:size(rSessionNames, 1)
sessionpath=fullfile(animalpath, rSessionNames(is, :));
BatchSessionClust(sessionpath)
end


