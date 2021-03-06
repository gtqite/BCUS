#                    Copyright © 2016 , UChicago Argonne, LLC
#                              All Rights Reserved
#                               OPEN SOURCE LICENSE

# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list
# of conditions and the following disclaimer.  Software changes, modifications, or 
# derivative works, should be noted with comments and the author and organization’s name.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list
# of conditions and the following disclaimer in the documentation and/or other materials 
# provided with the distribution.

# 3. Neither the names of UChicago Argonne, LLC or the Department of Energy nor the names
# of its contributors may be used to endorse or promote products derived from this software 
# without specific prior written permission.

# 4. The software and the end-user documentation included with the redistribution, if any, 
# must include the following acknowledgment:

# "This product includes software produced by UChicago Argonne, LLC under Contract 
# No. DE-AC02-06CH11357 with the Department of Energy.”

# ******************************************************************************************************
#                                             DISCLAIMER

# THE SOFTWARE IS SUPPLIED "AS IS" WITHOUT WARRANTY OF ANY KIND.

# NEITHER THE UNITED STATES GOVERNMENT, NOR THE UNITED STATES DEPARTMENT OF ENERGY, NOR UCHICAGO ARGONNE, 
# LLC, NOR ANY OF THEIR EMPLOYEES, MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LEGAL LIABILITY 
# OR RESPONSIBILITY FOR THE ACCURACY, COMPLETENESS, OR USEFULNESS OF ANY INFORMATION, DATA, APPARATUS, 
# PRODUCT, OR PROCESS DISCLOSED, OR REPRESENTS THAT ITS USE WOULD NOT INFRINGE PRIVATELY OWNED RIGHTS.

# ***************************************************************************************************

# Modified Date and By:
# - Created on Feb 27, 2015 by Matt Riddle from Argonne National Laboratory

# 1. Introduction
# This is the function to generate histograms and scatterplot matrices showing posterior distributions, with comparison to priors

# 2. Call structure
# Refer to 'Function Call Structure_Bayesian Calibration.pptx'


#===============================================================%
#     author: Matt Riddle, Yuming Sun							%
#     date: Feb 27, 2015										%
#===============================================================%

# GraphPosteriors Function to generate histograms and scatterplot
#   matrices showing posterior distributions, with comparison
#   to priors
#

#         Use this function to:
#            1. Generate histograms and scatterplot
#   matrices showing posterior distributions, with comparison
#   to priors

# CALLS: density.R
# CALLED BY: GraphGenerator.rb

#==============================================================%
#                        REQUIRED INPUTS                       %
#==============================================================%
# params_filename: name of file holding info on parameter priors
# pvals_filename: name of file holding posterior distributions
#   generated by mcmc
# burnin: number of steps from mcmc results to be discarded 
#   before showing posterior distributions
# graphs_output_folder: folder that graphs will be saved in

#===============================================================%
#                           OUTPUTS                             %
#===============================================================%
# nothing is returned, but a set of graphs are saved to pdf files
#       in the specified folder:
#   PosteriorVsPrior1.pdf ... posteriorVsPriorN.pdf (N = numTheta)
#		a set of histograms, one per parameter, showing posterior
#       distributions for the parameter compared against its prior 
#       distribution
#   posteriorScatterPlotsV1.pdf and posteriorScatterPlotsV2.pdf
#		two versions of a matrix of graphs with the diagonal 
#		matrices showing posterior distributions for each 
#		parameter and the off-diagonal showing scatter plots 
#		of the joint distributions for each pair of parameters
#		These will be generated only if 2 <= numTheta <= 6 

#  COMMENTS: the code can be changed to graph scatterplot matrices 
#		with more than 6 parameters

#===============================================================%

