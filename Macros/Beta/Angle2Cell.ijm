///======================MACRO=========================///
macro_name = "Angle2Cell";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro allows an automated calculation of angles 
between the output of fibrilTool_Batch_workflow.ijm and
the output of Cell_AspectRatio. It 
natively uses as input, output from the 
fibrilTool_Batch_workflow.ijm macro as well as from the 
Cell_RoiMaker.ijm macro.

See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "";//TO DO

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
microtubule_image_suffix = "_MTs.tif";
FT_RoiSet_suffix = "_RoiSet_FT.zip";
AspectRatio_file_suffix = "_CellAspectRatio.txt";
Anisotropy_suffix = "_FT.txt";

// Output paramaters: output file suffixes
Angles_file_suffix = "_Angle2Cell.txt";
Angles_image_suffix = "_Angle2Cell.tif";

///====================================================///
///====================================================///
///====================================================///

print("\\Clear");

//Select directory
dir = getDirectory("Choose a directory");
Folder_name = File.getName(dir);
list = getFileList(dir);

//Generate log file for record
log_file_name = "Log_" + Folder_name + "_" + macro_name + ".txt";
fLog = File.open(dir + File.separator + log_file_name);
print(fLog, "Files Processed with the macro "+ macro_name + ".ijm\n(" + macro_source + ")\n\n");
print(fLog, "Directory: " + dir + "\n\nFiles processed:");
File.close(fLog);

//Generate output file containing all the measured angles of all the images analyzed in this file
Output_angles_all = "All_" + Folder_name + Angles_file_suffix;
fAll = File.open(dir + File.separator + Output_angles_all);
print(fAll, "Genotype/condition" + "\t" + "Sample Number" + "\t" + "CellNumber" + "\t" + "FibrilTool Angle" + "\t" + "Cell Angle" + "\t" + "Raw angle" + "\t" + "Absolute angle" + "\t" + "Acute absolute angle to ablation" + "\t" + "Anisotropy" + "\t" + "AspectRatio");
File.close(fAll);

