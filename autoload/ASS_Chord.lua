local tr = aegisub.gettext
script_name = tr"ASS_Chord"
script_description = tr"Help to learn chord."
script_author = "domo"
script_version = "1.1"

local function split(str, split_char)      
    local sub_str_tab = {}
    while true do          
        local pos = string.find(str, split_char) 
        if not pos then              
            table.insert(sub_str_tab,str)
            break
        end  
        local sub_str = string.sub(str, 1, pos - 1)              
        table.insert(sub_str_tab,sub_str)
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

local function para_set()
	xres, yres,_,_ = aegisub.video_size()
	if not (xres and yres) then 
		aegisub.debug.out("Please load a video first.")
		aegisub.cancel()
	end
	--Key Shapes
	Normal_Key = {"m 0 0 l 0 82 l 15 82 l 15 54 l 9 54 l 9 0 ","m 19 0 l 19 53 l 10 53 l 10 0 ","m 20 54 l 16 54 l 16 82 l 31 82 l 31 54 l 27 54 l 27 0 l 20 0 ","m 28 0 l 28 53 l 37 53 l 37 0 ","m 32 54 l 32 82 l 47 82 l 47 0 l 38 0 l 38 54 ","m 48 0 l 48 82 l 63 82 l 63 54 l 56 54 l 56 0 ","m 66 0 l 66 53 l 57 53 l 57 0 ","m 67 54 l 64 54 l 64 82 l 79 82 l 79 54 l 74 54 l 74 0 l 67 0 ","m 75 0 l 75 53 l 84 53 l 84 0 ","m 85 54 l 80 54 l 80 82 l 95 82 l 95 54 l 92 54 l 92 0 l 85 0 ","m 93 0 l 93 53 l 102 53 l 102 0 ","m 111 0 l 111 82 l 96 82 l 96 54 l 103 54 l 103 0 "}
	scale=2
	Y = require"Yutils"
	other_tag="\\blur1" 
	hi_1c="\\1c&HFFEDBA&\\3c&HFF9389&"
	hi_other_tag="\\fad(100,200)\\bord2\\blur3"
end

local function std(chord_str)
	chord_str=string.gsub(chord_str,"^%l", string.upper)
	chord_str=string.gsub(chord_str,"m/M7","mM7")
	chord_str=string.gsub(chord_str,"m(M7)","mM7")
	chord_str=string.gsub(chord_str,"min/maj7","mM7")
	chord_str=string.gsub(chord_str,"min(maj7)","mM7")
	chord_str=string.gsub(chord_str,"6/9","69")
	chord_str=string.gsub(chord_str,"min(add9)","minadd9")
	return chord_str
end

local function slash_handler(org_chord,root_note)
	new_tbl={table.unpack(org_chord)}
	if not is_include(root_note,org_chord) and not is_include(root_note+12,org_chord) and not is_include(root_note-12,org_chord) then --Additional root.
		--aegisub.debug.out("Addition.\n")
		for i=1,#org_chord do
			new_tbl[i+1]=org_chord[i]
		end
		new_tbl[1]=root_tbl[slash_root] --B 12
		org_chord={table.unpack(new_tbl)}
		-- aegisub.debug.out(Y.table.tostring(org_chord))
		if math.min(table.unpack(org_chord))<org_chord[1] then -- need to do inversion
			org_chord[2]=org_chord[2]+12
		end
		if math.min(table.unpack(org_chord))~=org_chord[1] then
			org_chord[1]=org_chord[1]-12
		end
	else --Inversion
		-- aegisub.debug.out("Inversion.\n")
		for k,v in pairs(org_chord) do
			if (v-1)%12+1==root_tbl[slash_root] then
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
			if org_chord[i]<org_chord[1] then
				org_chord[i]=org_chord[i]+12
			end
		end
	end
	new_chord=org_chord
	return new_chord
end

local function ocatave_handler(chord_tbl)
	local chord_max,chord_min=math.max(table.unpack(chord_tbl)),math.min(table.unpack(chord_tbl))
	if chord_min>=12 and chord_max>=24 then 
		for i=1,#chord_tbl do
			chord_tbl[i]=chord_tbl[i]-12
		end
	end
	if chord_max-chord_min<=12 and chord_min<4 then
		for i=1,#chord_tbl do
			chord_tbl[i]=chord_tbl[i]+12
		end
	end
	return chord_tbl
end

local function analyse(chord_str)
	chord_str=std(chord_str)
	aegisub.debug.out(chord_str.."\n")
	if string.find(chord_str,"/")~=nil then
		slash=true
		chord_str=split(chord_str,"/")
		signature,s_or_f,chord=string.match(chord_str[1],"([CDEFGAB])([#♭b]?)([^#♭b　 ]*)")
		slash_root,other_thing=string.match(chord_str[2],"([CDEFGAB][#♭b]?)([^#♭b　 ]*)")
	else
		slash=false
		signature,s_or_f,chord=string.match(chord_str,"([CDEFGAB])([#♭b]?)([^#♭b　 ]*)")
	end
	root = signature..s_or_f
	if chord=="" then
		chord="major"
	end
	if chord==nil or chord_dict[chord]==nil then
		aegisub.debug.out("Cannot find chord: "..chord_str.." in the chord dict.\n")
	end
	if root_tbl[root]==nil or (root_tbl[slash_root]==nil and slash) then
		aegisub.debug.out("Root note doesn't exist.\n")
		return {}
	end
	if other_thing~="" and slash then
		aegisub.debug.out("Slash root error.\n")
	end
	output_tbl={}
	--Translate
	for i=1,#chord_dict[chord] do
		output_tbl[i]=chord_dict[chord][i]+root_tbl[root]-1
	end
	if slash and other_thing=="" then
		root_note=root_tbl[slash_root]
		output_tbl=slash_handler(output_tbl,root_note)
	end
	output_tbl=ocatave_handler(output_tbl)
	return output_tbl
