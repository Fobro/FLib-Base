# FLib Base

FLib is a Lua filestructure and central library for managing Garry's Mod servers and FLib-based addons. FLib-Base currently includes a wide variety of features all packed into a single menu:
- Server analytics which report on performance and connectivity over a period of time
- In-game configuration
- Player management and analysis
- Hotload which allows for mid-game resource downloads
- Development panel with Lua environment and other basic features

## Lua Documentation (Part 1: Functions)

Below are the lua functions that can be used for FLib-based works and compatibility

### **FLib.Func.AddSharedFile(** _path_ **)**
- _path_: file path relative to lua/flib

Adds the lua file to the client realm and then executes on both server and client

_**Example**_

FLib.Func.AddSharedFile( "modules/mymodule/mysharedscript.lua" )



### **FLib.Func.AddClientFile(** _path_ **)**
- _path_: file path relative to lua/flib

Adds and executes the lua file on client realm

_**Example**_

FLib.Func.AddSharedFile( "modules/mymodule/myclientscript.lua" )



### **FLib.Func.AddServerFile(** _path_ **)**
- _path_: file path relative to lua/flib

Executes a lua file only on the server

_**Example**_

FLib.Func.AddSharedFile( "modules/mymodule/myserverscript.lua" )



### **FLib.HotLoad.URLSource(**  _identifier_,  _url_, _filetype_, _onLoad_ **)**
- _identifier_ (string): the name (string index) used to retrieve the returned object. This had to be done since http is async
- _url_ (string): a link to the direct file (i.e. imgur.com/example.png)
- _filetype_ (string): this is really needed for VTF/VMT, but valid filetypes can be found under the gmod wiki page for file.Write
- _onLoad_ (function): a function that runs when the material is loaded (there is one parameter which is either the object, if material/image, or identifier otherwise)

Produces a resource (image, material, data, or sound) and stores it on disk while the user is playing. This functions returns nothing but will produce (depending on the file type)
- Images will be stored under **FLib.Resources.[_identifier_]**
- Sounds will be registered in gmods actual sound table under the sound name of the _identifier_ argument
- Materials will be stored in the same table formatting as the images (FLib.Resources.[_identifier_])


_**Example**_

local url = [[https://image.pngaaa.com/324/121324-middle.png]]

FLib.HotLoad.URLSource( "loadingIcon", url, "png" )

hook.Add( "HUDDraw", "Example", function()
    surface.SetMaterial ( FLib.Resources["loadingIcon"]:GetName() )
end )

### **FLib.HotLoad.SourceInSequence(**  _sequence identifier_,  _URL Source Table_**)**
-  _sequence identifier_ (string): the name (string index) used to retrieve data on the sequence (no further functions ready)
- _URL Source Table_ (table): a table containing the order of args needed in a regular URLSource (see example)

Produces an ordered series of resources from a given URL, making sure they download one after another rather than all at once (to prevent lag). You can't add to a sequence once it is started (since it internally measures progress), so try and cram as many needed resources into as few sequences to reduce the amount of coinciding downloads (keep more bandwidth for gameplay)


_**Example**_


FLib.HotLoad.SourceInSequence( "MenuButtons", {

	{ "main", "https://i.imgur.com/695Hxjv.png", "png" },

	{ "manage", "https://i.imgur.com/I10A7NH.png", "png" },

	{ "analysis", "https://i.imgur.com/4uCuUOt.png", "png"},

	{ "config", "https://i.imgur.com/cpRpoL3.png", "png"},

	{ "develop", "https://i.imgur.com/Sbid91C.png", "png"}

} )


## Lua Documentation (Part 2: File Structure)

In order to add a module to FLib, you need to use the expected file structure. This is pretty relaxed, in that FLib will simply search each folder in "lua/flib/modules" for a file called "autorun.lua". This will be executed as a shared file, so I suggest running the rest of your file initiation from there using the more specified functions (FLib AddServerFile etc)

## Lua Documentation (Part 3: Hooks)

### **Shared, FLib.PlayerLoaded, function( ply )**

Called when a player has rendered in the game, called using PostInitDraw

_**Arguments**_
- _ply_: the player who loaded in