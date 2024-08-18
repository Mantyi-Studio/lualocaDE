---@meta

---@class lualoca
local M={}

local SYMBOLS='qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890_'
do
	local table={}
	for i=1, #SYMBOLS do table[SYMBOLS:sub(i, i)]=true end
	---symbols available in entries names
	---@type {[string]: true}
	SYMBOLS=table
end

---Table with encoded text strings or another `lualoca.source`
---@class lualoca.source
---@field [string] string|lualoca.source
---@field [integer] string

---Table with decoded text strings or another `lualoca.group`
---@class lualoca.group
---@field [string] string|lualoca.group
---@field [integer] string

---Module version
M.VERSION='4.0'

---Decodes `source` localization to lualoca.group so you can use it
---@param funlutab funlutab
---@param source lualoca.source
---@return lualoca.group
function M.decode(funlutab, source)
	if not funlutab then error('"funlutab" param not specified. You must specify the funlutab module (https://github.com/Mantyi-Studio/funlutab)', 2) end
	local decoded={}
	for name, phrase in pairs(source) do
		if phrase[1] then phrase=table.concat(phrase, '\n') end
		local type=type(phrase)
		if type=='table' then decoded[name]=M.decode(funlutab, phrase)
		elseif type=='string' then
			local label=1
			local chunks={{}}
			local entry=false
			local hash=0
			for pos=1, #phrase do
				if hash>0 then hash=hash-1 end
				local symbol=phrase:sub(pos, pos)
				if entry and not SYMBOLS[symbol] then
					entry=false
					if hash<=0 or symbol~='#' then
						funlutab.add(chunks, phrase:sub(label, pos-1), {})
					end
					label=pos
				end
				if symbol=='#' and hash==0 then
					entry=true
					hash=2
					funlutab.add(chunks[#chunks], phrase:sub(label, pos-1))
					label=pos+1
				end
			end
			if entry then funlutab.add(chunks, phrase:sub(label))
			else funlutab.add(chunks[#chunks], phrase:sub(label))
			end
			for i=1, #chunks, 2 do chunks[i]=table.concat(chunks[i]) end
			if #chunks==1 then chunks=chunks[1] end
			decoded[name]=chunks
		end
	end
	return decoded
end

---Table containing data needed to get text
---@class lualoca.object
---@field path string[]
---@field values? {[string]: string|number|boolean|lualoca.object|string[]}|string|number|boolean|lualoca.object|string[]

---@param self lualoca.instance
---@return string|nil
local function get_language(self)
	return self.data.language
end

---Returns the instance language parameters
---@param self lualoca.instance
---@return {[string]: any}|nil
local function get_params(self)
	return self.data.params[self.data.language]
end

---Enters `object.values` into the text with `object.path` and returns it
---@param self lualoca.instance
---@param object lualoca.object|{[integer]: string}
---@return string
local function get_text(self, object)
	if not self.data.language then error('Language not specified', 2) end
	local path=object.path or object
	local text=self.data.text
	for _, group in ipairs(path) do
		text=text[group]
		if not text then error('Non-existent path '..table.concat(path, '.'), 2) end
	end
	if type(text)=='table' then
		text=self.data.funlutab.copy(text)
		local values=object.values
		if type(values)~='table' or values.path or values[1] then values={['']=values}
		else values=self.data.funlutab.copy(values)
		end
		for i=2, #text, 2 do
			local value=values[text[i]]
			if type(value)=='table' then value=self:get_text(value) end
			text[i]=tostring(value)
		end
		text=table.concat(text)
	end
	return text
end

---Loads the game text in `lang`. Returns the `lang` parameters (pivot, font, etc.)
---@param self lualoca.instance
---@param lang string
---@return {[string]: any}
local function set_language(self, lang)
	if not self.data.params[lang] then error('Non-existent language "'..lang..'"', 2) end
	self.data.language=lang
	self.data.text=M.decode(self.data.funlutab, self.data.json.decode(self.data.read(self.data.path..lang..'.json')))
	return self.data.params[self.data.language]
end

---@param path string
---@return string
local function DEFAULT_READ(path)
	local file=io.open(path, 'r')
	local text=file:read('a')
	file:close()
	return text
end

---Returns new lualoca instance
---@param funlutab funlutab https://github.com/Mantyi-Studio/funlutab version 2.1.1 - latest 2.x
---@param json table json module https://github.com/rxi/json.lua version 0.1.2
---@param path string path to folder with json files of localizations
---@param path_to_params string path to json file with params for all languages
---@param read? fun(path: string): string|nil custom read function
---@return lualoca.instance
function M.Instance(funlutab, json, path, path_to_params, read)
	if not funlutab then error('"funlutab" param not specified. You must specify the funlutab module (https://github.com/Mantyi-Studio/funlutab)', 2) end
	if not json then error('"funlutab" param not specified. You must specify the json module (https://github.com/rxi/json.lua)', 2) end
	if not path then error('"path" param not specified. You must specify the path to json file with params for all languages', 2) end
	if not path_to_params then error('"path_to_params" param is empty. You must specify the path to json file with params for all languages', 2) end
	---@class lualoca.instance
	local self={}
	self.data={}
	self.data.funlutab=funlutab
	self.data.json=json
	---Read function
	self.data.read=read or DEFAULT_READ
	---Path to folder with json files of localizations
	self.data.path=path
	---@type {[string]: any} Params of all languages
	self.data.params=self.data.json.decode(self.data.read(path_to_params))
	---@type {[string]: lualoca.group}
	self.data.text={}
	---@type string|nil Current language
	self.data.language=nil
	self.get_language=get_language
	self.get_params=get_params
	self.get_text=get_text
	self.set_language=set_language
	return self
end

return M
