# Params file
Unlike normal lualoca where isn't necessary params, in Defold Extended version you have to set 2 neceassy params:\
font: string - font family\
pivot: "left" | "right" - side where starts writing
```json
{
	"en": {
		"font": "european",
		"pivot": "left"
	},
	"ar": {
		"font": "arabic",
		"pivot": "right"
	}
}
```

# Font names
Font names consist of 2 parts:
1. Family - may be common to 1 or more languages:\
   "european" - common to English, French, Russian...\
   "simplified_chinese" - only for Simplified Chinese
2. Style - regular, bold, italic...
In font name in GUI file these parts must be connected by "/". Example: "european/regular".

# String format of [lualocaDE.object](https://github.com/Mantyi-Studio/lualoca/blob/main/docs/main.md#lualocaDEobject)
Method [lualocaDE:to_object](https://github.com/Mantyi-Studio/lualoca/blob/main/docs/instance.md#to_object) uses this special string format\
**It only supports path and font params**. They must be separated by ";" symbol. To indicate what param it is before param value write 1st letter of its name ("p" - path, "f" - font) (you can write capital letter to make it easier to distinguish between param name and value).\
Params:
* font (f) - [font style](https://github.com/Mantyi-Studio/lualocaDE/blob/main/docs/syntax.md#font-names)
* path (p) - path connected by "/"

Example: `Pwindows/settings/title;Fregular`
