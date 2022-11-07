///======================MACRO=========================///
macro_name = "FolderMaker";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro allows to automatically generate a folder 
architecture for batch analysis of multiple genotypes,
samples and timepoints in the frame of the 
MT_Angle2Ablation_Workflow.

See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/";

///=========Input/output file names parameters=========///
//None
///====================================================///
///====================================================///
///====================================================///

//Get date to propose as part of the folder name
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

//Dialog for folder architecture
Dialog.create("Folder architecture definition");
Dialog.addMessage("Define the name of the folder to be created that will contain the rest of the analysis (Genotpes/conditions, samples, timepoints)");
Dialog.addString("Experiment name", year + "-" + month + "-" + dayOfMonth + "_Tmlps_MT_Angle2ablationAnalysis", 40);
Dialog.addDirectory("Where to put this folder?", "Choose/a/directory");
Dialog.addMessage("Below, enter the names of each genotype or condition analyzed. Each name separated by a coma and a space.\nDo not put spaces or / in the name, use _ instead. e.g. GFP-MBD, GFP-MBD_bot1-7");
Dialog.addString("Genotpes/conditions names", "(e.g. GFP-MBD, GFP-MBD_bot1-7)", 40);
Dialog.addNumber("How many samples per genotypes/conditions?", "9");
Dialog.show();
ExpName = Dialog.getString();
dir = Dialog.getString();
GenoNames = Dialog.getString();
SampleNb = Dialog.getNumber();

//Create array for genotypes/conditions names
GenoNamesArray = split(GenoNames, ", ");

//Generate the experiment folders
File.makeDirectory(dir+File.separator+ExpName);

//Generate the genotype/condition folders
for (a=0; a<GenoNamesArray.length; a++){
	print(GenoNamesArray[a]);
	File.makeDirectory(dir+File.separator+ExpName+File.separator+GenoNamesArray[a]);
	
	//Generate the Sample folders
	for (b=0; b<SampleNb; b++){
		bb = b + 1;
		print(bb);
		File.makeDirectory(dir+File.separator+ExpName+File.separator+GenoNamesArray[a]+File.separator+bb);
	}
}

//End of the macro message
print("\n\n===> End of the FolderMaker macro");
print("Check new folder architecture created in:\n" + dir);
