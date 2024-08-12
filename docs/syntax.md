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

### UNFINISHED
