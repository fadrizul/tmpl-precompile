version = [0,1,3]

jade = require 'jade'
fs = require 'fs'
path = require 'path'
util = require 'util'
jsp = require("uglify-js").parser
pro = require("uglify-js").uglify

# Module requires
namespace = require './namespace'
{extractFunction, optimizeOutput} = require './optimize'

# Globals

cwd = ''
settings = {}

###
Precompiler(groupSettings)
Description: Creates a Precompiler instance for executing precompiling work

settings: 
  "uglify": Boolean(default:false), whether to minify JS
	"namespace": String(Required), namespace object when including templates to browser
	"source": String(Required), relative path to source directory
	"output": String(Required), relative path to output directory
	"templates": Array(Required), names of templates to be precompiled
  "compileDebug": Boolean(default: false), whether to compile Jade debugging
  "inline": Boolean(default: false), whether to inline Jade runtime functions
###

class Precompiler
  constructor: (groupSettings, callback) ->
    @settings = groupSettings
    @settings.uglify = groupSettings.uglify || true
    
    self = @
    
    namespace(@settings, (err, res) ->
      if err? then console.log err
      else 
        self.namespaces = res.join('\n') + '\n'
    )
    
  ###
  compile(group, namespaces)
  Description: Starts compiling the templates and outputs file

  Params: 
    group: The 'group' object to process
    namespaces: Buffer string, the result of namespace checking
  ###

  compile : (callback) ->
    {templates, namespaces, inline, uglify, output} = @settings
    buf = ''
    
    for template in @settings.templates
  	  #buf += optimizeOutput @settings, @compileTemplate(template).toString()
  	  buf += @compileTemplate(template).toString()
    
    buf = @namespaces + buf if namespaces isnt false
    buf = @helpers + buf if inline isnt true
    #buf = @uglifyOutput buf if uglify
    
    console.log(@namespaces)
    
    
    if callback? then callback(null, buf)
    else
      console.log 'Saving ' + (if uglify then 'and Uglifying ' else '' ) + output
      fs.writeFileSync cwd + output, buf

  ###
  compileTemplate(template, group)
  Description: Runs Jade's compile function 
 
  Params:
    template: Template file name
    group: Template group settings
  ###

  compileTemplate : (template) ->
    {source, namespace, compileDebug, inline} = @settings
    
    templateNamespace = template.replace(/\//g, '.') # Replaces '/' with '.'
  
    if @settings.verbose
      console.log "Compiling #{namespace}.#{templateNamespace} from #{source+template}"
    
    dir = path.normalize(process.cwd() + '/test/' + source + template + '.jade')
    data = fs.readFileSync(dir, 'utf8')
    source = namespace + '.' + templateNamespace + ' = ' + jade.compile(data, {compileDebug: compileDebug || false, inline: inline || false}) + ';\n'
    

  helpers: (->
    # Get Jade helpers
    attrs = jade.runtime.attrs.toString()
    escape = jade.runtime.escape.toString()
    helpers = """
      #{attrs}
      #{escape}
      var jade = {
        attrs: attrs,
        escape: escape
      }\n
    """
    helpers
  )()

  ###
  uglifyOutput(output)
  Description: Minifies generated JS with uglifyJS
  ###

  uglifyOutput : (output) ->
  	ast = jsp.parse output  # parse code and get the initial AST
  	ast = pro.ast_mangle ast # get a new AST with mangled names
  	ast = pro.ast_squeeze ast # get an AST with compression optimizations
  	pro.gen_code ast # compressed code here


###
---Module exports---

precompile(group, namespaces)
Description: Main precompile function

Params: 
  settings(object): Global settings object for tmpl-precompile
    "verbose": Boolean(default:false), if should output compile info on console
    "relative": Boolean(default:true), if paths to each template is relative to settings file
  dir(string): Main execution directory
###

module.exports.precompile = (newSettings,dir) ->
	cwd = dir
	settings = newSettings
	for group in settings.groups
		namespace(group, (err, res) ->
      if err? then console.log err
      else 
        namespaces = res.join('\n') + '\n'
        compile(group, namespaces)
    )

module.exports.Precompiler = Precompiler