graphPosteriors <- function(params_filename, pvals_filename, burnin, graphs_output_folder){

	#the following can be used for testing:
	#pvals_filename = "../Output/pvals.csv"
	#params_filename = "../Input/Calibration_Parameters_Prior.csv"
	#burnin = 1

	source("readFromParamFile.R")
	source("density.R")
	theta_info <- readFromParamFile(params_filename)

	num_theta = length (theta_info);
	pvals = read.csv(pvals_filename);
	pvals = tail(pvals, nrow(pvals[1])-burnin); # significant difference when showing burnin-data

	#------------------------
	library (ggplot2);
	library (triangle);
	library(gridExtra); # http://www.r-bloggers.com/extra-extra-get-your-gridextra/
	library(car);
	#------------------------
	nBins = 32; # good: 100

	plots  = list(); # List of plots, later to be up in grid
	plots2 = list(); # List of plots, later to be up in grid
	Vs         = list(); # List of V1,V2, ... Vn

	for (i in 1:num_theta)
	{
		i<<-i; # make it global
		max_x = theta_info [[i]]$max;
		min_x = theta_info [[i]]$min;
		rang_x =  max_x - min_x;
		pvals[[i]] = pvals[[i]] * rang_x + min_x; # normalize pvals between min_x and max_x
		#message("adjusted pvals")

		histo = hist(pvals[[i]], breaks=seq(min_x, max_x, l=nBins), plot=FALSE); # good: 50 bins
		#message("created histogram")

		pvals<<-pvals; # make it global

		# histo = histogram of pvals[i]
		# get total area of histogram
		pval_area = 0;
		delta_x = histo$mids[2] - histo$mids[1]; # width of histogram bars
		delta_x <<- delta_x; # make it global?
		for (c in 1:length (histo$counts))
		{
			pval_area = pval_area + histo$counts[c] * delta_x;
		}

		# create triangular distribution

		x = seq (min_x, max_x, length.out=100); # good: 100 for straighter lines
		#y = dtriangle (x, theta_info[[i]]$prior$min, theta_info[[i]]$prior$max,
		#				  theta_info[[i]]$prior$mode);

		y <- c()
		for (xi in 1:length(x)){
			y = c(y, density2(theta_info[[i]]$prior, x[xi]))
		}
		#message("generated trangle ys")

		# Area of triangle is 1, scale it's height so that
		# the area becames the area of the original histogram.

		ty = y * pval_area; # = altitude of ttiangle
		prior = data.frame (x, ty); # the prior (triangular) distribution
		#message("made triangle data frame")

		Vs = c(Vs, pvals[[i]]); #---

		# plot the histogram and triangular dist

		figureName <- paste(sprintf("%s/PosteriorVsPrior", graphs_output_folder), as.character(i), ".pdf")
		pdf(figureName)
		plot1 <- ggplot() +
		geom_histogram (data=pvals, aes(x=pvals[[i]]), binwidth=delta_x) +
		geom_line (data=prior, aes(x=x, y=ty),  color="red", size=1) +
		xlim (min(pvals[i], min_x),max(pvals[i], max_x)) +
		labs (x=theta_info[[i]]$name);


		print (plot1);
		#dev.off()
		#message ("--- generated plot ", i, " ---");
		#message ("pval_area = ", pval_area);
		#message ("nBins = ", nBins);
		#message ("x range: ", min_x, " to ", max_x);
	}


	#------------------------------
	scatter1Filename = sprintf("%s/posteriorScatterPlotsV1.pdf", graphs_output_folder)
	scatter2Filename = sprintf("%s/posteriorScatterPlotsV2.pdf", graphs_output_folder)

	# scatter1Filename = "../Output/posteriorScatterPlotsV1.pdf"
	#	scatter2Filename = "../Output/posteriorScatterPlotsV2.pdf"
	if (num_theta == 2)  # include for Matt R. delivery
	{
		pdf(scatter1Filename)
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2, data=pvals, smoother=FALSE, diagonal="histogram", pch='.',
		col="black", reg.line=FALSE, var.labels=NULL); # main="title"
		pdf(scatter2Filename)
		#dev.off()
		var_labels = rep(0, times = num_theta)
		for (i2 in 1:num_theta){
			var_labels[i2] = theta_info[[i2]]$name
		}
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2, data=pvals, smoother=FALSE, diagonal="density", pch='.',
		reg.line=FALSE,
		var.labels=var_labels);
		#dev.off()
	} else if (num_theta == 3){
		pdf(scatter1Filename)
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2+V3, data=pvals, smoother=FALSE, diagonal="histogram", pch='.',
		col="black", reg.line=FALSE, var.labels=NULL); # main="title"
		#dev.off()
		pdf(scatter2Filename)
		var_labels = rep(0, times = num_theta)
		for (i2 in 1:num_theta){
			var_labels[i2] = theta_info[[i2]]$name
		}
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2+V3, data=pvals, smoother=FALSE, diagonal="density", pch='.',
		reg.line=FALSE,
		var.labels=var_labels);
		#dev.off()
	} else if (num_theta == 4){
		pdf(scatter1Filename)
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2+V3+V4, data=pvals, smoother=FALSE, diagonal="histogram", pch='.',
		col="black", reg.line=FALSE, var.labels=NULL); # main="title"
		#dev.off()
		pdf(scatter2Filename)
		var_labels = rep(0, times = num_theta)
		for (i2 in 1:num_theta){
			var_labels[i2] = theta_info[[i2]]$name
		}
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2+V3+V4, data=pvals, smoother=FALSE, diagonal="density", pch='.',
		reg.line=FALSE,
		var.labels=var_labels);
		#dev.off()
	} else if (num_theta == 5){
		pdf(scatter1Filename)
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2+V3+V4+V5, data=pvals, smoother=FALSE, diagonal="histogram", pch='.',
		col="black", reg.line=FALSE, var.labels=NULL); # main="title"
		pdf(scatter2Filename)
		var_labels = rep(0, times = num_theta)
		for (i2 in 1:num_theta){
			var_labels[i2] = theta_info[[i2]]$name
		}
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2+V3+V4+V5, data=pvals, smoother=FALSE, diagonal="density", pch='.',
		reg.line=FALSE,
		var.labels=var_labels);
	} else if (num_theta == 6){
		pdf(scatter1Filename)
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2+V3+V4+V5+V6, data=pvals, smoother=FALSE, diagonal="histogram", pch='.',
		col="black", reg.line=FALSE, var.labels=NULL); # main="title"
		pdf(scatter2Filename)
		var_labels = rep(0, times = num_theta)
		for (i2 in 1:num_theta){
			var_labels[i2] = theta_info[[i2]]$name
		}
		#if num_theta changes to N, need to change to ~V1+V2+V3+...+VN.
		scatterplotMatrix(~V1+V2+V3+V4+V5+V6, data=pvals, smoother=FALSE, diagonal="density", pch='.',
		reg.line=FALSE,
		var.labels=var_labels);
	} else{
		message("scatter plot matrices not generated because scatterplotMatrix command is only set up for 2-6 parameters")
	}
}