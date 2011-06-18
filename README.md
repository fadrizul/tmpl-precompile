# jade-precompile - Jade Template Precompiler

jade-precompile will process a group of jade templates and output a javascript file containing a
precompiled function for each template. 

A primary use case is to send a javascript file containing precompiled jade templates to a browser.
The template can then be rendered by simply calling a function. Jade does not need to be included 
client-side for the templates to render, as the templates have been converted into pure javascript 
functions.

*NOTE:* This module is my first foray into any node.js technologies, including npm, jade, and uglify.
I'm not even sure if precompiling jade templates to serve to a browser is a good idea. The size of 
each output script for a tiny template is 2KB or 1.25KB uglified. An application with many large 
templates will probably find that using jade.js in the browser might actually be better. This 
project is really just intended as an experiment for now, but if it proves useful I will pursue 
further development.

## Usage

jade-precompile can be run from a shell command prompt, although it actually runs within node.js. 

### Basic Usage

    cd examples
    jade-precompile

By default, jade-precompile will look for a settings file named `jade-precompile.json` in the
current directory. This settings file defines which jade templates should be precompiled and the
output javascript file to save them in.

It is possible to specify a custom settings file as a command line parameter:

    jade-precompile settings.json

## Settings

The settings file defines one or more groups of jade templates. Each group of templates will be saved
into a separate output file. Each output can be uglified. File paths can be relative to the current
working directory or to the file system root.

Here is an example settings file:

	{
		"relative": true,
		"groups": [
			{
				"uglify": true,
				"namespace": "NS.uglified",
				"source": "/templates/",
				"output": "/output/uglified.js",
				"templates": [
					"layout",
					"root"
				]
			},
			{
				"uglify": false,
				"namespace": "NS.templates",
				"source": "/templates/",
				"output": "/output/templates.js",
				"templates": [
					"layout",
					"root"
				]
			}
		]
	}

The example above will process the following jade templates:

    ./templates/layout.jade
    ./templates/root.jade

These templates will be compiled into javascript functions and saved into the following files:

    ./output/uglified.js
    ./output/templates.js

The functions will have the following names:

    NS.uglified.layout
    NS.uglified.root
    NS.templates.layout
    NS.templates.root

### relative

If true, then the source and output paths are relative to the current working directory. If false, 
then source and output are relative to the file system root.

### groups

This must be an array of objects, even if only one group is specified. Each object represents a
group of jade template files and the options used to process them.

### uglify

If true, then the output file is uglified before saving. If false, the output is not uglified.

### source

Specifies the directory that contains `*.jade` template files. This directory is relative to the
current working directory if `relative` is true, otherwise the directory should be a fully
qualified path from the root of the file system.

### output

Specifies the location and filename of the javascript file to create. This javascript file will
contain a function for each template in the group. This file path is relative to the current 
working directory if `relative` is true, otherwise the path should be a fully qualified path 
from the root of the file system.

### templates

This must be an array of strings. Each string represents the name of a template. These strings are
used both as file names and as function names. There must be a `*.jade` file with the name specified 
in each string.

## Installation

This repo contains a precompiled `jade-precompile.js` file, but if you make changes to the
`jade-precompile.coffee` files, you need to recompile it:

    coffee -b -c jade-precompile.coffee

Make sure the script is executable:

     chmod 755 lib/jade-precompile.js