end

function add_assdrawing(subtitles, selected_lines, active_line)
	para_set()
	local x_off=(xres-112*scale*3)/2
	local y_off=2/3*yres
	local xspacing=112*scale
	for i=1,#Normal_Key do
		Normal_Key[i]=Y.shape.filter(Normal_Key[i],function(x,y) return scale*x,scale*y end)
	end
	require"chord_dict"
	for i=1, #subtitles do
		if subtitles[i].class == "dialogue" then
			l = subtitles[i]
			break
		end
	end
	for z, i in ipairs(selected_lines) do
		chord_str=""
		if subtitles[i].class == "dialogue" and subtitles[i].effect=="fx" and string.find(subtitles[i].style,"Chord")~=nil then
		l = subtitles[i]
		chord_str=l.text:gsub("{[^}]+}", "")
		pitch_tbl=analyse(chord_str)
		for j=1,#pitch_tbl do
			pitch=pitch_tbl[j]
			key = Normal_Key[math.fmod(pitch-1,12)+1]
			key_pos_x = math.floor((pitch-1)/12)*xspacing+1+x_off
			key_pos_y = y_off
			l.layer = 1
			l.text= "{"..string.format("\\an7\\1c%s\\pos(%d,%d)\\p1%s",hi_1c,key_pos_x,key_pos_y,hi_other_tag).."}"..key
			subtitles[0]=l
		end
		end
	end
	w_key=""
	b_key=""
	for j=1,3 do
		w_key = w_key..Y.shape.move(Normal_Key[1]..Normal_Key[3]..Normal_Key[5]..Normal_Key[6]..Normal_Key[8]..Normal_Key[10]..Normal_Key[12],(j-1)*xspacing+1+x_off,y_off)
		b_key = b_key..Y.shape.move(Normal_Key[2]..Normal_Key[4]..Normal_Key[7]..Normal_Key[9]..Normal_Key[11],(j-1)*xspacing+1+x_off,y_off)
	end
	l.comment=false
	l.effect="fx"
	l.actor="wkeys"
	l.text = "{"..string.format("\\1c&HFFFFFF&\\bord1\\3c&H000000&\\an7\\pos(%d,%d)\\p1%s",0,0,other_tag).."}"..w_key
	l.start_time = 0
	l.end_time = 36000000
	l.layer = 0
	subtitles[0]= l 
	l.actor="bkeys"
	l.text = "{"..string.format("\\1c&H000000&\\an7\\3c&H000000&\\pos(%d,%d)\\p1%s",0,0,other_tag).."}"..b_key
	subtitles[0]= l
	aegisub.debug.out("Done.")
end

function add_text(subtitles,selected_lines)
	para_set()
	for z, i in ipairs(selected_lines) do
		l = subtitles[i]
		chord_str=""
		prevl,nextl={},{}
		if l.class == "dialogue" and l.effect=="fx" and string.find(l.style,"Chord")~=nil then
			prevl.start_time = subtitles[i-1].start_time or subtitles[i].start_time-2000
			prevl.end_time = subtitles[i-1].end_time or subtitles[i].end_time-1000
			prevl.duration = prevl.end_time-prevl.start_time
			nextl.start_time = subtitles[i+1].start_time or subtitles[i].end_time+1000
			nextl.end_time = subtitles[i+1].end_time or subtitles[i].end_time+2000
			nextl.duration = nextl.end_time-nextl.start_time
			chord_str=l.text:gsub("{[^}]+}", "")
			chord_str=std(chord_str)
			org_duration = l.end_time-l.start_time
			l.start_time = prevl.start_time
			l.end_time = nextl.end_time
			if l.start_time>=l.end_time then
				l.end_time = l.start_time+2000
			end
			l.layer = 1
			l.text = string.format("{\\alpha&H80&\\frz0.2\\org(0,-100000)\\t(%d,%d,\\frz0\\alpha&H00&)\\t(%d,%d,\\frz-0.2\\alpha&H80&)\\an5\\fad(200,200)}",prevl.duration-100,prevl.duration+100,org_duration+prevl.duration-100,org_duration+prevl.duration+100)..chord_str
			subtitles[0]=l
		end
	end
	aegisub.debug.out("Done.")
end

aegisub.register_macro(script_name.."/Generate Key Animation", script_description, add_assdrawing)
aegisub.register_macro(script_name.."/Generate Text Animation", script_description, add_text)
