document.sharedFrameDict = {};

$.fn.updatePixel = function(){
	return this.each(function(){

                     var myName = this.id;
                     if (this.position == undefined){
                     this.position = $(this).iuPosition();
                     if (document.sharedFrameDict[myName] == undefined){
                     document.sharedFrameDict[myName] = this.position;
                     }
                     }
                     else{
                     /* check and update */
                     var newPosition = $(this).iuPosition();
                     if (this.position.top != newPosition.top || this.position.left != newPosition.left || this.position.width != newPosition.width || this.position.height != newPosition.height ){
                     document.sharedFrameDict[myName] = newPosition;
                     this.position = newPosition;
                     }
                     }
                     })
}

$.fn.iuPosition = function(){
	var top = $(this).position().top + parseFloat($(this).css('margin-top'));
	var left = $(this).position().left + parseFloat($(this).css('margin-left'));
	var width = parseFloat($(this).css('width'));
	var height = parseFloat($(this).css('height'));
	if($(this).css('position') == "relative"){
		var marginTop =  parseFloat($(this).css('margin-top'));
		var marginLeft = parseFloat($(this).css('margin-left'));
		return { top: top, left: left, width: width, height: height, marginTop:marginTop, marginLeft:marginLeft }
	}
	return { top: top, left: left, width: width, height: height }
}

/*

$.fn.iuFrame = function(){
	var parentWidth = parseFloat($(this).parent().css('width'));
	var parentHeight = parseFloat($(this).parent().css('height'));
    
	if($(this).css('position') == "fixed"){
		parentWidth = $(window).width();
		parentHeight = $(window).height();
	}
    
	var top = $(this).position().top + parseFloat($(this).css('margin-top'));
	var left = $(this).position().left + parseFloat($(this).css('margin-left'));
	var width = parseFloat($(this).css('width'));
	var height = parseFloat($(this).css('height'));
    
	var marginLeft = parseFloat($(this).css('margin-left'));
	var marginTop = parseFloat($(this).css('margin-top'));
    
	var percentTop, percentHeight, percentMarginTop;
	var percentLeft, percentWidth, percentMarginLeft;
    
	if(parentHeight==0){
		percentTop =100;
		percentHeight =100;
		percentMarginTop=100;
	}else{
		percentTop = Number(((top/parentHeight)*100).toFixed(2));
		percentHeight = Number(((height/parentHeight)*100).toFixed(2));
		percentMarginTop = Number(((marginTop/parentHeight)*100).toFixed(2));
	}
	if(parentWidth==0){
		percentLeft =100;
		percentWidth =100;
		percentMarginLeft=100;
	}
	else{
		percentLeft = Number(((left/parentWidth)*100).toFixed(2));
		percentWidth = Number(((width/parentWidth)*100).toFixed(2));
		percentMarginLeft = Number(((marginLeft/parentWidth)*100).toFixed(2));
	}
    
	return { top: top, left: left, width: width, height: height, marginLeft: marginLeft, marginTop: marginTop, percentTop : percentTop, percentLeft : percentLeft, percentWidth : percentWidth, percentHeight : percentHeight, percentMarginLeft : percentMarginLeft, percentMarginTop : percentMarginTop };
}
 
 */

function getDictionaryKeys(dictionary){
    var keyArray = Object.keys(dictionary);
    return keyArray;
}

function getIUUpdatedFrameThread(){
    //TODO:  IUObj Select하는 것으로 바꾸기
    $('div').updatePixel();
    
    if (Object.keys(document.sharedFrameDict).length > 0){
        console.reportFrameDict(document.sharedFrameDict);
        document.sharedFrameDict = {};
    }
}

function DoLogAction() {
	if ( console ) {
		/* calls our Objective-C console logging function */
		console.log("message: " + document.getElementById('inputValue').value);
	}
}

$(document).ready(function(){
            console.log("ready");
            setInterval(function(){
                              getIUUpdatedFrameThread();
                              }, 3000);

})