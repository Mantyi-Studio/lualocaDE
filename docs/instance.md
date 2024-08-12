# Methods

## add_on_update
Creates a new on_update event that fires if one of the `nodes` is updated. Returns its id which is necessary for editing and deleting it.
### Params:
0. self: lualocaDE.instance
1. nodes: (node | druid.text)\[]
2. before?: fun(self: lualocaDE.instance) - calls before updating
3. after?: fun(self: lualocaDE.instance) - calls after updating
### Returns:
1. integer - on_update function id

## create
Creates a new lualocaDE object for `node` (you can use druid text nodes). If no `object` is specified, creates one based on `node` text.
### Params:
0. self: lualocaDE.instance
1. node: node | druid.text
2. object?: [lualocaDE.object](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/main.md#lualocaDEobject)
### Returns:
1. [lualocaDE.object](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/main.md#lualocaDEobject)

## delete
Deletes the lualocaDE object of `node`
### Params:
0. self: lualocaDE.instance
1. node: node | druid.text

## delete_on_update
Deletes an on_update event with `id`
### Params:
0. self: lualocaDE.instance
1. id: integer

## get
Returns object of `node`
### Params:
0. self: lualocaDE.instance
1. node: node | druid.text
### Returns:
1. [lualocaDE.object](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/main.md#lualocaDEobject)

## to_object
Returns a new lualocaDE object based on `string`
### Params:
0. self: lualocaDE.instance
1. string: string
### Returns:
1. [lualocaDE.object](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/main.md#lualocaDEobject)

## update
Updates text of the specified objects. By default, updates all objects.
### Params:
0. self: lualocaDE.instance
...: node | druid.text
