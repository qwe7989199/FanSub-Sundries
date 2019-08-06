script_name="Text to QRCode"
script_description="Convert Text to QRCode ASSDrawing (Internal)"
script_author="domo"
script_version="1.01"

function text_to_qrcode(subtitles, selected_lines, active_line)
	local qrencode=require"qrencode"
	local shape=require"shape"
	local min_size=100
	local size,color,use_shape_lib,QRStyle=setting(min_size)
	local alpha_str,color_str=HTML2ASS(color)
	local width=4
	local code_shape=""
	local line_num=#selected_lines
	if QRStyle=="Square" then
		function gen_elem(a,b) return string.format("m %d %d l %d %d l %d %d l %d %d ",(a-1)*width,(b-1)*width,(a)*width,(b-1)*width,(a)*width,(b)*width,(a-1)*width,(b)*width) end
	elseif QRStyle=="Round" then
		use_shape_lib=false
		function gen_elem(a,b) return shape.ellipse((a-1)*width,(b-1)*width,width,width) end
	elseif QRStyle=="Diamond" then
		use_shape_lib=true
		function gen_elem(a,b) return shape.ellipse((a-1)*width,(b-1)*width,width,width) end
	elseif QRStyle=="RoundSquare" then
		use_shape_lib=false
		function gen_elem(a,b) return shape.rounded_rect((a-1)*width,(b-1)*width,width,width,1,1) end
	elseif QRStyle=="Triangle-Up" then
		use_shape_lib=false
		function gen_elem(a,b) return string.format("m %d %d l %d %d l %d %d ",(a-1)*width,(b)*width,(a)*width,(b)*width,(a-1)*width+width/2,(b-1)*width) end
	elseif QRStyle=="Triangle-Down" then
		use_shape_lib=false
		function gen_elem(a,b) return string.format("m %d %d l %d %d l %d %d ",(a-1)*width,(b-1)*width,(a)*width,(b-1)*width,(a-1)*width+width/2,(b)*width) end
	elseif QRStyle=="Triangle-Left" then
		use_shape_lib=false
		function gen_elem(a,b) return string.format("m %d %d l %d %d l %d %d ",(a)*width,(b-1)*width,(a)*width,(b)*width,(a-1)*width,(b-1)*width+width/2) end
	elseif QRStyle=="Triangle-Right" then
		use_shape_lib=false
		function gen_elem(a,b) return string.format("m %d %d l %d %d l %d %d ",(a-1)*width,(b-1)*width,(a-1)*width,(b)*width,(a)*width,(b-1)*width+width/2) end
	end
	if use_shape_lib then
		function connect(a,b) return shape.united(a,b) end
	else
		function connect(a,b) return b..a end
	end
	
	for z, k in ipairs(selected_lines) do
		aegisub.progress.title("Processing...("..z.."/"..line_num..")")
		code_shape=""
		l=subtitles[k]
		text_stripped=string.gsub(l.text,"%{.-%}","")
		if string.len(text_stripped)>900 then
			aegisub.debug.out("Text is too long.\n")
			aegisub.cancel()
		end
		ok, tab_or_message=qrencode.qrcode(text_stripped)
		if #tab_or_message*width/2>size or min_size>size then
			aegisub.debug.out("Size for text "..string.format("['%s'] is too small, and is adjusted automatically.\n",text_stripped))
		end
		for i=1,#tab_or_message do
			for j=1,#tab_or_message do
				if tab_or_message[i][j]>0 then
					new_elem=gen_elem(i,j)
					code_shape=connect(code_shape,new_elem)
				end
			end
		end
		org_size=#tab_or_message*width
		size=math.max(org_size/2,size)
		size_ratio=math.floor(size/org_size*100)
		if use_shape_lib then
			code_shape=shape.united("m 0 0",code_shape)
		end
		l.text=string.format("{\\fscx%d\\fscy%d\\1c%s\\1a%s",size_ratio,size_ratio,color_str,alpha_str).."\\bord0\\shad0\\p1}"..code_shape
		subtitles[0]=l
		aegisub.progress.set(z/line_num*100)
	end
end

function HTML2ASS(s)
    local ass_s = ""
	--  1 is "#"
	r = string.sub(s,2,3)
	g = string.sub(s,4,5)
	b = string.sub(s,6,7)
	a =  string.sub(s,8,9)
	ass_a = string.format("&H%s&",a)
	ass_c = string.format("&H%s%s%s&",b,g,r)
    return ass_a,ass_c
end

function setting(min_size)
	dialog_config = {
	{x=1,y=0,class="label",label="QRCode Size"},
	{x=1,y=1,class="intedit",name="Size",min=min_size/2,max=800,value=min_size},
	{x=1,y=2,class="label",label="QRCode Color"},
	{x=1,y=3,class="coloralpha",name="Color",value="#00000000"},
	{x=1,y=4,class="label",label="Optimize ASSDrawing"},
	{x=1,y=5,class="checkbox",name="use_shape_lib",value=true},
	{x=1,y=6,class="label",label="QRCode Style"},
	{x=1,y=7,class="dropdown",name="QRStyle",items={"Square","Diamond","Round","RoundSquare","Triangle-Up","Triangle-Down","Triangle-Left","Triangle-Right"},value="Square"}
	}
	
	button,config =_G.aegisub.dialog.display(dialog_config,{"OK","Cancel"})
	if button=="Cancel" then
		aegisub.cancel()
	end
	size=config.Size
	color=config.Color
	use_shape_lib=config.use_shape_lib
	QRStyle=config.QRStyle
	return size,color,use_shape_lib,QRStyle
end

aegisub.register_macro(script_name,script_description,text_to_qrcode)
