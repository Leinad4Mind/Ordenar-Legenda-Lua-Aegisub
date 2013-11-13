﻿--[[
 Copyright (c) 2012, Leinad4Mind
 All rights reserved®.
 
 Por Youka e modificado por Leinad4Mind
 Baseado em diversos scripts
 
 Um grande agradecimento a todos os meus amigos
 que sempre me apoiaram, e a toda a comunidade
 de anime portuguesa.
--]]

--Descrição da Macro
script_name = "Ordenar Legenda"
script_description = "Ordenar Legenda por Estilos"
script_author = "Youka e Leinad4Mind"
script_version = "1.1"
script_modified = "20 Setembro 2012"

--Ordenar!
function dialog_sort(subs, chosen)
	--Function to swap table values
	local function swap(t, i)
		local temp = t[i]
		t[i] = t[i+1]
		t[i+1] = temp
	end
	
	--Collect names of chosen type + dialog lines
	--Save first dialog line index
	local sort_table = {}
	local first_line
	for li=1, #subs do
		local line = subs[li]
		if line.class == "dialogue" then
			if not first_line then first_line = li end
			local index
			if chosen == "Camadas" then
				index = tostring(line.layer)
			elseif chosen == "Tempo de Saída" then
				index = tostring(line.start_time)
			elseif chosen == "Tempo de Entrada" then
				index = tostring(line.end_time)
			elseif chosen == "Estilo" then
				index = line.style
			elseif chosen == "Personagem" then
				index = line.actor
			elseif chosen == "Efeito" then
				index = line.effect
			end
			if not sort_table[index] then
				sort_table[index] = {}
			end
			table.insert(sort_table[index], line)
		end
	end
	
	--Save numeric type of sort table
	local sort_table_i = {}
	for key, lines in pairs(sort_table) do
		table.insert(sort_table_i, {key = key, lines = lines})
	end
	--Sort keys (bubble sort)
	for count = 1, #sort_table_i-1 do
		for name_i, name in ipairs(sort_table_i) do
			if name_i < #sort_table_i then
				local key1, key2 = name.key, sort_table_i[name_i+1].key
				if chosen == "Camadas" or chosen == "Tempo de Entrada" or chosen == "Tempo de Saída" then
					if tonumber(key1) > tonumber(key2) then
						swap(sort_table_i, name_i)
					end
				else
					local char1, char2
					for ci = 1, math.min(string.len(key1), string.len(key2)) do
						char1, char2 = key1:byte(ci), key2:byte(ci)
						if char1~=char2 then
							break
						end
					end
					if not char1 then	--One key empty
						if string.len(key1) > string.len(key2) then
							swap(sort_table_i, name_i)
						end
					else
						if (char1 > char2) or (char1 == char2 and key1:len()>key2:len()) then
							swap(sort_table_i, name_i)
						end
					end
				end
			end
		end
	end
	
	--Replace old lines with sorted lines
	local i = 0
	for _, name in ipairs(sort_table_i) do
		for _, line in ipairs(name.lines) do
			subs[first_line+i] = line
			i = i + 1
		end
	end
end

--GUI elements
local config = {
		{
			class = "label",
			x = 0, y = 0, width = 4, height = 1,
			label = " ...| Desenvolvido por Leinad4Mind |... "
		}
		,
		{
			class = "label",
			x = 0, y = 1, width = 1, height = 1,
			label = "Ordenar por:"
		},
		{
			class = "dropdown", name = "sel",
			x = 1, y = 1, width = 3, height = 1,
			items = {"Camadas", "Tempo de Entrada", "Tempo de Saída", "Estilo", "Personagem", "Efeito"}, value = "Camadas", hint = "Ordenar legenda por que estilo?"
		}
}
local buttons = {
	"Ordenar",
	"Cancelar"
}

--Selection GUI
function sort_gui(subs)
	local ok, conf = aegisub.dialog.display(config,buttons)
	if ok == "Ordenar" then
		dialog_sort(subs, conf.sel)
		aegisub.set_undo_point("\""..script_name.."\"")
	end
end

--Register macro
aegisub.register_macro(script_name, script_description, sort_gui)