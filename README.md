# Code Generator (visual programming)

![App pic](/Help/app.png)

One of life time projects. It is related to my research in currency market analysis and trading. Just one simple tool to test one trading strategy per day. It became much more sophisticated then I expected, but it helped me to check over a hundred strategies and even to select the best ones to trade real market.

## Code generator features

It wasn't intended to avoid coding, but to make it faster and visually manageable reusing independent code blocks.

### Pros

- It is compatible to any programming language and compiler, but mostly well designed for MQL4/5.
- It is based on visual Scheme editor, so it is easy to use and understand script logic.
- It has built-in blocks editor.
- Blocks and chains have adaptive coloring schemes for visual representation.
- It has layers support to group and fold code blocks.
- You can enable/disable blocks on the fly, manage debugging and build priority.
- It supports rich text blocks description.

### Cons

- It is from the past (started in 2008). The codebase remains the same. Don't expect any shiny modern frameworks here.
- Codebase is in Delphi 7. Old good IDE - simple and reliable, but well deserted in time.
- It is not a product, but a tool for my research.
- Code blocks are not well documented and it was originally targeted Russian-speaking audience.
- There is no learning curve or materials, everything made as is, to solve market research needs as fast as possible.

## Fast start guide

- Download last CodeGen release in your language from [GitHub releases](https://github.com/zergos/codegen/releases).
- Unpack it to any folder.
- Open CodeGen.exe.

## Development guide

- Download Delphi 7 or Delphi 7 Lite (ActionBar, Internet, Internet Direct).
- Open `CodeGroup.bpg` in Delphi 7.
- Build `CodeGen.exe` and `CC.exe`.

## Files format

### Compiler definition

Define compiler in `ini` files in `Schema` folder.

Section `[Main]`:

- `Base` - subdirectory base name in `Schema` folder.
- `Title` - compiler title.
- `DestMask` - destination mask for files dialogs in format `File type name|*.ext`.
- `BinExt` - binary extension after build.
- `PathPostfix` - last chunk of file path to cut to variable `$Path$`.
- `Compiler` - compiler binary path and command args.
- `DebugBlock` - explicit block name to insert debug log lines.
- `DebugLine` - debug log template.
- `CheckLog` - check log file after build `true` or `false`.
- `ErrorCheck` - template text to search for error in log file.
- `StringType` - string type to detect for language translation (C, C++, Pascal, etc). `C` is only supported now.

All other parameters are treated as custom variable names to insert into compiler command line.

Reserved `$variable$` names:

- `Name` - file name without extension.
- `Path` - file path ended to `PathPostfix`.
- `Log` - destination file name with `.log` extension.
- `Exe` - destination file name with extension.

It is possible to use Windows registry string keys in command line. Format it as `[HKLM\Software\Anything\Parameter]` or `[HKCU\...]`.

Example for MQL5:
```ini
[Main]
Base=MQL
Title=MetaQuotes Language 5
DestMask=Scripts MQ5|*.mq5
BinExt=ex5

MTPath=C:\Program Files\FINAM MetaTrader 5
PathPostfix=\MQL5
Compiler="$MTPath$\metaeditor64.exe" /inc:"$Path$" /compile:"$Name$" /log

DebugBlock=lines
DebugLine=Print("%s");

CheckLog=true
ErrorCheck=: error

StringType=C
```

## Schema unit (object) definition

All schema units (objects or tools) are stored in subdirectories of directory `Schema`.

* All objects has `*.o` file extension.
* Enumerated values are stored in `*.e` files.
* Translated strings are stored in `language.lst` file.
* Objects files are grouped by subdirectories on a disk, but visually grouped by property name `Group`.
* Each object has ini-like syntax, can contain several code sections to be inserted to current code template.
* Each section has it is own subsyntax described below.

Schema logic:

* Each visual schema contains several object-based blocks connected by chains.
* Each block can has data inputs and outputs, and control inputs and outputs. Control chains provide execution sequence, but data chains provides named data structures.
* Each block operates with input in output parameters, that are usually flow by control chains, but can be specified in case of multiple control inputs or specified manually on the visual schema.
* Complex chunks of blocks could be folded to layers.

### Schema unit file definition

#### Main section

`[Main]`

First line in section `Main` optionally defines objects as special one:
- `Modular` - root object with global template. Each new schema must be started with any modular object. Must have "Template" section.
- `Unit` - object is intended to be added to a schema to provide required functions for other blocks. It usually doesn't have any inputs of outputs.
- `Usable` - object is intended to be used by other objects like one before, but with differences: it is invisible on schema and it inherits caller properties.
- `Choice` - object is intended to to provide conditional logic. This mode removes default `CTRL` output and allows other multiple named control outputs.
- `BlockIn` - service object to define layer's input connection point.
- `BlockOut`- the same, but output connection point.
- `Custom` - regular object, but without default control inputs and outputs

If specialty is not defined - object treated as regular one: it has one default input control slot (must be connected) and one default output control slot (optionally connected).

Further lines define additional properties in format `Name=value`. All are required.
- `Title` - user readable name
- `Group` - user readable group name
- `Name` - unique machine readable name - to generate block names

#### "Uses" section

`[Uses]`

List of relative paths to all included _usable_ objects as modules (no extension needed).

Example:
```
[Uses]
common\compat
```

#### Properties section

`[Property]`

This section provides properties to customize block logic via design time.

The common syntax is:
```
PropertyName=type,default_value,description
```

Use `#` symbol character in the beginning of the line to comment out the property.

- `PropertyName` - any property identifier
- `type` - type hint for schema designer. Allowed types:
  - `t` - trigger type: _filled_ or blank. Intended to enable additional logic blocks.
  - `n` - numeric integer type
  - `f` - floating real type
  - `s` - any string (without quotes)
  - `d` - date representation
  - `file_name` - enumerated value selected from file `file_name.e`
- `default_value` - any string as default value. Commas mush be masked by backslash `\`
- `description` - any textual description visible design-time. Commas mush be masked by backslash `\`

#### Inputs

`[Input]`

List of all object inputs. Format is following:
```
InputName=type,description,default_flag
```

- `InputName` - any input symbol identifier
- `type` - type hint to mark input slot. Additionally to property types there are two special types:
  - `c` - control type. Mark input slot as control redirection. One control input slot and one control output slot named `CTRL` are created by default for each regular block.
  - `row` - any array-like structure or data generator
- `description` - any textual description
- `default_flag` - mark this input slot as default for _input parameters_ inheritance. Possible values: `d` or blank.

#### Outputs

`[Output]`

List of all object outputs. Format is following:
```
OutputName=type,symbol,description
```

- `OutputName` - any output symbol identifier
- `type` - type hint similar for input slot
- `symbol` - local variable name or any other code prepared to share as data to another chained block
- `description` - any textual description

#### Input parameters

`[InputPars]`

List of all required _input parameters_ names to execute the code.
Format is simple: one parameter name per line.
```
ParamName
```

#### Output parameters

Define or redefine output parameters for further connected blocks.
```
OutputParName=symbol
```

- `OutputParName` - the output parameter identifier, new or presented as input parameters
- `symbol` - any local variable name

#### Code sections

`[Code]`

This section contains programming language code. Code is divided to the blocks, each one related to specified named slot of template.

Each blocks started with special mark (should be started at the beginning of the line):
- `<block_name>` - contains block of code to be inserted by the order of appearance
- `<block_name*>` - code, inserted to the end of the block
- `<block_name^>` - code, inserted to the beginning of the block

Each block can operate with object properties. Each object property starts with "$" prefix. Following properties are accessible:
- Properties, defined in section `[Property]`.
- `[Input]` and `[Output]` related variable names. 
- `[InputPars]` and `[OutputPars]` parameters.
- Predefined parameters:
  - `$name` - block unique name
  - `$index` - zero-based index of this object appearance on the schema
  - `$index1` - the same, but 1-based index
  - `$debug` - contains "1" if debug is enabled for this block or for overall schema
  - `$comments` - contains `comments` entered to the block at design-time
  - `$version` - plain integer version number (auto-increased on each compilation)
  - `$english` - contains "*" if output language defined as english, blank otherwise
  - `$modular_name` - contains "1" if parameter name matches root schema modular name
  - `$schema_name` - contains "1" if parameter name matches schema name (from compiler definition configuration)

If a newline starts with `$`, it treated as template slot:
- `$mapped_block_name` - template slot, defined in `[Map]` section
- `$output_name.block_name` - redefine global template slot named "block_name" (specifically for output control flow named "output_name") to this place of code.

There are several code section to control workflow:
- `[Code]` - regular code, inserted to template by order of appearance or by design order
- `[Global]` - inserted to template by order, but only once for such type of object. Good for one-time initializations.
- `[Prefix]` - inserted by order, but to the beginning of the template block. Good for local initializations like opening files and connections, allocation structures etc.
- `[Postfix]` - inserted by order, but to the end of the template block. Good for uninitializations.

Each object parameter could be used in conditional macro-code:
```
<?Condition>
...code if condition is true
<~>
...otherwise
</>
```
Condition macro-code could be nested. Possible options for condition expressions:
- `<?Parameter>` - check if `$Parameter` is defined
- `<?!Parameter>` - check if `$Parameter` is not defined
- `<?Parameter=value>` - check if `$Parameter` literally equals "value"
- `<!?Parameter=value>` - check if `$Parameter` does not literally equal "value".

Example:
```
<?LogicIsEnabled>Print("Logic is enabled!");</>
```

Isolate variable names with "@" prefix, or mix with "$name" parameter. For, example, for blocks named `Logic1`, `Logic2`, `Logic3`... based on object `Logic`:
```
<lines>
  int @local = 1;
  // the code above generate variable names local, local1, local2, ...

<lines>
  int local_$name = 1;
  // this code generates local_Logic1, Local_Logic2, ...
```

Create external files by `=file_name` construction in the beginning of the line. All code until end of the block or until another `=file_name` mark is treated as external file content.
- You can use "*" for base name of generated file.
- You can use "#" postfix to export hex encoded binary file. `bin2hex.exe` util is inside `Utils` directory.

Example:

```
<header>
#include "unit.h"

<attach>
=unit.h
void func();
=*.res#
EFBBBF53696D706C652074657874210D0A
```

#### Template section

`[Template]`

Defines global template, must be presented in _modular_ object. Essentially, it contains programming language code with named marked slots to insert other objects code. Each named mark should starts from the begging of the line prefixed with symbol `$`.

For example:
```c
void main() {
$lines
}
```

#### Control map section

`[Map]`

Define additional template block slot to extend global template.

Format is following (to just define new block slot):
```
BlockName=new
```

or (to redefine global template slot)
```
BlockName=block_name,output_name
```

- `BlockName` - any identifier for the new template slot
- `block_name` - global template slot name
- `output_name` - control output slot name
- `new` - reserved word

#### Help section

`[Help]`

Markdown-compatible textual description of object's logic. Supported formatting specifiers:
- `**bold**`
- `__italic__`
- `[[name@email.com]]`
- `[[google.com]]`
- `<code>a = 1</code>`
- `-` - numerated list
- `*` - non-numerated list
- `\\` - line break
- `----` - line break with horizontal line
- Some smiles pictures `:-) =) :-D :-( :-/ :-\ 8-) :-| :-o ;-)`

## Enumerated definitions files

Enumerated types - are types, where the state is described by predefined constant value, usually by literal constant name. CodeGen propose to collect such constants in specific enumerated definitions files as a part of schema. The format of a file "*.e" is simple:

```
CONST_NAME - description
```

- `CONST_NAME` - is an actual value
- `description` (optional) - is a visual hint in value selection dialog. It supports translation via `language.lst`.

For example:
```
PRICE_CLOSE - Price of candle closing
PRICE_OPEN - Price of candle opening
```

## Code colorer

CodeGen is bundled with simple code editor `CC.exe`. It supports syntax highlighting for programming languages, including "*.o" object files. It was built as simple and customizable tool based of regex expressions. Therefore it works a bit slowly, but also motivates to keep object files compact.

## Localization

It is originally build in Russian language, to perform translation, several steps needed.

### Application interface

- Download [Better Translation Manager](https://github.com/andersmelander/better-translation-manager/releases)
- Build `CodeGen.exe`
- Run `amTranslationManager.exe`
- Open `CodeGen.xlat`
- Set source "Russian" and target "English"
- Perform needed translations
- Press Build -> English... and save `CodeGen.en` file
- Run in command line `ResInjectorEn.bat CodeGen`
- Run `CodeGen.en.exe` to check result

The same steps for `CC.exe`.

### Scripts messages translation

- Set an option in `CodeGen`: `Builder language` -> `English`.
- Compile (or generate output) with this option to update `language.lst` file.
- Add translated messages to this file if needed.
- Compile again.

## License

LGPL 2.1
