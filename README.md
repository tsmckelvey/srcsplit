# srcsplit

### About
SourceSplit (srcsplit) is a syntax and command-line program for authoring multiple source-code outputs from a single file input.

### Installation

SourceSplit isn't yet on NPM.

Instead, clone the repository and run:
```
$ npm link
```
In the repository root directory.

### Usage

```
$ srcsplit -s NamedStream <file>
```

Then redirect output to your file of choice:

```
$ srcsplit -s Server advanced-example.src > productlist.isml
$ srcsplit -s Client advanced-example.src > UI.Views.ProductList.cjsx
```

### Example (Simple)

simple-example.src
```
[All]
<div>
[~Server]
  This string should only be rendered from a server-side template.
[~Client]
  This string should only be rendered from a client-side template.
[All]
</div>
```

### Example (Advanced)

advanced-example.src
```
/*-
All: [Util.RemoveBlankLines]
Client: [ReactCompat.ConvertClassToClassName]
Server: []
-*/

[~Client]
define 'UI.Views.ProductList', [], ->

[All]
  <div class="productList">

[~Server] Loop over products.
    <isloop iterator="${pdict.SomeIterator}" var="i">
[~Client]
    {@state.products.map =>

[All] Emit a .productTile.
      <div class="productTile">
      </div> <!-- end .productTile -->

[~Client]
    }
[~Server]
    </isloop>

[All]
  </div> <!-- end .productList -->
```
