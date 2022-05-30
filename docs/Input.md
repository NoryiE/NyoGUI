With input's you are able to create a object where the user can type something in.<br>

Here are all possible functions available for inputs:<br>
Remember input inherits from [object](https://github.com/NoryiE/NyoUI/wiki/Object):

## setInputType
changes the input type
````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aInput = mainFrame:addInput("myFirstInput"):setInputType("password"):show()
````
**parameters:** string value ("text", "password", "number")<br>
**returns:** self<br>