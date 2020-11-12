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
A temporary version of the Jupyter notebook can be used on your web browser using binder. 

1. __To start it__ click here [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/VergerLab/MT_Angle2Ablation_Workflow/master)

It can take a few minutes to start it. Ultimately you will see the "home page" with all the content of the Github repository.

2. You can first __test the Notebook with the pre-loaded data__. To do this, click on “Stats_Angle2Ablation.ipynb”. This will start a new tab on your browser with the Jupyter notebook named “Statistics for Angle to ablation Analysis”. Then, follow the instructions in the notebook itself.

3. Then, to perform your own analysis, __upload your own data__. 
 - On the "home page", Click "New" and "Folder" in the top right corner.
 - Tick the box next to the newly created "Untitled Folder".
 - Click on "rename" above, and rename the folder "MyData" (or anything else of your choice).
 - Enter this folder and at the top right corner click "Upload".
 - You only need to upload the file called All_….txt. Each genotype and condition analyzed generate one such file. Each of this file has to be put in a separate folder under the "MyData" repository.

4. You can then __perform your own analysis__ using the notebook, in the same manner as with the pre-loaded data. Don't forget to define the correct path to your own data in the notebook.

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
   Alternatively you can simply navigate with your regular graphical interface file manager and open a terminal from there. 
   On linux, right-click in the folder of interest and select "Open in terminal". 
   On Windows, you can press the Shift key and right-click on a folder to open a PowerShell window directly to that folder.
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
  if not you can find the web link to the Jupyter notebook on the command window
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

8. __Start Jupyter__.

		jupyter lab

A page called "JupyterLab" should open automatically on your web browser.

9. __Open the Python notebook__. to do that, in the menu on the left, double click on "Stats_Angle2Abaltion.ipynb".

10. Finally, __to run the notebook__, follow the instructions in the notebook itself.
