# BCUS: Bayesian Calibration, Uncertainty, and Sensitivity
BCUS: Bayesian Calibration, Uncertainty, and Sensitivity is a cross platform set of Ruby and R scripts to support sensitivity analysis, uncertainty analysis, and Bayesian calibration of OpenStudio energy models.

Tutorials explaining installation and use of BCUS are found within the tutorials directory

The software has been developed in Windows 7 and has been tested on OS-X El Capitan

## Installation

#### BCUS has the following dependencies

* OpenStudio (>=1.11) with Ruby 2.0 bindings and EnergyPlus
* Ruby 2.0
* Ruby Gems: rubyXL
* R (>=3.1.0)
* R packages: sensitivity, ggplot2, lhs, car, triangle, gridextra 

* BCUS makes use of .xlsx spreadsheets.  While these can be read and written using OpenOffice or LibreOffice, some of the 


#### Ruby Install
For windows users it is recommended to use RubyInstaller obtained from 
http://rubyinstaller.org/downloads/

For OSX and Linux users it is recommended that you use the ruby version manager (rvm) 

Intall the ruby gem rubyXL with the command:   
`gem install rubyXL`


#### R Install
You can obtain an R install from the Comprehensive R Archive Network (http:/cran.r-project.org) but for higher performance, you may prefer to install Microsoft R Open with MKL extensions (https://mran.revolutionanalytics.com/download/)

__Note: It is recommended that even if you have those R packages listed above in the dependencies installed on your system, you should run the install_RPackages.rb included with BCUS as described below after setting the environmental variables to ensure that the R packages are accessible from `rinruby` which is used by BCUS to call R from Ruby__




#### BCUS Installation
* Copy the BCUSCode directory to your location of choice and set the environmental variable "BCUSCODE" to that directory
* add the same directory to your RUBYPATH

    For example, on a Windows system where BCUSCode is in C:\BCUS\BCUSCode you would set the following:  

    `set BCUSCODE=C:\BCUS\BCUSCode`  
    `set RUBYPATH=C:\BCUS\BCUSCode;%RUBYPATH%`  

    __NOTE: In windows, to permanently set the environmental variables you also need to use the setx command in addition to the set command as described above__

* Install R packages  
Install the R packages sensitivity, ggplot2, lhs, car, triangle, gridextra using the ruby script install_Rpackages.rb.  This script calls the RinRuby included in BCUS to install the R packages in a manner that they are accessible by `rinruby` as needed by BCUS.  To do that, open a command window and type the following command

    `ruby -S install_Rpackages.rb`  (the -S tells ruby to search %RUBYPATH%)

    If your environmental variables are set up properly, this ruby script will install (or re-install) the required R packages.
	
### Testing the installation
You can do a basic test of the installation by downloading the TestInstall directory, opening a command line, and running the TestInstall.bat or TestInstall.sh file

* Test installation by downloading the TestInstall directory and running the TestInstall.bat file


## Documentation

Instructions on how to use/run/modify are in the Tutorials directory

## Usage

Use the example directory as a base for your project.  Modify the files as discussed in the tutorials.




## Caveats and Todos

## Contributing
1. Fork it (https://github.com/Argonne-BEDTR/BCUS/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Wait a while until we find time to review the Pull Request






