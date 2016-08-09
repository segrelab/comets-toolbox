------Generating Docs
Documentation is easily generated using M2HTML (http://www.artefact.tk/software/matlab/m2html/)

To regenerate the documentation, delete the 'doc' folder then run the following MATLAB command in the CometsToolbox folder's parent directory.
	m2html('mfiles','CometsToolbox', 'htmldir','CometsToolbox/doc', 'recursive','on', 'global','on','template','frame','index','menu')


------LEGAL
COMETS (Computation Of Microbial Ecosystems in Time and Space) is Copyright (C) 2014 Daniel Segre, Bioinformatics Program, Boston University, Boston, MA. All rights reserved. E-mail: <dsegre@bu.edu>. COMETS is available under the terms of the GNU General Public License version 3.

Scripts included here as part of the COMETS Toolbox are Copyright (C) 2016 Daniel Segre, Bioinformatics Program, Boston University, Boston, MA. All rights reserved. E-mail: <dsegre@bu.edu>. COMETS is available under the terms of the GNU Lesser General Public License version 3.

------Contact
The COMETS toolbox is currently maintained by Michael Quintin. E-mail: mquintin@bu.edu