s = 0;
//Loop on all the images in the folder
for (j=0; j<list.length; j++){

	//Select image series to process
	if(endsWith (list[j], microtubule_image_suffix)){
		print("file_path ", dir + list[j]);

		//count samples analyzed
		s++;
		
		//Extract generic name of the image serie
		File_name = substring(list[j], 0, indexOf(list[j], microtubule_image_suffix));

		//Write to log txt file
		File.append("- Sample number: " + s + "\n" + File_name, dir + File.separator + log_file_name);
		
		//Generate output file containing all the measured angles of the [j] analyzed images
		Output_angles = File_name + Angles_file_suffix;
		fImg = File.open(dir + File.separator + Output_angles);
		print(fImg, "CellNumber" + "\t" + "FibrilTool Angle" + "\t" + "Cell Angle" + "\t" + "Raw angle" + "\t" + "Absolute angle" + "\t" + "Acute absolute angle to ablation" + "\t" + "Anisotropy" + "\t" + "AspectRatio");
		File.close(fImg);

		//Open Microtubule image
		Input_MTs = File_name + microtubule_image_suffix;
	    open(dir + File.separator + Input_MTs);

		//clean up the ROI manager and empty results tables
		roiManager("reset");
		run("Clear Results");
	
		//Open FibrilTool output ROI 
		Input_ROI_FT = File_name + FT_RoiSet_suffix;
		roiManager("Open", dir + File.separator + Input_ROI_FT);

		//Count FibrilTool ROI number
		//ft_roi_number = roiManager("count");
		//print ("FT ROIs:" + ft_roi_number);

		//Open Aspect ratio file
		//Input_AR_file = File_name + AspectRatio_file_suffix;
		//roiManager("Open", dir + File.separator + Input_AR_file);

		//Count total ROI number
		tot_roi_number = roiManager("count");
		print ("Total ROIs:" + tot_roi_number);

		//calculate line ROI number
		//line_roi_number = tot_roi_number - ft_roi_number;
		//print ("Line ROIs:" + line_roi_number);

		//Error message if ROI numbers are not equal
		//if (ft_roi_number != line_roi_number){
			//exit ("ROI number for FibrilTool and drawn lines not equal in sample " + File_name);  
		//}

		//Generate results from ROIs (including angles)
		run("Set Measurements...", "area mean min centroid redirect=None decimal=1");
		roiManager("measure");

		//Loop all corresponding FibrilTool and line ROIs
		for (i = 0; i < tot_roi_number; i++) {

			//Print cell number
			print("Cell:" + i + 1);

		    //Get FibrilTool ROI angle (and convert form -90/90 to 0/180 degrees angle values)
		    roiManager("select", i);
		    FTAngle = getResult("Angle", i);
		    if (FTAngle < 0){
		    	FTAngle = FTAngle + 180;
		    }
		    print ("FibrilTool Angle:" + FTAngle);
		    Overlay.addSelection();

		    //Get line ROI angle (and convert to 0/180 degrees angle values)
		    //roiManager("select", i + ft_roi_number);
		    //LineAngle = getResult("Angle", i + ft_roi_number);
		    //if (LineAngle < 0){
		    	//LineAngle = LineAngle + 180;
		    //}
		    //print ("Line Angle:" + LineAngle);
		    //Overlay.addSelection();

			//Retrieve Aspect ratio values
			Input_AR_file = File_name + AspectRatio_file_suffix;
			filestring = File.openAsString(dir + File.separator + Input_AR_file); 
			rows=split(filestring, "\n"); 
			ARangles=newArray(rows.length);
			ARaspectRatios=newArray(rows.length); 
			x1s=newArray(rows.length);
			y1s=newArray(rows.length); 
			x2s=newArray(rows.length); 
			y2s=newArray(rows.length); 
			for(k=0; k<rows.length; k++){ 
				columns=split(rows[k],"\t"); 
				ARangles[k]=parseFloat(columns[1]); 
				ARaspectRatios[k]=parseFloat(columns[2]); 
				x1s[k]=parseFloat(columns[5]); 
				y1s[k]=parseFloat(columns[6]); 
				x2s[k]=parseFloat(columns[7]); 
				y2s[k]=parseFloat(columns[8]); 
			} 
			ARangle = ARangles[(i+1)];
			print("ARangle :" + ARangle);
			ARaspectRatio = ARaspectRatios[(i+1)];
			print("ARaspectRatio :" + ARaspectRatio);
			x1 = x1s[(i+1)];
			print("x1 :" + x1);
			y1 = y1s[(i+1)];
			print("y1 :" + y1);
			x2 = x2s[(i+1)];
			print("x2 :" + x2);
			y2 = y2s[(i+1)];
			print("y2 :" + y2);

			//Draw Aspect Ratio lines
			makeLine(x1,y1,x2,y2);
			scale_factor = 4; //Scale line representation
			run("Add Selection...", "stroke=yellow width="+scale_factor);
		    
		    //Draw link between FT and line to check correspondance in angle calculation
		    //getPixelSize(unit, pixelWidth, pixelHeight); //Get pixel size to convert from micro to pixel
		    
		    //FT_X = getResult("X", i)/pixelWidth;
		    //FT_Y = getResult("Y", i)/pixelWidth;
		    //Line_X = getResult("X", i + ft_roi_number)/pixelWidth;
		    //Line_Y = getResult("Y", i + ft_roi_number)/pixelWidth;
		    //setColor("blue");
		    //Overlay.drawLine(FT_X, FT_Y, Line_X, Line_Y);

			//Calculate "raw" angle difference (Ang2Cell)
			Ang2Cell = FTAngle - ARangle;
			print("Raw angle:" + Ang2Cell);

			//Calculate absolute angle difference (AbsAng2Cell)
			AbsAng2Cell = abs(Ang2Cell);
			print("Abs angle:" + AbsAng2Cell);

			//Calculate acute absolute angle between both lines (AcAbsAng2Cell)
			AcAbsAng2Cell = AbsAng2Cell;
			if (AbsAng2Cell > 90){
		    	AcAbsAng2Cell = 180 - AbsAng2Cell;
		    }
		    print("Acute absolute angle to cell:" + AcAbsAng2Cell);

			//Retrieve anisotopy value from FibrilTool output file
			Input_anisotropy = File_name + Anisotropy_suffix;
			filestring = File.openAsString(dir + File.separator + Input_anisotropy); 
			rows=split(filestring, "\n"); 
			x=newArray(rows.length); 
			for(k=0; k<rows.length; k++){ 
				columns=split(rows[k],"\t"); 
				x[k]=parseFloat(columns[6]); 
			} 
			Anisotropy = x[(i+1)];
			print("Anisotropy :" + Anisotropy);
			
			//Writes output to the *_Angle2Ablation.txt file for each image
			File.append((i + 1) + "\t" + FTAngle + "\t" + ARangle + "\t" + Ang2Cell + "\t" + AbsAng2Cell + "\t" + AcAbsAng2Cell + "\t" + Anisotropy + "\t" + ARaspectRatio, dir + File.separator + Output_angles);

			//Writes output to the All_*_Angle2Ablation.txt file for all the images of the folder
			File.append(Folder_name + "\t" + s + "\t" + (i + 1) + "\t" +  FTAngle + "\t" + ARangle + "\t" + Ang2Cell + "\t" + AbsAng2Cell + "\t" + AcAbsAng2Cell + "\t" + Anisotropy + "\t" + ARaspectRatio, dir + File.separator + Output_angles_all);

		    //write angles on image (one decimal)
		    getPixelSize(unit, pixelWidth, pixelHeight); //Get pixel size to convert from micro to pixel
		    FT_X = getResult("X", i)/pixelWidth;
		    FT_Y = getResult("Y", i)/pixelWidth;
		    setColor("magenta");
		    Overlay.drawString(d2s(AcAbsAng2Cell,1), FT_X, FT_Y);
			Overlay.add;
		}
		//Flatten overlay and save image for verification
		Overlay.flatten
		Output_overlay = File_name + Angles_image_suffix;
		saveAs("tiff", dir + File.separator + Output_overlay);
		
		//Close files corresponding to analyzed image
		selectWindow(File_name + Angles_image_suffix);
		run("Close");
		selectWindow(File_name + microtubule_image_suffix);
		run("Close");
		
		//Write to log, input files used and output file generated
		File.append("\tInput :\n\t=> " + Input_ROI_FT + "\n\t=> " + Input_AR_file + "\n\t=> " + Input_MTs + "\n\t=> " + Input_anisotropy + "\n\tOutput :\n\t<= " + Output_overlay + "\n\t<= " + Output_angles, dir + File.separator + log_file_name);
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		File.append("\t" + hour + ":" + minute + ":" + second + " " + dayOfMonth + "/" + month + "/" + year + "\n\n", dir + File.separator + log_file_name);
	}
}

//Close all open files
selectWindow("ROI Manager");
run("Close");
selectWindow("Results");
run("Close");

//End of the macro message
print("\n\n===> End of the Angle2Ablation macro");
print("Check output files in:\n" + dir);
print("- " + log_file_name + "\n- All_" + Folder_name + Angles_file_suffix + "\n- *" + Angles_file_suffix + "\n- *_Angle2Ablation.tif\n(*) For each image analyzed");