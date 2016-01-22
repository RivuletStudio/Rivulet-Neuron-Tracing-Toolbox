We will provide the first ready to install package for different platforms.

Rivulet logo
============
![Build Status](https://github.com/lsqshr/Rivulet-Neuron-Tracing-Toolbox/blob/master/Rivulet_resources/Rivulet-Logo2.png)

The reason why we choose red R is that red represents a pioneer spirit. The red is also the color of blood and sun. The blood and sun is like force awaken. R is the first letter of rivulet. The curvature of R symbolizes the curved connections of neurons. We name our algorithm rivulet, because it is just like all streams flowing back to the sea. When you visualise the tracing process, you may understand what I am talking about.   
Examples
========
The gif below show the animation of tracing process. 
  
![Build Status](https://github.com/lsqshr/Rivulet-Neuron-Tracing-Toolbox/blob/master/traceplot.gif)

The gif below show the animation of soma detection process. 
  
![Build Status](https://github.com/lsqshr/Rivulet-Neuron-Tracing-Toolbox/blob/master/somadetection.gif)

=============================
Rivulet-Neuron-Tracing-Toobox (WIP)
=============================
1. **Rivulet Toolbox illustration**
  * **Input and Ouput Panel**
    * **V3D Matlab I/O button** : you should select the dirctionary which contains  v3d matlab io files. If you do not have this dictinary, do not worry about it. We supprt other format of files.
    * **Load Image** As its name suggests, load neuron image using this button.
    * **Load swc** As its name suggests, load swc using this button.
    * **Save Cropped** As its name suggests, it store the automatic cropped image.
  * **Render Panel**
    * **Image check box** When you want to visualise the original iamge, we suggest you tick this box.
    * **Tree check box** tick it make you can see swc reconstruction.
    * **Shift slider** The shift slkider can avoid the overlapping between the neuron reconstruction and original neuron image. In order words, it generates a better reconstruction visualization.
  * **Prepocessing Panel**
    * **Auto crop** Tick it if you want crop the redundant background of cube.
    * **Diffusion filter** when the image quality is not perfect, this option is always your loyal backup. 
  * **Segmentation Panel**
    * **Threshold slider bar** : Drag it horizontally to achieve the segmentation result. Do not forget to press update button.
    * **Level set check box** Normally, we suggest you do level set operation(tick the level set check box) only when there is strong noises. 
    * **classification button** Press this button if you want to remove noise using the machine learning method. This method's training data from vesselness, similar tensor based methods and the eigenvalues. It works very fast, because it just use quadratic regression. It do not make sense if quadratic regression solve and we insists on support vector machine.
  * **Soma Detection Panel**  
    * **Radius** : the size of initialization sphere
    * **Step** : the number step soma snake grows before it stops
    * **Smoooth** : the smoothness of each step
    * **threshold** : is the threshold used to find the center of soma location. We might consider remove it in the future.
    * **Soma expert** : do not tick it until you are expert and know exactly what you are doing.
    * **lambda 1 and lambda 2** : the strength of internal energy and external energy
    * **DT method** : use distance transform method to soma center
    * **soma plot** : the visuliazation of soma growth
  * **File Metadata Panel**
    * Basically, file metadata panel provides information about the size of input neuron image and name of file. 
  * **Tracing Parameters Panel**
    * **Plot check box** : Basically, click it means you want to visualise the tracing process. You just want to get swc as soon as possible, you should consider untick it.
    * **Washaway check box** : You've got to crack a few eggs to make an omelette. There is no free lunch in comuter vision area. This button increases the tracing process dramatically, but you have suffer some loss of detailed dendrites reconstructions.
    * **Soma check box** : Untick it if you do not have soma in this image. If you have soma in this image, you should do soma detection first. Although you can choose to do neuron reconstruction directly without soma detection, it is not recommended.
    * **Output swc** tick it if you want the swc file. Untick it if you do not.
    * **dump** there is redundant noises in the image you should tick it
    * **Coverage percentage** a high value means more detailed description
    * **Gap** the largest gap it can jump
    * **Connect** the threshold of connecting tracing part into swc tree
    * **Length** the shortest branch we have in our swc tree
    * **Trace button** : Press it, Rivulet start to trace. It is that simple. Believe it or not?
2. **Friendly reminder** : If you need help about specfic button, put your mouse on the name of button. And hang on a  few seconds and magic will show. The text are marked as green are the pararmeters you might consider to change to achieve best result. The text marked as aureate means that you may not consider changing it if you are are an expert.
3. **Tracing visualisation explanation**
  * **Red Sphere** : represents the startig point of each rivulet back tracing. 
  As you may already notice, most of rivulet tracing starts from the axon terminal or the dendrites termini of
  neuron.
  * **Blue Line** : represents the traced path of neuron.
  * **Red Line** : represents the swc structure ignoring the radius. We ignored radius deliberately to reveal the all potentialmiswiring connections.
4. **Soma detection visualisation explanation**
  * **Blue particles swarm** : represents the growing soma.
  * **Red particles swarm** : represents the foreground neuron signal.  

Background
==========
To acquire profound knowledge of the neuron structure is vital for efficient and accurate diagnosis and treatment of both neurological and psychiatric disorders. Due to the increasingly relying on bioimage assistance in medical practice, 3D neuron reconstruction will provide reliable and accurate data for neuron morphology study. There are few powerful automatic algorithms to trace a complete neuron. The most current algorithms are semi-automatic, so it is significant to propose an automatic neuron reconstruction method. The reconstruction result is barely satisfactory due to the appearance of irrelevant structure, background gradients, and inhomogeneous contrast of neuron image stacks. The fuzzy and discontinuous neuron structure is another challenge. Most of the current algorithms can only achieve satisfactory reconstruction results of single neuron. When the neuron structure is complex and complicated, most current algorithms fail. For example, any close neuron structures will lead to biased reconstruction results. The new automatic and robust neuron reconstruction method is required. We propose a fast, robust and automatic algorithm, which can generate reasonable satisfactory 3D reconstructions of complex and complicated neuron structure in a short time.  

Brief theoretical description
=============================
It is time to reveal the mystery of Rivulet Tracing Toolbox. We will use flowchart diagram to illustrate our Rivulet tracing.  
![Build Status](https://github.com/lsqshr/Rivulet-Neuron-Tracing-Toolbox/blob/master/rivuletflowchart.png)
The formulas description will be released in the near future. The academic are fans of formulas, are not they?
Nonetheless, understanding the reason why we use these formulas are far more important than understanding the usage of these formulas. 

Implementation
==============
This is a basic guide of hacking our code. The more detailed documentation might come in the future.
util/anisotropicfilter.m anisotropicfilter   
util/binarizeimage.m Segment the 3D v3draw uint image to binary image with a classifier or threshold  
trace.m it is the main trace function  
util/showswc.m it shows swc reconstruction  
lib/FastMarching_version3b/msfm.m fast marching  
util/ addbranch2tree add branch to tree  
lib/snake/mainsnake/somagrowth.m main soma detection file   
References
==========
Rivulet paper will be avaiable soon. It can be downloaded at xxxxx.(Not available yet)
The follwoing links are the libraries we are using now or used before. 

[Snake Link](https://github.com/pmneila/morphsnakes)

[Accurate fast marching](http://au.mathworks.com/matlabcentral/fileexchange/24531-accurate-fast-marching)

[Tree Toolbox](http://www.treestoolbox.org/)

[Vesselness filter](http://au.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter)

[Level set](http://uk.mathworks.com/matlabcentral/fileexchange/24998-2d-3d-image-segmentation-toolbox)

[Otsu Link](http://www.mathworks.com/matlabcentral/fileexchange/26532-image-segmentation-using-otsu-thresholding/content/otsu.m)

[Loops link](http://au.mathworks.com/matlabcentral/fileexchange/10722-count-loops-in-a-graph/)

[dir2](http://au.mathworks.com/matlabcentral/fileexchange/40016-recursive-directory-searching-for-multiple-file-specs/content/dir2.m)

[fm_tool_1.7](http://au.mathworks.com/matlabcentral/fileexchange/30853-field-mapping-toolbox)


