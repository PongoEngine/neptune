<img src="./neptune.png" height="200"  align="right">

# Neptune (WIP!!!)

Neptune is a renderer that sits on top of an application. It will automatically track changes in state and update the view. It is written as a HTML first tool but other platforms will be supported.

Goal: To have an inuitive API that feels like vanilla haxe. A macro is used to generate the view expressions but it shouldn't feel like its affecting the code.

Status: I'm currently working on what each expression type will transform into when in markup mode. I'm hoping to have all expression types accounted for and then will transition into tracking assignment expressions in different scopes.

Sidenote: If anyone reading this knows how the xml meta macro works hit me up. It functions well enough but I ran into a couple cases where it disagrees on what I consider valid.

## Expressions

- [x] EConst
* CInt
  * Value: TextNode
  * Update: None
* CFloat
  * Value: TextNode
  * Update: None
* CString
  * Value: TextNode
  * Update: None
* CIdent
  * Value: TextNode
  * Update: Update text content when identifier changes
* CRegexp
  * Not Supported

- [x] EArray
  * Value: Node
  * Update: Replace node when array index changes

- [x] EBinop
  * Value: TextNode
  * Update: Update text content when value changes

- [ ] EField

- [x] EParenthesis
  * Value: Node
  * Update: Determined by parenthesis item

- [ ] EObjectDecl
  * Not Supported

- [x] EArrayDecl
  * Value: Fragment
  * Update: None

- [ ] ECall

- [ ] ENew
  * Not Supported

- [x] EUnop
  * Not Supported

- [x] EVars
  * Not Supported

- [ ] EFunction
  * Not Supported

- [x] EBlock
  * Value: Node
  * Update: None

- [x] EFor
  * Value: Fragment
  * Update: Replace node when condition changes

- [x] EIf
  * Value: Node
  * Update: Replace node when condition changes

- [ ] EWhile

- [ ] ESwitch

- [ ] ETry

- [ ] EReturn

- [x] EBreak
  * Not Supported

- [ ] EContinue

- [ ] EUntyped

- [ ] EThrow

- [ ] ECast

- [ ] EDisplay

- [ ] EDisplayNew

- [ ] ETernary

- [ ] ECheckType

- [ ] EMeta
  * Value: Node
  * Update: None
