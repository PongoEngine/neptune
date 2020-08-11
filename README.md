<img src="./neptune.png" height="200"  align="right">

# Neptune (WIP!!!)

Neptune is a renderer that sits on top of an application. It will automatically track changes in state and update the view. It is written as a HTML first tool but other platforms will be supported.

Goal: To have an inuitive API that feels like vanilla haxe. A macro is used to generate the view expressions but it shouldn't feel like its affecting the code.

Status: I'm currently working on what each expression type will transform into when in markup mode. I'm hoping to have all expression types accounted for and then will transition into tracking assignment expressions in different scopes.

Sidenote: If anyone reading this knows how the xml meta macro works hit me up. It functions well enough but I ran into a couple cases where it disagrees on what I consider valid.

## Expressions

- [x] EConst
* CInt
  * Renders to a node
* CFloat
  * Renders to a node
* CString
  * Renders to a node
* CIdent
  * Saves to var
  * Updates when reference is modified
  * Renders to a node
* CRegexp
  * Not Supported

- [x] EArray
  * Updates when array index is modified
  * Renders to a node

- [ ] EBinop

- [ ] EField

- [ ] EParenthesis

- [ ] EObjectDecl

- [ ] EArrayDecl

- [ ] ECall

- [ ] ENew

- [ ] EUnop

- [ ] EVars

- [ ] EFunction

- [ ] EBlock

- [ ] EFor

- [ ] EIf

- [ ] EWhile

- [ ] ESwitch

- [ ] ETry

- [ ] EReturn

- [ ] EBreak

- [ ] EContinue

- [ ] EUntyped

- [ ] EThrow

- [ ] ECast

- [ ] EDisplay

- [ ] EDisplayNew

- [ ] ETernary

- [ ] ECheckType

- [ ] EMeta
