# How to install and run the different components of the workflow

In the simplest version of the installation you only need to have Fiji, the "Angle2ablation_Workflow_ToolSet.ijm" macro Toolset and two additional fiji plugins.

Then, data analysis can be performed with any appropriate software, but here we propose a user-friendly python __Jupyter notebook__ with predefined graph output and statistical analysis to ease a robust analysis of the results.
__This notebook can be run online with no install directly from your web browser__, or locally on your computer after installing the required software and python libraries. 

The detailed explanation for the installation of these components is presented below.

## - Fiji: 
Most of the workflow is designed to run on Fiji. If you don’t already have it, download it and install it following the procedure describe at https://fiji.sc/.

## - Plugins:
- MorpholibJ (“IJPB-Plugins” update site) 
- Linear Stack Alignment with SIFT MultiChannel (“PTBIOP” update site) 

To install the required plugins, turn on the corresponding update sites.
  1. Go in the “Help” menu of Fiji and click on “Update…”. This will open the “ImageJ updater”. 
  2. In “ImageJ updater”, click on “Manage update sites”.
  3. In the list, find e.g. “IJPB-Plugins” and click in the square next to it to add it. 
  4. Then close the window and apply changes on “ImageJ updater”. 
  5. Once this is done, Fiji needs to be restarted. 
 
## - Macros: 
You will need (available for download at): 
- Angle2ablation_Workflow_ToolSet.ijm (https://github.com/VergerLab/MT_Angle2Ablation_Workflow) 

Click on the green "code" button around the top right corner of the main page of this repository, and then ”download zip”. Then, unzip the file in the folder of your choice. Finally, copy the Angle2ablation_Workflow_ToolSet.ijm file and past it in the "/macros/toolsets/" folder of your Fiji install folder (on a Mac, access this by right clicking on the Fiji app in a Finder window and selecting "Show Package Contents"). 

To check if the toolset was loaded properly, open Fiji, and click on ">>" at the right end of the Fiji window. You should see Angle2ablation_Workflow_ToolSet in the drop-down menu. Select it and the toolset should appear in your Fiji toolbar. 

Then follow the [user guide](https://github.com/VergerLab/MT_Angle2Ablation_Workflow/blob/master/Step%20by%20step%20user%20guide_CMTs_draft.pdf) to understand how to operate the workflow.

## - Jupyter notebook: 
The data analysis workflow that we propose can be used with no prior knowledge of python programming by simply running the notebook in the browser (see __No-install Jupyter notebook online through Binder__ below).

However it can be useful to acquire a little bit of background on how to use this tool. The notebook is an efficient way to share our data analysis approach for better reproducibility. You can also install it locally simply by following the installation procedure which can allow you to modify the code as desired to adapt it to your sepcific needs.



We also recommand the very useful lecture series on BioImage Analysis from Robert Haase (https://www.youtube.com/playlist?list=PL5ESQNfM5lc7SAMstEu082ivW4BDMvd0U), in particular the lectures 9 to 11 about the use of python for data analysis and hypothesis testing. In addition some help can be found for the local installation of miniconda in lecture 9b (https://youtu.be/MOEPe9TGBK0?t=1807).

### No-install Jupyter notebook online through Binder:

__To start it click here__ [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/VergerLab/MT_Angle2Ablation_Workflow/master)

It can take a few minutes to start it. Ultimately you will see the "home page" with all the content of the Github repository.
Then simply follow the instructions in step 7 of the user guide to get started.

You can first __test the Notebook with the test data__ available on this repository under "/TestData/".

_The following video provides a very useful introduction to the use of Python and jupyter notebooks for bioimage analysis. In particular for running a notebook on Binder (38:10 --> 41:47) for the No-install approach. https://www.youtube.com/watch?v=2KF8vBrp3Zw_

### Local installation:

1. __Install miniconda :__
   
Follow the instructions provided here https://conda.io/projects/conda/en/stable/user-guide/install/index.html#regular-installation

2. You should now have miniconda properly installed; __test your installation__ by running "conda" in a terminal to make sure the command is found. 
To do this, on LINUX and MAC, you can directly copy and paste the commands below into the terminal and press enter. On Windows, look for "Miniconda prompt" in the search bar (next to the windows icon, bottom left of the desktop screen). Open the "Miniconda prompt" and directly continue to step 4.

	   conda


3. If not previously done for the macro, __download and extract the "MT_Angle2Ablation" repository__ to the location of your choice.
   To do this, click on the green "code" icon on the top right side of the repository page (https://github.com/VergerLab/MT_Angle2Ablation_Workflow/). Then "Download ZIP". 
   Finally extract the content of the zip to the location of your choice. 

4. __Create and activate a conda environment__. To do this, first, in your terminal (LINUX and MAC) or Miniconda Prompt (Windows), navigate to the "/MT_Angle2Ablation" folder that you have downloaded and extracted in the previous step.
  > Note: To navigate to a specific directory, you can do it in the terminal (LINUX and MAC) or Miniconda Prompt (Windows) with the "cd" (Change directory) command. On Windows if you need to navigate to a different drive (e.g. D:\ instead of C:\), first write the name of the drive before the cd commande (i.e. "D: cd \\...).
   Alternatively, on linux you can simply navigate with your regular graphical interface file manager (e.g. Nautilus). 
   Then, right-click in the folder of interest and select "Open in terminal".
   You can then directly paste the commands below into the terminal and press enter.
   

5. __Define a new conda environment__. To do this you can directly copy and paste the commands below into the terminal or Miniconda Prompt and press enter.

		conda env create -f environment.yml
   
 This should take a few seconds.

6. __Activate the environment__.

		conda activate A2A_Tmlps_Stats

7. __Start Jupyter__.

		jupyter notebook 

A new page will open in your web browser.

8. __Open the Python notebook__. To do that, in the file list on the jupyter page, double click on "A2A_Tmlps_Stats.ipynb".

9. Finally, __to run the notebook__, follow the instructions in the notebook itself and userguide.

When you are done with the analysis, you can close the web page and the terminal or Miniconda prompt that was used to launch Jupyter.

Later on, to restart an analysis, you only need to follow steps 7 to 9.
  
  > Conda tips:
  >
  > Get out of the current conda environment : 
  
	conda deactivate
  
  > View the available environments : 

	conda env list
