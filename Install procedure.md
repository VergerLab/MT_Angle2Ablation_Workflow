# How to install and run the different components of the workflow

In the simplest version of the installation you only need to have Fiji, the few macros listed below and the plug-in MorpholibJ.

Then, data analysis can be performed with any appropriate software, but here we propose a user-friendly python __Jupyter notebook__ with predefined graph output and statistical analysis to ease the analysis of the results.
This notebook can be run locally on your computer after installing the required software and python libraries, __or with no install using binder directly from your browser__. 

The detailed explanation for the installation of these components is presented below.

## - Fiji: 
Most of the workflow is designed to run on Fiji. If you don’t already have it, download it and install it following the procedure describe at https://fiji.sc/.

## - Macros: 
You will need (available for download at): 
- SurfCut2.ijm (https://github.com/VergerLab/SurfCut2) 
- FibrilTool_Batch_Workflow.ijm (https://github.com/VergerLab/FibrilTool_Batch_Workflow)
- Cell_ROIMaker.ijm (https://github.com/VergerLab/MT_Angle2Ablation_Workflow)
- Line_ROIMaker.ijm (https://github.com/VergerLab/MT_Angle2Ablation_Workflow)
- Angle2Ablation.ijm (https://github.com/VergerLab/MT_Angle2Ablation_Workflow)

Each of these macro can be directly downloaded in the folder of your choice.

  To run the macro: 
  1. Drag and drop the macro file into Fiji to open it.
  2. Click run in the editor window to run it. 

## - Plugins: 
The macro “Cell_ROIMaker.ijm” uses the plug-in MorpholibJ (Legland et al., 2016; https://imagej.net/MorphoLibJ).

  To install it: 
  1. Go in the “Help” menu of Fiji and click on “Update…”. This will open the “ImageJ updater”. 
  2. In “ImageJ updater”, click on “Manage update sites”.
  3. In the list, find “IJPB-Plugins” and click in the square next to it to add it. 
  4. Then close the window and apply changes on “ImageJ updater”. 
  5. Once this is done, Fiji needs to be restarted. 

## - Jupyter notebook: 

### No-install Jupyter notebook online through Binder:
A temporary version of the Jupyter notebook can be used on your browser  using binder. 
1. To start it click here [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/VergerLab/MT_Angle2Ablation_Workflow/master) (it can take a few minutes to start it). 
2. Then, upload your data in the “Data” folder on the web page. Only the file called All_….txt
3. Once this is done, click on “Stats_Angle2Ablation.ipynb” this will start a new tab on your browser with the Jupyter notebook named “Statistics for Angle to ablation Analysis”. 
4. Start the analysis process at the first line (“Load required packages”), click on it to select (Blue on the left side) and then use “shift + enter” to run the line. Proceed as for the first line with the rest. For the line, “single_file_path” put the path leading to your own data. To finish run the rest of the lines.

### Local installation:

1. __Download the miniconda installer__ from the official website repo.continuum.io\
	LINUX: https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh \
	MAC: https://repo.continuum.io/miniconda/Miniconda2-latest-MacOSX-x86_64.sh \
	Windows: https://repo.continuum.io/miniconda/Miniconda2-latest-Windows-x86_64.exe

	You can also use wget to perform this download from a terminal (LINUX or MAC):
	
       wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh

2. __Install miniconda__ by running the installer:
   
   LINUX: Open a new terminal window, go to the directory where you downloaded the installer and run:
   > Note: To navigate to a specific directory, you can do it in the terminal with the "cd" (Change directory) command. 
   Alternatively you can simply navigate with your regular graphical interface file manager (e.g. Nautilus). 
   Then right-click in the folder of interest and select "Open in terminal". 
   You can then directly paste the commands below into the terminal and press enter.
  
       bash Miniconda2-latest-Linux-x86_64.sh
       rm Miniconda2-latest-Linux-x86_64.sh
      
	 MAC: Open a new terminal window, go to the directory where you downloaded the installer and run:
 
       bash Miniconda2-latest-MacOSX-x86_64.sh
       rm Miniconda2-latest-MacOSX-x86_64.sh
	
   Windows: Execute the installer and follow the instructions
	
   During the installation you will be asked a number of choices. You can set up the directory of your choice when asked, e.g. ~/.miniconda. Make sure to answer YES when asked to add conda to your PATH

3. You should now have miniconda properly installed; __test your installation__ by running "conda" in a terminal to make sure the command is found. 
To do this you can directly copy and paste the commands below into the terminal and press enter.

	   conda


  > Conda tips:
  >
  > Get out of the current conda environment : 
  
	conda deactivate
  
  > View the available environments : 
  
	conda env list

4. __Download and extract the "MT_Angle2Ablation" repository__ to the location of your choice.
   To do this, click on the green "code" icon on the top right side of the repository page. Then "Download ZIP". 
   Finally extract the content of the zip to the location of your choice. 

5. __Create and activate a conda environment__. To do this, navigate to the "/MT_Angle2Ablation" folder that you have downloaded and extracted in the previous step.
  > Note: To navigate to a specific directory, you can do it in the terminal with the "cd" (Change directory) command. 
   Alternatively you can simply navigate with your regular graphical interface file manager (e.g. Nautilus). 
   Then right-click in the folder of interest and select "Open in terminal". 

6. __Define a new conda environment__. To do this you can directly copy and paste the commands below into the terminal and press enter.

       conda env create -f environment.yml
   
 This should take a few seconds.

7. __Activate the environment__.

       conda activate Stats_Angle2Abaltion


- Commands for Anaconda prompt for Windows:
To open the Jupyter notebook for the statistical analysis of the angles to ablation. You have to open first the command on the “Start” menu. Then you have to create a new environment. To do so you enter the command: 
conda env create
Following that command, before clicking on enter; write the name of the environment you wish to create (wait a few minutes until the installation of the packages in the environment is done) : 
Stats_Angle2Ablation_V2
In order to activate this new environment enter the following command:
conda activate Stats_Angle2Ablation
Note that you can find the path of all the environments that you created by using the command: 
conda info --envs
Once Stats_Angle2Ablation is activated type as command:
jupyter lab
A web page should open automatically if not you can find the web link to the Jupyter notebook on the command window.
    • “Statistics for Angle to ablation Analysis” Jupyter notebook:
Here, start at the first line (“Load required packages”), click on it to select (Blue on the left side) and then use “shift + enter” to run the line. Proceed as for the first line with the rest. For the line, “single_file_path” put the path leading to your own data. To finish run the rest of the lines.