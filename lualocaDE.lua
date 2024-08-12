---@meta

---@class lualocaDE
local M={}

---@class lualocaDE.object: lualoca.object
---@field font string
---@field callback? fun(self: self, node: node|druid.text, text: string, language: string)

---Module version
M.VERSION='4.0'

---Creates a new lualocaDE object for `node`. If no `object` is specified, creates one based on `node` text.
---@param self lualocaDE.instance
---@param node node|druid.text
---@param object? lualocaDE.object
---@return lualocaDE.object
local function create(self, node, object)
	if not object then
		local node=node
		if type(node)=='table' then node=node.node end
		object=self:to_object(gui.get_text(node))
	end
	self.objects[node]=object
	self.update(self, node)
	return object
end

---Deletes the lualocaDE object of `node`
---@param self lualocaDE.instance
---@param node node|druid.text
local function delete(self, node)
	self.objects[node]=nil
end

---Returns object of `node`
---@param self lualocaDE.instance
---@param node node|druid.text
---@return lualocaDE.object
local function get(self, node)
	return self.objects[node]
end

---Returns a new lualocaDE object based on `string`
---@param self lualocaDE.instance
---@param string string
---@return lualocaDE.object
local function to_object(self, string)
	---@type lualocaDE.object
	local object={}
	for param in string.gmatch(string, '[^;]+') do
		local value=string.sub(param, 2)
		param=string.lower(string.sub(param, 1, 1))
		if param=='p' then
			object.path={}
			for group in string.gmatch(value, '[^/]+') do self.data.funlutab.add(object.path, group) end
		elseif param=='f' then object.font=value
		end
	end
	return object
end

---Updates `node` text
---@param self lualocaDE.instance
---@param node node|druid.text
local function update_node(self, node)
	local object=self.objects[node]
	local language=self.data.instances.main:get_language()
	local params=self.data.params.main
	local success, text=pcall(self.data.instances.main.get_text, self.data.instances.main, object)
	if not success and self.data.instances.spare then
		language=self.data.instances.spare:get_language()
		---@type {[string]: any}
		params=self.data.params.spare
		success, text=pcall(self.data.instances.spare.get_text, self.data.instances.spare, object)
	end
	if type(node)=='userdata' then
		---@type node
		node=node
		if object.font then gui.set_font(node, params.font..'/'..object.font) end
		local pivot=gui.get_pivot(node)
		if (params.pivot=='right' and pivot>=6 and pivot<=8) or (params.pivot=='left' and pivot>=2 and pivot<=4) then
			local pos=gui.get_position(node)
			local size_x=gui.get_size(node).x*gui.get_scale(node).x
			if params.pivot=='right' and pivot>=6 and pivot<=8 then pos.x=pos.x+size_x
			elseif params.pivot=='left' and pivot>=2 and pivot<=4 then pos.x=pos.x-size_x
			end
			gui.set_position(node, pos)
			pivot=10-pivot
			gui.set_pivot(node, pivot)
		end
		if success then gui.set_text(node, text) end
	else
		---@type druid.text
		node=node
		if object.font then gui.set_font(node.node, params.font..'/'..object.font) end
		local pivot=gui.get_pivot(node.node)
		if (params.pivot=='right' and pivot>=6 and pivot<=8) or (params.pivot=='left' and pivot>=2 and pivot<=4) then
			pivot=10-pivot
			node:set_pivot(pivot)
		end
		if success then node:set_to(text) end
	end
	if object.callback then object:callback(node, text, language) end
end

---Updates text of the specified objects. By default, updates all objects.
---@param self lualocaDE.instance
---@vararg node|druid.text
local function update(self, ...)
	local nodes={...}
	local exist={}
	local events={}
	for _, node in ipairs(nodes) do exist[node]=true end
	for _, event in pairs(self.data.on_update) do
		local success
		for _, node in ipairs(event.nodes) do
			if #exist>0 then
				if exist[node] then success=true break end
			elseif self.objects[node] then success=true break
			end
		end
		if success then events[#events+1]=event end
	end
	for _, event in ipairs(events) do
		if event.before then event.before(self) end
	end
	self.data.params.main=self.data.instances.main:get_params()
	if self.data.instances.spare then self.data.params.spare=self.data.instances.spare:get_params() end
	if ... then
		for _, node in ipairs(nodes) do update_node(self, node) end
	else
		for node in pairs(self.objects) do update_node(self, node) end
	end
	for _, event in ipairs(events) do
		if event.after then event.after(self) end
	end
end

---Creates a new on_update event that fires if one of the `nodes` is updated. Returns its id which is necessary for editing and deleting it.
---@param self lualocaDE.instance
---@param nodes (node|druid.text)[]
---@param before? fun(self: lualocaDE.instance) calls before updating
---@param after? fun(self: lualocaDE.instance) calls after updating
---@return integer --on_update function id
local function add_on_update(self, nodes, before, after)
	local id=#self.data.on_update+1
	self.data.on_update[id]={nodes=nodes, before=before, after=after}
	return id
end

---Deletes an on_update event with `id`
---@param self lualocaDE.instance
---@param id integer
local function delete_on_update(self, id)
	self.data.on_update[id]=nil
end

---Creates a new lualocaDE instance
---@param funlutab funlutab
---@param lualoca lualoca version 4.0 or later
---@param path string path to folder with json files of localizations
---@param path_to_params string path to json file with params for all languages
---@param main_language string main language
---@param spare_language? string if there is no text localization in the main language, localization on the spare language will be used
---@return lualocaDE.instance
function M.Instance(funlutab, lualoca, path, path_to_params, main_language, spare_language)
	---@class lualocaDE.instance
	local self={}
	---lualocaDE objects
	---@type {[node|druid.text]: lualocaDE.object}
	self.objects={}
	self.data={}
	self.data.funlutab=funlutab
	self.data.lualoca=lualoca
	---Instances for main and spare languages
	---@type {main: lualoca.instance, spare?: lualoca.instance}
	self.data.instances={
		main=self.data.lualoca.Instance(self.data.funlutab, json, path, path_to_params, sys.load_resource)
	}
	self.data.instances.main:set_language(main_language)
	---Params for main and spare languages
	---@type {main: {[string]: any}, spare?: {[string]: any}}
	self.data.params={
		main=self.data.instances.main:get_params()
	}
	if spare_language then
		self.data.instances.spare=self.data.lualoca.Instance(self.data.funlutab, json, path, path_to_params, sys.load_resource)
		self.data.instances.spare:set_language(spare_language)
		self.data.params.spare=self.data.instances.spare:get_params()
	end
	---on_update functions
	---@type {nodes: (node|druid.text)[], before?: fun(), after?: fun()}[]
	self.data.on_update={}
	self.create=create
	self.delete=delete
	self.get=get
	self.to_object=to_object
	self.update=update
	self.add_on_update=add_on_update
	self.delete_on_update=delete_on_update
	return self
end

return M
