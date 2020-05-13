javascript:(function getChord(){
var chordData=tab_scroller.getElementsByTagName("li");
var timeData=tab_minite_array;
var timePerBeat=(timeData[timeData.length-1]-timeData[0])/(timeData.length-1);
var bpm=60.0/timePerBeat;
var initOffset=timeData[0];
var chordsObj=[];
var assStr="";
for (var i=0;i<chordData.length;i++){
	var chordName=chordData[i].textContent;
	var startTime=timeData[i];
	if (chordName!=""){
		chordsObj.push({"chordName":chordName,"startTime":startTime});
	}
}
for(var i=0;i<chordsObj.length;i++){
	var chordName = chordsObj[i].chordName;
	var startTime = chordsObj[i].startTime;
	var startBeat = Math.round((startTime-initOffset)/timePerBeat);
	if (i!=chordsObj.length-1){
		var endTime = chordsObj[i+1].startTime;
		var durBeat = Math.round((endTime-startTime)/timePerBeat);
	} else {
		var durBeat = 2;
		var endTime = chordsObj[i].startTime+durBeat*timePerBeat;
	}
	assStr = assStr + "Dialogue: 0," + msToTime(Math.round(startTime*1000)) + "," + msToTime(Math.round(endTime*1000)) + ",Chord,"+(startBeat)+"|"+durBeat+",0,0,0,fx," + chordName + "\n";
	}
function msToTime(s) {
    return new Date(s).toISOString().slice(11, -1);
}
navigator.clipboard.writeText(assStr);
alert("估测曲速为BPM"+Math.round(bpm)+"，和弦已复制到剪切板");
})();
