--Preliminary work of ASS_Chord
local Y = require"Yutils"
root_tbl={
["C"]=1,
["C#"]=2,
["D"]=3,
["D#"]=4,
["E"]=5,
["F"]=6,
["F#"]=7,
["G"]=8,
["G#"]=9,
["A"]=10,
["A#"]=11,
["B"]=12,
["D♭"]=2,
["E♭"]=4,
["G♭"]=7,
["A♭"]=9,
["B♭"]=11,
["Db"]=2,
["Eb"]=4,
["Gb"]=7,
["Ab"]=9,
["Bb"]=11
}

chord_type={
["major"]={1,5,8},
["-5"]={1,5,7},
["b5"]={1,5,7},
["5"]={1,8},
["6"]={1,5,8,10},
["M6"]={1,5,8,10},
["maj6"]={1,5,8,10},
["7"]={1,5,8,11},
["dom7"]={1,5,8,11},
["M7"]={1,5,8,12},
["Δ7"]={1,5,8,12},
["maj7"]={1,5,8,12},
["+"]={1,5,9},
["aug"]={1,5,9},
["+7"]={1,5,9,11},
["aug7"]={1,5,9,11},
["sus2"]={1,3,8},
["sus4"]={1,6,8},
["7sus4"]={1,6,8,11},
["m"]={1,4,8},
["min"]={1,4,8},
["m6"]={1,4,8,10},
["min6"]={1,4,8,10},
["m7"]={1,4,8,11},
["min7"]={1,4,8,11},
["mM7"]={1,4,8,12},
["minmaj7"]={1,4,8,12},
["m#7"]={1,4,8,12},
["7-5"]={1,5,7,11},
["7b5"]={1,5,7,11},
["7+5"]={1,5,9,11},
["7#5"]={1,5,9,11},
["o"]={1,4,7},
["dim"]={1,4,7},
["o7"]={1,4,7,10},
["dim7"]={1,4,7,10},
["ø"]={1,4,7,11},
["ø7"]={1,4,7,11},
["m7b5"]={1,4,7,11},
["m7-5"]={1,4,7,11},
["add9"]={1,5,8,15},
["9"]={1,5,8,11,15},
["9b5"]={1,5,7,11,15},
["9-5"]={1,5,7,11,15},
["9+5"]={1,5,9,15},
["9#5"]={1,5,9,15},
["m9"]={1,4,8,11,15},
["min9"]={1,4,8,11,15},
["9sus4"]={1,6,8,11,15},
["-9"]={1,4,8,11,15},
["maj9"]={1,5,8,12,15},
["M9"]={1,5,8,12,15},
["Δ9"]={1,5,8,12,15},
["7b9"]={1,5,8,11,14},
["7-9"]={1,5,8,11,14},
["7#9"]={1,5,8,11,16},
["7+9"]={1,5,8,11,16},
["69"]={1,5,8,10,15},
["11"]={1,5,8,11,15,18},
["m11"]={1,4,8,11,15,18},
["min11"]={1,4,8,11,15,18},
["-11"]={1,4,8,11,15,18},
["13"]={1,11,15,18,22},
["maj13"]={1,8,12,15,17,22},
["M13"]={1,8,12,15,17,22},
["Δ13"]={1,8,12,15,17,22},
}

function split(str, split_char)      
    local sub_str_tab = {}
    while true do          
        local pos = string.find(str, split_char) 
        if not pos then              
            _G.table.insert(sub_str_tab,str)
            break
        end  
        local sub_str = string.sub(str, 1, pos - 1)              
        _G.table.insert(sub_str_tab,sub_str)
        str = string.sub(str, pos + 1, string.len(str))
    end      
    return sub_str_tab
end

function is_include(value, tbl)
    for k,v in _G.ipairs(tbl) do
      if v == value then
          return true
      end
    end
    return false
end

function std(chord_str)
	chord_str=string.gsub(chord_str,"m/M7","mM7")
	chord_str=string.gsub(chord_str,"m(M7)","mM7")
	chord_str=string.gsub(chord_str,"min/maj7","mM7")
	chord_str=string.gsub(chord_str,"min(maj7)","mM7")
	chord_str=string.gsub(chord_str,"6/9","69")
	return chord_str
end

function slash_handler(org_chord,root_note)
	new_tbl={table.unpack(org_chord)}
	if not is_include(root_note,org_chord) then --Additional root.
		print("Addition")
		for i=1,#org_chord do
			new_tbl[i+1]=org_chord[i]
		end
		new_tbl[1]=root_tbl[slash_root]
		org_chord={table.unpack(new_tbl)}
		if math.min(table.unpack(org_chord))~=org_chord[1] then
			org_chord[1]=org_chord[1]-12
		end
	else --Inversion
		print("Inversion")
		for k,v in pairs(org_chord) do
			if v==root_tbl[slash_root] then
				key=k
				break
			end
		end  
		n=#org_chord
		for i=1,n do
			new_tbl[#new_tbl+1]=org_chord[i]
		end
		for i=1,n do
			org_chord[i]=new_tbl[key+i-1]
		end
		if math.max(table.unpack(org_chord))~=org_chord[#org_chord] then
			org_chord[#org_chord]=org_chord[#org_chord]+12
		end
	end
	new_chord=org_chord
	return new_chord
end

function ocatave_handler(chord_tbl)
	if math.min(table.unpack(chord_tbl))>=12 and math.max(table.unpack(chord_tbl))>=24 then 
		for i=1,#chord_tbl do
			chord_tbl[i]=chord_tbl[i]-12
		end
	end
	return chord_tbl
end

function analyse(chord_str)
	chord_str=std(chord_str)
	if string.find(chord_str,"/")~=nil then
		slash=true
		chord_str=split(chord_str,"/")
		signature,s_or_f,chord=string.match(chord_str[1],"([CDEFGAB])([#♭b]?)([^#♭b]*)")
		slash_root,other_thing=string.match(chord_str[2],"([CDEFGAB][#♭b]?)([^#♭b]*)")
	else
		slash=false
		signature,s_or_f,chord=string.match(chord_str,"([CDEFGAB])([#♭b]?)([^#♭b]*)")
	end
	root = signature..s_or_f
	if root_tbl[root]==nil or (root_tbl[slash_root]==nil and slash) then
		print("Root note doesn't exist.")
		return {}
	end
	if other_thing~="" and slash then
		print("Slash root error.")
	end
	if chord=="" then
		chord="major"
	end
	output_tbl={}
	for i=1,#chord_type[chord] do
		output_tbl[i]=chord_type[chord][i]+root_tbl[root]-1
	end
	if slash and other_thing=="" then
		root_note=root_tbl[slash_root]
		output_tbl=slash_handler(output_tbl,root_note)
	end
	output_tbl=ocatave_handler(output_tbl)
	return output_tbl
end
--TO DO
--Test
