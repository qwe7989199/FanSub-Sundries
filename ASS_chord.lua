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
}

chord_type={
["major"]={1,5,8},
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
["m"]={1,4,8},
["min"]={1,4,8},
["m6"]={1,4,8,10},
["min6"]={1,4,8,10},
["m7"]={1,4,8,11},
["min7"]={1,4,8,11},
["mM7"]={1,4,8,12},
["m/M7"] ={1,4,8,12},
["m(M7)"]={1,4,8,12},
["minmaj7"]={1,4,8,12},
["min/maj7"]={1,4,8,12},
["min(maj7)"]={1,4,8,12},
["o"]={1,4,7},
["dim"]={1,4,7},
["o7"]={1,4,7,10},
["dim7"]={1,4,7,10},
["ø"]={1,4,7,11},
["ø7"]={1,4,7,11}
}

function analyse(chord_str)
	signature,s_or_f,chord = string.match(chord_str,"([CDEFGAB])([#♭]?)([^#♭]*)")
	root = signature..s_or_f
	if chord=="" then
		chord="major"
	end
	print(signature,s_or_f,chord)
	output_tbl={}
	for k,v in pairs(chord_type) do 
		if k==chord then
			for i=1,#chord_type[k] do
				output_tbl[i]=(chord_type[k][i]+root_tbl[root]-2)%12+1
			end
		end
	end
	return output_tbl
end
print(Y.table.tostring(analyse(("D#m7"))))
--TO DO
--1.Extend the range to two/three octaves.
--2.Add support for inversion and polychords.
--3.Add more synonyms.
--Reference https://www.8notes.com/piano_chord_chart
