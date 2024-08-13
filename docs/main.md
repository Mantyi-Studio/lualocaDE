# Syntax
Read about syntax in [syntax.md](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/syntax.md)

# Types
## lualocaDE.object
Table containing data needed to get text and set it to a text node\
[lualoca.object](https://github.com/Mantyi-Studio/lualoca/blob/main/docs/main.md#lualocaobject) + 
```
{
	font: string - font style,
	callback?: fun(self: self, node: node|druid.text, text: string, language: string) - calls after updating text
}
```
[About font names](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/syntax.md#font-names)

# Classes
## [Instance](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/instance.md)
It's needed to autotranslate text. Every lualocaDE instance can use 2 languages: [main and spare](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/main.md#params)

# Functions
## Instance
Creates a new [lualocaDE.instance](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/main.md#instance)
### Params:
1. funlutab: [funlutab module](https://github.com/Mantyi-Studio/funlutab)
2. lualoca: [lualoca module](https://github.com/Mantyi-Studio/lualoca)
3. path: string - path to folder with json files of localizations
4. path_to_params: string - path to json file with params for all languages
5. main_language: string - main language
6. spare_language?: string - if there is no text localization in the main language, localization on the spare language will be used
### Returns:
1. [lualocaDE.instance](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/main.md#instance)

# Constants
## VERSION
Current module version ("4.0")
